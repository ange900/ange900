# Carte des routes — panel O11 Pro d'origine

15 routes, relevées dans le tableau `routes` du routeur, après désobfuscation.
Chaque composant est nommé : l'obfuscateur a laissé la propriété `__name` de
Vue intacte, ce qui donne les **vrais noms d'origine** des 90 composants.

## Écart avec le README

Le `README.md` du dépôt liste 11 pages et donne `/linear`, `/vod` et `/config`.
Le code en déclare **15**, et trois chemins n'ont pas la forme annoncée :

| README | Réalité du bundle |
|---|---|
| `/linear` | `/linear/:provider?` |
| `/vod` | `/vod/:provider?` |
| `/config` | `/provider/:provider?/:type?/config` |
| _(absent)_ | `/search` |
| _(absent)_ | `/servers` |
| _(absent)_ | `/jobs` |
| _(absent)_ | `/epg/:provider?/:stream?` |

C'est le code qui fait foi ici, pas le README.

## Garde de navigation (`router.beforeEach`)

Dans l'ordre exact, et sans autre branche :

1. `generatePageTitle(to.meta.title)` — le titre de l'onglet suit la route.
2. Route `login` **et** session ouverte → redirection vers `providers`.
3. Session absente **et** route ≠ `login` → redirection vers `login`.
4. Chemin `/` → redirection vers `providers`. **Il n'existe pas de route `/`** :
   la racine est une redirection, pas un écran.
5. Sinon, `next()`.

Aucune route n'a de garde propre : l'autorisation fine (admin, accès web) est
appliquée **dans** les écrans, pas par le routeur.

## Les 15 routes

### `/login`

| | |
|---|---|
| Nom de route | `login` |
| Composant | `LoginView.vue` |
| Titre d'onglet | _(vide — écran de connexion)_ |
| Paramètres d'URL | _aucun_ |
| Chaîne de requête | _aucune_ |
| Stores Pinia | `auth` |
| Composants enfants (0) | _aucun_ |
| Routes d'API atteintes (2) | `/login`, `/user/get` |

### `/servers`

| | |
|---|---|
| Nom de route | `servers` |
| Composant | `ServerView.vue` |
| Titre d'onglet | `Servers` |
| Paramètres d'URL | _aucun_ |
| Chaîne de requête | `?server=` (serveur distant sélectionné) — lu par `route.query.server` |
| Stores Pinia | `servers` |
| Composants enfants (7) | `ButtonPrimary`, `ButtonSecondary`, `ConfirmationModal`, `EmptyContent`, `InformationModal`, `ItemServer`, `PageTitle` |
| Routes d'API atteintes (6) | `/server/add`, `/server/delete`, `/server/edit`, `/server/get`, `/server/getinfo`, `/shutdown` |

### `/search`

| | |
|---|---|
| Nom de route | `search` |
| Composant | `SearchView.vue` |
| Titre d'onglet | `Search` |
| Paramètres d'URL | _aucun_ |
| Chaîne de requête | `?s=` (terme cherché) — lu par `route.query.s` |
| Stores Pinia | `streams`, `providers` |
| Composants enfants (12) | `EmptyContent`, `FilterStreams`, `InformationModal`, `ItemStream`, `LoadingSpinner`, `PageTitle`, `SearchResource`, `SortStreamsToggle`, `StreamPlayer`, `StreamTypeSelector`, `TableStreams`, `ViewTypeSelector` |
| Routes d'API atteintes (26) | `/bootstrap`, `/provider/add`, `/provider/backup`, `/provider/cachelogos`, `/provider/delete`, `/provider/edit`, `/provider/export`, `/provider/exportkeys`, `/provider/exportmanifestandkeys`, `/provider/get`, `/provider/import`, `/provider/massupdate`, `/provider/pushkeys`, `/provider/rescan`, `/stream/add`, `/stream/delete`, `/stream/edit`, `/stream/flushkeys`, `/stream/get`, `/stream/refresh`, `/stream/refreshkeys`, `/stream/start`, `/stream/status`, `/stream/stoprefresh`, `/stream/{start|stop}`, `/{type}/refresh{request|apply}` |

### `/linear/:provider?`

