# Pièges du backend O11 Pro

Seize comportements du binaire ne sont écrits nulle part et ne se devinent pas.
Chacun a été trouvé en interrogeant le vrai serveur, et chacun casse le panel en
silence — sans erreur, sans journal, sans rien à l'écran.

Ils sont consignés ici parce qu'ils reviendront mordre quiconque touchera à ce
code sans les connaître.

## 1. Un entier envoyé en chaîne répond « 200 success » et n'enregistre rien

```
POST /api/provider/edit  {"ProviderId":"x","Provider":{ …, "HttpGetTimeout":"45" }}
→ 200 {"Code":200,"Message":"success"}
→ relecture : HttpGetTimeout = 30   (inchangé)
```

Le champ est ignoré, les autres champs du même envoi sont bien enregistrés, et
la réponse dit « succès ». Un exploitant qui modifie un délai le voit revenir à
sa valeur d'avant sans comprendre pourquoi.

**Conséquence :** tout champ entier doit partir en JSON `number`. Le panel
d'origine s'en sort avec `v-model.number` sur 28 champs ; le panel reconstruit
le fait sur **tous** ses champs entiers, via `InputConfig` qui honore le
modificateur `.number`.

## 2. `linear` devient `channel` dans les CHEMINS, jamais dans les charges utiles

| Emploi | Valeur attendue |
|---|---|
| `POST /api/channel/refreshrequest` | `channel` |
| `POST /api/channel/refreshapply` | `channel` |
| `StreamType` dans `/stream/get`, `/stream/status`, l'abonnement WebSocket | **`linear`** |

Mesuré : `StreamType: "channel"` renvoie **zéro flux**, avec un code 200. L'écran
Linear paraît vide alors que tout va bien.

## 3. `StreamType` accepte une LISTE

`recordings.getStatus()` envoie `StreamType: "linear,event"` — un enregistrement
porte sur une chaîne ou sur un événement. Écrire `"recording"` ne renvoie rien.

## 4. Les charges d'écriture sont enveloppées, et pas de la même façon

| Route | Forme acceptée | Ce qui échoue |
|---|---|---|
| `/provider/edit` | `{ProviderId, Provider}` | objet à plat → `403 invalid provider` |
| `/stream/edit` | `{ProviderId, StreamId, Stream}` | sans `StreamId` → `404 stream not found` |
| `/stream/add` | `{ProviderId, StreamName, Stream}` | — |
| `/recording/delete`, `/recording/stop` | `{RecordingId}` seul | — |
| `/job/delete`, `/job/run` | `{Id}` | — |
| `/user/delete` | `{Username}` | — |

`/provider/edit` sert aussi au renommage, avec une charge réduite —
`{ProviderId, ProviderName}` — où `LogoBase64` et `OverlayBase64` ne sont joints
**que s'ils ont une valeur** : une chaîne vide effacerait le logo en place.

## 5. Les trames WebSocket sont gzippées

Le canal envoie deux sortes de trames :

- du **texte**, qui est du JSON — sauf pour les journaux, où c'est un fragment
  brut qui n'a rien de JSON ;
- du **binaire**, qui est du JSON **compressé en gzip**.

Le panel d'origine décompressait avec `pako`. Le panel reconstruit emploie
`DecompressionStream('gzip')`, natif au navigateur : aucune dépendance.

Un panel qui appellerait `JSON.parse` sur la trame binaire lèverait une
exception par message et n'afficherait jamais rien.

## 6. Les journaux s'ACCUMULENT, ils ne se remplacent pas

Chaque trame `Action: logs` est la **suite** du texte. Le panel d'origine fait
`this.logs += data`. Écraser à chaque message ne laisse voir que la dernière
ligne.

## 7. `StreamingUrl` est une liste d'OBJETS, pas d'adresses

```json
"StreamingUrl": [
  { "Url": "…/master.m3u8?u=…&p=…", "Quality": "unkown (HLS)", "Resolution": "" },
  { "Url": "…/sondech?u=…&p=…",     "Quality": "unkown (TS)",  "Resolution": "" }
]
```

Un flux est servi en plusieurs variantes — HLS et TS ici. Passer l'élément tel
quel à un lecteur donne `[object Object]` : la vidéo reste noire, sans erreur.
Et n'en montrer qu'une masque les autres sorties.

