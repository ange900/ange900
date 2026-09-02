# Couche de compatibilité — API legacy O11 Pro → o11-rebuild

Relevé sur une instance **réelle** d'o11-rebuild rc29, démarrée pour l'occasion,
et sur les 119 routes de son API. Chaque ligne porte un état MESURÉ, pas
supposé — un banc d'essai (`tests/rebuild/`) l'établit ou ne l'établit pas.

## Ce que ce document a d'abord annoncé de faux

Une première version affirmait qu'o11-rebuild n'a « ni DRM, ni CDM, ni comptes
d'opérateur ». **C'était faux.** Interrogé sur son propre schéma, il déclare
`use_cdm`, un secret `content_keys`, et un secret `script_accounts`. Je m'étais
fié à des notes de conception plutôt qu'au logiciel. Le détail est dans
`KEYS_DRM_GAP.md` et `ACCOUNTS_GAP.md`.

## Les états

| État | Ce qu'il veut dire |
|---|---|
| **FULL** | traduite ET vérifiée par un banc, sur données réelles |
| PARTIAL | traduite ; une partie de la charge n'a pas d'équivalent, et l'adaptateur le **déclare** dans sa réponse (`Ignored`) |
| MISSING | pas de traduction possible ; le panel reçoit un **501 avec sa raison**, jamais un succès vide |
| REALTIME | servie par le pont temps réel, pas par une route |
| NOT_TESTED | traduite, pas encore couverte par un banc — donc pas encore promise |

## Le compte

| | Routes | Part |
|---|---:|---:|
| FULL | 24 | 31 % |
| PARTIAL | 15 | 19 % |
| MISSING | 28 | 36 % |
| NOT_TESTED | 10 | 13 % |
| **Total** | **77** | |

**39 routes sur 77** rendent quelque chose d'utilisable ; 28 disent
explicitement pourquoi elles ne peuvent pas.

## FULL — traduites et vérifiées (24)

| Route legacy | État | Note |
|---|---|---|
| `/channel/refreshrequest` | **FULL** | éprouvée sur instance réelle |
| `/epg/get` | **FULL** | éprouvée sur instance réelle |
| `/epg/refresh` | **FULL** | éprouvée sur instance réelle |
| `/log/export` | **FULL** | éprouvée sur instance réelle |
| `/log/get` | **FULL** | éprouvée sur instance réelle |
| `/log/getconf` | **FULL** | éprouvée sur instance réelle |
| `/provider/add` | **FULL** | éprouvée sur instance réelle |
| `/provider/backup` | **FULL** | éprouvée sur instance réelle |
| `/provider/delete` | **FULL** | éprouvée sur instance réelle |
| `/provider/get` | **FULL** | éprouvée sur instance réelle |
| `/provider/rescan` | **FULL** | éprouvée sur instance réelle |
| `/recording/add` | **FULL** | éprouvée sur instance réelle |
| `/recording/delete` | **FULL** | éprouvée sur instance réelle |
| `/recording/get` | **FULL** | éprouvée sur instance réelle |
| `/server/get` | **FULL** | éprouvée sur instance réelle |
| `/server/getinfo` | **FULL** | éprouvée sur instance réelle |
| `/stream/add` | **FULL** | éprouvée sur instance réelle |
| `/stream/delete` | **FULL** | éprouvée sur instance réelle |
| `/stream/get` | **FULL** | éprouvée sur instance réelle |
| `/stream/refresh` | **FULL** | éprouvée sur instance réelle |
| `/stream/start` | **FULL** | éprouvée sur instance réelle |
| `/stream/status` | **FULL** | éprouvée sur instance réelle |
| `/stream/stop` | **FULL** | éprouvée sur instance réelle |
| `/user/get` | **FULL** | éprouvée sur instance réelle |

## PARTIAL — traduites, avec une part déclarée ignorée (15)

L'adaptateur répond 200 **et dit ce qu'il n'a pas fait** :

```json
{"Code": 200, "Written": 1, "Ignored": ["CdmType", "PRLAVersion"],
 "Message": "success — 1 réglage(s) enregistré(s), 2 sans équivalent … ignoré(s)"}
```

Un « 200 success » sur une requête à moitié appliquée est le mensonge que cette
couche existe pour éviter.

