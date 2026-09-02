# Champs de configuration — panel O11 Pro d'origine

**301 champs**, relevés le 2026-09-02. Les noms, les types et les valeurs par
défaut ne sont pas déduits du JavaScript : ils viennent du **binaire lui-même**,
interrogé dans un bac à sable jetable où un provider, un flux, un compte, un
utilisateur, un serveur, une tâche et un enregistrement de sonde ont été créés
puis relus. Le libellé et le contrôle d'interface, eux, viennent du bundle
désobfusqué (138 champs y sont reliés à un contrôle nommé).

Un tiret dans la colonne « libellé » ne veut pas dire que le champ est inutile :
il veut dire qu'il n'est pas exposé par un contrôle nommé de l'écran Config —
il est porté par une fiche, une liste, ou renvoyé en lecture seule.

## Provider — 144 champs

Écran **Config** (`/provider/:provider?/:type?/config`), onglet provider. Ces champs sont aussi la **valeur par défaut héritée** par les flux du provider.

Enregistrement : `providers.edit()` → `POST /api/provider/edit`

| Champ (clé JSON backend) | Type | Défaut du binaire | Libellé dans l'interface | Contrôle |
|---|---|---|---|---|
| `AddOverlay` | booléen | `false` | Add overlay on picture | `CheckBoxConfig` |
| `AllowDuplicateEvents` | booléen | `false` | Allow duplicate events | `CheckBoxConfig` |
| `AlwaysAutorestart` | booléen | `false` | Always auto-restart on failure | `CheckBoxConfig` |
| `AlwaysResetSession` | booléen | `false` | Always reset session | `CheckBoxConfig` |
| `AlwaysSelectDefaultTracks` | booléen | `false` | Always select default tracks | `CheckBoxConfig` |
| `AlwaysTranscode` | booléen | `false` | Always transcode | `CheckBoxConfig` |
| `AppendResolution` | booléen | `false` | Append resolution to channel name in playlist | `CheckBoxConfig` |
| `BurnMessage` | texte | _(vide)_ | Burn message | `InputConfig` |
| `CTV` | booléen | `false` | cbCtv | `CheckBoxConfig` |
| `CdmCert` | texte | _(vide)_ | CDM certificate | `InputConfig` |
| `ChannelsAutorefresh` | booléen | `false` | Auto-refresh channels | `CheckBoxConfig` |
| `ChannelsAutoremove` | booléen | `false` | Auto-remove missing channels | `CheckBoxConfig` |
| `ChannelsRefreshCron` | texte | `@daily` | Channels refresh cron | `InputConfig` |
| `CleanEventsOnRefresh` | booléen | `false` | Reset events list on refresh | `CheckBoxConfig` |
| `DRMLevel` | texte | _(vide)_ | DRM level | `InputConfig` |
| `DVBSubsColorsFilter` | texte | _(vide)_ | DVBSubs colors filter | `InputConfig` |
| `DVBSubsNoColors` | booléen | `false` | Disable DVBSubs colors | `CheckBoxConfig` |
| `DVBSubsNoStyleParsing` | booléen | `false` | Disable DVBSubs style | `CheckBoxConfig` |
| `DVBSubsQuality` | entier | `2` | (sans libellé propre) | `DvbSubsQualitySelector` |
| `DVBSubsSizePercentage` | entier | `100` | DVBSubs size | `InputConfig` |
| `DVBSubsTranslationDstLang` | texte | _(vide)_ | DVBSubs translation dest | `InputConfig` |
| `DVBSubsTranslationSrcLang` | texte | _(vide)_ | DVBSubs translation src | `InputConfig` |
| `DVBSubsVerticalOffsetPercentage` | entier | `95` | DVBSubs Vertical Offset | `InputConfig` |
| `DashTimeOffsetMs` | entier | `0` | DASH time offset (ms) | `InputConfig` |
| `DefaultAudio` | texte | _(vide)_ | Default audio | `InputConfig` |
| `DefaultCdn` | texte | _(vide)_ | Default CDN | `InputConfig` |
| `DefaultEventDuration` | entier | `14400` | Default events duration | `InputConfig` |
| `DefaultSubtitles` | texte | _(vide)_ | Default subtitles | `InputConfig` |
| `DefaultTracksFirstMatch` | booléen | `false` | Only match first default track | `CheckBoxConfig` |
| `DefaultVideo` | texte | _(vide)_ | Default video | `InputConfig` |
| `DeleteRemovedStreamLogs` | booléen | `false` | Delete removed streams logs | `CheckBoxConfig` |
| `DontAddNewChannels` | booléen | `false` | Don't add new channels on refresh | `CheckBoxConfig` |
| `DontAutoCacheLogos` | booléen | `false` | Don't auto-cache logos | `CheckBoxConfig` |
| `DontCooldownEventStart` | booléen | `false` | Don't cool down event start | `CheckBoxConfig` |
| `DontGzipEpgInPlaylist` | booléen | `false` | Don't Gzip EPG in playlist | `CheckBoxConfig` |
| `DownloadManifestScript` | booléen | `false` | downloadmanifestscript | `CheckBoxConfig` |
| `DownloadMediaScript` | booléen | `false` | downloadmediascript | `CheckBoxConfig` |
| `EpgAutorefresh` | booléen | `false` | Auto-refresh EPG | `CheckBoxConfig` |
| `EpgRefreshCron` | texte | `@daily` | EPG refresh cron | `InputConfig` |
| `EpgTimezone` | texte | _(vide)_ | (sans libellé propre) | `EpgTimezoneSelector` |
| `EventFilters` | texte | _(vide)_ | Event filters | `InputConfig` |
| `EventsAppendDate` | booléen | `false` | Append date to event name | `CheckBoxConfig` |
| `EventsAutorefresh` | booléen | `false` | Auto-refresh events | `CheckBoxConfig` |
| `EventsEndOffset` | entier | `0` | Events end offset (s) | `InputConfig` |
| `EventsFirstId` | entier | `0` | Events first ID | `InputConfig` |
| `EventsRefreshCron` | texte | `@daily` | Events refresh cron | `InputConfig` |
| `EventsReversedIds` | booléen | `false` | Reversed events ids | `CheckBoxConfig` |
| `EventsSqlStreamingUrl` | texte | _(vide)_ | SQL Stream URL | `InputConfig` |
| `EventsSqlUrl` | texte | _(vide)_ | Events SQL URL | `InputConfig` |
| `EventsStartOffset` | entier | `0` | Events start offset (s) | `InputConfig` |
| `ExternalCdmScript` | texte | _(vide)_ | — | — |
| `ForcePropagateManifestUrlParams` | booléen | `false` | forcepropagatemanifesturlparams | `CheckBoxConfig` |
| `ForcePsshFromManifest` | booléen | `false` | Force PSSH from manifest | `CheckBoxConfig` |
| `Headers2` | objet | `…` | — | — |
| `HlsFragmentsDuration` | entier | `0` | HLS fragments duration (s) | `InputConfig` |
| `HlsIsMp4` | booléen | `false` | hlsismp4 | `CheckBoxConfig` |
| `HlsIsTs` | booléen | `false` | hlsists | `CheckBoxConfig` |
| `HttpGetRetries` | entier | `2` | HTTP get tentatives count | `InputConfig` |
| `HttpGetTimeout` | entier | `30` | HTTP get timeout | `InputConfig` |
| `HwAccel` | texte | `none` | (sans libellé propre) | `HwAccelSelector` |
| `Id` | texte | `sonde` | — | — |
| `IgnoreDashSegmentTimeline` | booléen | `false` | ignoredashsegmenttimeline | `CheckBoxConfig` |
| `IgnoreKeysCache` | booléen | `false` | Don't use keys cache | `CheckBoxConfig` |
| `IgnoreOldestFragment` | booléen | `false` | Ignore oldest fragment | `CheckBoxConfig` |
| `IgnoreStaticDash` | booléen | `false` | ignorestaticdash | `CheckBoxConfig` |
| `InvalidPatDetection` | booléen | `false` | InvalidPatDetection | `CheckBoxConfig` |
| `KeepEndedEvents` | booléen | `false` | Don't auto-remove finished events | `CheckBoxConfig` |
| `KeysArchiveProviderId` | texte | _(vide)_ | CDM provider ID | `InputConfig` |
| `LastEventIndex` | entier | `0` | — | — |
| `LastVodIndex` | entier | `0` | — | — |
| `LegacyDashParser` | booléen | `false` | legacydashparser | `CheckBoxConfig` |
| `LogoUrl` | texte | _(vide)_ | Logo URL | `InputConfig` |
| `ManifestBind` | texte | _(vide)_ | — | — |
| `ManifestDns` | texte | _(vide)_ | — | — |
| `ManifestDoh` | texte | _(vide)_ | — | — |
| `ManifestNetwork` | texte | `same` | (sans libellé propre) | `Dropdown` |
| `ManifestProxy` | texte | _(vide)_ | — | — |
| `ManifestWorker` | texte | _(vide)_ | — | — |
| `MaxAutorestart` | entier | `0` | Max autorestart tentatives | `InputConfig` |
| `MaxConcurrentScript` | entier | `0` | Max concurrent script calls | `InputConfig` |
| `MaxConcurrentStreams` | entier | `0` | Max streams concurrency | `InputConfig` |
| `MaxDownloadConcurrency` | entier | `50` | Max download concurrency | `InputConfig` |
| `MaxEventsCount` | entier | `0` | Max events count | `InputConfig` |
| `MaxEventsHours` | entier | `0` | Max events hours | `InputConfig` |
| `MaxStreamsPerAccount` | entier | `0` | Max streams per account | `InputConfig` |
| `MediaBind` | texte | _(vide)_ | — | — |
| `MediaDns` | texte | _(vide)_ | — | — |
| `MediaDoh` | texte | _(vide)_ | — | — |
| `MediaNetwork` | texte | `same` | (sans libellé propre) | `Dropdown` |
| `MediaProxy` | texte | _(vide)_ | — | — |
| `MediaWorker` | texte | _(vide)_ | — | — |
| `Name` | texte | `SONDE` | — | — |
| `NbAnnouncedFragments` | entier | `0` | Output fragments count | `InputConfig` |
| `NoEventNameInPlaylist` | booléen | `false` | Use event number as name in playlist | `CheckBoxConfig` |
| `NoRefererInRedirects` | booléen | `false` | norefererinredirects | `CheckBoxConfig` |
| `NoRestartOnError` | booléen | `false` | No restart on error | `CheckBoxConfig` |
| `NoRestartOnTrackChange` | booléen | `false` | No restart on track change | `CheckBoxConfig` |
| `NoWaitFullPlaylist` | booléen | `false` | nowaitfullplaylist | `CheckBoxConfig` |
| `OffAirFallback` | booléen | `false` | Off air event fallback | `CheckBoxConfig` |
| `OutputMode` | texte | `directhls` | (sans libellé propre) | `Dropdown` |
| `PipeOutputCmdFormated` | texte | `tsplay -pace-pcr2-pmt -stdin %s` | Pipe command | `InputConfig` |
| `PlaybackDelay` | entier | `0` | Playback Delay (s) | `InputConfig` |
| `PlaylistDuration` | entier | `15` | HLS playlist duration (s) | `InputConfig` |
| `PreProcessPssh` | booléen | `false` | Pre-process PSSH | `CheckBoxConfig` |
| `PropagateManifestUrlParams` | booléen | `false` | propagatemanifesturlparams | `CheckBoxConfig` |
| `PushKeysToArchive` | booléen | `false` | Push keys to archive | `CheckBoxConfig` |
| `RandomAutorestartOffset` | entier | `0` | Autorestart random offset (s) | `InputConfig` |
| `RandomAutostartPeriod` | entier | `0` | Random autostart period (s) | `InputConfig` |
| `RandomNetworkParam` | booléen | `false` | (sans libellé propre) | `CheckBoxConfig` |
| `RemoveMissingEvents` | booléen | `false` | Remove events not returned by script | `CheckBoxConfig` |
| `RestartCoolDown` | booléen | `false` | Cooldown streams auto-restart | `CheckBoxConfig` |
| `RestartDelay` | entier | `30` | Restart delay (s) | `InputConfig` |
| `RestartFinished` | booléen | `false` | Restart finished broadcast | `CheckBoxConfig` |
| `RetryDownloadWithNewManifestCount` | entier | `1` | Retry new manifest count | `InputConfig` |
| `ReuseEventIndex` | booléen | `false` | Reuse event index | `CheckBoxConfig` |
| `RunningMode` | texte | `internalremuxer` | (sans libellé propre) | `Dropdown` |
| `SSAI` | booléen | `false` | cbSsai | `CheckBoxConfig` |
| `Script` | texte | _(vide)_ | — | — |
| `ScriptAccounts` | null (non renseigné) | _null_ | — | — |
| `ScriptAccountsUser` | texte | `none` | (sans libellé propre) | `Dropdown` |
| `ScriptBind` | texte | _(vide)_ | — | — |
| `ScriptDns` | texte | _(vide)_ | — | — |
| `ScriptDoh` | texte | _(vide)_ | — | — |
| `ScriptNetwork` | texte | _(vide)_ | (sans libellé propre) | `Dropdown` |
| `ScriptProxy` | texte | _(vide)_ | — | — |
| `ScriptTimeout` | entier | `30` | Script timeout (s) | `InputConfig` |
| `ScriptWorker` | texte | _(vide)_ | — | — |
| `SequencialAutostartPeriod` | entier | `0` | Seq autostart period (s) | `InputConfig` |
| `StallDetectTimeout` | entier | `60` | Stalled stream timeout (s) | `InputConfig` |
| `Streams` | null (non renseigné) | _null_ | — | — |
| `StreamsCount` | entier | `1` | — | — |
| `TryAllCdn` | booléen | `false` | Try next CDN on failure | `CheckBoxConfig` |
| `UseDashDelay` | booléen | `false` | usedashdelay | `CheckBoxConfig` |
| `UseDashLocation` | booléen | `false` | usedashlocation | `CheckBoxConfig` |
| `UseIPV6` | booléen | `false` | (sans libellé propre) | `CheckBoxConfig` |
| `UseJsonRedirectUrl` | booléen | `false` | usejsonredirecturl | `CheckBoxConfig` |
| `UseMediaNetworkForHlsKey` | booléen | `false` | Use media network for HLS key | `CheckBoxConfig` |
| `UseNewestDashPeriod` | booléen | `false` | usenewestdashperiod | `CheckBoxConfig` |
| `UseProviderScriptForSubtitles` | booléen | `false` | Use provider script for DVBSubs | `CheckBoxConfig` |
| `UseSessionCookies` | booléen | `false` | usesessioncookies | `CheckBoxConfig` |
| `UseVttTimestampMap` | booléen | `false` | Use X-TIMESTAMP-MAP for VTT | `CheckBoxConfig` |
| `UserAgent` | texte | `Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/…` | User Agent | `InputConfig` |
| `VmxUniqueId` | texte | _(vide)_ | Unique ID | `InputConfig` |
| `XForwardedFor` | texte | _(vide)_ | X-Forwarded-For | `InputConfig` |