Le paramètre `p=` est l'**empreinte** du mot de passe, pas le mot de passe :
c'est celle que `/user/get` renvoie dans le champ `Password`. Le champ
`password` du store d'authentification existe pour ça — le vider casserait la
lecture.

## 8. `Headers` / `Headers2` sont structurés en TROIS familles

```json
"Headers2": { "Manifest": {}, "Media": {}, "HlsKey": {} }
```

Ce ne sont pas trois en-têtes : ce sont trois familles de requêtes, chacune
portant son propre dictionnaire nom → valeur. Traiter le premier niveau comme
des en-têtes affiche « [object Object] » et **écrase les trois familles dès la
première saisie**.

Le panel d'origine écrit bien `Headers.Manifest`, `Headers.Media` et
`Headers.HlsKey` séparément.

## 9. `/stream/edit` accepte des champs qu'il n'enregistre pas

Relevé **champ par champ** sur le binaire (`analysis/champs-inscriptibles.json`) :
chaque champ a été écrit seul, relu, puis remis à sa valeur d'avant.

| Objet | Inscriptibles | Acceptés mais ignorés |
|---|---:|---|
| Flux | 53 scalaires + 8 énumérations | **16** |
| Provider | 128 | **3** (`LastEventIndex`, `LastVodIndex`, `StreamsCount`) |

Les 16 champs de flux ignorés :

```
Category  CdnName  Description        ← viennent de la playlist du provider
EpgNow  EpgNext  EpgNowStart  EpgNowEnd   ← viennent du guide
ExtraStatus  Info  ManifestInfo  ManifestType  ManifestExpiration
HasKeys  HasManifest  HasInternalDrm  OriginalLogoUrl
```

`Category` et `Description` sont les plus trompeurs : ils **existent** sur un
flux, s'affichent, et se laissent modifier sans erreur — mais reviennent
inchangés. Ils sont renseignés à l'import et par le script du provider.

Le panel les affiche donc, et ne les propose jamais en saisie.


`License`, `Heartbeat`, `Drm` et `ManifestInfo2` peuvent être envoyés : la
réponse est `200 success`, et la relecture les rend **inchangés**.

Le témoin est `Headers`, un objet imbriqué du même flux : lui s'enregistre. Ce
n'est donc pas une limite des structures imbriquées, mais un choix du backend —
ces champs sont renseignés par le moteur, pas par l'exploitant.

```
Stream.Headers   = {"Manifest":{"X-Temoin":"oui"}, …}  → relu identique  ✅
Stream.License   = {"Url":"https://…","Params":"a=1"}  → relu {"Url":"","Params":""}  ❌
Stream.Heartbeat = {"Url":"https://…","PeriodMs":5000} → relu {"Url":"","PeriodMs":0} ❌
```

Le panel les affiche donc **en lecture seule**, dans une section « Runtime ».
Un champ de saisie qui n'écrit rien est pire qu'un champ absent : l'exploitant
croit avoir réglé quelque chose.

## 10. La trame de statut ne porte que 27 champs sur 92

`/stream/get` renvoie la **configuration** : 92 champs.
`/stream/status` et l'abonnement WebSocket renvoient l'**état** : 27 champs,
dont 19 qui n'existent que là (`Bw`, `Uptime`, `Status`, `StatusColor`,
`ConnectedClients`, `StreamErrors`…). **84 réglages sont absents du statut** —
`Manifest`, `UseCdm`, `Autostart`, `CdmType`, `Headers`, tous les champs réseau…

Deux conséquences, et la seconde détruit des données :

1. Une entrée de liste mise à jour par **remplacement** perd ses 84 réglages.
   Les abonnements « update » doivent **fusionner** :
   `streams[i] = { ...streams[i], ...trame }`.
2. Un formulaire d'édition alimenté depuis la liste de statut enverrait ces 84
   champs **vides** au serveur. L'écran Config relit donc toujours le flux par
   `/stream/get` avant de l'ouvrir.

C'est le piège le plus coûteux de la liste : il ne se voit pas à l'écran, et il
n'apparaît qu'au moment où l'exploitant enregistre.

