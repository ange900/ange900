# LE LECTEUR — un seul, pour Linear, Events et VOD

> Écrit le 2026-09-03. Tout ce qui suit a été mesuré en cliquant sur le vrai
> panel O11 Pro, puis vérifié dans Chromium sur les deux amonts.

## 1. Ce que fait l'original — relevé, pas déduit

En cliquant réellement sur le bouton bleu d'une carte Linear du panel
d'origine, puis en lisant l'état du DOM :

| Mesure | Valeur relevée |
|---|---|
| Forme | **overlay flottant**, pas un lecteur dans la carte |
| Classes | `fixed group shadow-lg z-50 w-[16rem] lg:w-[32rem] h-fit aspect-video` |
| Position par défaut | `top-15 right-5` — 512 × 288 à `top: 60` |
| Balise | `bg-black aspect-video rounded-xl ring-1 ring-neutral-50/10` |
| `controls` | **oui** · `autoplay` **oui** · `playsinline` **oui** |
| `muted` | **non** · `poster` aucun · `loop` non |
| `src` | **`blob:`** → pipeline MSE |
| Coins | 4 boutons révélés au survol, qui déplacent l'overlay |
| Fermeture | croix `-top-2 -right-2` |
| Transition | `scale-0 → scale-100`, 200 ms |

Le bouton porteur est celui à **survol bleu** (`hover:text-blue-500`), avec le
glyphe téléviseur. Il existe sur **Linear, Events et VOD** — et sur aucune
autre carte : Recordings, EPG et Providers n'en ont pas.

**Le clic n'appelle PAS `/stream/start`.** Vérifié : après un clic TV, aucune
requête API ne part. Le lecteur ouvre une adresse, il ne démarre rien. On a
reproduit ce comportement exactement.

Sa configuration hls.js, extraite du bundle et dépouillée de l'obfuscation :

```js
{ maxBufferLength: 15, liveSyncDuration: 15, liveMaxLatencyDuration: 1/0,
  liveDurationInfinity: true, enableWorker: true, lowLatencyMode: true,
  debug: false }
```

## 2. Ce dont on s'écarte, et pourquoi

L'original a trois défauts qu'on ne recopie pas :

1. **`playStream` crée un `new Hls(...)` sans détruire le précédent.** Changer
   de chaîne laisse l'ancien moteur télécharger des segments indéfiniment.
   Ici : on détruit avant de construire, toujours.
2. **Son unique gestionnaire d'erreur appelle `swapAudioCodec()` quoi qu'il
   arrive, et n'affiche rien.** Un flux mort donne un rectangle noir muet.
   Ici : récupération bornée, puis un message qui nomme la cause.
3. **`hls.destroy()` est appelé sans vérifier qu'un moteur existe.**

Ce sont des corrections de cycle de vie, pas un redesign : l'apparence, la
géométrie et les gestes restent ceux de l'original.

## 3. La source — jamais devinée

`StreamingUrl` n'est **pas une chaîne**. Forme réelle :

```json
[{ "Url": ".../master.m3u8?u=…&p=…", "Quality": "1080p50 (…) (HLS)" },
 { "Url": ".../sondech?u=…&p=…",     "Quality": "1080p50 (…) (TS)"  }]
```

L'original prend `StreamingUrl[0].Url`. On prend l'entrée **marquée `(HLS)`** :
dans les données réelles c'est la première, mais dépendre de l'ordre c'est
dépendre de rien.

* Un `.mp4` (titres VOD) n'est pas du HLS, même quand le serveur écrit
  « (HLS) » dans sa qualité : **c'est l'adresse qui tranche**, et la balise le
  lit directement, sans hls.js.
* **VOD** : un titre porte **sa propre** `StreamingUrl`. Rien à fabriquer, et
  surtout pas un lien vers `vod.m3u`, qui est la liste du catalogue entier.
* **Events** : l'original emploie `StreamingUrl` même à l'antenne, et ne
  réserve `StreamingOnAirUrl` qu'au menu « Links ». **On s'en écarte sur
  consigne** : à l'antenne (`OnAirId` non vide) et si une adresse existe, on
  sert `StreamingOnAirUrl`. Dites-le si vous préférez le comportement d'origine.

Aucune adresse n'est construite par le panel. Celles-ci viennent du serveur,
jeton compris.

## 4. Pourquoi le lecteur d'ORIGINE reste noir sur le banc

O11 Pro écrit dans son master :

```
#EXT-X-STREAM-INF:…,RESOLUTION=1080,CODECS="avc1.64002a,mp4a"
```

`mp4a` sans son suffixe d'objet n'est pas un codec valide. Mesuré dans
Chromium :

```
MediaSource.isTypeSupported('video/mp4;codecs="avc1.64002a,mp4a")      → false
MediaSource.isTypeSupported('video/mp4;codecs="avc1.64002a,mp4a.40.2") → true
```

hls.js écarte donc tous les niveaux :

```
ERROR mediaError manifestIncompatibleCodecsError fatal=true
one or more CODECS in variant not supported: ["avc1.64002a,mp4a"]
```

Le lecteur d'origine reçoit cette erreur, appelle `swapAudioCodec()`, et
n'affiche rien : d'où le rectangle noir. **Le nôtre rejoue la playlist de
VARIANTE que le master désigne lui-même** — elle n'annonce aucun codec, le
démultiplexeur découvre les vrais, et l'image apparaît. Ce n'est pas une
adresse devinée : c'est celle du serveur, résolue comme un navigateur le ferait.