| | |
|---|---|
| Nom de route | `linear` |
| Composant | `LinearView.vue` |
| Titre d'onglet | `Linear` |
| Paramètres d'URL | `:provider?` (facultatif) |
| Chaîne de requête | _aucune_ |
| Stores Pinia | `streams`, `providers` |
| Composants enfants (15) | `EmptyContent`, `FilterStreams`, `InformationModal`, `ItemStream`, `LoadingSpinner`, `OutputM3uLinksGlobal`, `PageTitle`, `ProviderSelector`, `RefreshResource`, `SearchResource`, `SortStreamsToggle`, `StreamPlayer`, `TableStreams`, `ViewTypeSelector`, `o11Pagination` |
| Routes d'API atteintes (26) | `/bootstrap`, `/provider/add`, `/provider/backup`, `/provider/cachelogos`, `/provider/delete`, `/provider/edit`, `/provider/export`, `/provider/exportkeys`, `/provider/exportmanifestandkeys`, `/provider/get`, `/provider/import`, `/provider/massupdate`, `/provider/pushkeys`, `/provider/rescan`, `/stream/add`, `/stream/delete`, `/stream/edit`, `/stream/flushkeys`, `/stream/get`, `/stream/refresh`, `/stream/refreshkeys`, `/stream/start`, `/stream/status`, `/stream/stoprefresh`, `/stream/{start|stop}`, `/{type}/refresh{request|apply}` |

### `/providers`

| | |
|---|---|
| Nom de route | `providers` |
| Composant | `ProvidersView.vue` |
| Titre d'onglet | `Providers` |
| Paramètres d'URL | _aucun_ |
| Chaîne de requête | _aucune_ |
| Stores Pinia | `providers` |
| Composants enfants (7) | `ButtonPrimary`, `ButtonSecondary`, `EmptyContent`, `InformationModal`, `ItemProvider`, `PageTitle`, `SearchResource` |
| Routes d'API atteintes (14) | `/bootstrap`, `/provider/add`, `/provider/backup`, `/provider/cachelogos`, `/provider/delete`, `/provider/edit`, `/provider/export`, `/provider/exportkeys`, `/provider/exportmanifestandkeys`, `/provider/get`, `/provider/import`, `/provider/massupdate`, `/provider/pushkeys`, `/provider/rescan` |

### `/provider/:provider?/:type?/config`

| | |
|---|---|
| Nom de route | `config` |
| Composant | `ConfigView.vue` |
| Titre d'onglet | `Config` |
| Paramètres d'URL | `:provider?` (facultatif), `:type?` (facultatif) |
| Chaîne de requête | _aucune_ |
| Stores Pinia | `providers`, `streams`, `users`, `epg` |
| Composants enfants (33) | `ButtonDanger`, `ButtonPrimary`, `ButtonSecondary`, `CdmModeSelector`, `CdmTypeSelector`, `CdnSelector`, `CheckBoxConfig`, `ConfirmationModal`, `DropdownTrackSelector`, `DvbSubsQualitySelector`, `EmptyContent`, `EpgTimezoneSelector`, `FilterStreams`, `GenericDropdown`, `HwAccelSelector`, `InformationModal`, `InputConfig`, `ItemProviderAccount`, `ItemStreamConfig`, `LoadingSpinner`, `MassConfigSet`, `NetworkSettings`, `OutputM3uLinksGlobal`, `PageTitle`, `PairingModal`, `ProviderSelector`, `RunningMode`, `SearchResource`, `SelectUserAccount`, `SortStreamsToggle`, `StreamPlayer`, `StreamTypeSelector`, `o11Pagination` |
| Routes d'API atteintes (47) | `/account/add`, `/account/delete`, `/account/deletedisabled`, `/account/disableall`, `/account/edit`, `/account/enableall`, `/account/export`, `/account/get`, `/account/import`, `/account/login`, `/account/pairinput`, `/account/pairstart`, `/account/pairstatus`, `/account/pairstop`, `/bootstrap`, `/epg/get`, `/epg/refresh`, `/epg/refreshapply`, `/provider/add`, `/provider/backup`, `/provider/cachelogos`, `/provider/delete`, `/provider/edit`, `/provider/export`, `/provider/exportkeys`, `/provider/exportmanifestandkeys`, `/provider/get`, `/provider/import`, `/provider/massupdate`, `/provider/pushkeys`, `/provider/rescan`, `/stream/add`, `/stream/delete`, `/stream/edit`, `/stream/flushkeys`, `/stream/get`, `/stream/refresh`, `/stream/refreshkeys`, `/stream/start`, `/stream/status`, `/stream/stoprefresh`, `/stream/{start|stop}`, `/user/add`, `/user/delete`, `/user/edit`, `/user/get`, `/{type}/refresh{request|apply}` |

### `/events/:provider?`