## 11. Les trames temps réel n'ont pas la clé qu'on attend

| Abonnement | Racine de la trame |
|---|---|
| `eventget` | `{ Timezone, Entries }` — **pas** `Events` |
| `replayget` | `{ Timezone, Replays }` |
| `jobget` | `{ Jobs }` |
| `recordingget` | `{ Recordings }` |
| `streamstatus` | `{ Providers: [ { …, Streams } ] }` |
| `monitoring` | l'objet de mesures, à plat |

Se tromper de clé donne un écran **vide en permanence**, sans erreur — et
indiscernable d'un provider qui n'a réellement rien.

### Un événement n'a pas les champs d'une chaîne

```
Title  ChannelName  LinearStreamName  Start/End  StartFmt/EndFmt  EventId
OnAirId  FilteredEventId  LogoUrl  StreamingUrl  StreamingOnAirUrl
Bw  Uptime  ConnectedClients  HasKeys  HasManifest  IsStreaming  Running
Status  StatusColor
```

Pas de `Name`, pas de `Category`, pas de `Description`. Les horaires arrivent
**déjà formatés** dans `StartFmt`/`EndFmt`, exprimés dans le `Timezone` que la
trame annonce : les reconstruire depuis les horodatages afficherait l'heure du
navigateur, pas celle du provider.

À l'antenne, c'est `StreamingOnAirUrl` qu'il faut lire, pas `StreamingUrl`.

### `StatusColor` est un nom de couleur, pas une catégorie

Valeurs observées et traitées par le panel d'origine : `green`, `orange`,
`yellow`, `red`, `blue`, et **`LightSteelBlue`** — ce dernier en cas explicite.
Un flux au repos renvoie `LightSteelBlue`. Déduire la couleur du texte de
`Status` donnerait un résultat différent selon la langue du provider.

## 12. Chaque écran a sa forme de charge — aucune ne se devine

Relevé sur le binaire, écran par écran :

| Écran | Source | Forme |
|---|---|---|
| Recordings | `/recording/get` + WS `recordingget` | `{Recordings:[…]}` — **`StreamingUrl` est une CHAÎNE**, pas une liste d'objets comme pour un flux |
| EPG | `/epg/get` | `{Entries, AvailableDates}` ; une entrée porte exactement neuf champs : `ChannelName, EpgId, StreamId, StreamType, Title, Description, Lang, Start, End`. **Ni logo, ni adresse de lecture**, et des horodatages **bruts** (contrairement aux événements, déjà formatés) |
| Monitoring | WS `monitoring` seul | `{Readers, TotalBwIn, TotalBwOut, CpuLoad, CpuLoadColor, Memory}` ; `Readers` vaut `null` quand personne ne lit |
| Jobs | WS `jobget` seul | `{Jobs:[…]}` |
| Users | `/user/get` | `{Users:[…]}` — contient **`AuthToken`**, un jeton de session qui ne doit jamais s'afficher |
| Servers | `/server/get` | `{Servers:[…]}` — contient **`Password` en clair** |
| Replays | WS `replayget` | `{Timezone, Replays}` ; une rediffusion porte **onze** champs : `ProviderName, ProviderId, EventName, EventId, Start, End, StreamingUrl [{Url, Quality:"replay", …}], OnAir, StartFmt, EndFmt, CurrentIndex`. **Ni `Name`, ni `Title`, ni `Status`, ni logo** |
| Logs | WS `logs` | du **TEXTE brut**, en fragments cumulatifs, avec des **codes ANSI** |

Trois conséquences pratiques :

- **Enregistrer un programme depuis le guide** exige `StreamId` de l'entrée EPG,
  pas `Id` — une entrée du guide n'a pas de champ `Id`.
- **Lire depuis le guide demande une résolution.** L'entrée ne porte aucune
  `StreamingUrl` : il faut retrouver le flux par son `StreamId` (via
  `/stream/get` sur les trois types) pour obtenir une adresse. Sans cela, le
  bouton « Play » ouvre un lecteur sur rien — sans erreur.
- **`/recording/add` est PLAT** : `{ProviderId, StreamId, Title, Description,
  Start, End}`. Enveloppé dans `Recording`, l'appel est accepté (200) et **tous
  les champs sont ignorés** — l'enregistrement est créé sans titre ni créneau.
