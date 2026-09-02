# Matrice de parité fonctionnelle — O11 Pro

Chaque ligne vient d'une **mesure**. Les routes, composants, stores et actions
sortent du bundle désobfusqué ; les champs de configuration sortent du binaire
**interrogé en direct** ; la colonne « Reconstruit » est vérifiée par
`scripts/check-functional-parity.sh` et par `scripts/essai-panel.mjs`, qui
ouvre un vrai navigateur devant le vrai binaire.

## Résultat

| Nature | Nombre | Parité |
|---|---:|---|
| Routes de l'interface | 15 | ✅ |
| Composants Vue nommés | 90 | ✅ |
| Stores Pinia | 13 | ✅ |
| Actions de store | 110 | ✅ |
| Getters de store | 4 | ✅ |
| Champs d'état de store | 80 | ✅ |
| Routes d'API HTTP | 75 | ✅ |
| Abonnements WebSocket | 7 | ✅ |
| Champs de configuration | 262 | ✅ |
| Préférences persistées | 4 | ✅ |
| **Total** | **576** | **✅ 100 %** |

## Essai en conditions réelles

`scripts/essai-panel.mjs` connecte un navigateur au panel reconstruit, placé
devant le **binaire d'origine** qui tourne en bac à sable. Il commence par
remettre le décor d'aplomb (`scripts/semer-sonde.mjs`) : un événement dont le
créneau est passé disparaît du guide, et l'échec ne voudrait plus dire
« régression ». **125/125 contrôles
passés.**

