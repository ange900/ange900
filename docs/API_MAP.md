# Carte de l'API — panel O11 Pro d'origine

Relevée le 2026-09-02 par **double désobfuscation** du bundle
`index-BX-yLeHZ.js` : 18 090 chaînes rétablies depuis le tableau chiffré, puis
2 870 références de dictionnaires locaux inlinées. Les résultats sont ensuite
**confirmés en interrogeant le binaire** dans un bac à sable jetable.

La seconde couche n'était pas une coquetterie : **5 des 7 abonnements
WebSocket** n'étaient visibles qu'après elle.

## Règles de transport, communes à tous les appels

| Point | Valeur |
|---|---|
| Méthode | **POST**, sans exception. Un `GET` répond `403 method not supported`, même sur une route inexistante — le code HTTP ne permet donc pas d'énumérer la surface. |
| Préfixe | `//` + `window.location.host` + `/api` (`Config.getApiUrl()`) |
| En-tête d'auth | `Authorization: <JWT brut>` — **sans** `Bearer`. `Bearer <jeton>` est refusé en 401. |
| Variante en query | `?token=<JWT>` pour ce que le navigateur ouvre lui-même (logos, lecture, WebSocket) |
| Corps | JSON ; `{}` quand l'action ne prend rien |
| `responseType` | `json` par défaut ; 3ᵉ argument de `q.req` pour `blob`/`text` |
| Réponse d'erreur | `{ "Code": <n>, "Message": "<texte>" }` |
| Compression | le serveur gzippe **sans négocier** ; un client qui ne décompresse pas lit du binaire |
| Jeton stocké | `localStorage["o11-token"]`, ou `o11-token-remote` si `Config.isRemote` |

## Les 78 couples route/action HTTP

