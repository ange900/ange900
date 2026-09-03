# LOGS — le journal, tel que le serveur l'envoie

> Écrit le 2026-09-03. Relevé sur le DOM réel du panel d'origine
> (`analysis/original-dom` + captures Chromium du binaire) et sur le composant
> `LogsView` du bundle désobfusqué.

## 1. La structure de l'écran

De haut en bas, exactement comme l'original :

- une rangée d'ACTIONS : **Clear logs**, **Export logs**, et un bouton bascule
  vert/rouge **Start Logs / Stop Logs** ;
- une rangée FILTRE : le champ **Live filter** et la case **Highlight only** ;
- une rangée de SÉLECTEURS : le **provider** (« Main Log » en tête), le **flux**
  (visible seulement quand un provider est choisi), le **niveau**
  (Error, Warning, Info, Debug, Verbose, Trace), puis — quand un flux est
  sélectionné — les commandes du flux : démarrer/arrêter, lire, config ;
- le **lecteur** de flux, partagé avec Linear/Events/VOD ;
- la **zone de journal** : fond noir, monospace, colorée par les codes ANSI que
  le serveur envoie.

## 2. Ce que le serveur impose

- **Portée.** Le binaire n'accepte que deux formes : le journal GLOBAL
  (`ProviderId` et `StreamId` vides) ou un couple provider + flux VALIDE. Un
  provider SEUL répond `404 stream not found`. On retombe donc sur le journal
  global tant qu'un flux n'est pas réellement sélectionné — et un lien
  `/logs/<provider>` sans flux ouvre le journal global, comme l'original.
- **Le filtre est SERVEUR.** Niveau, filtre texte et surlignage partent par
  `/log/setconf` ; le serveur renvoie déjà les lignes filtrées. On ne refiltre
  rien côté navigateur.
- **Les noms de champs diffèrent entre lecture et écriture.** `getconf` répond
  `{LogLevel, Filter, HighlightFilter}` ; `setconf` attend
  `{LogLevel, LogFilter, HighlightLogFilter}`. Recopier les noms de la lecture
  ferait échouer le filtre en silence.
- **`log/get` renvoie aussi `User` et `Password`.** On ne garde que `Logs` :
  ranger l'objet entier afficherait « [object Object] » et conserverait
  l'empreinte du mot de passe dans l'état de l'écran.
- **Les couleurs viennent de l'ANSI du serveur**, pas d'une classification du
  texte : O11 Pro colore `ERRO` en rouge (`\e[0;31m`) et les correspondances
  surlignées en vert (`\e[1;32m`). o11-rebuild n'émet aucune couleur — son
  journal reste monochrome, ce qui est fidèle à ce qu'il envoie.

## 3. Ce qu'on fait mieux, en le disant

- **Rattrapage d'abord.** À l'ouverture et à chaque changement de portée, on
  charge les 512 dernières lignes en HTTP (`/log/get`) AVANT d'ouvrir le canal
  temps réel. Sans lui, un flux au repos afficherait un écran vide jusqu'à la
  prochaine ligne, ce qui se lit comme une panne. (L'original fait de même.)
- **Autoscroll intelligent.** Le panel d'origine réécrit `scrollTop` à CHAQUE
  trame, rendant impossible la lecture d'une ligne ancienne pendant que ça
  défile. Ici on ne suit le bas QUE si l'utilisateur y est déjà ; dès qu'il
  remonte, le suivi se suspend et reprend quand il redescend. Aucune ligne
  perdue.
- **Reconnexion.** Si le canal tombe sans qu'on l'ait fermé, l'écran l'annonce
  (« Connection lost — reconnecting… ») et rouvre le MÊME abonnement, avec une
  attente qui s'allonge. Une génération d'abonnement empêche qu'une reconnexion
  périmée ressuscite un canal ou en fasse vivre deux.
- **Tampon borné.** La zone garde au plus ~400 000 caractères ; au-delà, les
  plus anciennes lignes sont jetées au passage d'un saut de ligne. Un flux en
  défaut n'accumule donc pas des centaines de milliers de lignes en mémoire.
- **Affichage = TEXTE.** Les lignes sont rendues comme du texte (jamais
  `v-html`) : une ligne contrôlée par un provider ne peut pas exécuter de HTML.
- **Secrets expurgés à l'affichage et à l'export** (jamais dans le tampon) :
  `Authorization: Bearer …`, `Cookie:` / `Set-Cookie:`, `password=`/`pwd=`,
  `token=`/`apikey=`, et les identifiants collés dans les adresses de flux
  (`?u=…&p=…`, où `p` est l'empreinte du mot de passe). Voir
  `expurgerSecrets` dans `src/utils.js`.

## 4. Pause et export

- **Stop Logs = la pause de l'original.** Elle ferme le canal : plus aucune
  nouvelle ligne n'arrive, mais celles déjà affichées restent. Start Logs
  rouvre sur la portée courante.
- **Export logs télécharge le tampon courant** — c'est ce que fait le panel
  d'origine : il appelle `/log/export` (que ce build refuse en 404, sans
  effet) et écrit le contenu affiché dans un fichier `o11-<date>.log`. Un vrai
  fichier, secrets expurgés.

## 5. Devant o11-rebuild

Le journal d'o11-rebuild est **global** (le serveur ne tient pas de journal par
flux). Les sélecteurs de provider/flux restent utilisables, mais la portée
envoyée reste globale ; et `setconf` n'y applique que le **niveau** (le filtre
texte et le surlignage sont ignorés côté serveur, ce que l'adaptateur signale).
Rien n'est simulé : ce que rebuild ne fait pas, l'écran ne le prétend pas.

## 6. Le banc

```
node tests/auto/essai-logs.mjs [base] [user] [mdp] [legacy|rebuild]
```

- **legacy** (devant O11 Pro) : **44/44**, 0 N/A.
- **rebuild** (devant o11-rebuild) : **34/34**, **6 N/A** justifiés (portée par
  flux, lien profond par flux, autoscroll live et reconnexion — éprouvés sur le
  passage legacy ; journal global en rebuild).

Le banc éprouve, dans un vrai navigateur : structure, données réelles, temps
réel, portée serveur, filtre `setconf`, lien profond `/logs/<p>/<s>` (avec
rechargement complet), autoscroll, pause, clean, export (téléchargement réel),
get/set config, XSS (fixtures `<script>` / `onerror` → `window.__LOG_XSS__`
reste indéfini), multiligne/JSON/Unicode, expurgation des secrets, performance
(5000 lignes), reconnexion (chute RÉELLE du canal via `routeWebSocket`), absence
de doublon de canal, et affichage d'erreur (jamais un vide déguisé).