| Contrôle | Résultat |
|---|---|
| écran de connexion rendu | ✅ |
| connexion aboutie (redirigé vers /providers) | ✅ |
| jeton rangé dans o11-token | ✅ |
| titre d'onglet « Providers | o11 PRO » | ✅ |
| écran providers rend « Providers » | ✅ |
| écran providers sans erreur de console | ✅ |
| écran providers sans « [object Object] » | ✅ |
| écran linear rend « Linear » | ✅ |
| écran linear sans erreur de console | ✅ |
| écran linear sans « [object Object] » | ✅ |
| écran events rend « Events » | ✅ |
| écran events sans erreur de console | ✅ |
| écran events sans « [object Object] » | ✅ |
| écran vod rend « VOD » | ✅ |
| écran vod sans erreur de console | ✅ |
| écran vod sans « [object Object] » | ✅ |
| écran recordings rend « Recordings » | ✅ |
| écran recordings sans erreur de console | ✅ |
| écran recordings sans « [object Object] » | ✅ |
| écran epg rend « EPG » | ✅ |
| écran epg sans erreur de console | ✅ |
| écran epg sans « [object Object] » | ✅ |
| écran monitoring rend « Monitoring » | ✅ |
| écran monitoring sans erreur de console | ✅ |
| écran monitoring sans « [object Object] » | ✅ |
| écran logs rend « Logs » | ✅ |
| écran logs sans erreur de console | ✅ |
| écran logs sans « [object Object] » | ✅ |
| écran jobs rend « Jobs » | ✅ |
| écran jobs sans erreur de console | ✅ |
| écran jobs sans « [object Object] » | ✅ |
| écran search rend « Search » | ✅ |
| écran search sans erreur de console | ✅ |
| écran search sans « [object Object] » | ✅ |
| écran servers rend « Servers » | ✅ |
| écran servers sans erreur de console | ✅ |
| écran servers sans « [object Object] » | ✅ |
| écran users rend « Users » | ✅ |
| écran users sans erreur de console | ✅ |
| écran users sans « [object Object] » | ✅ |
| écran help rend « Help » | ✅ |
| écran help sans erreur de console | ✅ |
| écran help sans « [object Object] » | ✅ |
| écran config rend « Config » | ✅ |
| écran config sans erreur de console | ✅ |
| écran config sans « [object Object] » | ✅ |
| le provider de sonde apparaît dans Providers | ✅ |
| la chaîne de sonde apparaît dans Linear | ✅ |
| l'utilisateur de sonde apparaît dans Users | ✅ |
| le serveur de sonde apparaît dans Servers | ✅ |
| la carte Linear porte l’option autostart (champ de configuration) | ✅ |
| la carte VOD porte sa description (champ de configuration) | ✅ |
| l’événement de sonde apparaît dans Events | ✅ |
| l’horaire vient du serveur, pas du navigateur | ✅ |
| le fuseau employé par le serveur est annoncé | ✅ |
| Replays montre la rediffusion enregistrée | ✅ |
| Replays nomme la rediffusion par EventName et son provider | ✅ |
| Replays affiche le créneau formaté par le serveur | ✅ |
| Replays propose une lecture | ✅ |
| la rediffusion se lit sur une adresse /replay/ | ✅ |
| action « Cache logos » atteignable depuis le menu | ✅ |
| action « Export » atteignable depuis le menu | ✅ |
| action « Backup » atteignable depuis le menu | ✅ |
| les 4 actions courantes restent hors du menu | ✅ |
| action « Start autostarts » atteignable depuis le menu | ✅ |
| action « Start on air » atteignable depuis le menu | ✅ |
| le rafraîchissement annonce ses deux temps | ✅ |
| le menu Links donne des adresses http réelles | ✅ |
| chaque variante servie est listée | ✅ |
| « Play » alimente le lecteur avec une adresse http | ✅ |
| les en-têtes exposent leurs trois familles | ✅ |
| la fiche porte le réglage « Manifest » (absent du statut) | ✅ |
| la fiche porte le réglage « Cdm Type » (absent du statut) | ✅ |
| la fiche porte le réglage « Autostart » (absent du statut) | ✅ |
| le manifeste du flux est chargé, pas vide | ✅ |
| « Category » n’est PAS proposé en saisie (non enregistrable) | ✅ |
| « Description » n’est PAS proposé en saisie (non enregistrable) | ✅ |
| « Cdn Name » n’est PAS proposé en saisie (non enregistrable) | ✅ |
| « License acquisition » est visible dans Config | ✅ |
| « Heartbeat » est visible dans Config | ✅ |
| « DRM detected » est visible dans Config | ✅ |
| « Manifest analysis » est visible dans Config | ✅ |
| aucune de ces structures n’offre de champ de saisie | ✅ |
| Recordings montre l’enregistrement de sonde | ✅ |
| Recordings affiche l’état venu du serveur | ✅ |
| Recordings nomme la capture par sa chaîne quand le titre est vide | ✅ |
| Recordings ne fabrique aucune date pour un créneau absent | ✅ |
| Recordings distingue une capture démarrée d’une non planifiée | ✅ |
| EPG montre une entrée du guide | ✅ |
| EPG propose les dates que le serveur déclare | ✅ |
| EPG résout une adresse de lecture depuis le StreamId | ✅ |
| « Play » depuis le guide alimente le lecteur avec une adresse http | ✅ |
| la barre EPG tient sur une seule ligne | ✅ |
| Monitoring affiche « Bandwidth in » | ✅ |
| Monitoring affiche « Bandwidth out » | ✅ |
| Monitoring affiche « CPU load » | ✅ |
| Monitoring affiche « Memory » | ✅ |
| Monitoring affiche « Readers » | ✅ |
| Monitoring affiche une mesure réelle du serveur | ✅ |
| Jobs montre la tâche de sonde | ✅ |
| Jobs affiche la planification cron | ✅ |
| Jobs affiche le résultat de la dernière exécution | ✅ |
| Jobs date la dernière exécution | ✅ |
| « Run » relance la tâche et l’écran se met à jour tout seul | ✅ |
| le résultat complet s’ouvre dans une boîte de dialogue | ✅ |
| Users montre le compte de sonde | ✅ |
| Users n’affiche AUCUN jeton | ✅ |
| Users ne prétend pas qu’une liste vide donne tout | ✅ |
| Users signale un compte restreint à un provider | ✅ |
| Users signale un compte sans accès web | ✅ |
| Users rappelle que l’admin en ligne de commande n’est pas listé | ✅ |
| Servers montre le serveur de sonde | ✅ |
| Servers n’affiche pas le mot de passe | ✅ |
| Servers nomme le serveur que « Shut down » va éteindre | ✅ |
| la confirmation d’arrêt nomme la machine visée | ✅ |
| Servers dit quel serveur les chiffres décrivent | ✅ |
| Logs reçoit des lignes en direct | ✅ |
| Logs ne montre aucune séquence ANSI brute | ✅ |
| Logs colore les lignes selon leur niveau | ✅ |
| la recherche affiche le terme venu de l’URL | ✅ |
| la pastille d’état reste bornée | ✅ |
| un WebSocket est ouvert par Monitoring | ✅ |
| le WebSocket porte le jeton en query | ✅ |
| l'écran Config expose ses contrôles | ✅ |
| sans session, toute route renvoie à /login | ✅ |