## Flux (channel / event / vod) — 92 champs

Écran **Config**, onglet flux, et les fiches de `ItemStreamConfig`. Un champ laissé vide hérite de la valeur du provider.

Enregistrement : `streams.edit()` → `POST /api/stream/edit`

| Champ (clé JSON backend) | Type | Défaut du binaire | Libellé dans l'interface | Contrôle |
|---|---|---|---|---|
| `Audio` | texte | _(vide)_ | — | — |
| `AudioList` | null (non renseigné) | _null_ | — | — |
| `AutorestartCron` | texte | _(vide)_ | — | — |
| `Autostart` | booléen | `false` | Autostart | `CheckBoxConfig` |
| `Category` | texte | _(vide)_ | — | — |
| `CdmMode` | texte | `external` | (sans libellé propre) | `CdmModeSelector` |
| `CdmType` | texte | `widevine` | (sans libellé propre) | `CdmTypeSelector` |
| `Cdn` | null (non renseigné) | _null_ | — | — |
| `CdnName` | texte | _(vide)_ | (sans libellé propre) | `DropdownTrackSelector` |
| `DailyEndTime` | entier | `0` | — | — |
| `DailyOnAir` | booléen | `false` | (sans libellé propre) | `CheckBoxConfig` |
| `DailyStartTime` | entier | `0` | — | — |
| `Description` | texte | _(vide)_ | — | — |
| `Drm` | objet | `…` | — | — |
| `End` | entier | `0` | — | — |
| `EpgId` | texte | _(vide)_ | — | — |
| `EpgNext` | texte | _(vide)_ | — | — |
| `EpgNow` | texte | _(vide)_ | — | — |
| `EpgNowEnd` | entier | `0` | — | — |
| `EpgNowStart` | entier | `0` | — | — |
| `ExtraStatus` | texte | _(vide)_ | — | — |
| `FirstAudioTrack` | texte | _(vide)_ | — | — |
| `FirstSubtitlesTrack` | texte | _(vide)_ | — | — |
| `HasInternalDrm` | booléen | `false` | — | — |
| `HasKeys` | booléen | `true` | — | — |
| `HasManifest` | booléen | `true` | — | — |
| `Headers` | objet | `…` | — | — |
| `Heartbeat` | objet | `…` | — | — |
| `HwAccelDeviceIndex` | entier | `0` | — | — |
| `Id` | texte | `sondech` | — | — |
| `IgnoreUpdate` | booléen | `false` | Ignore update | `CheckBoxConfig` |
| `Info` | texte | _(vide)_ | — | — |
| `Keys` | null (non renseigné) | _null_ | — | — |
| `LegacyId` | texte | _(vide)_ | — | — |
| `License` | objet | `…` | — | — |
| `LogLevel` | entier | `0` | — | — |
| `LogoUrl` | texte | _(vide)_ | Logo URL | `InputConfig` |
| `Manifest` | texte | `http://127.0.0.1:1/x.m3u8` | — | — |
| `ManifestBind` | texte | _(vide)_ | — | — |
| `ManifestDns` | texte | _(vide)_ | — | — |
| `ManifestDoh` | texte | _(vide)_ | — | — |
| `ManifestExpiration` | entier | `0` | — | — |
| `ManifestInfo` | texte | _(vide)_ | — | — |
| `ManifestInfo2` | objet | `…` | — | — |
| `ManifestNetwork` | texte | _(vide)_ | (sans libellé propre) | `Dropdown` |
| `ManifestProxy` | texte | _(vide)_ | — | — |
| `ManifestType` | texte | _(vide)_ | — | — |
| `ManifestWorker` | texte | _(vide)_ | — | — |
| `ManualEvent` | booléen | `false` | (sans libellé propre) | `CheckBoxConfig` |
| `MediaBind` | texte | _(vide)_ | — | — |
| `MediaDns` | texte | _(vide)_ | — | — |
| `MediaDoh` | texte | _(vide)_ | — | — |
| `MediaNetwork` | texte | _(vide)_ | (sans libellé propre) | `Dropdown` |
| `MediaProxy` | texte | _(vide)_ | — | — |
| `MediaWorker` | texte | _(vide)_ | — | — |
| `ModeOverride` | booléen | `false` | Mode override | `CheckBoxConfig` |
| `Name` | texte | `SONDE-CH` | — | — |
| `NetworkOverride` | booléen | `false` | Network Override | `CheckBoxConfig` |
| `OnDemand` | booléen | `false` | On demand | `CheckBoxConfig` |
| `OriginalLogoUrl` | texte | _(vide)_ | — | — |
| `OutputMode` | texte | `directhls` | (sans libellé propre) | `Dropdown` |
| `PRClientVersion` | texte | _(vide)_ | — | — |
| `PRCustomData` | texte | _(vide)_ | — | — |
| `PRLAVersion` | texte | _(vide)_ | — | — |
| `PipeOutputParams` | texte | _(vide)_ | — | — |
| `ProcessDVBSubs` | booléen | `false` | Process DVBSubs | `CheckBoxConfig` |
| `ProtoOutputParams` | texte | _(vide)_ | — | — |
| `RecordEvent` | booléen | `false` | (sans libellé propre) | `CheckBoxConfig` |
| `RecordTs` | booléen | `false` | Record TS | `CheckBoxConfig` |
| `RunningMode` | texte | `internalremuxer` | (sans libellé propre) | `Dropdown` |
| `ScriptAccountsUser` | texte | `provider` | (sans libellé propre) | `Dropdown` |
| `ScriptBind` | texte | _(vide)_ | — | — |
| `ScriptDns` | texte | _(vide)_ | — | — |
| `ScriptDoh` | texte | _(vide)_ | — | — |
| `ScriptNetwork` | texte | _(vide)_ | (sans libellé propre) | `Dropdown` |
| `ScriptParams` | texte | _(vide)_ | — | — |
| `ScriptProxy` | texte | _(vide)_ | — | — |
| `ScriptWorker` | texte | _(vide)_ | — | — |
| `SessionManifest` | booléen | `false` | Session manifest | `CheckBoxConfig` |
| `SortId` | entier | `0` | — | — |
| `SpeedUp` | booléen | `false` | Speed up | `CheckBoxConfig` |
| `Start` | entier | `0` | — | — |
| `StreamingResolutions` | null (non renseigné) | _null_ | — | — |
| `StreamingUrl` | liste | `…` | — | — |
| `Subtitles` | texte | _(vide)_ | — | — |
| `SubtitlesList` | null (non renseigné) | _null_ | — | — |
| `SubtitlesOffset` | entier | `0` | — | — |
| `TimeRange` | booléen | `false` | — | — |
| `Type` | texte | `linear` | — | — |
| `UseCdm` | booléen | `false` | Use CDM | `CheckBoxConfig` |
| `Video` | texte | _(vide)_ | — | — |
| `VideoList` | null (non renseigné) | _null_ | — | — |