- **`/recording/edit` n'enregistre rien du tout.** Les neuf champs modifiables
  ont été sondés un par un, sous trois formes de charge : la réponse est
  toujours « 200 success », la relecture toujours inchangée. L'action est
  conservée à l'identique — le panel d'origine la propose aussi — mais le panel
  reconstruit **relit après coup** et dit ce qui s'est réellement passé, au lieu
  d'annoncer un succès imaginaire.

### Un enregistrement démarré perd son heure de début

Trois états observés, et le troisième se confond avec le premier si on ne
regarde que `Start` :

| `Start` | `End` | Sens |
|---|---|---|
| > 0 | > 0 | planifié, fenêtre complète |
| **0** | > 0 | **démarré** — le binaire efface le début, `Status` passe de `scheduled` à `init` |
| 0 | 0 | rien de planifié |

Dire « non planifié » d'une capture en cours est faux ; afficher une date de
1970 pour un `0` l'est tout autant.

Au passage, `/recording/add` répond `{"Code":200,"Message":"%!d(string=<id>)"}`.
Ce `%!d(string=…)` est un défaut de formatage Go dans le binaire — un `%d`
appliqué à une chaîne. L'identifiant est bien là, le message ne veut rien dire.

### Une rediffusion naît d'un événement qui a RÉELLEMENT diffusé

Ce n'est ni un événement terminé, ni un réglage : le binaire écrit
`hls/replay/<port>-<provider>-<event>/` — segments `.ts` plus un `info.json` —
pendant qu'un événement **diffuse** avec `RecordEvent`. Un événement dont le
créneau est simplement passé ne produit rien, même avec `KeepEndedEvents`.

Vérifié en montant une mire HLS locale (`scripts/source-hls.mjs`, générée par
ffmpeg) et en laissant l'événement diffuser : la rediffusion apparaît, servie
sur `/replay/<provider>/<event>/master.m3u8`, `Quality: "replay"`.

Au passage : **le binaire ne résout pas les URI relatives** d'une playlist HLS
(« unsupported protocol scheme "" » sur `seg022.ts`). La source doit écrire ses
segments en adresses absolues.

### Les journaux sont du texte ANSI, et `/log/get` ne les rend pas

Le canal WebSocket fonctionne et envoie les lignes en direct. La route HTTP
`/log/get`, elle, répond `{Logs:"", User, Password, StreamType}` **même quand
`logs/<provider>_<flux>.log` contient plusieurs kilooctets sur le disque** —
mesuré. C'est la voie du WebSocket qui sert l'écran, pas elle.

Sa réponse porte aussi `Password`, l'empreinte du mot de passe : ranger l'objet
entier dans l'état de l'écran l'y conserverait sans raison.

Le panel d'origine ne traite pas les codes ANSI : il affiche la séquence en
toutes lettres. Le panel reconstruit les **traduit en couleur** — les effacer
perdrait la seule marque du niveau d'une ligne.

## 13. Le nom de script d'une tâche s'écrit SANS extension

```
ScriptName = "sonde"      → le binaire exécute scripts/sonde.py   ✅
ScriptName = "sonde.py"   → « Job [X] script not found »          ❌
```

Le binaire résout lui-même l'extension (`.py` ou `.sh`) sous
`<répertoire de travail>/scripts/`. Et le piège est double : `/job/run` répond
**`200 success` dans les deux cas**. Avec l'extension, la tâche ne s'exécute
jamais et rien ne le dit — sauf une ligne dans le journal du serveur.

Le champ « Script name » de l'écran Jobs porte donc cette précision sous lui.

`LastRunResult` et `LastRunTimestamp` sont écrits par le moteur : `/job/edit`
les accepte et les ignore, comme il se doit.

## 14. Une liste de providers VIDE ne donne accès à rien

C'est le piège le plus lourd de conséquence, parce qu'il porte sur des droits.

```
ProviderIds: []          -> /provider/get renvoie {"Providers": null}   → RIEN
ProviderIds: ["sonde"]   -> /provider/get renvoie 1 provider            → sonde
IsAdmin: true            -> tous les providers
```