| | |
|---|---|
| Nom de route | `events` |
| Composant | `EventsView.vue` |
| Titre d'onglet | `Events` |
| Paramètres d'URL | `:provider?` (facultatif) |
| Chaîne de requête | _aucune_ |
| Stores Pinia | `events`, `streams`, `providers` |
| Composants enfants (18) | `ButtonDanger`, `ButtonPrimary`, `ConfirmationModal`, `EmptyContent`, `InformationModal`, `ItemEvent`, `ItemEventCompact`, `ItemEventReplay`, `OutputM3uLinksGlobal`, `PageTitle`, `ProviderSelector`, `RefreshResource`, `SearchResource`, `StreamPlayer`, `TableEventReplay`, `TableEvents`, `ViewTypeSelector`, `o11Pagination` |
| Routes d'API atteintes (27) | `/bootstrap`, `/provider/add`, `/provider/backup`, `/provider/cachelogos`, `/provider/delete`, `/provider/edit`, `/provider/export`, `/provider/exportkeys`, `/provider/exportmanifestandkeys`, `/provider/get`, `/provider/import`, `/provider/massupdate`, `/provider/pushkeys`, `/provider/rescan`, `/replay/delete`, `/stream/add`, `/stream/delete`, `/stream/edit`, `/stream/flushkeys`, `/stream/get`, `/stream/refresh`, `/stream/refreshkeys`, `/stream/start`, `/stream/status`, `/stream/stoprefresh`, `/stream/{start|stop}`, `/{type}/refresh{request|apply}` |

### `/vod/:provider?`

| | |
|---|---|
| Nom de route | `vod` |
| Composant | `VodView.vue` |
| Titre d'onglet | `VOD` |
| Paramètres d'URL | `:provider?` (facultatif) |
| Chaîne de requête | _aucune_ |
| Stores Pinia | `streams`, `providers` |
| Composants enfants (14) | `EmptyContent`, `FilterStreams`, `InformationModal`, `ItemVod`, `ListViewToggle`, `Mp4VideoPlayer`, `OutputM3uLinksGlobal`, `PageTitle`, `ProviderSelector`, `RefreshResource`, `SearchResource`, `SortStreamsToggle`, `TableStreams`, `o11Pagination` |
| Routes d'API atteintes (26) | `/bootstrap`, `/provider/add`, `/provider/backup`, `/provider/cachelogos`, `/provider/delete`, `/provider/edit`, `/provider/export`, `/provider/exportkeys`, `/provider/exportmanifestandkeys`, `/provider/get`, `/provider/import`, `/provider/massupdate`, `/provider/pushkeys`, `/provider/rescan`, `/stream/add`, `/stream/delete`, `/stream/edit`, `/stream/flushkeys`, `/stream/get`, `/stream/refresh`, `/stream/refreshkeys`, `/stream/start`, `/stream/status`, `/stream/stoprefresh`, `/stream/{start|stop}`, `/{type}/refresh{request|apply}` |

### `/monitoring`

| | |
|---|---|
| Nom de route | `monitoring` |
| Composant | `MonitoringView.vue` |
| Titre d'onglet | `Monitoring` |
| Paramètres d'URL | _aucun_ |
| Chaîne de requête | _aucune_ |
| Stores Pinia | `monitoring`, `streams` |
| Composants enfants (7) | `EmptyContent`, `InformationModal`, `ItemMonitoring`, `PageTitle`, `SearchResource`, `SortStreamsToggle`, `StreamPlayer` |
| Routes d'API atteintes (12) | `/stream/add`, `/stream/delete`, `/stream/edit`, `/stream/flushkeys`, `/stream/get`, `/stream/refresh`, `/stream/refreshkeys`, `/stream/start`, `/stream/status`, `/stream/stoprefresh`, `/stream/{start|stop}`, `/{type}/refresh{request|apply}` |

### `/logs/:provider?/:stream?`

| | |
|---|---|
| Nom de route | `logs` |
| Composant | `LogsView.vue` |
| Titre d'onglet | `Logs` |
| Paramètres d'URL | `:provider?` (facultatif), `:stream?` (facultatif) |
| Chaîne de requête | _aucune_ |
| Stores Pinia | `logs` |
| Composants enfants (5) | `ButtonSecondary`, `Dropdown`, `IconSettings`, `PageTitle`, `StreamPlayer` |
| Routes d'API atteintes (5) | `/log/clean`, `/log/export`, `/log/get`, `/log/getconf`, `/log/setconf` |

### `/epg/:provider?/:stream?`