## Compte de script — 26 champs

Écran **Config**, section `ItemProviderAccount` / `SelectUserAccount`.

Enregistrement : `users.edit()` → `POST /api/account/edit`

| Champ (clé JSON backend) | Type | Défaut du binaire | Libellé dans l'interface | Contrôle |
|---|---|---|---|---|
| `Description` | texte | _(vide)_ | — | — |
| `Device` | texte | _(vide)_ | — | — |
| `Enabled` | booléen | `false` | (sans libellé propre) | `CheckBoxConfig` |
| `ManifestBind` | texte | _(vide)_ | — | — |
| `ManifestDns` | texte | _(vide)_ | — | — |
| `ManifestDoh` | texte | _(vide)_ | — | — |
| `ManifestNetwork` | texte | _(vide)_ | (sans libellé propre) | `Dropdown` |
| `ManifestProxy` | texte | _(vide)_ | — | — |
| `ManifestWorker` | texte | _(vide)_ | — | — |
| `MediaBind` | texte | _(vide)_ | — | — |
| `MediaDns` | texte | _(vide)_ | — | — |
| `MediaDoh` | texte | _(vide)_ | — | — |
| `MediaNetwork` | texte | _(vide)_ | (sans libellé propre) | `Dropdown` |
| `MediaProxy` | texte | _(vide)_ | — | — |
| `MediaWorker` | texte | _(vide)_ | — | — |
| `NetworkOverride` | booléen | `false` | Network Override | `CheckBoxConfig` |
| `Password` | texte | _(vide)_ | — | — |
| `Pin` | texte | _(vide)_ | — | — |
| `RunningStreams` | entier | `0` | — | — |
| `ScriptBind` | texte | _(vide)_ | — | — |
| `ScriptDns` | texte | _(vide)_ | — | — |
| `ScriptDoh` | texte | _(vide)_ | — | — |
| `ScriptNetwork` | texte | _(vide)_ | (sans libellé propre) | `Dropdown` |
| `ScriptProxy` | texte | _(vide)_ | — | — |
| `ScriptWorker` | texte | _(vide)_ | — | — |
| `User` | texte | _(vide)_ | — | — |