Mesuré en créant deux comptes et en ouvrant une session avec chacun. Une liste
vide n'est **pas** « aucune restriction » : c'est « aucun accès ». Un panel qui
afficherait « all providers » déclarerait non restreint un compte en réalité
enfermé dehors — et personne ne s'en apercevrait avant que l'exploitant ne se
plaigne d'un écran vide.

Le compte administrateur passé en ligne de commande (`-user` / `-password`)
n'appartient pas au magasin d'utilisateurs : il n'apparaît jamais dans
`/user/get`. L'écran Users le rappelle, faute de quoi on le croirait supprimé.

## 15. `/server/getinfo` et `/shutdown` ne visent pas le serveur qu'on nomme

Les deux s'adressent au serveur auquel la **requête** est envoyée — celui de
`config.getApiUrl()` — et non à celui qu'on désigne dans la liste.

```
/server/getinfo {}                     ┐
/server/getinfo {"Id":"sondesrv"}      ├─ réponses IDENTIQUES
/server/getinfo {"ServerId":"sondesrv"}┘
```

Le panel d'origine envoie pourtant `{Id: server.Id}`. Le binaire l'ignore.

Deux conséquences, et la seconde peut couper une diffusion :

- Cliquer « Info » sur un serveur **auquel on n'est pas connecté** renvoie les
  chiffres d'un autre serveur, présentés comme les siens. Le panel reconstruit
  le dit explicitement au lieu de laisser croire.
- **`/shutdown` éteint le serveur COURANT.** Un bouton nommé « Shutdown » tout
  court ne dit pas ce qu'il arrête. Il porte désormais le nom de sa cible —
  « Shut down Local » — et la confirmation nomme la machine et son adresse.

## 16. `/log/getconf` et `/log/get` refusent un provider sans flux

```
{}                                      → 200   (journal global)
{"ProviderId":"x"}                      → 404 stream not found
{"ProviderId":"x","StreamId":""}        → 404 stream not found
{"ProviderId":"x","StreamId":"y"}       → 200
```

Il n'existe pas de « journaux d'un provider ». Soit le journal global, soit un
couple provider + flux valide. L'écran Journaux du panel reconstruit n'envoie
donc le provider **que** lorsqu'un flux est également désigné.

## Et un dix-septième, qui n'est pas un piège mais un manque

`logs.exportLogs()` appelle `POST /api/log/export`. **Le binaire répond
`404 invalid action`** : la fonction existe dans le panel, la route n'existe pas
dans ce build. Le panel reconstruit fait le même appel et reçoit la même erreur,
affichée telle quelle.

Ce n'est pas réparé, et c'est délibéré : « corriger » cela voudrait dire
inventer un comportement que le serveur n'a pas.

## La leçon commune : regarder la valeur, pas l'écran

Trois de ces pièges — `StreamingUrl`, `Headers`, et les trames gzippées — sont
la même erreur sous trois formes : une structure imbriquée traitée comme un
scalaire. Aucune ne lève d'exception, aucune ne vide l'écran. On lit
« [object Object] », ou rien du tout, et on passe à côté.

`scripts/essai-panel.mjs` cherche donc « [object Object] » sur **chaque** écran,
et vérifie la **valeur** des adresses de lecture, pas seulement leur présence.

## Ce qui reste identique, et doit le rester

| Point | Valeur |
|---|---|
| Méthode | POST, sans exception — un GET répond `403 method not supported` |
| En-tête d'auth | `Authorization: <JWT brut>`, **sans** `Bearer` (refusé en 401) |
| WebSocket | `ws(s)://<hôte>/ws?token=<JWT>`, un message d'abonnement à l'ouverture |
| Compression | le serveur gzippe ses réponses **sans négocier** |
| Titre d'onglet | `<Titre> | o11 PRO`, et une chaîne ALÉATOIRE de 20 caractères sur l'écran de connexion |
| Clés de stockage | `o11-token`, `o11-token-remote`, `o11-preferences-view`, `o11-preferences-sort` |
| URL de lecture | `<hôte>/<nom>.<ext>?token=…&format=…[&filter=…][&streamids=…][&provider=…]` — ordre compris |