| Méthode | Chemin | Charge utile | Fonction JS | Écran | Présence sur le binaire |
|---|---|---|---|---|---|
| POST | `/{channel\|event\|vod\|epg}/refresh{request\|apply}` | `{}` | `streams.refreshStreams()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | composée |
| POST | `/{channel\|event\|vod\|epg}/refresh{request\|apply}` | `{}` | `streams.applyRefreshStreams()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | composée |
| POST | `/account/add` | objet monté par le composant | `provider-accounts.add()` | `/provider/…/config` (comptes de script) | non sondée (écriture) |
| POST | `/account/delete` | objet monté par le composant | `provider-accounts.delete()` | `/provider/…/config` (comptes de script) | non sondée (écriture) |
| POST | `/account/deletedisabled` | objet monté par le composant | `provider-accounts.deleteDisabled()` | `/provider/…/config` (comptes de script) | non sondée (écriture) |
| POST | `/account/disableall` | objet monté par le composant | `provider-accounts.disableAll()` | `/provider/…/config` (comptes de script) | non sondée (écriture) |
| POST | `/account/edit` | objet monté par le composant | `provider-accounts.edit()` | `/provider/…/config` (comptes de script) | présente |
| POST | `/account/enableall` | objet monté par le composant | `provider-accounts.enableAll()` | `/provider/…/config` (comptes de script) | non sondée (écriture) |
| POST | `/account/export` | `{ "ProviderId": _0x4869b9 }` | `provider-accounts.exportAccounts()` | `/provider/…/config` (comptes de script) | présente |
| POST | `/account/get` | objet monté par le composant | `provider-accounts.get()` | `/provider/…/config` (comptes de script) | présente |
| POST | `/account/import` | objet monté par le composant | `provider-accounts.importAccounts()` | `/provider/…/config` (comptes de script) | non sondée (écriture) |
| POST | `/account/login` | objet monté par le composant | `provider-accounts.login()` | `/provider/…/config` (comptes de script) | présente |
| POST | `/account/pairinput` | objet monté par le composant | `provider-accounts.pairInput()` | `/provider/…/config` (comptes de script) | présente |
| POST | `/account/pairstart` | objet monté par le composant | `provider-accounts.pair()` | `/provider/…/config` (comptes de script) | présente |
| POST | `/account/pairstatus` | objet monté par le composant | `provider-accounts.getPairStatus()` | `/provider/…/config` (comptes de script) | présente |
| POST | `/account/pairstop` | objet monté par le composant | `provider-accounts.pairStop()` | `/provider/…/config` (comptes de script) | présente |
| POST | `/bootstrap` | `{}` | `providers.getMassUpdateOptions()` | `/providers`, `/provider/…/config` | présente |
| POST | `/epg/get` | objet monté par le composant | `epg.getEpg()` | `/epg/:p?/:s?` | présente |
| POST | `/epg/refresh` | objet monté par le composant | `epg.refreshEpg()` | `/epg/:p?/:s?` | présente |
| POST | `/epg/refreshapply` | objet monté par le composant | `epg.applyRefreshEpg()` | `/epg/:p?/:s?` | présente |
| POST | `/job/add` | `{ "Job": _0x398ce5 }` | `jobs.add()` | `/jobs` | non sondée (écriture) |
| POST | `/job/delete` | `{ "Id": _0x4e4a50["Id"] }` | `jobs.delete()` | `/jobs` | non sondée (écriture) |
| POST | `/job/edit` | `{ "Job": _0x10d3cd }` | `jobs.edit()` | `/jobs` | présente |
| POST | `/job/run` | `{ "Id": _0x18f004["Id"] }` | `jobs.run()` | `/jobs` | présente |
| POST | `/log/clean` | objet monté par le composant | `logs.clearLogs()` | `/logs/:p?/:s?` | non sondée (écriture) |
| POST | `/log/export` | objet monté par le composant | `logs.exportLogs()` | `/logs/:p?/:s?` | **ABSENTE (404)** |
| POST | `/log/get` | objet monté par le composant | `logs.getLogs()` | `/logs/:p?/:s?` | présente |
| POST | `/log/getconf` | objet monté par le composant | `logs.getConf()` | `/logs/:p?/:s?` | présente |
| POST | `/log/setconf` | objet monté par le composant | `logs.setConf()` | `/logs/:p?/:s?` | présente |
| POST | `/login` | objet monté par le composant | `auth.login()` | `/login` + garde globale | présente |
| POST | `/provider/add` | `{ "ProviderName": _0x556e94, "LogoBase64": _0x2166f5 }` | `providers.add()` | `/providers`, `/provider/…/config` | non sondée (écriture) |
| POST | `/provider/backup` | `{}` | `providers.backup()` | `/providers`, `/provider/…/config` | non sondée (écriture) |
| POST | `/provider/cachelogos` | objet monté par le composant | `providers.cacheLogos()` | `/providers`, `/provider/…/config` | non sondée (écriture) |
| POST | `/provider/delete` | `{ "ProviderId": _0x50b4eb["Id"] }` | `providers.deleteProvider()` | `/providers`, `/provider/…/config` | non sondée (écriture) |
| POST | `/provider/edit` | objet monté par le composant | `providers.editNameLogo()` | `/providers`, `/provider/…/config` | présente |
| POST | `/provider/edit` | objet monté par le composant | `providers.edit()` | `/providers`, `/provider/…/config` | présente |
| POST | `/provider/export` | `{ "ProviderId": _0x2965b7, "StreamId": _0x5887bd }` | `providers.exportProvider()` | `/providers`, `/provider/…/config` | présente |
| POST | `/provider/exportkeys` | `{ "ProviderId": _0x14b8d6 }` | `providers.exportKeys()` | `/providers`, `/provider/…/config` | présente |
| POST | `/provider/exportmanifestandkeys` | `{ "ProviderId": _0x180816 }` | `providers.exportManifestAndKeys()` | `/providers`, `/provider/…/config` | présente |
| POST | `/provider/get` | `{}` | `providers.getAllProviders()` | `/providers`, `/provider/…/config` | présente |
| POST | `/provider/get` | objet monté par le composant | `providers.get()` | `/providers`, `/provider/…/config` | présente |
| POST | `/provider/import` | `{ "FileName": _0x4eaf11, "ProviderImportConfig": _0x3c042f }` | `providers.import()` | `/providers`, `/provider/…/config` | non sondée (écriture) |
| POST | `/provider/massupdate` | objet monté par le composant | `providers.massUpdate()` | `/providers`, `/provider/…/config` | non sondée (écriture) |
| POST | `/provider/pushkeys` | `{ "ProviderId": _0x2c2924 }` | `providers.pushKeys()` | `/providers`, `/provider/…/config` | non sondée (écriture) |
| POST | `/provider/rescan` | `{}` | `providers.rescan()` | `/providers`, `/provider/…/config` | présente |
| POST | `/recording/add` | objet monté par le composant | `recordings.add()` | `/recordings/:p?` | non sondée (écriture) |
| POST | `/recording/delete` | objet monté par le composant | `recordings.delete()` | `/recordings/:p?` | non sondée (écriture) |
| POST | `/recording/edit` | objet monté par le composant | `recordings.edit()` | `/recordings/:p?` | présente |
| POST | `/recording/get` | objet monté par le composant | `recordings.getRecordings()` | `/recordings/:p?` | présente |
| POST | `/recording/stop` | `{ "RecordingId": _0x1031ea }` | `recordings.stop()` | `/recordings/:p?` | présente |
| POST | `/replay/delete` | objet monté par le composant | `events.deleteReplay()` | `/events/:p?` | non sondée (écriture) |
| POST | `/server/add` | objet monté par le composant | `servers.add()` | `/servers` | non sondée (écriture) |
| POST | `/server/delete` | objet monté par le composant | `servers.delete()` | `/servers` | non sondée (écriture) |
| POST | `/server/edit` | objet monté par le composant | `servers.edit()` | `/servers` | présente |
| POST | `/server/get` | objet monté par le composant | `servers.getAll()` | `/servers` | présente |
| POST | `/server/getinfo` | objet monté par le composant | `servers.getServerVersion()` | `/servers` | présente |
| POST | `/shutdown` | `{}` | `servers.shutdown()` | `/servers` | non sondée (écriture) |
| POST | `/stream/{start\|stop}` | `{}` | `streams.toggleStreamPlayback()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | composée |
| POST | `/stream/add` | objet monté par le composant | `streams.add()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | non sondée (écriture) |
| POST | `/stream/delete` | objet monté par le composant | `streams.delete()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | non sondée (écriture) |
| POST | `/stream/edit` | objet monté par le composant | `streams.edit()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | présente |
| POST | `/stream/flushkeys` | objet monté par le composant | `streams.flushKeys()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | non sondée (écriture) |
| POST | `/stream/get` | objet monté par le composant | `streams.get()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | présente |
| POST | `/stream/get` | objet monté par le composant | `streams.getStreams()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | présente |
| POST | `/stream/get` | objet monté par le composant | `streams.getStream()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | présente |
| POST | `/stream/get` | objet monté par le composant | `streams.updateStream()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | présente |
| POST | `/stream/refresh` | objet monté par le composant | `streams.refresh()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | présente |
| POST | `/stream/refreshkeys` | objet monté par le composant | `streams.refreshKeys()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | présente |
| POST | `/stream/start` | objet monté par le composant | `streams.startAutostarts()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | présente |
| POST | `/stream/start` | objet monté par le composant | `streams.startOnAirs()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | présente |
| POST | `/stream/status` | objet monté par le composant | `streams.getStatus()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | présente |
| POST | `/stream/status` | objet monté par le composant | `recordings.getStatus()` | `/recordings/:p?` | présente |
| POST | `/stream/stoprefresh` | objet monté par le composant | `streams.stopRefresh()` | `/linear/:p?`, `/events/:p?`, `/vod/:p?`, `/search` | présente |
| POST | `/user/add` | objet monté par le composant | `users.add()` | `/users` | non sondée (écriture) |
| POST | `/user/delete` | objet monté par le composant | `users.delete()` | `/users` | non sondée (écriture) |
| POST | `/user/edit` | objet monté par le composant | `users.edit()` | `/users` | présente |
| POST | `/user/get` | objet monté par le composant | `auth.getLoggedInUser()` | `/login` + garde globale | présente |
| POST | `/user/get` | `{}` | `users.getUsers()` | `/users` | présente |