## 1. Routes (15)

| Route | Composant | Origine | Reconstruit |
|---|---|---|---|
| `/login` | `LoginView.vue` | OUI | **OUI** |
| `/servers` | `ServerView.vue` | OUI | **OUI** |
| `/search` | `SearchView.vue` | OUI | **OUI** |
| `/linear/:provider?` | `LinearView.vue` | OUI | **OUI** |
| `/providers` | `ProvidersView.vue` | OUI | **OUI** |
| `/provider/:provider?/:type?/config` | `ConfigView.vue` | OUI | **OUI** |
| `/events/:provider?` | `EventsView.vue` | OUI | **OUI** |
| `/vod/:provider?` | `VodView.vue` | OUI | **OUI** |
| `/monitoring` | `MonitoringView.vue` | OUI | **OUI** |
| `/logs/:provider?/:stream?` | `LogsView.vue` | OUI | **OUI** |
| `/epg/:provider?/:stream?` | `EpgView.vue` | OUI | **OUI** |
| `/recordings/:provider?` | `RecordingsView.vue` | OUI | **OUI** |
| `/users` | `UsersView.vue` | OUI | **OUI** |
| `/help` | `HelpView.vue` | OUI | **OUI** |
| `/jobs` | `JobsView.vue` | OUI | **OUI** |

## 2. Stores Pinia (13)

| Store Pinia | État | Getters | Actions | Origine | Reconstruit |
|---|---|---|---|---|---|
| `auth` | 8 | 0 | 4 | OUI | **OUI** |
| `notifications` | 1 | 0 | 2 | OUI | **OUI** |
| `servers` | 8 | 1 | 12 | OUI | **OUI** |
| `providers` | 10 | 2 | 18 | OUI | **OUI** |
| `streams` | 13 | 1 | 25 | OUI | **OUI** |
| `monitoring` | 4 | 0 | 2 | OUI | **OUI** |
| `logs` | 4 | 0 | 7 | OUI | **OUI** |
| `recordings` | 6 | 0 | 8 | OUI | **OUI** |
| `users` | 5 | 0 | 4 | OUI | **OUI** |
| `provider-accounts` | 4 | 0 | 14 | OUI | **OUI** |
| `epg` | 6 | 0 | 3 | OUI | **OUI** |
| `events` | 6 | 0 | 5 | OUI | **OUI** |
| `jobs` | 5 | 0 | 6 | OUI | **OUI** |

## 3. Actions de store (110)