## Utilisateur du panel — 7 champs

Écran **Users** (`/users`), composant `ItemUser`.

Enregistrement : `users.edit()` → `POST /api/user/edit`

| Champ (clé JSON backend) | Type | Défaut du binaire | Libellé dans l'interface | Contrôle |
|---|---|---|---|---|
| `AuthToken` | texte | _(jeton de session — jamais affiché)_ | — | — |
| `HasWebAccess` | booléen | `false` | — | — |
| `IsAdmin` | booléen | `false` | — | — |
| `Network` | texte | _(vide)_ | — | — |
| `Password` | texte | _(vide)_ | — | — |
| `ProviderIds` | liste | _vide_ | — | — |
| `Username` | texte | `sonde` | — | — |

## Serveur distant — 5 champs

Écran **Servers** (`/servers`), composant `ItemServer`.

Enregistrement : `servers.edit()` → `POST /api/server/edit`

| Champ (clé JSON backend) | Type | Défaut du binaire | Libellé dans l'interface | Contrôle |
|---|---|---|---|---|
| `Id` | texte | `sondesrv` | — | — |
| `Name` | texte | `SONDE-SRV` | — | — |
| `Password` | texte | `y` | — | — |
| `Url` | texte | `http://127.0.0.1:1` | — | — |
| `User` | texte | _(vide)_ | — | — |

