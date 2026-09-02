# Liste de contrôle des régressions — reconstruction du panel O11 Pro

À dérouler **sur une installation réelle**, panel reconstruit branché sur le
même binaire `o11pro` que le panel d'origine. Une case cochée veut dire :
« constaté de mes yeux, pas déduit ».

Le contrôle mécanique (`scripts/check-functional-parity.sh`) vérifie qu'aucun
point n'a disparu du **code**. Cette liste-ci vérifie qu'il n'a pas disparu du
**comportement** — ce qu'aucun `grep` ne saura dire.

## Avant de commencer

- [ ] `sha256sum o11pro.original` répond
      `adaa54924ed57fa13994ba50c11217a5e58d9154966efcb9ee7f31c956e346e5`
- [ ] `bash scripts/check-functional-parity.sh` sort en 0
- [ ] Le binaire d'origine tourne toujours, non modifié, non patché
- [ ] Une sauvegarde des `.cfg` existe (`o11.cfg`, `o11-job.cfg`, `o11-rec.cfg`)
- [ ] Les deux panels — origine et reconstruit — sont ouverts côte à côte

## 1. Transport et session

- [ ] La connexion renvoie un JWT, et il est rangé dans `localStorage["o11-token"]`
- [ ] Un appel d'API part en **POST**, jamais en GET
- [ ] L'en-tête est `Authorization: <jeton>` — **sans** `Bearer`
- [ ] En mode distant, le jeton est rangé dans `o11-token-remote`, pas dans `o11-token`
- [ ] Les réponses gzippées sont lues correctement (le serveur compresse sans négocier)
- [ ] Une erreur backend `{Code, Message}` s'affiche telle quelle, sans reformulation
- [ ] Un jeton expiré ramène à `/login` sans boucle de redirection

## 2. Navigation

- [ ] `/` redirige vers `/providers`
- [ ] Sans session, toute route redirige vers `/login`
- [ ] Avec session, `/login` redirige vers `/providers`
- [ ] Le titre de l'onglet suit `meta.title` de la route
- [ ] `/login` s'ouvre et affiche des données réelles
- [ ] `/servers` s'ouvre et affiche des données réelles
- [ ] `/search` s'ouvre et affiche des données réelles
- [ ] `/linear/:provider?` s'ouvre et affiche des données réelles
- [ ] `/providers` s'ouvre et affiche des données réelles
- [ ] `/provider/:provider?/:type?/config` s'ouvre et affiche des données réelles
- [ ] `/events/:provider?` s'ouvre et affiche des données réelles
- [ ] `/vod/:provider?` s'ouvre et affiche des données réelles
- [ ] `/monitoring` s'ouvre et affiche des données réelles
- [ ] `/logs/:provider?/:stream?` s'ouvre et affiche des données réelles
- [ ] `/epg/:provider?/:stream?` s'ouvre et affiche des données réelles
- [ ] `/recordings/:provider?` s'ouvre et affiche des données réelles
- [ ] `/users` s'ouvre et affiche des données réelles
- [ ] `/help` s'ouvre et affiche des données réelles
- [ ] `/jobs` s'ouvre et affiche des données réelles

## 3. Paramètres d'URL et chaînes de requête

- [ ] `/linear/mon-provider` ouvre bien Linear filtré sur ce provider
- [ ] `/logs/mon-provider/mon-flux` préfiltre les journaux
- [ ] `/provider/mon-provider/channel/config` ouvre la config du bon type
- [ ] `/search?s=terme` reprend le terme dans le champ de recherche
- [ ] `/servers?server=id` sélectionne le bon serveur distant

## 4. Temps réel (WebSocket) — le plus facile à perdre sans s'en apercevoir

- [ ] Une seule connexion `ws(s)://<hôte>/ws?token=<JWT>` est ouverte
- [ ] `wss` est employé quand la page est en HTTPS, `ws` sinon
- [ ] `Action: streamstatus` — l'état d'un flux change **sans recharger la page**
- [ ] `Action: monitoring` — l'écran Monitoring se met à jour tout seul
- [ ] `Action: logs` — les journaux défilent en direct
- [ ] `Action: recordingget` — un enregistrement en cours avance tout seul
- [ ] `Action: replayget` — les rediffusions apparaissent seules
- [ ] `Action: eventget` — la grille des événements se met à jour seule
- [ ] `Action: jobget` — le résultat d'une tâche remonte seul
- [ ] Changer d'écran ferme l'ancien canal (`closeWsClient`) : pas de fuite
- [ ] Le filtre `SearchPattern` / `SortAlpha` est bien transmis à l'abonnement

