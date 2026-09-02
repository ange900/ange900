# Comptes — legacy O11 Pro face à o11-rebuild

Trois notions distinctes que le panel legacy mélange volontiers. Les séparer est
la première condition pour les traduire.

| Notion | Legacy | o11-rebuild |
|---|---|---|
| **Utilisateur du panel** | `/user/*` — `{Username, Password, IsAdmin, HasWebAccess, ProviderIds}` | `/api/v1/users` — rôles, sessions, mot de passe Argon2id |
| **Jeton de lecture** | le paramètre `p=` des URL, empreinte du mot de passe | `/api/v1/users/{id}/output-tokens` — jetons opaques révocables |
| **Compte d'opérateur (script)** | `/account/*` — 26 champs, 14 routes | secret `script_accounts` d'un provider |

## Utilisateurs du panel — traduisible

| Legacy | o11-rebuild | État |
|---|---|---|
| `/user/get` | `GET /api/v1/users` + `/auth/me` | complet |
| `/user/add` | `POST /api/v1/users` | complet |
| `/user/edit` | `PATCH /api/v1/users/{id}` | complet |
| `/user/delete` | `DELETE /api/v1/users/{id}` | complet |

Deux différences à ne pas masquer :

- **`ProviderIds` n'existe pas** dans o11-rebuild : la portée passe par le rôle.
  Le panel affichera la portée réelle, pas une liste vide qu'il faudrait
  interpréter — et surtout pas « all providers », dont j'ai déjà mesuré qu'il
  était faux côté legacy.
- **`HasWebAccess` n'a pas d'équivalent** : dans o11-rebuild, un compte qui
  existe peut se connecter.

## Jetons de lecture — meilleur qu'en legacy

Le legacy signe ses URL avec `p=`, l'empreinte du mot de passe : changer de mot
de passe casse tous les liens, et l'empreinte circule dans chaque URL.
o11-rebuild émet des **jetons opaques révocables**, indépendants du mot de
passe. L'adaptateur peut les employer pour construire les URL de lecture.

## Comptes d'opérateur — partiellement traduisible

o11-rebuild garde les comptes de script dans le **secret** `script_accounts`
d'un provider. On peut donc les écrire ; on ne peut pas les relire.

| Legacy | Traduction possible |
|---|---|
| `/account/get` | liste des noms via `configured_secrets`, **jamais les valeurs** |
| `/account/add`, `/account/edit` | écriture dans `script_accounts` |
| `/account/delete` | suppression du secret |
| `/account/export`, `/account/import` | **impossible** : un secret ne se relit pas |
| `/account/disableall`, `/account/enableall`, `/account/deletedisabled` | pas de notion d'activation |
| `/account/login` | pas de connexion d'opérateur pilotable |

## Appairage — sans équivalent

Les quatre routes `/account/pair{start,stop,status,input}` orchestrent un
appairage auprès d'un opérateur, en quatre temps. o11-rebuild n'a pas cette
mécanique : elle suppose un script provider capable de dialoguer avec
l'opérateur, ce qu'o11-rebuild ne fait pas de cette façon.

L'adaptateur répond **501 avec la raison**. Émuler un appairage laisserait un
état ouvert côté opérateur sans que personne puisse le fermer.
