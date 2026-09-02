# Parité de l'installateur — avant / après

Le passage à une commande unique ne devait **retirer aucune fonction**. Voici
l'inventaire, dressé avant la modification et vérifié après.

Chaque ligne « après » a été constatée par une exécution réelle sur cette
machine, contre le vrai `o11pro` en bac à sable — pas par relecture du code.

| Fonction | Avant | Après |
|---|---|---|
| Installation dans `/opt/o11-panel` | OUI | **OUI** |
| Service systemd `o11-panel` | OUI | **OUI** |
| Reverse proxy sans dépendance | OUI | **OUI** |
| Détection automatique d'o11pro | OUI | **OUI** |
| Signature d'o11pro (`GET /api/login`) | OUI | **OUI** |
| Refus de deviner si plusieurs instances | OUI | **OUI** |
| `--upstream` | OUI | **OUI** |
| `--port` | OUI | **OUI** |
| `--prefix` | OUI | **OUI** |
| `--no-service` | OUI | **OUI** |
| `--check` | OUI | **OUI** |
| `--uninstall` | OUI | **OUI** |
| Idempotence | OUI | **OUI** |
| Sauvegarde `dist.precedent` | OUI | **OUI** |
| Contrôles de fonctionnement après pose | OUI | **OUI** |
| Refus du port d'o11pro | OUI | **OUI** |
| Port occupé : ne jamais tuer l'occupant | OUI | **OUI** |
| Routage API vers o11pro | OUI | **OUI** |
| Routage des écrans vers le panel | OUI | **OUI** |
| Garde-fou « ancien panel » | OUI | **OUI** |
| HTTP/1.1 correct | OUI | **OUI** |
| Keep-alive, plusieurs requêtes par connexion | OUI | **OUI** |
| Élévation WebSocket | OUI | **OUI** |
| Vérification d'empreinte de l'archive | OUI | **OUI** |
| o11pro jamais modifié | OUI | **OUI** |
| 139 contrôles navigateur | OUI | **OUI** |

## Ce qui a été ajouté

| Fonction | Avant | Après |
|---|---|---|
| `install.sh` — installation en une commande | non | **OUI** |
| Empreinte vérifiée automatiquement (fichier `.sha256` à côté) | non | **OUI** |
| curl / wget / fetch | non | **OUI** |
| Téléchargement dans `mktemp`, nettoyé par `trap` | non | **OUI** |
| `--bind` | non | **OUI** |
| `--yes` | non | **OUI** |
| `--version` (les deux scripts) | non | **OUI** |
| Version inscrite dans les journaux d'installation | non | **OUI** |
| Distinction installation / réinstallation / **mise à jour** | non | **OUI** |
| Réglages repris d'une installation précédente | non | **OUI** |
| `install-panel.py` copié dans le préfixe | non | **OUI** |
| `--check` parcourt **les 15** routes de l'interface | 2 routes | **15 routes** |
| `--check` vérifie l'état du service systemd | non | **OUI** |
| Table de routage explicite (UI / backend) | préfixes | **table** |
| En-têtes hop-by-hop retirés, le reste intact | partiel | **OUI** |
| `HEAD`, `OPTIONS`, `PUT`, `DELETE` | implicite | **explicite** |
| `Range` / `206 Partial Content` sur les fichiers du panel | non | **OUI** |
| Réponses amont en `chunked` ou sans longueur | non | **OUI** |
| Réinstallation : arrête **notre** service, jamais un autre | non | **OUI** |
| `packaging/publier.py` — une commande pour publier | non | **OUI** |

## Ce qui a été corrigé au passage

- **`install-panel.py` n'était pas copié dans le préfixe.** `--check` et
  `--uninstall` depuis `/opt/o11-panel/install-panel.py` — le chemin que la
  documentation indique — échouaient sur « fichier introuvable ».
- **Une réinstallation butait sur son propre port.** Le panel déjà en place
  occupait le port, et l'installateur refusait, croyant à un conflit. Il arrête
  désormais **son** service, et lui seul.
- **Deux appels d'API en 401 à chaque ouverture de la page de connexion.** La
  barre latérale se montait le temps d'une image, avant que la route ne soit
  résolue.

## Vérification

```
bash scripts/check-functional-parity.sh          # code + fraîcheur du paquet
node scripts/essai-panel.mjs http://127.0.0.1:<port> admin <mdp>
```

Dernier passage : **139/139** contre le service systemd réellement installé.