| Store | Action | Origine | Reconstruit |
|---|---|---|---|
| `auth` | `getLoggedInUser()` | OUI | **OUI** |
| `auth` | `getToken()` | OUI | **OUI** |
| `auth` | `login()` | OUI | **OUI** |
| `auth` | `logout()` | OUI | **OUI** |
| `notifications` | `hideNotification()` | OUI | **OUI** |
| `notifications` | `showNotification()` | OUI | **OUI** |
| `servers` | `add()` | OUI | **OUI** |
| `servers` | `createLocal()` | OUI | **OUI** |
| `servers` | `delete()` | OUI | **OUI** |
| `servers` | `edit()` | OUI | **OUI** |
| `servers` | `getAll()` | OUI | **OUI** |
| `servers` | `getInfo()` | OUI | **OUI** |
| `servers` | `getServerById()` | OUI | **OUI** |
| `servers` | `getServerVersion()` | OUI | **OUI** |
| `servers` | `loginRemote()` | OUI | **OUI** |
| `servers` | `setSelectedServer()` | OUI | **OUI** |
| `servers` | `shutdown()` | OUI | **OUI** |
| `servers` | `testLogin()` | OUI | **OUI** |
| `providers` | `add()` | OUI | **OUI** |
| `providers` | `backup()` | OUI | **OUI** |
| `providers` | `cacheLogos()` | OUI | **OUI** |
| `providers` | `deleteProvider()` | OUI | **OUI** |
| `providers` | `edit()` | OUI | **OUI** |
| `providers` | `editNameLogo()` | OUI | **OUI** |
| `providers` | `exportKeys()` | OUI | **OUI** |
| `providers` | `exportManifestAndKeys()` | OUI | **OUI** |
| `providers` | `exportProvider()` | OUI | **OUI** |
| `providers` | `get()` | OUI | **OUI** |
| `providers` | `getAllProviders()` | OUI | **OUI** |
| `providers` | `getMassUpdateOptions()` | OUI | **OUI** |
| `providers` | `import()` | OUI | **OUI** |
| `providers` | `massUpdate()` | OUI | **OUI** |
| `providers` | `pushKeys()` | OUI | **OUI** |
| `providers` | `rescan()` | OUI | **OUI** |
| `providers` | `setCurrentSelectedProvider()` | OUI | **OUI** |
| `providers` | `setDefaultCurrentSelectedProvider()` | OUI | **OUI** |
| `streams` | `add()` | OUI | **OUI** |
| `streams` | `applyRefreshStreams()` | OUI | **OUI** |
| `streams` | `closeWsClient()` | OUI | **OUI** |
| `streams` | `delete()` | OUI | **OUI** |
| `streams` | `edit()` | OUI | **OUI** |
| `streams` | `flushKeys()` | OUI | **OUI** |
| `streams` | `get()` | OUI | **OUI** |
| `streams` | `getStatus()` | OUI | **OUI** |
| `streams` | `getStatusSingle_WS()` | OUI | **OUI** |
| `streams` | `getStatus_WS()` | OUI | **OUI** |
| `streams` | `getStream()` | OUI | **OUI** |
| `streams` | `getStreams()` | OUI | **OUI** |
| `streams` | `refresh()` | OUI | **OUI** |
| `streams` | `refreshKeys()` | OUI | **OUI** |
| `streams` | `refreshStreams()` | OUI | **OUI** |
| `streams` | `resetStreams()` | OUI | **OUI** |
| `streams` | `setCurrentSelectedStreamType()` | OUI | **OUI** |
| `streams` | `setDefaultCurrentStreamType()` | OUI | **OUI** |
| `streams` | `startAutostarts()` | OUI | **OUI** |
| `streams` | `startOnAirs()` | OUI | **OUI** |
| `streams` | `stopRefresh()` | OUI | **OUI** |
| `streams` | `toggleStreamPlayback()` | OUI | **OUI** |
| `streams` | `updateStream()` | OUI | **OUI** |
| `streams` | `updateStreamStatusV2_WS()` | OUI | **OUI** |
| `streams` | `updateStreamStatus_WS()` | OUI | **OUI** |
| `monitoring` | `closeWsClient()` | OUI | **OUI** |
| `monitoring` | `getMonitoring_WS()` | OUI | **OUI** |
| `logs` | `clearLogs()` | OUI | **OUI** |
| `logs` | `closeWsClient()` | OUI | **OUI** |
| `logs` | `exportLogs()` | OUI | **OUI** |
| `logs` | `getConf()` | OUI | **OUI** |
| `logs` | `getLogs()` | OUI | **OUI** |
| `logs` | `getLogs_WS()` | OUI | **OUI** |
| `logs` | `setConf()` | OUI | **OUI** |
| `recordings` | `add()` | OUI | **OUI** |
| `recordings` | `closeWsClient()` | OUI | **OUI** |
| `recordings` | `delete()` | OUI | **OUI** |
| `recordings` | `edit()` | OUI | **OUI** |
| `recordings` | `getRecordings()` | OUI | **OUI** |
| `recordings` | `getRecordings_WS()` | OUI | **OUI** |
| `recordings` | `getStatus()` | OUI | **OUI** |
| `recordings` | `stop()` | OUI | **OUI** |
| `users` | `add()` | OUI | **OUI** |
| `users` | `delete()` | OUI | **OUI** |
| `users` | `edit()` | OUI | **OUI** |
| `users` | `getUsers()` | OUI | **OUI** |
| `provider-accounts` | `add()` | OUI | **OUI** |
| `provider-accounts` | `delete()` | OUI | **OUI** |
| `provider-accounts` | `deleteDisabled()` | OUI | **OUI** |
| `provider-accounts` | `disableAll()` | OUI | **OUI** |
| `provider-accounts` | `edit()` | OUI | **OUI** |
| `provider-accounts` | `enableAll()` | OUI | **OUI** |
| `provider-accounts` | `exportAccounts()` | OUI | **OUI** |
| `provider-accounts` | `get()` | OUI | **OUI** |
| `provider-accounts` | `getPairStatus()` | OUI | **OUI** |
| `provider-accounts` | `importAccounts()` | OUI | **OUI** |
| `provider-accounts` | `login()` | OUI | **OUI** |
| `provider-accounts` | `pair()` | OUI | **OUI** |
| `provider-accounts` | `pairInput()` | OUI | **OUI** |
| `provider-accounts` | `pairStop()` | OUI | **OUI** |
| `epg` | `applyRefreshEpg()` | OUI | **OUI** |
| `epg` | `getEpg()` | OUI | **OUI** |
| `epg` | `refreshEpg()` | OUI | **OUI** |
| `events` | `closeAllWsClients()` | OUI | **OUI** |
| `events` | `closeWsClient()` | OUI | **OUI** |
| `events` | `deleteReplay()` | OUI | **OUI** |
| `events` | `getReplays_WS()` | OUI | **OUI** |
| `events` | `getSchedule_WS()` | OUI | **OUI** |
| `jobs` | `add()` | OUI | **OUI** |
| `jobs` | `closeWsClient()` | OUI | **OUI** |
| `jobs` | `delete()` | OUI | **OUI** |
| `jobs` | `edit()` | OUI | **OUI** |
| `jobs` | `getJobs()` | OUI | **OUI** |
| `jobs` | `run()` | OUI | **OUI** |

