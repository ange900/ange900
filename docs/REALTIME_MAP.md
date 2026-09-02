# Le temps réel — un WebSocket côté panel, cinq côté o11-rebuild

Le panel n'ouvre **qu'une** connexion : `ws(s)://<hôte>/ws?token=<jeton>`. Il
envoie un message d'abonnement — `{"Action": "streamstatus"}` — et écoute.

o11-rebuild fait l'inverse : **cinq** points d'entrée, le sujet dans l'URL,
l'authentification par cookie de session, et aucun message d'abonnement.

`packaging/pont-websocket.py` tient les deux bouts, sans bibliothèque : la
poignée de main et le découpage des trames sont écrits des deux côtés.

## La correspondance

| Abonnement legacy | Canal amont | Clé de la trame rendue | État |
|---|---|---|---|
| `streamstatus` | `/api/v1/ws/streams` | `{Providers:[{…, Streams}]}` | vérifié |
| `monitoring` | `/api/v1/ws/monitoring` | l'objet de mesures, à plat | vérifié |
| `logs` | `/api/v1/ws/logs` | **texte brut**, pas du JSON | vérifié |
| `eventget` | `/api/v1/ws/events` | `{Timezone, Entries}` | vérifié |
| `jobget` | `/api/v1/ws/jobs` | `{Jobs}` | vérifié |
| `recordingget` | *(aucun canal amont)* | `{Recordings}` — sondage 5 s | vérifié |
| `replayget` | *(aucun canal amont)* | `{Timezone, Replays}` — sondage 5 s | vérifié |

Se tromper de clé donne un écran **vide en permanence, sans erreur**, et
indiscernable d'un provider qui n'a réellement rien. C'est pourquoi chaque clé
a son propre contrôle dans `tests/rebuild/essai-pont.py`.

## La règle qui tient le pont

**Le WebSocket amont sert de SIGNAL** — il dit *quand* quelque chose a changé —
**et la forme legacy est reconstruite par la traduction REST déjà écrite dans
l'adaptateur.**

Traduire une seconde fois, à partir des trames, donnerait deux moteurs de
traduction qui divergeraient au premier réglage ajouté. Deux exceptions, pour
lesquelles un aller-retour REST n'ajouterait que de la latence : le
**monitoring** et les **journaux**, dont la trame amont porte déjà tout.

## Ce que le pont garantit

- **Un premier instantané part sans attendre un événement.** Sans lui, un écran
  resterait vide jusqu'au premier changement — c'est-à-dire indéfiniment sur un
  serveur au repos.
- **Un pas minimal d'une seconde.** Deux trames de statut à moins d'une seconde
  n'apprennent rien à l'œil et coûtent une traduction complète. Le compte part
  de l'instantané initial, sinon le premier événement amont ferait doublon.
- **Un changement d'abonnement ne rouvre pas la connexion.** Un compteur de
  génération distingue « on m'a remplacé » de « ça a cassé » : sans lui, le
  thread précédent signalait une panne à chaque changement de filtre.
- **Un canal qui meurt le DIT.** Il envoie `{Code: 500, Message: …}` avant de
  rendre la main. Un canal muet donne un écran figé qu'on croit à jour — la
  panne la plus coûteuse d'un panel, parce que personne ne la voit.
- **Sans session valide, l'élévation est refusée AVANT la poignée de main.**
  Une fois élevée, la connexion n'a plus de code HTTP à rendre.
- **Les trames clientes sont bornées** à 64 Ko, et les trames fragmentées sont
  refusées : le panel n'en envoie jamais, et les accepter ouvrirait un chemin
  qu'on ne saurait pas éprouver.

## Ce que le pont ne rend pas

**`Readers`** — la liste nominative des lecteurs de l'écran Monitoring.
o11-rebuild ne la tient pas. Le champ est **omis**, pas mis à un tableau vide :
« aucun lecteur » se lirait « personne ne regarde », ce qui est une mesure, et
elle serait fausse.

Même règle pour `TotalBwIn`, `CpuLoad` et les autres : une mesure absente est
absente. L'écran affiche « — », qui est vrai.

## Un défaut d'o11-rebuild, trouvé en construisant ce pont

rc29 calcule son `Sec-WebSocket-Accept` avec une constante fautive :

```
la sienne : 258EAFA5-E914-47DA-95CA-5AB0DC85B11F
le RFC    : 258EAFA5-E914-47DA-95CA-C5AB0DC85B11
```

Un caractère a glissé. La conséquence n'est pas théorique : **un navigateur
vérifie cet en-tête et coupe la connexion quand il ne correspond pas** (RFC 6455
§4.1). Les cinq canaux temps réel d'o11-rebuild sont donc injoignables depuis un
navigateur — ce qui ne se voit pas dans ses propres tests, qui emploient la même
constante des deux côtés.

Le pont parle à o11-rebuild **de serveur à serveur**, où rien ne vérifie : il
tolère la valeur fautive pour que le panel fonctionne aujourd'hui, et le
consigne au lieu de la faire passer pour normale. **Corriger la constante
appartient à o11-rebuild**, pas à cette couche — une ligne, dans
`internal/api/websocket.go`.

## Devant O11 Pro

Le pont n'existe pas : l'élévation est un **tunnel d'octets** vers le binaire,
exactement comme avant. Les 139 contrôles du banc legacy, dont ceux qui ouvrent
un WebSocket, passent à l'identique.
