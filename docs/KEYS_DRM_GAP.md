# Clés, DRM et CDM — legacy O11 Pro face à o11-rebuild

## Correction d'un relevé précédent

J'ai d'abord écrit qu'o11-rebuild n'avait « ni DRM ni CDM ». **C'était faux**, et
l'erreur venait d'une lecture trop rapide : je m'étais fié aux notes de
conception plutôt qu'au schéma que le logiciel déclare lui-même.

Interrogé sur une instance réelle, `/api/v1/streams/schema` renvoie :

```
settings : … use_cdm …
secrets  : manifest_headers, media_headers, key_headers,
           manifest_proxy, media_proxy, content_keys
```

`use_cdm` et `content_keys` existent donc bel et bien.

## Ce qui se traduit

| Legacy | o11-rebuild | Nature |
|---|---|---|
| `UseCdm` | `use_cdm` | réglage, équivalent direct |
| `Keys` (KID:KEY) | `content_keys` | **secret**, chiffré au repos |
| en-têtes de requête de clé | `key_headers` | secret |
| `ManifestProxy` / `MediaProxy` | `manifest_proxy` / `media_proxy` | secrets |

Un secret n'est pas un réglage ordinaire : il s'écrit par
`PUT /api/v1/streams/{id}/secrets/{name}`, ne se relit jamais en clair, et
n'apparaît que dans `configured_secrets` — la liste des noms renseignés.

**Conséquence pour le panel :** l'écran peut dire *qu'une* clé est en place et
permettre de la remplacer. Il ne pourra jamais la réafficher. C'est une
propriété du backend, pas une limite de l'adaptateur — et c'est un progrès sur
le legacy, qui rendait les clés en clair.

## Ce qui n'a pas d'équivalent

| Legacy | Pourquoi |
|---|---|
| `CdmType`, `CdmMode`, `CdmCert`, `ExternalCdmScript`, `DRMLevel` | o11-rebuild n'expose pas le choix d'un CDM ni son mode |
| `PRClientVersion`, `PRCustomData`, `PRLAVersion` | pas de réglages PlayReady |
| `PreProcessPssh`, `ForcePsshFromManifest` | traitement du PSSH non exposé |
| `License.Url`, `License.Params` | pas de réglage d'acquisition de licence |
| `VmxUniqueId`, `HasInternalDrm` | pas d'équivalent |
| `/provider/exportkeys`, `/provider/exportmanifestandkeys`, `/provider/pushkeys` | pas d'export ni de transfert de clés |
| `/stream/flushkeys`, `/stream/refreshkeys` | le cache de clés n'est pas pilotable |

## Ce que fait l'adaptateur

- `UseCdm` et les clés de contenu sont **traduits**.
- Les routes d'export et de transfert de clés répondent **501 avec leur
  raison**, jamais un succès vide.
- **Aucun endpoint n'est fabriqué**, aucune clé n'est inventée, et l'adaptateur
  ne déchiffre rien.

En mode legacy o11pro, tout continue comme avant : l'adaptateur n'est pas dans
le chemin.