## Tâche planifiée — 10 champs

Écran **Jobs** (`/jobs`), composant `ItemJob`.

Enregistrement : `jobs.edit()` → `POST /api/job/edit`

| Champ (clé JSON backend) | Type | Défaut du binaire | Libellé dans l'interface | Contrôle |
|---|---|---|---|---|
| `Cron` | texte | _(vide)_ | — | — |
| `Description` | texte | _(vide)_ | — | — |
| `Enabled` | booléen | `false` | (sans libellé propre) | `CheckBoxConfig` |
| `Id` | texte | `49c4969a-36d4-40da-a536-f0a2b9d7f535` | — | — |
| `LastRunResult` | texte | _(vide)_ | — | — |
| `LastRunTimestamp` | entier | `0` | — | — |
| `Name` | texte | _(vide)_ | — | — |
| `ScriptName` | texte | _(vide)_ | — | — |
| `ScriptParams` | texte | _(vide)_ | — | — |
| `ScriptTimeout` | entier | `0` | Script timeout (s) | `InputConfig` |

## Enregistrement — 14 champs

Écran **Recordings** (`/recordings/:provider?`), composant `ItemRecording`.

Enregistrement : `recordings.edit()` → `POST /api/recording/edit`

| Champ (clé JSON backend) | Type | Défaut du binaire | Libellé dans l'interface | Contrôle |
|---|---|---|---|---|
| `Description` | texte | _(vide)_ | — | — |
| `End` | entier | `0` | — | — |
| `Id` | texte | `GaQGK3QuyXFnHnxt` | — | — |
| `ProviderId` | texte | `sonde` | — | — |
| `ProviderName` | texte | `SONDE` | — | — |
| `Start` | entier | `0` | — | — |
| `Status` | texte | `scheduled` | — | — |
| `StatusColor` | texte | `white` | — | — |
| `StreamId` | texte | `sondech` | — | — |
| `StreamName` | texte | `SONDE-CH` | — | — |
| `StreamingUrl` | texte | `http://127.0.0.1:8391/stream/rec-GaQGK3QuyXFnHnxt.mp4?u=admi…` | — | — |
| `Title` | texte | _(vide)_ | — | — |
| `VideoDesc` | texte | _(vide)_ | — | — |
| `VideoId` | texte | _(vide)_ | — | — |