## Le canal WebSocket — 7 abonnements

Une seule connexion, ouverte sur
`ws(s)://<hôte>/ws?token=<JWT>` (`wss` si la page est en HTTPS). Le client
envoie **un message d'abonnement JSON à l'ouverture**, puis ne fait que
recevoir. Chaque store ferme son canal (`closeWsClient`) avant d'en ouvrir un
autre : il n'y a jamais deux abonnements concurrents pour un même store.

| `Action` | Autres champs du message | Fonctions JS |
|---|---|---|
| `eventget` | `ProviderId` | `events.getSchedule_WS` |
| `jobget` | _aucun_ | `jobs.getJobs` |
| `logs` | `ProviderId`, `StreamId` | `logs.getLogs_WS` |
| `monitoring` | `SearchPattern` | `monitoring.getMonitoring_WS` |
| `recordingget` | `ProviderId`, `RecordingId` | `recordings.getRecordings_WS` |
| `replayget` | `ProviderId` | `events.getReplays_WS` |
| `streamstatus` | `Filter`, `ProviderId`, `SearchPattern`, `SortAlpha`, `StreamId`, `StreamType` | `streams.getStatus_WS`, `getStatusSingle_WS`, `updateStreamStatus_WS`, `updateStreamStatusV2_WS` |

C'est par ce canal que passent l'état des flux, le monitoring, les journaux en
direct, les enregistrements, les rediffusions, la grille des événements et les
tâches. **Un panel reconstruit qui se contenterait des routes HTTP perdrait
tout le temps réel.**

## Routes composées à l'exécution

Deux familles ne sont jamais écrites en toutes lettres :

- `q.req(api + "/" + type + "/refreshrequest")` et `.../refreshapply`, avec
  `type` ∈ `channel` (l'écran Linear envoie `channel`, **pas** `linear`),
  `event`, `vod`, `epg`. **`recording` n'existe pas** : sondé, il répond
  `404 invalid action`.
- `q.req(api + "/stream/" + action)`, `action` ∈ `{start, stop}`, appelé par
  `streams.toggleStreamPlayback(action, providerId, stream, type)`.

## Divergence relevée, et laissée telle quelle

`logs.exportLogs()` appelle `POST /api/log/export` avec `{ProviderId, StreamId}`.
**Le binaire répond `404 invalid action`.** La fonction existe dans le panel, la
route n'existe pas dans ce build. Le panel reconstruit garde l'appel à
l'identique : le retirer serait une perte de fonctionnalité, le « corriger »
serait modifier le backend.

## Ce qui n'a pas été sondé, et pourquoi

27 actions destructives (`*/add`, `*/delete`, `*/import`, `/shutdown`,
`/log/clean`, `/provider/pushkeys`, `/stream/flushkeys`, `/account/disableall`…)
n'ont pas été déclenchées à l'aveugle. Elles sont attestées par le code du panel,
qui est la référence de ce qu'il faut reproduire. Celles qui devaient révéler une
structure de données ont été appelées **avec des objets de sonde**, dans le bac à
sable jetable, jamais sur une installation réelle.