## 4. Routes d'API (75)

| Route d’API | Origine | Reconstruit |
|---|---|---|
| `/account/add` | OUI | **OUI** |
| `/account/delete` | OUI | **OUI** |
| `/account/deletedisabled` | OUI | **OUI** |
| `/account/disableall` | OUI | **OUI** |
| `/account/edit` | OUI | **OUI** |
| `/account/enableall` | OUI | **OUI** |
| `/account/export` | OUI | **OUI** |
| `/account/get` | OUI | **OUI** |
| `/account/import` | OUI | **OUI** |
| `/account/login` | OUI | **OUI** |
| `/account/pairinput` | OUI | **OUI** |
| `/account/pairstart` | OUI | **OUI** |
| `/account/pairstatus` | OUI | **OUI** |
| `/account/pairstop` | OUI | **OUI** |
| `/bootstrap` | OUI | **OUI** |
| `/channel/refreshapply` | OUI | **OUI** |
| `/channel/refreshrequest` | OUI | **OUI** |
| `/epg/get` | OUI | **OUI** |
| `/epg/refresh` | OUI | **OUI** |
| `/epg/refreshapply` | OUI | **OUI** |
| `/epg/refreshrequest` | OUI | **OUI** |
| `/event/refreshapply` | OUI | **OUI** |
| `/event/refreshrequest` | OUI | **OUI** |
| `/job/add` | OUI | **OUI** |
| `/job/delete` | OUI | **OUI** |
| `/job/edit` | OUI | **OUI** |
| `/job/run` | OUI | **OUI** |
| `/log/clean` | OUI | **OUI** |
| `/log/export` | OUI | **OUI** |
| `/log/get` | OUI | **OUI** |
| `/log/getconf` | OUI | **OUI** |
| `/log/setconf` | OUI | **OUI** |
| `/login` | OUI | **OUI** |
| `/provider/add` | OUI | **OUI** |
| `/provider/backup` | OUI | **OUI** |
| `/provider/cachelogos` | OUI | **OUI** |
| `/provider/delete` | OUI | **OUI** |
| `/provider/edit` | OUI | **OUI** |
| `/provider/export` | OUI | **OUI** |
| `/provider/exportkeys` | OUI | **OUI** |
| `/provider/exportmanifestandkeys` | OUI | **OUI** |
| `/provider/get` | OUI | **OUI** |
| `/provider/import` | OUI | **OUI** |
| `/provider/massupdate` | OUI | **OUI** |
| `/provider/pushkeys` | OUI | **OUI** |
| `/provider/rescan` | OUI | **OUI** |
| `/recording/add` | OUI | **OUI** |
| `/recording/delete` | OUI | **OUI** |
| `/recording/edit` | OUI | **OUI** |
| `/recording/get` | OUI | **OUI** |
| `/recording/stop` | OUI | **OUI** |
| `/replay/delete` | OUI | **OUI** |
| `/server/add` | OUI | **OUI** |
| `/server/delete` | OUI | **OUI** |
| `/server/edit` | OUI | **OUI** |
| `/server/get` | OUI | **OUI** |
| `/server/getinfo` | OUI | **OUI** |
| `/shutdown` | OUI | **OUI** |
| `/stream/add` | OUI | **OUI** |
| `/stream/delete` | OUI | **OUI** |
| `/stream/edit` | OUI | **OUI** |
| `/stream/flushkeys` | OUI | **OUI** |
| `/stream/get` | OUI | **OUI** |
| `/stream/refresh` | OUI | **OUI** |
| `/stream/refreshkeys` | OUI | **OUI** |
| `/stream/start` | OUI | **OUI** |
| `/stream/status` | OUI | **OUI** |
| `/stream/stop` | OUI | **OUI** |
| `/stream/stoprefresh` | OUI | **OUI** |
| `/user/add` | OUI | **OUI** |
| `/user/delete` | OUI | **OUI** |
| `/user/edit` | OUI | **OUI** |
| `/user/get` | OUI | **OUI** |
| `/vod/refreshapply` | OUI | **OUI** |
| `/vod/refreshrequest` | OUI | **OUI** |