## 5. Authentification — deux mécanismes réels

| Amont | Mécanisme | Mesure |
|---|---|---|
| O11 Pro | le serveur fabrique l'adresse avec `?u=…&p=…` | rien à ajouter |
| o11-rebuild | **session** | sans cookie `401`, avec la session `200` |

o11-rebuild sert la lecture sous `/output/streams/{id}/index.m3u8`. Deux
corrections ont été nécessaires :

* la couche rendait une adresse **absolue vers l'amont** (`:8485`), donc hors
  origine du panel : le relais était court-circuité, aucun jeton n'était joint,
  et l'adresse était « exacte mais ne jouait pas ». Elle est maintenant
  **relative** ;
* le proxy relaie `/output/` en y remettant **la session de l'appelant** — la
  même chaîne d'authentification que pour `/api/`. Sans jeton : **401**. Rien
  n'est contourné, rien n'est fabriqué.

Côté navigateur, hls.js joint le jeton du panel par `xhrSetup` **et**
`fetchSetup` — hls.js 1.7 emploie le chargeur `fetch`, et n'en poser qu'un
laissait passer les requêtes sans jeton (mesuré : `auth=non`, puis 401). Le
jeton n'est joint **qu'en même origine**, n'apparaît dans aucune adresse et
n'est jamais journalisé.

## 6. Erreurs — des phrases, pas « Playback failed »

| Cause | Message |
|---|---|
| manifeste 404 | HLS manifest not found — the stream may not be running. |
| manifeste 401/403 | Playback refused by the server (authentication required). |
| manifeste illisible | HLS manifest is malformed. |
| codecs refusés | The server advertises codecs this browser cannot decode: … |
| segments taris | Stream segments stopped arriving. |
| ni MSE ni HLS natif | This browser supports neither native HLS nor Media Source Extensions. |
| rien ne démarre | The stream did not start within 25 s — it may not be running. |
| aucune adresse | No playback URL available for this item. |

Une erreur **fatale de manifeste** est définitive : `startLoad()` ne redemande
pas le manifeste, et l'appeler laissait le sablier tourner pour toujours —
défaut trouvé et corrigé. Réseau : 3 reprises. Média : 2, dont un
`swapAudioCodec` au second essai. Ensuite on arrête, et on le dit.

## 7. Support natif — pourquoi hls.js passe devant

Chromium rend `canPlayType('application/vnd.apple.mpegurl')` = **`"maybe"`**
alors qu'il ne sait pas lire du HLS. On ne traite donc comme natif que
`"probably"`. L'ordre effectif :

1. natif si **réellement** supporté (`probably`) ;
2. hls.js + MSE — le seul chemin qui marche sur Chrome, Firefox, Edge ;
3. natif en dernier recours (`maybe`, pour Safari/iOS sans MSE) ;
4. sinon, message d'incompatibilité.

## 8. Cycle de vie

À la fermeture, au changement de flux et au démontage de la vue :
`stopLoad()` → `detachMedia()` → `destroy()` → `pause()` →
`removeAttribute('src')` → **`load()`**. Le `load()` n'est pas décoratif :
sans lui Chromium garde la connexion média ouverte et continue de tirer des
octets. Un compteur de génération périme toute réponse en vol.

## 9. Ce qui a été éprouvé

```
node tests/lecteur/essai-source.mjs                     27/27
node tests/lecteur/essai-lecteur.mjs <base> <u> <p> <prov>
     devant O11 Pro        40 contrôles — 39 réussis, 1 N/A
     devant o11-rebuild    39 contrôles — 37 réussis, 2 N/A
```

Décodage réel exigé partout : `videoWidth > 0`, `readyState ≥ 2`, et un
`currentTime` qui avance.

* **Linear, O11 Pro** : 343 × 180, readyState 4, +5 s en 5 s.
* **Events, O11 Pro** : 343 × 180, lecture qui progresse.
* **Linear, o11-rebuild rc30** : 343 × 180, readyState 4, manifeste et
  segments en 200 avec la session, 401 sans.
* **20 ouvertures/fermetures** : 0 requête résiduelle, 0 exception, un seul
  lecteur, une seule balise.
* **Changement de flux** : une seule racine de segments circule.
* **Navigation** : le lecteur disparaît avec la vue, 0 requête ensuite.
* **Plein écran** : `requestFullscreen()` accepté.

### Les N/A, avec leur preuve

* **VOD, O11 Pro** : le catalogue du banc n'a qu'un titre, `SONDE-FILM-2`,
  dont la source `/stream/sonde/vod1.mp4` répond **404** — le provider affiche
  lui-même pourquoi : `Get "http://127.0.0.1:1/f.mpd": connection refused`.
  L'adresse est correcte (elle vient du titre), et le lecteur nomme l'échec.
  La **branche progressive** que ce titre emprunte est éprouvée à part, sur un
  vrai MP4 : 320 × 180, readyState 4, lecture qui avance.
* **Events et VOD, o11-rebuild** : les flux du banc s'arrêtent seuls après une
  trentaine de segments ; le manifeste n'est alors plus servi. Le lecteur
  demande la bonne adresse et annonce « Stream unavailable ».

## 10. Ce qui n'est pas fait

* **Recordings** n'a pas de bouton lecteur dans l'original : on n'en a pas
  ajouté. Le composant pourrait le servir si vous le demandez.
* Aucun sélecteur de qualité : l'original laisse hls.js en ABR automatique.
* Aucune interface audio/sous-titres : l'original n'en a pas.