| Route legacy | État | Note |
|---|---|---|
| `/bootstrap` | PARTIAL | traduite ; les réglages sans équivalent sont déclarés ignorés |
| `/channel/refreshapply` | PARTIAL | éprouvée ; les réglages sans équivalent sont déclarés ignorés |
| `/epg/refreshapply` | PARTIAL | traduite ; les réglages sans équivalent sont déclarés ignorés |
| `/event/refreshapply` | PARTIAL | traduite ; les réglages sans équivalent sont déclarés ignorés |
| `/job/add` | PARTIAL | éprouvée ; les réglages sans équivalent sont déclarés ignorés |
| `/job/edit` | PARTIAL | traduite ; les réglages sans équivalent sont déclarés ignorés |
| `/log/setconf` | PARTIAL | éprouvée ; les réglages sans équivalent sont déclarés ignorés |
| `/provider/edit` | PARTIAL | éprouvée ; les réglages sans équivalent sont déclarés ignorés |
| `/recording/edit` | PARTIAL | traduite ; les réglages sans équivalent sont déclarés ignorés |
| `/server/add` | PARTIAL | traduite ; les réglages sans équivalent sont déclarés ignorés |
| `/server/edit` | PARTIAL | traduite ; les réglages sans équivalent sont déclarés ignorés |
| `/stream/edit` | PARTIAL | éprouvée ; les réglages sans équivalent sont déclarés ignorés |
| `/user/add` | PARTIAL | traduite ; les réglages sans équivalent sont déclarés ignorés |
| `/user/edit` | PARTIAL | traduite ; les réglages sans équivalent sont déclarés ignorés |
| `/vod/refreshapply` | PARTIAL | traduite ; les réglages sans équivalent sont déclarés ignorés |

## MISSING — sans équivalent (28)

Chacune répond **501 avec sa raison**. Le panel les affiche en clair : l'écran
Config, onglet Accounts, montre « Not available on this server » suivi du motif,
au lieu d'annoncer qu'il n'y a aucun compte.

| Route legacy | État | Raison rendue au panel |
|---|---|---|
| `/account/add` | MISSING | non traduite : le panel reçoit un 501 explicite |
| `/account/delete` | MISSING | non traduite : le panel reçoit un 501 explicite |
| `/account/deletedisabled` | MISSING | o11-rebuild n'a pas de notion d'activation par compte. |
| `/account/disableall` | MISSING | o11-rebuild n'a pas de notion d'activation par compte. |
| `/account/edit` | MISSING | non traduite : le panel reçoit un 501 explicite |
| `/account/enableall` | MISSING | o11-rebuild n'a pas de notion d'activation par compte. |
| `/account/export` | MISSING | les comptes de script sont un SECRET dans o11-rebuild : ils s'écrivent, ils ne se relisent pas. |
| `/account/get` | MISSING | non traduite : le panel reçoit un 501 explicite |
| `/account/import` | MISSING | import de comptes non traduit : voir docs/ACCOUNTS_GAP.md. |
| `/account/login` | MISSING | o11-rebuild ne pilote pas la connexion d'un compte d'opérateur. |
| `/account/pairinput` | MISSING | o11-rebuild n'a pas d'appairage d'opérateur : émuler l'échange laisserait une session ouverte chez l'opérateur sans personne pour la fermer. |
| `/account/pairstart` | MISSING | o11-rebuild n'a pas d'appairage d'opérateur : émuler l'échange laisserait une session ouverte chez l'opérateur sans personne pour la fermer. |
| `/account/pairstatus` | MISSING | o11-rebuild n'a pas d'appairage d'opérateur : émuler l'échange laisserait une session ouverte chez l'opérateur sans personne pour la fermer. |
| `/account/pairstop` | MISSING | o11-rebuild n'a pas d'appairage d'opérateur : émuler l'échange laisserait une session ouverte chez l'opérateur sans personne pour la fermer. |
| `/login` | MISSING | non traduite : le panel reçoit un 501 explicite |
| `/provider/cachelogos` | MISSING | o11-rebuild ne pré-remplit pas son cache de logos : il les récupère à la demande. Sa seule route, DELETE /logos/cache, VIDE le cache — brancher le bouton dessus ferait l'inverse de ce qu'il annonce. |
| `/provider/export` | MISSING | non traduite : le panel reçoit un 501 explicite |
| `/provider/exportkeys` | MISSING | o11-rebuild garde les clés de contenu en secret chiffré : elles ne se relisent pas, donc ne s'exportent pas. |
| `/provider/exportmanifestandkeys` | MISSING | mêmes raisons que l'export de clés. |
| `/provider/import` | MISSING | non traduite : le panel reçoit un 501 explicite |
| `/provider/massupdate` | MISSING | non traduite : le panel reçoit un 501 explicite |
| `/provider/pushkeys` | MISSING | o11-rebuild n'accepte pas de clés poussées depuis un autre serveur. |
| `/refreshapply` | MISSING | non traduite : le panel reçoit un 501 explicite |
| `/refreshrequest` | MISSING | non traduite : le panel reçoit un 501 explicite |
| `/shutdown` | MISSING | o11-rebuild n'expose aucune route d'arrêt — refus délibéré de son auteur, pas un oubli de la couche. |
| `/stream/flushkeys` | MISSING | le cache de clés d'o11-rebuild n'est pas pilotable. |
| `/stream/refreshkeys` | MISSING | le cache de clés d'o11-rebuild n'est pas pilotable. |
| `/stream/stoprefresh` | MISSING | un rafraîchissement o11-rebuild n'est pas interruptible. |