## 5. Abonnements WebSocket (7)

| Abonnement WebSocket | Origine | Reconstruit |
|---|---|---|
| `Action: streamstatus` | OUI | **OUI** |
| `Action: logs` | OUI | **OUI** |
| `Action: monitoring` | OUI | **OUI** |
| `Action: recordingget` | OUI | **OUI** |
| `Action: replayget` | OUI | **OUI** |
| `Action: eventget` | OUI | **OUI** |
| `Action: jobget` | OUI | **OUI** |

## 6. Composants Vue (90)

Les noms sont les **vrais** noms d'origine : l'obfuscateur a renommé les
symboles mais laissé la propriété `__name` de Vue intacte.

| Composant | Employé par | Origine | Reconstruit |
|---|---|---|---|
| `App` | `JobsView` | OUI | **OUI** |
| `ButtonDanger` | `Sidebar`, `ConfirmationModal`, `RecordingsView`, `ConfigView`, `Event | OUI | **OUI** |
| `ButtonPrimary` | `Sidebar`, `InformationModal`, `ConfirmationModal`, `RefreshResource`, | OUI | **OUI** |
| `ButtonSecondary` | `ItemProvider`, `ProvidersView`, `LogsView`, `ItemRecording`, `ItemTab | OUI | **OUI** |
| `ButtonText` | `ItemStreamConfig`, `ItemProviderAccount` | OUI | **OUI** |
| `CdmModeSelector` | `ConfigView` | OUI | **OUI** |
| `CdmTypeSelector` | `ConfigView` | OUI | **OUI** |
| `CdnSelector` | `ConfigView` | OUI | **OUI** |
| `CheckBoxConfig` | `ConfigView` | OUI | **OUI** |
| `ConfigView` | _racine_ | OUI | **OUI** |
| `ConfirmationModal` | `RefreshResource`, `RecordingsView`, `ItemProviderAccount`, `ConfigVie | OUI | **OUI** |
| `ConnectedClients` | `ItemStreamCompact`, `ItemStream` | OUI | **OUI** |
| `Dropdown` | `FilterStreams`, `LogsView`, `RunningMode`, `NetworkSettings`, `Select | OUI | **OUI** |
| `DropdownProviderSelector` | `UsersView` | OUI | **OUI** |
| `DropdownTrackSelector` | `ConfigView` | OUI | **OUI** |
| `DvbSubsQualitySelector` | `ConfigView` | OUI | **OUI** |
| `EmptyContent` | `ProviderSelector`, `LinearView`, `ProvidersView`, `MonitoringView`, ` | OUI | **OUI** |
| `EpgTimezoneSelector` | `ConfigView` | OUI | **OUI** |
| `EpgView` | _racine_ | OUI | **OUI** |
| `EventsView` | _racine_ | OUI | **OUI** |
| `FilterStreams` | `LinearView`, `ConfigView`, `VodView`, `SearchView` | OUI | **OUI** |
| `Footer` | `App` | OUI | **OUI** |
| `GenericDropdown` | `OutputM3uLinksGlobal`, `OutputLinksM3us`, `ViewTypeSelector`, `Config | OUI | **OUI** |
| `HelpView` | _racine_ | OUI | **OUI** |
| `HwAccelSelector` | `ConfigView` | OUI | **OUI** |
| `IconSettings` | `ItemStreamCompact`, `ItemTableStreams`, `ItemStream`, `LogsView`, `It | OUI | **OUI** |
| `InformationModal` | `RefreshResource`, `LinearView`, `ProvidersView`, `MonitoringView`, `C | OUI | **OUI** |
| `InputConfig` | `MassConfigSet`, `ConfigView` | OUI | **OUI** |
| `ItemEpg` | `EpgView` | OUI | **OUI** |
| `ItemEvent` | `EventsView` | OUI | **OUI** |
| `ItemEventCompact` | `EventsView` | OUI | **OUI** |
| `ItemEventReplay` | `EventsView` | OUI | **OUI** |
| `ItemHelp` | `HelpView` | OUI | **OUI** |
| `ItemJob` | `JobsView` | OUI | **OUI** |
| `ItemMonitoring` | `MonitoringView` | OUI | **OUI** |
| `ItemProvider` | `ProvidersView` | OUI | **OUI** |
| `ItemProviderAccount` | `ConfigView` | OUI | **OUI** |
| `ItemRecording` | `RecordingsView` | OUI | **OUI** |
| `ItemServer` | `ServerView` | OUI | **OUI** |
| `ItemStream` | `LinearView`, `SearchView` | OUI | **OUI** |
| `ItemStreamCompact` | _racine_ | OUI | **OUI** |
| `ItemStreamConfig` | `ConfigView` | OUI | **OUI** |
| `ItemTableEpg` | `TableEpg` | OUI | **OUI** |
| `ItemTableEvent` | `TableEvents` | OUI | **OUI** |
| `ItemTableEventReplay` | `TableEventReplay` | OUI | **OUI** |
| `ItemTableRecording` | _racine_ | OUI | **OUI** |
| `ItemTableStreams` | `TableStreams` | OUI | **OUI** |
| `ItemUser` | `UsersView` | OUI | **OUI** |
| `ItemVod` | `VodView` | OUI | **OUI** |
| `JobsView` | _racine_ | OUI | **OUI** |
| `LinearView` | _racine_ | OUI | **OUI** |
| `ListViewToggle` | `RecordingsView`, `VodView`, `EpgView` | OUI | **OUI** |
| `LiveIndicator` | `ItemEvent`, `ItemEpg`, `ItemTableEpg` | OUI | **OUI** |
| `LoadingSpinner` | `LinearView`, `ConfigView`, `EpgView`, `SearchView` | OUI | **OUI** |
| `LoginView` | _racine_ | OUI | **OUI** |
| `LogsView` | _racine_ | OUI | **OUI** |
| `MassConfigSelector` | `MassConfigSet` | OUI | **OUI** |
| `MassConfigSet` | `ConfigView` | OUI | **OUI** |
| `MonitoringView` | _racine_ | OUI | **OUI** |
| `Mp4VideoPlayer` | `RecordingsView`, `VodView` | OUI | **OUI** |
| `NetworkSettings` | `ConfigView` | OUI | **OUI** |
| `OutputLinksM3us` | `ItemStreamCompact`, `ItemTableStreams`, `ItemStream`, `ItemStreamConf | OUI | **OUI** |
| `OutputM3uLinksGlobal` | `Sidebar`, `LinearView`, `ItemUser`, `ConfigView`, `VodView`, `EventsV | OUI | **OUI** |
| `PageTitle` | `LinearView`, `ProvidersView`, `MonitoringView`, `LogsView`, `Recordin | OUI | **OUI** |
| `PairingModal` | `ConfigView` | OUI | **OUI** |
| `ProviderSelector` | `LinearView`, `RecordingsView`, `ConfigView`, `VodView`, `EventsView`, | OUI | **OUI** |
| `ProvidersView` | _racine_ | OUI | **OUI** |
| `RecordingsView` | _racine_ | OUI | **OUI** |
| `RefreshResource` | `LinearView`, `VodView`, `EventsView` | OUI | **OUI** |
| `RunningMode` | `ConfigView` | OUI | **OUI** |
| `SearchResource` | `LinearView`, `ProvidersView`, `MonitoringView`, `RecordingsView`, `Co | OUI | **OUI** |
| `SearchView` | _racine_ | OUI | **OUI** |
| `SelectUserAccount` | `ConfigView` | OUI | **OUI** |
| `ServerSelector` | `Sidebar` | OUI | **OUI** |
| `ServerView` | _racine_ | OUI | **OUI** |
| `Sidebar` | `App` | OUI | **OUI** |
| `SortStreamsToggle` | `LinearView`, `MonitoringView`, `ConfigView`, `VodView`, `SearchView` | OUI | **OUI** |
| `StreamPlayer` | `LinearView`, `MonitoringView`, `LogsView`, `ConfigView`, `EventsView` | OUI | **OUI** |
| `StreamTypeSelector` | `ConfigView`, `SearchView` | OUI | **OUI** |
| `TableEpg` | `EpgView` | OUI | **OUI** |
| `TableEventReplay` | `EventsView` | OUI | **OUI** |
| `TableEvents` | `EventsView` | OUI | **OUI** |
| `TableRecordings` | `RecordingsView` | OUI | **OUI** |
| `TableStreams` | `LinearView`, `VodView`, `SearchView` | OUI | **OUI** |
| `UsersView` | _racine_ | OUI | **OUI** |
| `ViewTypeSelector` | `LinearView`, `EventsView`, `SearchView` | OUI | **OUI** |
| `VodView` | _racine_ | OUI | **OUI** |
| `o11Pagination` | `LinearView`, `ConfigView`, `VodView`, `EventsView`, `EpgView` | OUI | **OUI** |
| `o11Toast` | `App` | OUI | **OUI** |
| `o11Version` | `Sidebar`, `Footer` | OUI | **OUI** |

