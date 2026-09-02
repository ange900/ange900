# AUTO EPG — comment une chaîne trouve son guide sans qu'on clique

> Écrit le 2026-09-02. Tout ce qui suit a été mesuré sur les deux amonts
> réels, pas déduit d'une documentation.

## 1. Ce qui a été trouvé dans les amonts avant d'écrire quoi que ce soit

La règle était de chercher d'abord un mécanisme natif, et de n'écrire du code
panel qu'en dernier recours. Voici ce que les deux binaires savent faire.

### o11-rebuild (rc30)

Son job `epg.refresh` fait **tout**, en un seul passage transactionnel :

| Étape | Où c'est fait |
|---|---|
| Télécharge le XMLTV | `epg.Recuperer` |
| Valide (DOCTYPE, taille, bornes) | `epgPermanent`, `ErrXMLInvalide`… |
| **Remplace le guide** | `s.EPG.Remplacer` — atomique |
| Purge le passé et le futur lointain | `s.EPG.Purger` |
| **Ré-associe** | `s.EPG.AutoMapper(ctx, providerID, false)` |
| **Reprend les logos XMLTV** | `s.EPG.AppliquerLogosXMLTV` |

Il possède aussi un **verrou** partagé avec l'API manuelle (`s.epgRefresh.prendre`)
et son `AutoMapper` **préserve les mappings manuels**. En cas d'échec du
téléchargement, `Remplacer` n'est jamais appelé : le dernier bon guide tient.

Il ne lui manquait qu'une chose : **une planification**. Aucun horaire n'était
enregistré (`GET /api/v1/job-schedules` → `[]`).

→ **Niveau 1 de la préférence : scheduler natif du backend.**

### O11 Pro

| Réglage | Valeur relevée | Ce que ça fait vraiment |
|---|---|---|
| `EpgAutorefresh` | `False` | active le rafraîchissement périodique |
| `EpgRefreshCron` | `'@daily'` | sa cadence |
| `ChannelsRefreshCron` | `'@daily'` | idem pour les chaînes |
| `EpgTimezone` | `''` | fuseau appliqué au guide |

Mais `POST /api/epg/refresh` sur un provider sans script répond
`{"Code":500,"Message":"no script specified"}` : ce rafraîchissement natif
**pilote le script du provider**. Sans script, il n'existe pas.

Et surtout : **O11 Pro n'associe rien tout seul.** Aucun champ, aucune route,
aucun réglage ne fait passer une chaîne de « pas de guide » à « guide trouvé ».
`EpgId` se remplit flux par flux, à la main.

→ **Niveaux 1 à 3 indisponibles de ce côté. Niveau 4 : mécanisme panel côté
serveur** — choisi parce que les autres n'existent pas, pas parce qu'il était
plus commode.

## 2. Ce qui a donc été construit

```
                       ┌──────────────────────────────────────┐
   o11-rebuild   ←──── │  assurer_planification_rebuild()     │
   (fait tout seul)    │  pose l'horaire natif, puis s'efface │
                       └──────────────────────────────────────┘

                       ┌──────────────────────────────────────┐
   O11 Pro       ←──── │  Planificateur (fil du service)      │
   (n'associe pas)     │  toutes les 6 h, verrou par provider │
                       └──────────────────────────────────────┘
```

Le moteur vit dans **`packaging/moteur-epg.py`**, chargé par le processus du
panel. Pas dans la page. C'est toute la différence entre « le guide se remplit
quand je regarde » et « le guide est rempli quand j'arrive ».

### Le barème est le même des deux côtés

`moteur-epg.py` est le port ligne à ligne de `src/auto/score.js`. Un port
dérive ; **`tests/epg/essai-parite-moteur.mjs`** fait passer 18 cas d'épreuve
aux deux implémentations et exige des verdicts identiques — score, choix,
motif, forme de retour comprise. Le jour de la dérive, il tombe.

| Preuve | Points |
|---|---|
| `epg-id` exact | 100 |
| nom exact | 90 |
| alias exact | 85 |
| nom normalisé (marqueurs de qualité retirés) | 80 |
| **+** le candidat porte la marque du provider | +10 |

Seuil : **85**. Ex æquo au sommet → **aucune association** (choisir serait
tirer au sort). Sous le seuil → **aucune association**.

