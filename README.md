# Panel O11

Une interface web moderne pour **deux serveurs à la fois** :

- **O11 Pro** — le panel parle directement son API. Le binaire `o11pro` n'est ni
  modifié, ni remplacé, ni reconfiguré.
- **o11-rebuild** — le panel passe par une **couche de compatibilité** qui
  traduit son API, et qui **dit ce qu'elle ne peut pas traduire** au lieu de
  faire semblant.

L'installateur reconnaît lequel des deux tourne et se configure seul.

---

## INSTALLATION

Commande standard :

```bash
curl -fsSL https://raw.githubusercontent.com/OWNER/REPO/main/install.sh | sudo sh
```

Avec `wget` :

```bash
sh -c "$(wget -O- https://raw.githubusercontent.com/OWNER/REPO/main/install.sh)"
```

Avec `fetch` (BSD) :

```bash
sh -c "$(fetch -o - https://raw.githubusercontent.com/OWNER/REPO/main/install.sh)"
```

C'est tout. L'installateur détecte le serveur — O11 Pro **ou** o11-rebuild —,
choisit un port libre, pose le panel, installe le service, le démarre et le
teste.

### Savoir ce que le panel peut faire sur CE serveur

```bash
curl -s http://<machine>:<port>/__panel/capabilities
```

Devant O11 Pro : `"upstream_kind": "o11pro"`, tout est natif.
Devant o11-rebuild : la liste des routes traduites, celle des routes sans
équivalent, et pourquoi. Les écrans concernés l'affichent aussi, en clair.

### Avec des ports imposés

Derrière un tube, les options passent après `-s --` :

```bash
curl -fsSL https://raw.githubusercontent.com/OWNER/REPO/main/install.sh | \
  sudo sh -s -- --upstream 1337 --port 8080
```

### Mise à jour

La même commande. L'installateur reconnaît une installation existante, reprend
ses réglages et annonce `mise à jour 1.0.0 → 1.1.0` :

```bash
curl -fsSL https://raw.githubusercontent.com/OWNER/REPO/main/install.sh | sudo sh
```

### Vérifier

```bash
sudo python3 /opt/o11-panel/install-panel.py --check
```

### Désinstaller

```bash
sudo python3 /opt/o11-panel/install-panel.py --uninstall
```

---

## Options

| Option | Effet |
|---|---|
| `--upstream PORT` | port d'`o11pro` ; détecté seul s'il est omis |
| `--port PORT` | port d'écoute du panel (8080 par défaut) |
| `--bind ADRESSE` | adresse d'écoute (`0.0.0.0` par défaut) |
| `--prefix CHEMIN` | répertoire d'installation (`/opt/o11-panel`) |
| `--yes` | ne pose aucune question ; prend un port libre si besoin |
| `--check` | vérifie une installation existante |
| `--uninstall` | retire le panel — `o11pro` n'est pas touché |
| `--version` | version installée et empreinte de l'archive |
| `--no-service` | dépose les fichiers sans installer de service |

---

## Ce que l'installateur ne fait jamais

Il ne touche à **rien** de ce qui appartient à O11 Pro :

- le binaire `o11pro`
- `o11.cfg`, `o11-job.cfg`, `o11-rec.cfg`
- `providers/`, `logs/`, `rec/`, `hls/`, `epg/`, `dl/`, `keys.txt`
- les enregistrements, la VOD, le guide, les données d'utilisateurs

Il ne tue jamais un processus, ne remplace jamais un service qui n'est pas le
sien, et n'ouvre jamais le port d'`o11pro`.

```
NAVIGATEUR
    │
    ▼
PANEL O11  (port 8080)
    ├── interface servie localement
    ├── /api/*      ──▶ O11PRO
    ├── /ws         ──▶ O11PRO   (temps réel)
    ├── /static/*   ──▶ O11PRO   (ressources embarquées)
    ├── /stream/*   ──▶ O11PRO   (lecture)
    ├── /replay/*   ──▶ O11PRO   (rediffusions)
    └── *.m3u, *.xml.gz ──▶ O11PRO   (listes de lecture, guide)

O11PRO reste exactement comme avant, sur son port.
```

---

## Sécurité de l'installation

L'ordre est strict, et jamais l'inverse :

```
TÉLÉCHARGEMENT  →  VÉRIFICATION SHA-256  →  EXÉCUTION
```