## 7. Champs de configuration

Le détail — type, valeur par défaut, libellé, contrôle — est dans
[`CONFIG_FIELDS.md`](CONFIG_FIELDS.md).

« Réseau (bloc) » désigne les 18 champs `Manifest/Media/Script ×
Network/Proxy/Bind/Doh/Dns/Worker`, portés ensemble par `NetworkSettings` parce
qu'un seul s'applique à la fois.

« Lecture seule » ne désigne QUE ce que le backend calcule ou observe : état
d'exécution, pistes détectées, guide en cours. Tout ce que l'exploitant
renseigne reste modifiable.

| Objet | Champs | Modifiables | Réseau (bloc) | Lecture seule (calculés) | Reconstruit |
|---|---|---|---|---|---|
| Provider | 144 | 120 | 18 | 6 | **OUI** |
| Stream | 92 | 47 | 18 | 27 | **OUI** |
| Account | 26 | 8 | 18 | 0 | **OUI** |

## 8. Préférences persistées

| Clé `localStorage` | Rôle | Reconstruit |
|---|---|---|
| `o11-token` | JWT de session (local) | **OUI** |
| `o11-token-remote` | JWT de session (distant) | **OUI** |
| `o11-preferences-view` | affichage par écran | **OUI** |
| `o11-preferences-sort` | tri par écran | **OUI** |