> **Un défaut trouvé et corrigé en route.** Les deux côtés estampillaient le
> provider sur *toutes* les chaînes du guide. Tout candidat gagnait alors dix
> points : le bonus ne discriminait plus rien, et le seuil effectif tombait de
> 85 à **75** — assez pour laisser passer un rapprochement par nom normalisé
> que le barème refuse exprès. Le provider n'est désormais marqué que si
> l'identifiant de la chaîne le porte (`sonde_event1`), ce qui est justement
> la forme qu'O11 Pro produit.

## 3. Comment un choix manuel est protégé

O11 Pro n'a **aucun champ** distinguant « associé à la main » de « associé
automatiquement ». Sans mémoire, le moteur écraserait au premier passage le
choix que l'exploitant vient de faire.

Le journal `<état>/etat-epg.json` (0600, écriture atomique) est cette mémoire :

| État observé | Verdict | Le moteur peut-il écrire ? |
|---|---|---|
| `EpgId` vide | **LIBRE** | oui |
| `EpgId` = ce que le moteur a écrit | **À NOUS** | oui, pour corriger |
| `EpgId` présent et différent, ou inconnu du journal | **MANUEL** | **jamais** |

Le journal étant sur disque, la protection **survit à un redémarrage** — qui
est précisément le moment où l'on serait tenté de tout refaire.

> **Conséquence à connaître.** Sur un système déjà en service, le journal est
> vide au premier démarrage : **toutes** les associations existantes sont donc
> lues comme MANUELLES et gelées. C'est le côté sûr. L'écran l'affiche
> (« N manual, frozen ») plutôt que de le taire.

Le **logo** suit la même règle : il n'est écrit que s'il est vide ou s'il vient
du moteur. Un logo posé à la main n'est jamais remplacé.

## 4. Atomicité et verrous

* **Le guide d'abord, l'écriture ensuite.** Si le téléchargement ou l'analyse
  échoue, la passe sort **sans rien écrire** : guide, associations et logos
  précédents restent exactement ce qu'ils étaient, et l'échec est nommé.
* **Un verrou par provider, non bloquant.** Une seconde passe pendant qu'une
  tourne **renonce** et le dit — elle ne fait pas la queue. Faire la queue
  finirait par empiler six heures de retard sur un amont lent.
* Côté o11-rebuild, c'est le verrou natif du binaire qui joue le même rôle.

## 5. Ce qui n'est jamais écrit nulle part

Aucun mot de passe, jeton, cookie ni en-tête d'autorisation — ni dans les
journaux, ni dans la route d'état, ni dans un message d'erreur.
`_sans_secret()` est la seule porte de sortie du texte venu de l'amont, et
quatre contrôles du banc le vérifient, dont un sur la sortie réelle du service.

## 6. Réglage

| Variable | Défaut | Rôle |
|---|---|---|
| `O11_AUTO_EPG` | `1` | `0` éteint complètement le moteur |
| `O11_AUTO_INTERVALLE` | `21600` (6 h) | cadence |
| `O11_AUTO_PREMIER_DELAI` | `45` | délai avant la première passe |
| `O11_AUTO_TOKEN` | — | identifiant de service (voie propre) |
| `O11_PANEL_ETAT` | `/var/lib/o11-panel` | où vivent journal et identifiant |

**Identifiant, trois sources dans cet ordre :** `O11_AUTO_TOKEN` ; sinon le
jeton d'un administrateur passé par le panel, retenu en 0600 (une seule
connexion, un jour, suffit pour que l'automatisation tourne ensuite seule) ;
sinon **rien — et le moteur le dit**, au lieu de faire semblant de tourner.
Un identifiant qui marche n'est jamais remplacé par celui du visiteur suivant.

Route d'état : `GET /__panel/epg-auto`. Passe à la demande :
`POST /__panel/epg-auto?provider=<id>` — elle prend les mêmes verrous.

### Le piège `ProtectSystem=strict`

L'unité systemd du panel durcit le service sans déclarer de `StateDirectory` :
**aucun chemin n'est ouvert en écriture**. Le journal ne s'écrivait donc nulle
part, et deux `except OSError: pass` bien intentionnés transformaient l'échec
en perte silencieuse — c'est-à-dire en perte de la protection des choix
manuels, à chaque redémarrage.

Deux corrections :