`install.sh` télécharge `install-panel.py` **et** son empreinte
`install-panel.py.sha256`, compare, et refuse d'exécuter un fichier dont
l'empreinte ne correspond pas :

```
Checksum verification FAILED.
Installation aborted.
```

Le fichier est déposé dans un `mktemp` et effacé par un `trap`, y compris si
l'installation échoue ou est interrompue.

Tout est servi en HTTPS. L'installateur lui-même n'a **aucune dépendance** :
`python3` et sa bibliothèque standard suffisent — jamais de `pip install`.

---

## Publier une nouvelle version

Une seule commande produit tout ce qu'un dépôt doit servir :

```bash
python3 packaging/publier.py --repo OWNER/REPO --version 1.1.0
```

Elle écrit dans `release/` :

```
install.sh                 URL et version déjà inscrites
install-panel.py           l'installateur, panel embarqué
install-panel.py.sha256    son empreinte, que install.sh vérifie
VERSION
```

L'empreinte vit **à côté** de l'installateur : publier une nouvelle version ne
demande de modifier aucun fichier à la main. L'URL de base n'existe qu'à un seul
endroit — la constante `BASE_URL` d'`install.sh`, réécrite par `publier.py`.

Il ne reste qu'à déposer le contenu de `release/` à la racine du dépôt.

---

## Les deux amonts

| | O11 Pro | o11-rebuild |
|---|---|---|
| API | 75 routes, toutes en POST | 119 routes REST sous `/api/v1/` |
| Authentification | jeton brut dans `Authorization` | session par cookie |
| Temps réel | un `/ws` avec message d'abonnement | **cinq** WebSockets |
| Le panel | relaie tel quel | traduit, et déclare ce qu'il ne traduit pas |

Devant o11-rebuild, **24 routes sont vérifiées complètes**, 15 partielles (elles
déclarent ce qu'elles ignorent), et 28 répondent **501 avec leur raison**. Le
détail mesuré est dans `docs/ADAPTER_MAP.md`.

Trois choses n'ont pas d'équivalent derrière o11-rebuild, et le panel le dit
plutôt que de les simuler : l'essentiel de l'écran **Config** (143 des 262
réglages d'O11 Pro n'existent pas), les **comptes d'opérateur** et
l'**appairage**, et les fonctions d'**export de clés**.

## Documentation

| Document | Contenu |
|---|---|
| [`docs/DIVERGENCES.md`](docs/DIVERGENCES.md) | Les 16 pièges du backend — **à lire avant de toucher au code** |
| [`FUNCTIONAL_PARITY.md`](FUNCTIONAL_PARITY.md) | Ce que l'installateur faisait avant, et fait toujours |
| [`docs/FUNCTIONAL_MATRIX.md`](docs/FUNCTIONAL_MATRIX.md) | La parité du panel avec celui d'O11 Pro |
| [`docs/DEPLOIEMENT.md`](docs/DEPLOIEMENT.md) | Servir le panel autrement (nginx, sans service) |
| [`docs/CONFIG_FIELDS.md`](docs/CONFIG_FIELDS.md) | Les 262 champs de configuration |
| [`docs/API_MAP.md`](docs/API_MAP.md) | 75 routes et 7 abonnements temps réel |
| [`docs/ROUTES_MAP.md`](docs/ROUTES_MAP.md) | Les 15 routes de l'interface |
| [`docs/REGRESSION_CHECKLIST.md`](docs/REGRESSION_CHECKLIST.md) | Ce qu'aucun `grep` ne saura dire |
| [`docs/ADAPTER_MAP.md`](docs/ADAPTER_MAP.md) | **La couche o11-rebuild, route par route, avec son état mesuré** |
| [`docs/REALTIME_MAP.md`](docs/REALTIME_MAP.md) | Le pont temps réel : cinq WebSockets vers un |
| [`docs/CONFIG_GAP.md`](docs/CONFIG_GAP.md) | Les 262 réglages face à o11-rebuild : 55 traduits, 143 absents |
| [`docs/KEYS_DRM_GAP.md`](docs/KEYS_DRM_GAP.md) | Clés, DRM et CDM : ce qui passe et ce qui ne passe pas |
| [`docs/ACCOUNTS_GAP.md`](docs/ACCOUNTS_GAP.md) | Comptes du panel, jetons de lecture, comptes d'opérateur |