| | |
|---|---|
| Nom de route | `epg` |
| Composant | `EpgView.vue` |
| Titre d'onglet | `EPG` |
| Paramètres d'URL | `:provider?` (facultatif), `:stream?` (facultatif) |
| Chaîne de requête | _aucune_ |
| Stores Pinia | `epg`, `providers` |
| Composants enfants (15) | `ButtonPrimary`, `ButtonSecondary`, `Dropdown`, `EmptyContent`, `GenericDropdown`, `InformationModal`, `ItemEpg`, `ListViewToggle`, `LoadingSpinner`, `PageTitle`, `ProviderSelector`, `SearchResource`, `StreamPlayer`, `TableEpg`, `o11Pagination` |
| Routes d'API atteintes (17) | `/bootstrap`, `/epg/get`, `/epg/refresh`, `/epg/refreshapply`, `/provider/add`, `/provider/backup`, `/provider/cachelogos`, `/provider/delete`, `/provider/edit`, `/provider/export`, `/provider/exportkeys`, `/provider/exportmanifestandkeys`, `/provider/get`, `/provider/import`, `/provider/massupdate`, `/provider/pushkeys`, `/provider/rescan` |

### `/recordings/:provider?`

| | |
|---|---|
| Nom de route | `recordings` |
| Composant | `RecordingsView.vue` |
| Titre d'onglet | `Recordings` |
| Paramètres d'URL | `:provider?` (facultatif) |
| Chaîne de requête | _aucune_ |
| Stores Pinia | `recordings`, `streams` |
| Composants enfants (12) | `ButtonDanger`, `ButtonPrimary`, `ButtonSecondary`, `ConfirmationModal`, `EmptyContent`, `ItemRecording`, `ListViewToggle`, `Mp4VideoPlayer`, `PageTitle`, `ProviderSelector`, `SearchResource`, `TableRecordings` |
| Routes d'API atteintes (17) | `/recording/add`, `/recording/delete`, `/recording/edit`, `/recording/get`, `/recording/stop`, `/stream/add`, `/stream/delete`, `/stream/edit`, `/stream/flushkeys`, `/stream/get`, `/stream/refresh`, `/stream/refreshkeys`, `/stream/start`, `/stream/status`, `/stream/stoprefresh`, `/stream/{start|stop}`, `/{type}/refresh{request|apply}` |

### `/users`

| | |
|---|---|
| Nom de route | `users` |
| Composant | `UsersView.vue` |
| Titre d'onglet | `Users` |
| Paramètres d'URL | _aucun_ |
| Chaîne de requête | _aucune_ |
| Stores Pinia | `users` |
| Composants enfants (5) | `ButtonPrimary`, `ButtonSecondary`, `DropdownProviderSelector`, `ItemUser`, `PageTitle` |
| Routes d'API atteintes (18) | `/account/add`, `/account/delete`, `/account/deletedisabled`, `/account/disableall`, `/account/edit`, `/account/enableall`, `/account/export`, `/account/get`, `/account/import`, `/account/login`, `/account/pairinput`, `/account/pairstart`, `/account/pairstatus`, `/account/pairstop`, `/user/add`, `/user/delete`, `/user/edit`, `/user/get` |

### `/help`

| | |
|---|---|
| Nom de route | `help` |
| Composant | `HelpView.vue` |
| Titre d'onglet | `Help` |
| Paramètres d'URL | _aucun_ |
| Chaîne de requête | _aucune_ |
| Stores Pinia | _aucun_ |
| Composants enfants (2) | `ItemHelp`, `PageTitle` |
| Routes d'API atteintes (0) | _aucune_ |

### `/jobs`

| | |
|---|---|
| Nom de route | `jobs` |
| Composant | `JobsView.vue` |
| Titre d'onglet | `Jobs` |
| Paramètres d'URL | _aucun_ |
| Chaîne de requête | _aucune_ |
| Stores Pinia | `jobs` |
| Composants enfants (8) | `App`, `ButtonPrimary`, `ButtonSecondary`, `EmptyContent`, `InformationModal`, `ItemJob`, `PageTitle`, `SearchResource` |
| Routes d'API atteintes (4) | `/job/add`, `/job/delete`, `/job/edit`, `/job/run` |

## Préférences d'affichage, conservées côté navigateur

Le routeur ne les porte pas, mais elles changent ce que chaque écran montre et
doivent survivre à la reconstruction :

| Clé `localStorage` | Contenu | Défaut |
|---|---|---|
| `o11-token` | JWT de session (installation locale) | — |
| `o11-token-remote` | JWT de session quand `Config.isRemote` est vrai | — |
| `o11-preferences-view` | mode d'affichage par écran : `linear`, `events`, `vod`, `recordings`, `epg` | `grid` partout |
| `o11-preferences-sort` | tri actif par écran : `linear`, `vod`, `monitoring` | `false` partout |
