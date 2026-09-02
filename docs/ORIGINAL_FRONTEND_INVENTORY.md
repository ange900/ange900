# Inventaire du frontend embarqué — O11 Pro

Relevé le 2026-09-02 sur le binaire `o11pro` (ELF 64 bits, strippé,
37 923 032 octets, SHA-256 `adaa54924ed57fa13994ba50c11217a5e58d9154966efcb9ee7f31c956e346e5`).

## Comment ces fichiers ont été obtenus

Le binaire n'a **jamais** été modifié. Il a été copié en `o11pro.original`
(lecture seule), puis **exécuté en bac à sable** sur un port jetable, dans un
dossier de travail créé pour l'occasion — c'est lui qui a servi ses propres
ressources en HTTP. Deux fichiers que le serveur ne publie pas
(`static/font.ttf`, `templates/publicepg.html`) ont été découpés directement
dans le rodata, à leur signature.

Chaque octet extrait a ensuite été **recherché dans le binaire** : les 18
ressources s'y retrouvent en clair, à l'offset indiqué. C'est la preuve qu'on
tient la ressource embarquée, et non une transformation.

Le serveur renvoie les `static/*` **compressés en gzip** ; les tailles
ci-dessous sont celles du contenu décompressé, tel qu'il est stocké.

## Les 18 ressources

| Chemin | Taille | Offset | SHA-256 | Rôle |
|---|---:|---|---|---|
| `static/apple-touch-icon.png` | 1 906 | `0x15aa6e0` | `17f4da46c89840fd…` | Icône iOS. |
| `static/base.css` | 2 067 | `0x15aae60` | `fd754322b18762fb…` | Styles de base servis à part. |
| `static/default_logo.png` | 4 788 | `0x15ac440` | `1159006ebceeb9de…` | Logo de repli d'une chaîne sans logo. |
| `static/example.py` | 11 051 | `0x15b80e0` | `db197939681a4d8c…` | Script provider d'exemple, documenté. |
| `static/favicon-16x16.png` | 578 | `0x15a8d8b` | `b03950fbf525c865…` | Favicon 16. |
| `static/favicon-32x32.png` | 833 | `0x15a95bc` | `d73e17ed10f421f4…` | Favicon 32. |
| `static/favicon.ico` | 15 086 | `0x15bac20` | `f9888da4a8e10a3c…` | Favicon multi-tailles. |
| `static/font.ttf` | 317 968 | `0x15ff000` | `5f865ddf37549ae4…` | Police embarquée, TrueType 18 tables. |
| `static/index-BX-yLeHZ.js` | 1 454 472 | `0x164ca20` | `c998583df9078106…` | Bundle applicatif — **obfusqué**. C'est tout le panel : vues, routeur, appels API, WebSocket. |
| `static/index-Bj6KzdKF.css` | 96 560 | `0x15e76c0` | `52aff8679c2a4c70…` | Feuille de style du panel, générée (couches `@layer`). |
| `static/o11-logo-white-transparent-no-slogan.svg` | 7 403 | `0x15b4680` | `7272e844dfe64012…` | Logo o11 sans slogan. |
| `static/o11-logo-white-transparent.svg` | 16 283 | `0x15be720` | `6447403e0f3a1253…` | Logo o11 avec slogan. |
| `static/o11-placeholder.svg` | 805 | `0x15a9297` | `aa8f03d6d9e320e7…` | Vignette de remplacement. |
| `static/o11.py` | 24 619 | `0x15cbe80` | `5924132acf780cd4…` | SDK Python des scripts providers. Servi au navigateur avec `?token=`. |
| `static/safari-pinned-tab.svg` | 3 502 | `0x15ab680` | `a8c68f13d2046ae6…` | Icône d'onglet épinglé Safari. |
| `static/vendor-modules-BcUHiSD3.js` | 1 921 794 | `0x17afbc0` | `9031aeb96818528a…` | Dépendances : Vue 3, hls.js et les bibliothèques tierces. |
| `templates/index.html` | 529 | `0x15a8b7a` | `8b50949bc97b7752…` | Coquille de la SPA. Référence les trois bundles ; le corps est un seul `<div id="app">`. |
| `templates/publicepg.html` | 1 170 | `0x15a9d20` | `7394e13acae65be3…` | Gabarit Go du guide EPG public : table des programmes, variables `{{.Timezone}}` et `{{.Entries}}`. |

**Total : 18 fichiers, 3 881 414 octets.**

## Références croisées

`templates/index.html` référence exactement trois ressources :

    /static/index-BX-yLeHZ.js          (module ES)
    /static/vendor-modules-BcUHiSD3.js (modulepreload)
    /static/index-Bj6KzdKF.css         (feuille de style)

Les autres — favicons, logos, police, `o11.py`, `example.py` — sont demandées
par le bundle applicatif ou par le navigateur, pas par la coquille.

## Ce que l'analyse a établi

- **Le bundle applicatif est obfusqué.** `index-BX-yLeHZ.js` commence par
  `(function(_0x5c98df,_0x3f8137){…}` : symboles renommés, chaînes déportées
  dans un tableau et décalées. Aucune source map n'existe dans le binaire.
  Reconstruire ce panel ne consiste donc pas à reformater du code lisible :
  il faut rétablir le sens à partir d'un code rendu illisible volontairement.
- **L'authentification** passe par `Authorization: <jeton>` — le JWT brut,
  **sans** préfixe `Bearer` — ou par `?token=<jeton>` en query. Les deux ont
  été vérifiées ; `Bearer <jeton>` est refusé (401).
- **Toute l'API est en POST.** Un GET sur une route d'API répond
  `403 method not supported`, y compris sur une route qui n'existe pas : un
  code HTTP ne suffit donc pas à énumérer la surface.
- **Le serveur renvoie la coquille SPA pour tout chemin inconnu** (529 octets,
  HTTP 200). C'est ce qui a fait croire, au premier passage, que `font.ttf` et
  `publicepg.html` étaient servis.
