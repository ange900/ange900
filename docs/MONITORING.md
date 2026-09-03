# MONITORING — ce que le serveur mesure, tel qu'il le dit

> Écrit le 2026-09-03. Relevé sur le DOM réel du panel d'origine et sur les
> trames réelles du binaire.

## 1. Deux canaux, pas un

En ouvrant `/monitoring` sur le vrai panel, le navigateur émet **exactement** :

```json
{"Action":"monitoring","SearchPattern":""}
{"Action":"streamstatus","ProviderId":"","StreamId":"all","SearchPattern":"",
 "Filter":"allrunning","StreamType":"","SortAlpha":false}
```

Aucune route HTTP n'alimente cet écran. Et aucun des deux canaux ne porte ce
que l'autre contient : compter les flux en marche à partir des mesures, ou
déduire les lecteurs de la liste des flux, reviendrait à inventer un chiffre.

**Canal `monitoring`** — six champs, tous préformatés par le serveur :

| Champ | Exemple O11 Pro |
|---|---|
| `TotalBwIn` / `TotalBwOut` | `0.00Mbps` |
| `CpuLoad` + `CpuLoadColor` | `0.25/12` + `green` |
| `Memory` | `59MB` |
| `Readers` | `null`, ou un tableau |

Un `Reader` porte quatorze champs : `Enabled, StreamName, Quality,
ProviderName, Type, User, Ip, UserAgent, Uid, Uptime, Bw, BwColor, Errors,
ErrorsColor`.

**Canal `streamstatus` + `Filter: allrunning`** — `{Providers:[{Id, Name,
HasEpg, Streams:[…27 champs…]}]}`.

## 2. Ce que l'écran rend

Relevé sur le DOM : six tuiles sur une grille `2 / md:3 / lg:6` —
**Input Bandwidth · Output Bandwidth · Running Streams · Connected Clients ·
CPU Load · Memory Usage** — puis deux onglets, **Connected Clients** (ouvert
par défaut) et **Running Streams**.

* Onglet clients : recherche « Search for username, stream or provider name »,
  puis la liste, ou un cadre `h-[25vh]` disant « There are no clients
  connected. »
* Onglet flux : bascule « A-Z », puis, par provider, un badge jaune avec son
  nom et un badge « N running », suivis d'une grille de cartes compactes.

La carte d'un flux en marche est dépouillée : nom centré, badge de résolution,
menu « Links ». **Ni marche/arrêt, ni journaux, ni configuration** — Monitoring
regarde, il ne pilote pas. On n'a rien ajouté.

## 3. Le panel ne recalcule rien

Toutes les valeurs sont des chaînes du serveur, **y compris la couleur** de la
charge processeur : c'est lui qui sait à partir de quand il s'inquiète.

Deux conséquences assumées :

* une valeur qu'on n'a pas encore reçue s'écrit « — ». Zéro serait un
  mensonge : « aucun client » et « on ne sait pas encore » ne sont pas la même
  chose ;
* la recherche et le tri A-Z **repartent sur le fil** (`SearchPattern`,
  `SortAlpha`). Filtrer côté panel ne verrait que ce qui est déjà arrivé.

### Les deux amonts n'écrivent pas dans la même unité

| | O11 Pro | o11-rebuild |
|---|---|---|
| Bande passante | `0.00Mbps` | `794 bps` |
| Charge | `0.25/12` | `3.1 %` |
| Mémoire | `59MB` | `6 Go / 46 Go` |

C'est normal, et le banc en tient compte : il exige une valeur chiffrée portant
une unité, jamais le format de l'un des deux.

## 4. Éprouvé

```
node tests/auto/essai-monitoring.mjs [base] [user] [mdp]
     devant O11 Pro       28/28
     devant o11-rebuild   21/21
```

Sur données réelles : un client branché en vrai apparaît dans la table avec son
IP et son agent ; la tuile « Running Streams » annonce exactement autant de
flux que la grille en montre ; « A-Z » et la recherche sont vérifiés **sur les
trames envoyées**, pas sur l'affichage.

## 5. Un bug trouvé en chemin, hors Monitoring

Le banc Recordings s'est mis à bloquer : la modale d'édition restait ouverte.
Cause réelle — le panel envoyait à `/recording/edit` une charge **plate**
(`{ProviderId, Id, Title, …}`) que le binaire **refuse en 404 « recording not
found »**. La modification ne partait donc jamais.

La forme que le binaire déclare est `{ProviderId, RecordingId, Recording}` :
elle est acceptée (`200 success`) — mais, sur ce build, **elle n'enregistre
aucun champ** (relu une seconde plus tard, le titre est inchangé). Le panel
emploie désormais la forme déclarée plutôt qu'une forme rejetée, et continue de
dire la vérité : « The server accepted the request but stored nothing —
recordings are read-only on this build. »
