# Servir le panel reconstruit

## Installation sur une autre machine

Une seule commande. Voir [`../README.md`](../README.md) pour le détail.

```bash
curl -fsSL <BASE>/install.sh | sudo sh
```

`install.sh` télécharge `install-panel.py`, **vérifie son empreinte**, puis
l'exécute — jamais l'inverse. Le paquet ne touche pas au binaire `o11pro`, ni à
`o11.cfg`, `o11-job.cfg`, `o11-rec.cfg`, ni aux dossiers de données. Toutes ses
écritures tiennent dans `/opt/o11-panel` et dans une unité systemd.

Publier une version : `python3 packaging/publier.py --repo OWNER/REPO`.

## 1. Reverse proxy — la voie retenue

Une couche devant le binaire sert le panel reconstruit et laisse tout le reste
passer. C'est ce que fait `scripts/banc-essai.mjs`, et c'est ce sur quoi les
40 contrôles de `scripts/essai-panel.mjs` ont été passés.

Le partage se fait **par l'extension**, pas par le préfixe — et ce détail n'est
pas facultatif :

| Va au binaire | Va au panel |
|---|---|
| `/api/**`, `/ws`, `/logos/**` | `/` et toutes les routes de l'interface |
| `/static/**` (ressources embarquées) | `/static/assets/**` (le panel lui-même) |
| tout ce qui porte une extension : `.m3u`, `.conf`, `.xml`, `.gz`, `.ts`, `.py`, `.svg`… | le reste |

**Le piège :** les listes de lecture s'appellent `/linear.m3u`, `/event.m3u`,
`/vod.m3u`, et les routes de l'interface s'appellent `/linear/:provider?`,
`/events/:provider?`, `/vod/:provider?`. Router sur le seul préfixe envoie
l'écran Linear au binaire, qui répond avec **son** panel — on croit alors tester
le nouveau et on regarde l'ancien. C'est arrivé pendant ce chantier, et ça n'a
été vu que sur une capture d'écran.

Équivalent nginx :

```nginx
location /static/assets/ { root /chemin/vers/frontend-modern/dist; }
location ~ ^/(api|ws|logos|static)/ { proxy_pass http://127.0.0.1:1337; }
location ~ \.(m3u|m3u8|conf|xml|gz|ts|mp4|py|svg|png|ico|ttf)$ { proxy_pass http://127.0.0.1:1337; }
location / { root /chemin/vers/frontend-modern/dist; try_files $uri /index.html; }
```

Le WebSocket exige les en-têtes d'élévation habituels (`Upgrade`, `Connection`)
sur `/ws`. Sans eux, tout le temps réel du panel est muet — et muet sans erreur.

## 2. Dossier de ressources configurable

Le binaire accepte `-path` (répertoire de travail). Il ne prévoit rien pour
servir un dossier de ressources externe à la place de ses ressources
embarquées : cette voie demanderait une option qui n'existe pas.

## 3. Patch du binaire — non fait, et déconseillé

Les ressources sont stockées **en clair** dans le rodata, à des offsets connus
(voir [`ORIGINAL_FRONTEND_INVENTORY.md`](ORIGINAL_FRONTEND_INVENTORY.md)). On
pourrait donc y réécrire des octets.

On ne l'a pas fait, pour une raison mécanique et pas seulement par prudence : la
table de noms d'un `embed.FS` Go porte les **longueurs** des ressources. Le
bundle reconstruit fait 133 ko là où l'original en fait 1 454 ko. Écrire une
ressource de taille différente sans reconstruire la table produit un binaire qui
démarre et sert des octets tronqués — la pire des pannes, parce qu'elle
ressemble à un problème de réseau.

Le proxy obtient le même résultat sans toucher un octet, et se défait en
supprimant une ligne de configuration.

## Construire

```bash
cd frontend-modern
npm install          # ou : ln -s <node_modules existant> node_modules
npx vite build       # produit dist/
```

Sortie : ~133 ko de JavaScript (49 ko gzippés) contre 3 376 ko pour les deux
bundles d'origine.

## Essayer

```bash
# 1. le binaire d'origine, en bac à sable, sur un port jetable
bash run/lancer.sh

# 2. le panel devant lui
node scripts/banc-essai.mjs frontend-modern/dist 8391 8392

# 3. les contrôles, dans un vrai navigateur (le décor est semé automatiquement)
node scripts/essai-panel.mjs http://127.0.0.1:8392 admin <mot-de-passe>

#    — ou seulement remettre le décor d'aplomb :
node scripts/semer-sonde.mjs 8391

# 4. la parité fonctionnelle, sur le code
bash scripts/check-functional-parity.sh
```
