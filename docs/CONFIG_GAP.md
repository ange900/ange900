# Écart de configuration — legacy O11 Pro → o11-rebuild

Les **262 champs** relevés sur le binaire d'O11 Pro, confrontés un à un aux
schémas qu'o11-rebuild rc29 déclare sur `/api/v1/providers/schema` et
`/api/v1/streams/schema` — interrogés sur une instance réelle.

## Une correction

Un premier relevé annonçait « ni DRM, ni CDM, ni comptes de script ».
**C'était faux.** Le schéma des flux porte `use_cdm` et un secret
`content_keys` ; celui des providers porte `script_accounts`. La couverture
est meilleure que ce que j'avais écrit.

## Les chiffres

| | Champs | Part |
|---|---:|---:|
| A — équivalent direct | 35 | 13 % |
| B — équivalent avec transformation | 20 | 8 % |
| D — devenue automatique dans o11-rebuild | 29 | 11 % |
| E — réellement absente | 143 | 55 % |
| F — valeur d'exécution, pas un réglage | 35 | 13 % |
| **Total** | **262** | |

Sur les **227 champs qui sont de vrais réglages** (hors les 35 valeurs
d'exécution) : **55 se traduisent**, 29 n'ont plus lieu d'être, **143 n'existent
pas**.

## A — équivalent direct (35)

Même sens, même effet. La traduction est un simple changement de nom.

### Provider
| Legacy | o11-rebuild |
|---|---|
| `ChannelsRefreshCron` | channels_refresh_cron |
| `EpgRefreshCron` | epg_refresh_cron |
| `EpgTimezone` | epg_timezone |
| `EventsRefreshCron` | events_refresh_cron |
| `HttpGetRetries` | http_retries |
| `HttpGetTimeout` | http_timeout_s |
| `MaxConcurrentScript` | script_concurrency |
| `MaxConcurrentStreams` | max_concurrent_streams |
| `MaxDownloadConcurrency` | download_concurrency |
| `PlaylistDuration` | playlist_duration_s |
| `RestartDelay` | restart_delay_s |
| `Script` | script_name |
| `ScriptTimeout` | script_timeout_s |
| `StallDetectTimeout` | stall_detect_timeout_s |
| `UseSessionCookies` | use_session_cookies |
| `UserAgent` | user_agent |

### Flux
| Legacy | o11-rebuild |
|---|---|
| `Audio` | audio_track |
| `Autostart` | autostart |
| `DailyOnAir` | daily_on_air |
| `IgnoreUpdate` | ignore_update |
| `ModeOverride` | mode_override |
| `NetworkOverride` | network_override |
| `OnDemand` | on_demand |
| `ProcessDVBSubs` | process_dvb_subs |
| `RecordTs` | record_ts |
| `ScriptParams` | script_params |
| `SpeedUp` | speed_up |
| `UseCdm` | use_cdm |
| `Video` | video_track |

## B — équivalent avec transformation (20)

Le sens existe, la forme diffère : un secret au lieu d'un réglage, une colonne
au lieu d'un champ, une valeur inversée.

### Provider
| Legacy | o11-rebuild |
|---|---|
| `Headers2` | manifest_headers+media_headers (secrets) |
| `ManifestNetwork` | manifest_network |
| `ManifestProxy` | manifest_proxy (secret) |
| `MediaNetwork` | media_network |
| `MediaProxy` | media_proxy (secret) |
| `ScriptAccounts` | script_accounts (secret) |
| `ScriptAccountsUser` | script_accounts (secret) |
| `ScriptNetwork` | script_network |
| `ScriptProxy` | script_proxy (secret) |

### Flux
| Legacy | o11-rebuild |
|---|---|
| `Headers` | manifest/media/key_headers (secrets) |
| `Keys` | content_keys (secret) |
| `LogoUrl` | logo_url (colonne) |
| `Manifest` | input_url (colonne) |
| `ManifestExpiration` | manifest_ttl_s |
| `ManifestProxy` | manifest_proxy (secret) |
| `MediaProxy` | media_proxy (secret) |
| `Name` | name (colonne) |
| `OutputMode` | remux_mode |
| `RunningMode` | remux_mode |
| `SessionManifest` | manifest_source |

## D — devenue automatique (29)

o11-rebuild s'en charge seul. Exposer l'option ferait croire à un levier qui
n'existe plus.

`Subtitles`, `AlwaysResetSession`, `AlwaysSelectDefaultTracks`, `DashTimeOffsetMs`, `DefaultTracksFirstMatch`, `ForcePropagateManifestUrlParams`, `ForcePsshFromManifest`, `IgnoreDashSegmentTimeline`, `IgnoreOldestFragment`, `IgnoreStaticDash`, `InvalidPatDetection`, `LegacyDashParser`, `NbAnnouncedFragments`, `NoRefererInRedirects`, `NoRestartOnTrackChange`, `NoWaitFullPlaylist`, `PreProcessPssh`, `PropagateManifestUrlParams`, `RandomAutorestartOffset`, `RandomAutostartPeriod`, `RandomNetworkParam`, `RestartCoolDown`, `RetryDownloadWithNewManifestCount`, `SequencialAutostartPeriod`, `UseDashDelay`, `UseDashLocation`, `UseJsonRedirectUrl`, `UseMediaNetworkForHlsKey`, `UseNewestDashPeriod`

## E — réellement absente (143)

Aucune destination. Ce sont pour l'essentiel les réglages DASH fins, les
variantes de sortie, les options d'événements et les réglages DVB de l'ancien
moteur.

Le panel les affichera **désactivés et signalés** en mode o11-rebuild, jamais
avec un bouton d'enregistrement qui ne ferait rien.

## Ce que l'écran Config devient en mode o11-rebuild

- **55 champs modifiables**, ceux des catégories A et B ;
- **29 champs retirés**, avec la mention « géré automatiquement » ;
- **143 champs visibles mais inertes**, marqués « indisponible avec
  o11-rebuild » ;
- **le bouton Enregistrer n'envoie que les 55.**

En mode legacy o11pro, **les 262 continuent de fonctionner exactement comme
avant**. C'est la même interface, pas le même contrat.