## NOT_TESTED — traduites, pas encore promises (10)

| Route legacy | État | Note |
|---|---|---|
| `/epg/refreshrequest` | NOT_TESTED | traduite, pas encore couverte par un banc |
| `/event/refreshrequest` | NOT_TESTED | traduite, pas encore couverte par un banc |
| `/job/delete` | NOT_TESTED | traduite, pas encore couverte par un banc |
| `/job/run` | NOT_TESTED | traduite, pas encore couverte par un banc |
| `/log/clean` | NOT_TESTED | traduite, pas encore couverte par un banc |
| `/recording/stop` | NOT_TESTED | traduite, pas encore couverte par un banc |
| `/replay/delete` | NOT_TESTED | traduite, pas encore couverte par un banc |
| `/server/delete` | NOT_TESTED | traduite, pas encore couverte par un banc |
| `/user/delete` | NOT_TESTED | traduite, pas encore couverte par un banc |
| `/vod/refreshrequest` | NOT_TESTED | traduite, pas encore couverte par un banc |

## Le temps réel

Le détail est dans `REALTIME_MAP.md`. En résumé : le panel n'ouvre qu'UN
WebSocket, o11-rebuild en a **cinq**, et le pont tient les deux bouts.

| Abonnement legacy | Canal amont | Rôle |
|---|---|---|
| `eventget` | `/api/v1/ws/events` | signal amont |
| `jobget` | `/api/v1/ws/jobs` | signal amont |
| `logs` | `/api/v1/ws/logs` | signal amont |
| `monitoring` | `/api/v1/ws/monitoring` | signal amont |
| `recordingget` | `sondage REST, 5 s` | aucun canal amont |
| `replayget` | `sondage REST, 5 s` | aucun canal amont |
| `streamstatus` | `/api/v1/ws/streams` | signal amont |

## Les deux obstacles qui restent

### La configuration ne se traduit qu'au quart

262 champs relevés sur O11 Pro ; **55 se traduisent**, 29 sont devenus
automatiques, **143 n'existent pas**. Le compte exact, champ par champ, est dans
`CONFIG_GAP.md`. Aucune couche ne peut inventer un réglage qui n'a rien
derrière.

### Deux modèles de planification qui ne se recouvrent pas

O11 Pro planifie des **scripts** par expression cron. o11-rebuild planifie
**trois travaux connus** — `epg.refresh`, `vod.probe`, `manifest.refresh` — à
une **cadence en secondes**, et n'exécute aucun script. L'adaptateur convertit
`@daily`, `@hourly`, `@weekly`, `*/N * * * *` et `0 */N * * *` ; il refuse
« 30 4 * * 1 » en expliquant qu'une heure de rendez-vous n'est pas une cadence.

## Devant O11 Pro, rien de tout cela ne s'applique

En mode legacy, la couche **n'est pas dans le chemin** : le proxy relaie, le
WebSocket est un tunnel, et les 139 contrôles du banc legacy passent à
l'identique. `/__panel/capabilities` le dit — `upstream_kind: "o11pro"`,
`playback_urls: "native"`.