* le panel **sonde** le dossier d'état au démarrage, publie `persistance` sur
  `/__panel/epg-auto`, et l'annonce dans son journal quand ça ne marche pas ;
* `preview-install.sh` pose un drop-in
  `/etc/systemd/system/o11-panel.service.d/10-etat-epg.conf` contenant
  `StateDirectory=o11-panel` (mode 0700), retiré par `--rollback`.

Sans persistance, le moteur reste **du côté sûr** : journal vide au démarrage
signifie que toute association existante est lue comme manuelle, donc gelée.
Il n'écrase jamais rien ; il cesse seulement d'entretenir ses propres choix.

## 7. Ce qui a été éprouvé, et comment

```
node   tests/epg/essai-parite-moteur.mjs              24/24
python tests/epg/essai-auto-sans-navigateur.py        59/59
node   tests/auto/essai-epg.mjs <base> <user> <mdp>   36/36
```

`essai-auto-sans-navigateur.py` ne lance **aucun navigateur**, à aucun moment :

* **A — moteur, amont contrôlé** : association seule, logo repris, choix manuel
  gelé, logo manuel gelé, ex æquo refusé, sous-seuil refusé, idempotence,
  **guide en panne = rien n'est effacé**, verrou, **redémarrage**, un EpgId
  modifié à la main passe en MANUEL, une chaîne apparue entre deux cycles est
  prise seule.
* **B — le panel entier**, lancé comme un service : il associe, reprend le
  logo, épargne le manuel, **recommence au cycle suivant**, survit à un
  redémarrage sans réécrire ce qui est déjà juste, et ne laisse fuir aucun
  jeton.
* **C — le VRAI O11 Pro** : lecture, guide réel, puis **écriture réelle** sur
  un flux de banc remis ensuite dans son état d'origine.
* **D — le VRAI o11-rebuild rc30** : horaire natif posé, actif, à 6 h,
  idempotent, et le contrat fermé du binaire vérifié.

> **Le faux amont refuse ce que le vrai refuse.** Il a d'abord accepté la forme
> `{ProviderId, Type, Stream}` que le moteur envoyait — le vrai binaire répond
> `stream not found` avec un 404 poli et n'écrit rien. La bonne forme est
> `{ProviderId, StreamId, Stream}`. Le faux amont exige désormais `StreamId`,
> pour qu'aucune erreur de forme ne puisse plus se cacher derrière une
> imitation complaisante.

### Vérifié en dehors du banc

Sur le vrai O11 Pro, `EpgId` d'un flux a été vidé à la main, puis **plus
personne n'a rien ouvert**. Soixante secondes plus tard, le journal du service
disait :

```
[epg-auto] guide lu : /epg/sonde.xml.gz → 1 chaînes
[epg-auto] sonde : 1 associés, 0 corrigés, 0 logos, 6 manuels préservés
```

et le champ valait de nouveau `sonde_event1` — par nom normalisé (80) plus la
marque du provider (+10), donc 90 ≥ 85.

Sur l'installation réelle sous systemd (`/opt/o11-panel`, `ProtectSystem=strict`) :
un administrateur s'est connecté **une fois**, le navigateur a été fermé, puis
le service a été redémarré. `identifiant` valait ensuite « connexion retenue »,
`persistance` valait `true`, et le rapport de la dernière passe avait été relu
du disque. Les deux fichiers d'état sont en `0600`.

Sur le vrai o11-rebuild, l'horaire natif a été ramené à 60 s : le binaire a
déclenché **seul** à t+60 s, `state: success`, guide téléchargé et stocké. Le
panel n'a été sollicité à aucun moment.

## 8. Ce qui n'est pas fait

* **Le guide FRANCE ne se remplira pas tout seul** si aucune source XMLTV
  publique ne couvre ses chaînes : le moteur associe ce que le guide du
  serveur contient, il n'invente pas de source. C'est la même limite honnête
  que celle notée pour l'auto-découverte d'o11-rebuild.
* Sur un système déjà en service, les associations existantes sont **gelées**
  (§3). Les reprendre demanderait de distinguer manuel et automatique
  rétroactivement — ce qu'aucune donnée ne permet.
* Le **lecteur vidéo intégré** (HLS/MSE) reste absent des cartes, ici comme
  dans Linear, Events et VOD.