## Journalisation — 3 champs

Écran **Logs** (`/logs/:provider?/:stream?`), bouton `IconSettings`. Attention : la lecture renvoie `LogLevel`/`Filter`/`HighlightFilter`, mais l'écriture attend `LogLevel`/`LogFilter`/`HighlightLogFilter` **plus** `ProviderId` et `StreamId`. Les noms diffèrent entre lecture et écriture.

Enregistrement : `logs.setConf()` → `POST /api/log/setconf`

| Champ (clé JSON backend) | Type | Défaut du binaire | Libellé dans l'interface | Contrôle |
|---|---|---|---|---|
| `Filter` | texte | _(vide)_ | — | — |
| `HighlightFilter` | booléen | `false` | — | — |
| `LogLevel` | entier | `0` | — | — |

## Mise à jour de masse — 37 options

`providers.getMassUpdateOptions()` appelle `POST /api/bootstrap`, et le
**backend** renvoie la liste des options applicables en masse. Elle n'est pas
codée dans le panel : la reconstruire en dur serait une régression le jour où le
backend en ajoute une.

| Paramètre | Titre affiché | Action |
|---|---|---|
| `autostart` | Autostart | `setunset` |
| `ondemand` | On demand | `setunset` |
| `speedup` | Speed up | `setunset` |
| `processdvbsubs` | Process DVBSubs | `setunset` |
| `sessionmanifest` | Session manifest | `setunset` |
| `usecdm` | Use CDM | `setunset` |
| `networkoverride` | Network override | `setunset` |
| `modeoverride` | Mode override | `setunset` |
| `recordevent` | Record event | `setunset` |
| `recordts` | Record TS | `setunset` |
| `manualevent` | Manual event | `setunset` |
| `dailyonair` | Daily on air | `setunset` |
| `clearsortid` | Clear sort Ids | `set` |
| `clearlogourl` | Clear logo Urls | `set` |
| `clearoldkeys` | Clear old keys | `set` |
| `setdefaultcdn` | Set default CDN | `set` |
| `manifest` | Manifest | `setvalue` |
| `scriptparams` | Script params | `setvalue` |
| `scriptaccountsuser` | Script account user | `setvalue` |
| `cdmtype` | CDM type | `setvalue` |
| `scriptnetwork` | Script network | `setvalue` |
| `scriptnetworkvalue` | Script network value | `setvalue` |
| `manifestnetwork` | Manifest network | `setvalue` |
| `manifestnetworkvalue` | Manifest network value | `setvalue` |
| `medianetwork` | Media network | `setvalue` |
| `medianetworkvalue` | Media network value | `setvalue` |
| `scriptworkerdns` | Script worker | `setvalue` |
| `manifestworkerdns` | Manifest worker | `setvalue` |
| `mediaworkerdns` | Media worker | `setvalue` |
| `setvideo` | Set video | `setvalue` |
| `setaudio` | Set audio | `setvalue` |
| `setsubtitles` | Set subtitles | `setvalue` |
| `sethwdeviceid` | HW Accel Device ID | `setvalue` |
| `firstaudiotrack` | First audio track | `setvalue` |
| `firstsubtitlestrack` | First subtitles track | `setvalue` |
| `autorestartcron` | Auto-restart cron | `setvalue` |
| `dailyonairstartend` | Daily on air value | `setstartend` |

L'envoi se fait par `providers.massUpdate()` → `POST /api/provider/massupdate`.

## Trois pièges à ne pas reproduire de travers

1. **`log/getconf` et `log/setconf` n'emploient pas les mêmes noms.** Lire donne
   `Filter` et `HighlightFilter` ; écrire exige `LogFilter` et
   `HighlightLogFilter`. Recopier les noms de la lecture dans l'écriture casse
   silencieusement le filtre.
2. **`ScriptAccountsUser` vaut `none` sur un provider et `provider` sur un
   flux.** Les deux champs portent le même nom et n'ont pas la même valeur par
   défaut.
3. **Un champ réseau vide sur un flux n'est pas « désactivé »** : il hérite du
   provider. `ManifestNetwork` vaut `same` sur le provider et `""` sur le flux —
   forcer `same` sur le flux changerait le comportement.