## 5. Actions destructives — à faire sur une installation jetable

- [ ] Suppression d'un provider : confirmation demandée, puis disparition réelle
- [ ] Suppression d'un flux, d'un utilisateur, d'un compte, d'une tâche, d'un serveur
- [ ] `/account/disableall`, `/account/enableall`, `/account/deletedisabled`
- [ ] `/log/clean` vide bien les journaux
- [ ] `/stream/flushkeys` et `/provider/pushkeys`
- [ ] `/shutdown` arrête le serveur (dernier test de la série, forcément)

## 6. Import / export — le format doit être identique à l'octet près

- [ ] `provider/export` puis `provider/import` : aller-retour sans perte
- [ ] `account/export` puis `account/import` : idem
- [ ] `provider/exportkeys` et `provider/exportmanifestandkeys` produisent les
      mêmes fichiers que le panel d'origine
- [ ] `provider/backup` produit une sauvegarde exploitable

## 7. Configuration

- [ ] Les **301 champs** sont présents, et au même endroit qu'avant
- [ ] Une case à cocher laissée intacte n'est pas envoyée transformée
- [ ] Un champ réseau vide sur un flux **hérite** du provider (il n'est pas forcé à `same`)
- [ ] `log/setconf` envoie `LogFilter` / `HighlightLogFilter` — **pas** les noms
      renvoyés par `log/getconf`
- [ ] La mise à jour de masse liste les options venues de `/bootstrap`, pas une
      liste écrite en dur
- [ ] Les réglages DRM / CDM (`UseCdm`, `CdmType`, `CdmMode`, `CdmCert`,
      `ExternalCdmScript`, `DRMLevel`, `PreProcessPssh`, `ForcePsshFromManifest`)
      sont **transmis inchangés** au backend

## 8. Préférences persistées

- [ ] Le mode d'affichage (`grid` / liste) tient au rechargement, écran par écran
- [ ] Le tri tient au rechargement sur Linear, VOD et Monitoring
- [ ] Les préférences d'origine (`o11-preferences-view`, `o11-preferences-sort`)
      sont **relues**, pas écrasées, à la première ouverture du panel reconstruit

## 9. Lecture et médias

- [ ] `StreamPlayer` lit un flux HLS
- [ ] `Mp4VideoPlayer` lit un enregistrement et une VOD
- [ ] Les liens M3U générés (`OutputM3uLinksGlobal`, `OutputLinksM3us`) sont
      identiques à ceux du panel d'origine
- [ ] Le logo de repli s'affiche quand `LogoUrl` est vide

## 10. Routes d'API — chacune déclenchée au moins une fois

- [ ] `/account/add`
- [ ] `/account/delete`
- [ ] `/account/deletedisabled`
- [ ] `/account/disableall`
- [ ] `/account/edit`
- [ ] `/account/enableall`
- [ ] `/account/export`
- [ ] `/account/get`
- [ ] `/account/import`
- [ ] `/account/login`
- [ ] `/account/pairinput`
- [ ] `/account/pairstart`
- [ ] `/account/pairstatus`
- [ ] `/account/pairstop`
- [ ] `/bootstrap`
- [ ] `/channel/refreshapply`
- [ ] `/channel/refreshrequest`
- [ ] `/epg/get`
- [ ] `/epg/refresh`
- [ ] `/epg/refreshapply`
- [ ] `/epg/refreshrequest`
- [ ] `/event/refreshapply`
- [ ] `/event/refreshrequest`
- [ ] `/job/add`
- [ ] `/job/delete`
- [ ] `/job/edit`
- [ ] `/job/run`
- [ ] `/log/clean`
- [ ] `/log/export`
- [ ] `/log/get`
- [ ] `/log/getconf`
- [ ] `/log/setconf`
- [ ] `/login`
- [ ] `/provider/add`
- [ ] `/provider/backup`
- [ ] `/provider/cachelogos`
- [ ] `/provider/delete`
- [ ] `/provider/edit`
- [ ] `/provider/export`
- [ ] `/provider/exportkeys`
- [ ] `/provider/exportmanifestandkeys`
- [ ] `/provider/get`
- [ ] `/provider/import`
- [ ] `/provider/massupdate`
- [ ] `/provider/pushkeys`
- [ ] `/provider/rescan`
- [ ] `/recording/add`
- [ ] `/recording/delete`
- [ ] `/recording/edit`
- [ ] `/recording/get`
- [ ] `/recording/stop`
- [ ] `/replay/delete`
- [ ] `/server/add`
- [ ] `/server/delete`
- [ ] `/server/edit`
- [ ] `/server/get`
- [ ] `/server/getinfo`
- [ ] `/shutdown`
- [ ] `/stream/add`
- [ ] `/stream/delete`
- [ ] `/stream/edit`
- [ ] `/stream/flushkeys`
- [ ] `/stream/get`
- [ ] `/stream/refresh`
- [ ] `/stream/refreshkeys`
- [ ] `/stream/start`
- [ ] `/stream/status`
- [ ] `/stream/stop`
- [ ] `/stream/stoprefresh`
- [ ] `/user/add`
- [ ] `/user/delete`
- [ ] `/user/edit`
- [ ] `/user/get`
- [ ] `/vod/refreshapply`
- [ ] `/vod/refreshrequest`

## 11. Les seize pièges du backend — chacun se vérifie à l'œil

Le détail est dans [`DIVERGENCES.md`](DIVERGENCES.md). Ils ne produisent
aucune erreur : il faut les regarder.

- [ ] Modifier un champ ENTIER (par ex. « HTTP get timeout »), enregistrer,
      **recharger** : la nouvelle valeur est toujours là. Si elle est revenue à
      l'ancienne, le panel envoie une chaîne au lieu d'un nombre.
- [ ] L'écran Linear affiche des chaînes. S'il est vide alors que le provider en
      a, `StreamType` part probablement à `channel` au lieu de `linear`.
- [ ] Le rafraîchissement Linear atteint bien `/channel/refreshrequest`
      (à vérifier dans l'onglet réseau du navigateur).
- [ ] L'état des enregistrements remonte — le type envoyé est `linear,event`.
- [ ] Renommer un provider **sans** choisir de logo : le logo en place est
      conservé, pas effacé.
- [ ] Le Monitoring se remplit : si l'écran reste vide, les trames gzippées ne
      sont pas décompressées.
- [ ] Les journaux DÉFILENT et s'accumulent ; ils ne se remplacent pas ligne
      à ligne.
- [ ] L'écran Journaux ouvert sans flux désigné n'affiche pas
      « 404 stream not found ».
- [ ] Le bouton **Play** d'une chaîne ouvre le lecteur sur une adresse `http…`,
      pas sur `[object Object]` : `StreamingUrl` est une liste d'objets.
- [ ] Le menu **Links** d'une chaîne liste **toutes** ses variantes (HLS et TS),
      chacune avec son étiquette de qualité.
- [ ] L'écran Config montre les **trois familles** d'en-têtes — Manifest, Media,
      HLS key — et non trois lignes nommées d'après elles.
- [ ] **Aucun écran n'affiche `[object Object]`.** C'est la trace d'une
      structure imbriquée traitée comme une valeur simple.
- [ ] La section **Runtime** d'un flux montre `License`, `Heartbeat`,
      `DRM detected` et `Manifest analysis` — **sans aucun champ de saisie**.
      `/stream/edit` répond « success » pour ces champs et n'enregistre rien.
- [ ] L'écran **Events** montre des événements quand le provider en a. Un écran
      vide peut cacher une clé de trame erronée (`Entries`, pas `Events`) : le
      symptôme est identique à un provider sans événement.
- [ ] Les horaires d'un événement viennent de `StartFmt`/`EndFmt`, et le fuseau
      employé par le serveur est affiché à côté.
- [ ] Un événement **à l'antenne** se lit via `StreamingOnAirUrl`.
- [ ] Un flux au repos affiche une pastille bleue (`LightSteelBlue`), pas la
      couleur par défaut.
- [ ] Les cartes **Linear** et **VOD** portent des champs de CONFIGURATION —
      catégorie, autostart, CDM, description. S'ils manquent, l'écran s'est
      abonné à l'état sans charger la configuration : la trame de statut ne
      partage que **8 champs sur 92**.
- [ ] L'écran Config ne propose **aucun champ de saisie** pour `Category`,
      `Description` et `Cdn Name` : `/stream/edit` les accepte et ne les
      enregistre pas.
- [ ] **Monitoring** montre débit entrant, débit sortant, charge CPU, mémoire et
      la table des lecteurs. Il n'a AUCUNE route HTTP : un écran vide veut dire
      que le canal n'est pas ouvert.
- [ ] **Jobs** liste les tâches : elles arrivent par WebSocket, pas par HTTP.
- [ ] **Jobs** : « Run » sur une tâche fait apparaître son résultat et sa date
      **sans recharger**. Le nom du script s'écrit **sans extension** —
      « sonde », pas « sonde.py » : avec l'extension, `/job/run` répond
      « success » et la tâche ne s'exécute jamais.
- [ ] **Users** n'affiche jamais `AuthToken`, et **Servers** jamais le mot de
      passe — les deux sont pourtant dans la charge de l'API.
- [ ] **Users** : un compte sans provider coché est signalé comme ne voyant
      RIEN — jamais « all providers ». Le vérifier en ouvrant une session avec
      ce compte : il doit tomber sur une liste vide.
- [ ] **Users** : un compte sans accès web porte un avertissement visible.
- [ ] **Servers** : le bouton d'arrêt **nomme la machine** qu'il va éteindre, et
      la confirmation répète son adresse. `/shutdown` vise le serveur COURANT,
      pas celui qu'on choisit dans la liste.
- [ ] **Servers** : « Info » sur un serveur non connecté prévient que les
      chiffres décrivent un autre serveur — le binaire ignore l'`Id` demandé.
- [ ] **Servers** : le serveur auquel le panel parle porte la marque
      « connected », et son bouton « Connect » est inactif.
- [ ] **Events / Replays** : une rediffusion est nommée par `EventName` et son
      provider, avec un créneau formaté par le serveur, et se lit sur une
      adresse `/replay/…`. Une carte vide signale des champs d'événement lus à
      la place des siens.
- [ ] **Logs** défile en direct, coloré par niveau, sans séquence ANSI visible.
      Un flux qui diffuse SANS incident n'écrit rien : c'est le journal global
      qu'il faut regarder, ou provoquer une erreur.
      La route HTTP `/log/get` renvoie du vide même quand le fichier existe :
      c'est le WebSocket qui sert l'écran.
- [ ] **EPG** : « Play » sur un programme ouvre le lecteur sur une adresse
      `http…`. L'entrée du guide n'en porte pas : elle est résolue par
      `StreamId`. Un bouton actif qui n'ouvre rien signale une résolution
      manquante.
- [ ] **EPG** : « Record » sur un programme crée un enregistrement **avec son
      titre et son créneau**. La charge est PLATE et exige `StreamId` de
      l'entrée : enveloppée, elle est acceptée et vidée de tous ses champs.
- [ ] **Recordings** : une capture sans titre est nommée par sa chaîne, jamais
      par son identifiant, et un créneau absent affiche « not scheduled » —
      jamais une date de 1970.
- [ ] **Recordings** : une capture EN COURS affiche « until <fin> », pas
      « not scheduled » — le binaire efface `Start` au démarrage.
- [ ] **Recordings** : modifier une capture avertit honnêtement que le serveur
      n'enregistre rien sur ce build.
- [ ] **Search** : ouvrir `/search?s=<terme>` montre le terme DANS le champ. Un
      champ vide devant des résultats filtrés rend un lien partagé
      incompréhensible.
- [ ] Une pastille d'état contenant un message d'erreur entier reste bornée et
      ne recouvre pas les colonnes voisines ; le texte complet est dans
      l'infobulle et derrière « ⋯ ».
- [ ] **Le test qui compte.** Ouvrir un flux dans Config, vérifier que son
      manifeste, `Cdm Type` et `Autostart` sont renseignés, **enregistrer sans
      rien changer**, puis rouvrir : tout doit être intact. La trame de statut
      ne porte que 27 champs sur 92 ; un formulaire alimenté depuis elle
      enverrait 84 réglages vides.

## 12. Le cas connu, à ne pas « réparer »

- [ ] `log/export` répond `404 invalid action` — **comme sur le panel
      d'origine**. Le comportement est reproduit à l'identique : ni masqué, ni
      corrigé, ni supprimé.
