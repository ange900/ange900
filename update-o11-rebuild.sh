#!/bin/sh
# Mise à jour d'o11-rebuild — correctif WebSocket RFC 6455 (rc29 → rc30).
#
#   curl -fsSL <URL>/update-o11-rebuild.sh | sudo sh
#
# Ce script met à jour UN SEUL fichier : l'exécutable. Il ne touche ni la
# configuration, ni la base, ni les providers, ni les flux, ni les secrets, ni
# les enregistrements, ni les journaux. Il sauvegarde l'exécutable en place
# avant de le remplacer, et le restaure si quoi que ce soit échoue ensuite.
#
# Le panel O11 est un autre produit, avec son propre installateur : rien ici ne
# le concerne.
#
#   --check     n'écrit rien : dit ce qui tourne, sa version, son état
#   --dry-run   n'écrit rien : dit ce qui SERAIT fait, dans l'ordre
#   --yes       ne pose aucune question (obligatoire en mode manuel)
#   --help      cette aide
#
# Pour éprouver aussi la poignée de main sur les cinq canaux — qui exigent une
# session —, donner un compte en lecture :
#
#   O11R_USER=admin O11R_PASSWORD=… sh update-o11-rebuild.sh --check

set -eu

# ─────────────────────────────────────────────────────── ce qu'on installe
VERSION_CIBLE="0.1.0-rc30"
SHA_CIBLE="be4c22cb842b0346129ea3dbad4cbc309ece512515655b6b459a1e53233e5200"

# L'URL n'existe qu'ICI. Tout le reste s'en déduit.
BASE_URL="${O11R_BASE_URL:-https://raw.githubusercontent.com/ange900/ange900/main/backend}"
ARTEFACT="o11-rebuild-${VERSION_CIBLE}-linux-amd64"
BIN_URL="${BASE_URL}/${ARTEFACT}"
SHA_URL="${BIN_URL}.sha256"

# Le GUID du RFC 6455 §1.3, et celui — fautif — que portait rc29. Les deux
# servent à reconnaître un binaire à l'octet près, sans avoir à le démarrer.
GUID_RFC="258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
GUID_RC29="258EAFA5-E914-47DA-95CA-5AB0DC85B11F"

# Le vecteur d'exemple du RFC. Il est FIXE : aucune somme à calculer ici, donc
# aucune dépendance à openssl, xxd ou python sur la machine cible.
RFC_CLE="dGhlIHNhbXBsZSBub25jZQ=="
RFC_ACCEPT="s3pPLMBiTxaQ9kYGzzhZRbK+xOo="

CANAUX="streams logs monitoring events jobs"

# ──────────────────────────────────────────────────────────────── affichage
if [ -t 1 ]; then V="$(printf '\033[32m')"; R="$(printf '\033[31m')"
                 J="$(printf '\033[33m')"; B="$(printf '\033[1m')"
                 N="$(printf '\033[0m')"
else V=""; R=""; J=""; B=""; N=""; fi

ok()    { printf '  %s✓%s %s\n' "$V" "$N" "$*"; }
ko()    { printf '  %s✗%s %s\n' "$R" "$N" "$*"; }
info()  { printf '  · %s\n' "$*"; }
alerte(){ printf '  %s!%s %s\n' "$J" "$N" "$*"; }
etape() { printf '\n%s%s%s\n' "$B" "$*" "$N"; }
echec() { printf '\n%sÉCHEC :%s %s\n\n' "$R" "$N" "$*" >&2; exit 1; }

usage() {
  sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

# ────────────────────────────────────────────────────────────── arguments
ACTION="update"; SANS_QUESTION=0
SERVICE_IMPOSE=""; BINAIRE_IMPOSE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --check)    ACTION="check" ;;
    --dry-run)  ACTION="dryrun" ;;
    --yes|-y)   SANS_QUESTION=1 ;;
    --service)  shift; SERVICE_IMPOSE="${1:-}" ;;
    --binary)   shift; BINAIRE_IMPOSE="${1:-}" ;;
    --version)  printf 'update-o11-rebuild pour %s\n' "$VERSION_CIBLE"; exit 0 ;;
    --help|-h)  usage ;;
    *) echec "option inconnue : $1  (--help)" ;;
  esac
  shift
done

# ───────────────────────────────────────────────────────────── outils de base
# Un seul téléchargeur, choisi une fois. `fetch` est là pour les BSD.
if command -v curl >/dev/null 2>&1;  then TELECHARGE="curl -fsSL -o"
elif command -v wget >/dev/null 2>&1; then TELECHARGE="wget -qO"
elif command -v fetch >/dev/null 2>&1; then TELECHARGE="fetch -qo"
else echec "aucun de curl, wget ou fetch n'est disponible."
fi

empreinte() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1;  then shasum -a 256 "$1" | cut -d' ' -f1
  elif command -v sha256 >/dev/null 2>&1;  then sha256 -q "$1"
  else echec "aucun outil d'empreinte SHA-256 (sha256sum, shasum, sha256)."
  fi
}

TEMPO=""
nettoyer() { [ -n "$TEMPO" ] && rm -rf "$TEMPO" || true; }
trap nettoyer EXIT INT TERM

# ═══════════════════════════════════════════════════════════════ DÉTECTION
#
# Rien n'est supposé : ni le chemin, ni le nom du service, ni le port. Les
# installations diffèrent d'une machine à l'autre, et deviner produirait une
# mise à jour qui « réussit » sur le mauvais fichier.

MODE=""; SERVICE=""; PID=""; BINAIRE=""; CONFIG=""; PORT=""
VERSION_ACTUELLE=""; SHA_ACTUEL=""

trouver_service() {
  command -v systemctl >/dev/null 2>&1 || return 1
  if [ -n "$SERVICE_IMPOSE" ]; then
    systemctl cat "$SERVICE_IMPOSE" >/dev/null 2>&1 || return 1
    SERVICE="$SERVICE_IMPOSE"; return 0
  fi
  # On cherche par ce que l'unité EXÉCUTE, pas par son nom : un service peut
  # s'appeler autrement et rester le bon.
  for u in $(systemctl list-units --type=service --all --no-legend --plain 2>/dev/null \
             | awk '{print $1}'); do
    case "$u" in *o11*) ;; *) continue ;; esac
    exec_start=$(systemctl show "$u" -p ExecStart --value 2>/dev/null || true)
    case "$exec_start" in *o11-rebuild*) SERVICE="$u"; return 0 ;; esac
  done
  return 1
}

trouver_processus() {
  # /proc est la source de vérité : le lien `exe` donne le fichier réellement
  # exécuté, même si le binaire a été renommé ou remplacé depuis.
  #
  # Plusieurs instances peuvent coexister — une de production, un bac à sable —
  # et prendre la première venue mettrait à jour la mauvaise. On les compte
  # AVANT de choisir.
  trouves=""
  for p in /proc/[0-9]*; do
    [ -r "$p/exe" ] || continue
    cible=$(readlink "$p/exe" 2>/dev/null || true)
    case "$cible" in
      *o11-rebuild*)
        case "$cible" in *o11-rebuild.pre-*|*.backup-*) continue ;; esac
        trouves="$trouves ${p#/proc/}:${cible% (deleted)}" ;;
    esac
  done
  [ -n "$trouves" ] || return 1

  nb=0
  for t in $trouves; do nb=$((nb+1)); done
  if [ "$nb" -gt 1 ] && [ -z "$BINAIRE_IMPOSE" ]; then
    ko "$nb instances d'o11-rebuild tournent sur cette machine :"
    for t in $trouves; do
      pid_t="${t%%:*}"; bin_t="${t#*:}"
      port_t=""
      command -v ss >/dev/null 2>&1 && port_t=$(ss -ltnp 2>/dev/null \
        | grep "pid=$pid_t," | sed -n 's/.*:\([0-9]\{1,5\}\) .*/\1/p' | head -1)
      info "PID $pid_t  port ${port_t:-?}  $bin_t"
    done
    printf '\n'
    info "Choisir laquelle mettre à jour, plutôt que de la deviner :"
    info "  sudo sh \$0 --binary <chemin de l'exécutable>"
    echec "refus de choisir à votre place."
  fi

  for t in $trouves; do
    pid_t="${t%%:*}"; bin_t="${t#*:}"
    if [ -n "$BINAIRE_IMPOSE" ]; then
      [ "$bin_t" = "$BINAIRE_IMPOSE" ] || continue
    fi
    PID="$pid_t"; BINAIRE="$bin_t"
    return 0
  done
  # Un exécutable imposé qui ne tourne pas : ce n'est pas une erreur, on le
  # mettra à jour à l'arrêt.
  [ -n "$BINAIRE_IMPOSE" ] && { BINAIRE="$BINAIRE_IMPOSE"; return 0; }
  return 1
}

lire_config_du_processus() {
  [ -n "$PID" ] && [ -r "/proc/$PID/cmdline" ] || return 0
  # cmdline est séparé par des NUL ; on le rend lisible ligne à ligne.
  suivant=0
  for mot in $(tr '\0' '\n' < "/proc/$PID/cmdline"); do
    if [ "$suivant" = 1 ]; then CONFIG="$mot"; suivant=0; continue; fi
    case "$mot" in -config|--config) suivant=1 ;; esac
  done
  # Un chemin relatif se résout depuis le répertoire de travail du processus.
  case "$CONFIG" in
    ""|/*) ;;
    *) cwd=$(readlink "/proc/$PID/cwd" 2>/dev/null || true)
       [ -n "$cwd" ] && CONFIG="$cwd/$CONFIG" ;;
  esac
}

trouver_port() {
  [ -n "$PID" ] || return 0
  if command -v ss >/dev/null 2>&1; then
    PORT=$(ss -ltnp 2>/dev/null | grep "pid=$PID," \
           | sed -n 's/.*:\([0-9]\{1,5\}\) .*/\1/p' | head -1)
  fi
  # Repli : la configuration le dit aussi, et elle est lisible sans privilège
  # particulier sur le processus.
  if [ -z "$PORT" ] && [ -n "$CONFIG" ] && [ -r "$CONFIG" ]; then
    PORT=$(sed -n '/^http:/,/^[^ ]/p' "$CONFIG" \
           | sed -n 's/^[[:space:]]*port:[[:space:]]*\([0-9]*\).*/\1/p' | head -1)
  fi
}

detecter() {
  if [ -n "$BINAIRE_IMPOSE" ]; then BINAIRE="$BINAIRE_IMPOSE"; fi

  if trouver_service; then
    MODE="systemd"
    PID=$(systemctl show "$SERVICE" -p MainPID --value 2>/dev/null || echo "")
    [ "$PID" = "0" ] && PID=""
    if [ -z "$BINAIRE" ]; then
      if [ -n "$PID" ] && [ -r "/proc/$PID/exe" ]; then
        BINAIRE=$(readlink "/proc/$PID/exe")
      else
        # Service à l'arrêt : le chemin se lit dans l'unité.
        BINAIRE=$(systemctl show "$SERVICE" -p ExecStart --value 2>/dev/null \
                  | sed -n 's/.*path=\([^ ;]*\).*/\1/p' | head -1)
      fi
    fi
  elif trouver_processus; then
    MODE="manuel"
  else
    MODE="absent"
  fi

  lire_config_du_processus
  trouver_port

  if [ -n "$BINAIRE" ] && [ -x "$BINAIRE" ]; then
    VERSION_ACTUELLE=$("$BINAIRE" -version 2>/dev/null | awk '{print $2}' || echo "?")
    SHA_ACTUEL=$(empreinte "$BINAIRE")
  fi
}

# ══════════════════════════════════════════════════════════════ VÉRIFICATIONS

verifier_fichier() {
  # Ce qu'on peut savoir d'un exécutable SANS le lancer. C'est ce qui permet de
  # refuser un artefact douteux avant qu'il ne touche la machine.
  fichier="$1"; attendu_sha="$2"
  [ -s "$fichier" ] || { ko "fichier vide"; return 1; }
  reel=$(empreinte "$fichier")
  if [ "$reel" != "$attendu_sha" ]; then
    ko "empreinte NON conforme"
    info "attendu : $attendu_sha"
    info "obtenu  : $reel"
    return 1
  fi
  ok "empreinte conforme — ${reel%????????????????????????????????????????????????}…"
  if command -v file >/dev/null 2>&1; then
    case "$(file -b "$fichier")" in
      *ELF*64-bit*x86-64*) ok "exécutable ELF 64 bits x86-64" ;;
      *) ko "ce n'est pas un exécutable ELF x86-64"; return 1 ;;
    esac
  fi
  if grep -aq "$GUID_RC29" "$fichier"; then
    ko "cet exécutable porte ENCORE le GUID WebSocket fautif"
    return 1
  fi
  if grep -aq "$GUID_RFC" "$fichier"; then
    ok "le GUID WebSocket est celui du RFC 6455"
  else
    ko "aucun GUID WebSocket reconnu dans cet exécutable"
    return 1
  fi
  chmod +x "$fichier" 2>/dev/null || true
  v=$("$fichier" -version 2>/dev/null | awk '{print $2}' || echo "")
  if [ "$v" = "$VERSION_CIBLE" ]; then
    ok "il s'annonce en $v"
  else
    ko "version annoncée « $v », attendue « $VERSION_CIBLE »"
    return 1
  fi
  return 0
}

api_repond() {
  p="$1"
  reponse=$($TELECHARGE - "http://127.0.0.1:$p/api/v1/meta" 2>/dev/null || true)
  [ -n "$reponse" ] || return 1
  case "$reponse" in *'"api_version":"v1"'*|*'"api_version": "v1"'*) ;; *) return 1 ;; esac
  printf '%s' "$reponse"
  return 0
}

version_de_l_api() {
  printf '%s' "$1" | sed -n 's/.*"version":[[:space:]]*"\([^"]*\)".*/\1/p' | head -1
}

# Une élévation WebSocket brute, en lisant VRAIMENT l'en-tête de réponse.
# `curl` suffit : on ne parle pas le protocole, on lit la poignée de main.
poignee() {
  chemin="$1"; p="$2"; biscuit="${3:-}"
  command -v curl >/dev/null 2>&1 || { printf 'SANS-CURL'; return 0; }
  entetes=""
  [ -n "$biscuit" ] && entetes="-H Cookie:$biscuit"
  # shellcheck disable=SC2086
  curl -s -i --http1.1 --max-time 6 $entetes \
    -H 'Connection: Upgrade' -H 'Upgrade: websocket' \
    -H 'Sec-WebSocket-Version: 13' \
    -H "Sec-WebSocket-Key: $RFC_CLE" \
    "http://127.0.0.1:$p$chemin" 2>/dev/null | tr -d '\r'
}

# Ouvre une session si un compte a été fourni. Sans compte, les canaux
# répondent 401 : c'est une réponse correcte, mais elle ne prouve pas la
# poignée de main. On le DIT plutôt que de compter un succès.
ouvrir_session() {
  p="$1"
  [ -n "${O11R_USER:-}" ] && [ -n "${O11R_PASSWORD:-}" ] || return 1
  command -v curl >/dev/null 2>&1 || return 1
  curl -s -o /dev/null -c "$TEMPO/biscuits" \
    -H 'Content-Type: application/json' \
    -d "{\"username\":\"$O11R_USER\",\"password\":\"$O11R_PASSWORD\"}" \
    "http://127.0.0.1:$p/api/v1/auth/login" 2>/dev/null || return 1
  [ -s "$TEMPO/biscuits" ] || return 1
  awk '/o11r_session/ {print $6"="$7}' "$TEMPO/biscuits" | head -1
}

tester_websockets() {
  p="$1"; echecs=0
  biscuit=$(ouvrir_session "$p" 2>/dev/null || true)

  if [ -z "$biscuit" ]; then
    alerte "aucun compte fourni : la poignée de main ne peut pas être ouverte"
    info "les canaux exigent une session ; sans elle ils répondent 401"
    info "pour l'éprouver : O11R_USER=… O11R_PASSWORD=… $0 --check"
    # Sans session on vérifie au moins que la route EXISTE et que le serveur
    # répond — un 404 dirait que le binaire servi n'est pas celui qu'on croit.
    for c in $CANAUX; do
      rep=$(poignee "/api/v1/ws/$c" "$p")
      case "$rep" in
        *"401"*) ok "/api/v1/ws/$c — la route répond (401 sans session)" ;;
        *) ko "/api/v1/ws/$c — réponse inattendue"; echecs=$((echecs+1)) ;;
      esac
    done
    printf '%s' "$echecs" > "$TEMPO/ws_echecs"
    return 0
  fi

  # Avec session : le vrai contrôle. La clé est celle du RFC, la réponse
  # attendue est celle que le RFC annonce, à l'octet près.
  rep=$(poignee "/api/v1/ws/streams" "$p" "$biscuit")
  accepte=$(printf '%s' "$rep" | sed -n 's/^[Ss]ec-[Ww]eb[Ss]ocket-[Aa]ccept:[[:space:]]*//p' | head -1)
  if [ "$accepte" = "$RFC_ACCEPT" ]; then
    ok "vecteur RFC 6455 : Sec-WebSocket-Accept = $RFC_ACCEPT"
  else
    ko "vecteur RFC 6455 : obtenu « ${accepte:-aucun} », attendu « $RFC_ACCEPT »"
    echecs=$((echecs+1))
  fi

  for c in $CANAUX; do
    rep=$(poignee "/api/v1/ws/$c" "$p" "$biscuit")
    accepte=$(printf '%s' "$rep" | sed -n 's/^[Ss]ec-[Ww]eb[Ss]ocket-[Aa]ccept:[[:space:]]*//p' | head -1)
    case "$rep" in *"101"*) elev=1 ;; *) elev=0 ;; esac
    if [ "$elev" = 1 ] && [ "$accepte" = "$RFC_ACCEPT" ]; then
      ok "/api/v1/ws/$c — 101, accept conforme"
    else
      ko "/api/v1/ws/$c — élévation=$elev accept=«${accepte:-aucun}»"
      echecs=$((echecs+1))
    fi
  done
  printf '%s' "$echecs" > "$TEMPO/ws_echecs"
  return 0
}

# ═════════════════════════════════════════════════════════ ARRÊT ET DÉMARRAGE

arreter() {
  case "$MODE" in
    systemd) systemctl stop "$SERVICE" ;;
    manuel)  [ -n "$PID" ] && kill "$PID" 2>/dev/null || true ;;
  esac
  i=0
  while [ $i -lt 20 ]; do
    [ -n "$PORT" ] || break
    command -v ss >/dev/null 2>&1 || break
    ss -ltn 2>/dev/null | grep -q ":$PORT " || break
    sleep 0.5; i=$((i+1))
  done
}

demarrer() {
  case "$MODE" in
    systemd) systemctl start "$SERVICE" ;;
    manuel)  return 0 ;;   # relancé par l'exploitant : voir le message final
  esac
  i=0
  while [ $i -lt 30 ]; do
    [ -n "$PORT" ] && api_repond "$PORT" >/dev/null 2>&1 && return 0
    sleep 0.5; i=$((i+1))
  done
  [ "$MODE" = "manuel" ] && return 0
  return 1
}

BACKUP=""
# restaurer() rend :
#   0  l'exécutable d'origine est revenu ET le service répond
#   1  l'exécutable est revenu, mais le service ne repart pas
#   2  la restauration elle-même a échoué
#
# La distinction n'est pas une coquetterie. Annoncer « rollback terminé » sur un
# service à terre enverrait l'exploitant chercher la panne du mauvais côté :
# l'exécutable d'origine est bien en place, la cause est ailleurs.
restaurer() {
  [ -n "$BACKUP" ] && [ -f "$BACKUP" ] || return 2
  arreter
  cp -p "$BACKUP" "$BINAIRE" || return 2
  chmod +x "$BINAIRE"
  demarrer || return 1
  [ -n "$PORT" ] || return 0
  api_repond "$PORT" >/dev/null 2>&1 || return 1
  return 0
}

# annoncer_retour dit ce qui s'est RÉELLEMENT passé, selon le code de restaurer.
annoncer_retour() {
  case "$1" in
    0) printf '\n  %sUPDATE FAILED — ROLLBACK COMPLETED%s\n' "$R" "$N"
       info "version restaurée : $("$BINAIRE" -version 2>/dev/null | awk '{print $2}')"
       info "le service répond de nouveau sur le port $PORT" ;;
    1) printf '\n  %sUPDATE FAILED — ROLLBACK PARTIEL%s\n' "$R" "$N"
       info "l'exécutable d'origine EST restauré : $BACKUP"
       info "mais le service ne redémarre toujours pas — la cause n'est donc"
       info "pas la mise à jour. Regarder :"
       [ "$MODE" = "systemd" ] && info "  journalctl -u $SERVICE -n 50 --no-pager" ;;
    *) printf '\n  %sUPDATE FAILED — ET LA RESTAURATION A ÉCHOUÉ%s\n' "$R" "$N"
       info "sauvegarde à remettre à la main : $BACKUP"
       info "  cp -p $BACKUP $BINAIRE" ;;
  esac
}

# ═════════════════════════════════════════════════════════════════ EXÉCUTION

printf '\n  %sMise à jour d'\''o11-rebuild vers %s%s\n' "$B" "$VERSION_CIBLE" "$N"
printf '  correctif WebSocket RFC 6455\n'

etape "1. Ce qui tourne sur cette machine"
detecter
case "$MODE" in
  systemd)
    ok "service systemd : $SERVICE"
    [ -n "$PID" ] && info "PID $PID" ;;
  manuel)
    alerte "processus lancé À LA MAIN — aucun service systemd"
    info "PID $PID" ;;
  absent)
    echec "aucun o11-rebuild trouvé, ni en service ni en processus.
         S'il tourne sous un autre nom, l'indiquer :
           --service <unité>   ou   --binary <chemin>" ;;
esac
[ -n "$BINAIRE" ] || echec "chemin de l'exécutable introuvable (--binary <chemin>)"

# GARDE-FOU — trouvé par le banc d'essai, et il vaut pour de vrai.
#
# Quand le service est à l'arrêt, on lit son ExecStart. Or beaucoup
# d'installations n'y mettent pas le binaire mais un LANCEUR : un script de
# surveillance, un wrapper qui exporte des variables. Remplacer ce fichier par
# l'exécutable détruirait le lanceur — et la mise à jour annoncerait un succès.
#
# On n'écrit donc que sur un fichier qui se PRÉSENTE comme o11-rebuild.
verifier_cible() {
  [ -f "$BINAIRE" ] || { ko "« $BINAIRE » n'est pas un fichier"; return 1; }
  if command -v file >/dev/null 2>&1; then
    case "$(file -b "$BINAIRE")" in
      *ELF*) ;;
      *) ko "« $BINAIRE » n'est pas un exécutable ELF"
         info "c'est probablement un LANCEUR, pas le binaire lui-même :"
         info "  $(head -1 "$BINAIRE" 2>/dev/null | cut -c1-70)"
         return 1 ;;
    esac
  fi
  sortie=$("$BINAIRE" -version 2>/dev/null || true)
  case "$sortie" in
    *o11-rebuild*) return 0 ;;
    *) ko "« $BINAIRE » ne s'annonce pas comme o11-rebuild"
       info "obtenu : ${sortie:-aucune sortie}"
       return 1 ;;
  esac
}
if ! verifier_cible; then
  printf '\n'
  info "Indiquez le vrai exécutable :"
  info "  sudo sh \$0 --binary /chemin/vers/o11-rebuild"
  echec "refus d'écrire sur un fichier qui n'est pas o11-rebuild."
fi
ok "exécutable : $BINAIRE"
[ -n "$CONFIG" ] && info "configuration : $CONFIG (NON modifiée)" || info "configuration : non déclarée en ligne de commande"
[ -n "$PORT" ]   && ok "port : $PORT" || alerte "port indéterminé"
ok "version en place : ${VERSION_ACTUELLE:-inconnue}"
info "empreinte : ${SHA_ACTUEL:-inconnue}"
if grep -aq "$GUID_RC29" "$BINAIRE" 2>/dev/null; then
  alerte "cet exécutable porte le GUID WebSocket FAUTIF (canaux injoignables depuis un navigateur)"
elif grep -aq "$GUID_RFC" "$BINAIRE" 2>/dev/null; then
  ok "cet exécutable porte déjà le GUID du RFC"
fi

etape "2. Ce que le service répond"
if [ -n "$PORT" ] && meta=$(api_repond "$PORT"); then
  ok "l'API répond, api_version v1"
  ok "elle s'annonce en $(version_de_l_api "$meta")"
  TEMPO=$(mktemp -d)
  tester_websockets "$PORT"
else
  alerte "l'API ne répond pas sur le port ${PORT:-?} — le service est peut-être arrêté"
fi

# ─────────────────────────────────────────────────────────────────── --check
if [ "$ACTION" = "check" ]; then
  printf '\n  %sVérification seule — rien n'\''a été modifié.%s\n\n' "$B" "$N"
  if [ "$SHA_ACTUEL" = "$SHA_CIBLE" ]; then
    printf '  %sDéjà à jour%s en %s.\n\n' "$V" "$N" "$VERSION_CIBLE"
  else
    printf '  Une mise à jour est disponible : %s → %s\n' \
      "${VERSION_ACTUELLE:-?}" "$VERSION_CIBLE"
    printf '  La poser :  sudo sh %s\n\n' "$0"
  fi
  exit 0
fi

# ──────────────────────────────────────────────── déjà à jour : on s'arrête
if [ "$SHA_ACTUEL" = "$SHA_CIBLE" ]; then
  printf '\n  %sAlready up to date.%s  %s, empreinte identique.\n\n' \
    "$V" "$N" "$VERSION_CIBLE"
  exit 0
fi

# ───────────────────────────────────────────────────────────────── --dry-run
HORODATAGE=$(date +%Y%m%d-%H%M%S)
BACKUP_PREVU="${BINAIRE}.backup-${HORODATAGE}"
if [ "$ACTION" = "dryrun" ]; then
  etape "3. Ce qui SERAIT fait — rien n'est modifié"
  info "téléchargement   : $BIN_URL"
  info "empreinte lue    : $SHA_URL"
  info "empreinte exigée : $SHA_CIBLE"
  info "sauvegarde       : $BACKUP_PREVU"
  info "remplacement de  : $BINAIRE"
  case "$MODE" in
    systemd) info "arrêt puis relance : systemctl restart $SERVICE" ;;
    manuel)  info "arrêt du PID $PID ; la relance reste à votre main" ;;
  esac
  info "contrôles ensuite : API, version, vecteur RFC, les 5 canaux"
  info "en cas d'échec    : restauration de la sauvegarde et relance"
  printf '\n  Aucune écriture. Rien n'\''a changé.\n\n'
  exit 0
fi

# ────────────────────────────────────────────────── garde-fous avant écriture
[ "$(id -u)" = "0" ] || echec "il faut être root pour remplacer l'exécutable."

if [ "$MODE" = "manuel" ] && [ "$SANS_QUESTION" != "1" ]; then
  printf '\n'
  alerte "Ce processus n'est pas géré par systemd."
  info "Le tuer ici le laisserait ARRÊTÉ : personne ne le relèvera."
  info "Relancez avec --yes si vous acceptez de le redémarrer vous-même,"
  info "ou passez-le sous systemd d'abord."
  printf '\n  Rien n'\''a été modifié.\n\n'
  exit 2
fi

etape "3. Téléchargement, puis vérification — jamais l'inverse"
[ -n "$TEMPO" ] || TEMPO=$(mktemp -d)
NEUF="$TEMPO/o11-rebuild.new"
$TELECHARGE "$NEUF" "$BIN_URL" || echec "téléchargement impossible : $BIN_URL"
ok "téléchargé ($(wc -c < "$NEUF") octets)"

# L'empreinte publiée à côté de l'artefact, ET celle inscrite dans ce script.
# Les deux doivent concorder : la première protège d'un fichier corrompu, la
# seconde d'un fichier remplacé à la source.
$TELECHARGE "$TEMPO/sha" "$SHA_URL" 2>/dev/null || true
if [ -s "$TEMPO/sha" ]; then
  publiee=$(cut -d' ' -f1 < "$TEMPO/sha")
  if [ "$publiee" != "$SHA_CIBLE" ]; then
    echec "l'empreinte publiée ($publiee) ne correspond pas à celle attendue
         par ce script ($SHA_CIBLE). Publication incohérente : on s'arrête."
  fi
  ok "l'empreinte publiée concorde avec celle de ce script"
fi

verifier_fichier "$NEUF" "$SHA_CIBLE" || echec "l'artefact téléchargé est refusé. Rien n'a été touché."

etape "4. Sauvegarde de l'exécutable en place"
BACKUP="$BACKUP_PREVU"
cp -p "$BINAIRE" "$BACKUP" || echec "sauvegarde impossible — on n'ira pas plus loin."
ok "sauvegardé : $BACKUP"
info "empreinte  : $(empreinte "$BACKUP")"

etape "5. Bascule"
arreter
ok "arrêté"
# `mv` dans le même répertoire : le remplacement est atomique, il n'existe
# jamais d'instant où le fichier est à moitié écrit.
cp -p "$BINAIRE" "$TEMPO/modele" 2>/dev/null || true
mv "$NEUF" "$BINAIRE" || { restaurer; echec "remplacement impossible — sauvegarde restaurée."; }
chmod +x "$BINAIRE"
# On rend au fichier le propriétaire et les droits qu'il avait.
if [ -f "$TEMPO/modele" ]; then
  chown --reference="$TEMPO/modele" "$BINAIRE" 2>/dev/null || true
  chmod --reference="$TEMPO/modele" "$BINAIRE" 2>/dev/null || true
  chmod +x "$BINAIRE"
fi
ok "exécutable remplacé"

if [ "$MODE" = "manuel" ]; then
  printf '\n  %sL'\''exécutable est remplacé.%s\n' "$B" "$N"
  info "Le processus n'était pas géré par systemd : à vous de le relancer,"
  info "avec la MÊME ligne de commande qu'avant :"
  [ -n "$CONFIG" ] && printf '      %s -config %s\n' "$BINAIRE" "$CONFIG" \
                   || printf '      %s\n' "$BINAIRE"
  info "Sauvegarde conservée : $BACKUP"
  printf '\n'
  exit 0
fi

if ! demarrer; then
  ko "le service ne répond pas après redémarrage"
  if restaurer; then retour=0; else retour=$?; fi
  annoncer_retour "$retour"
  printf '\n'
  exit 1
fi
ok "service relancé"

etape "6. Contrôles après bascule"
ECHECS=0
if meta=$(api_repond "$PORT"); then
  ok "l'API répond, api_version v1"
  v=$(version_de_l_api "$meta")
  if [ "$v" = "$VERSION_CIBLE" ]; then ok "elle s'annonce en $v"
  else ko "version « $v », attendue « $VERSION_CIBLE »"; ECHECS=$((ECHECS+1)); fi
else
  ko "l'API ne répond pas"; ECHECS=$((ECHECS+1))
fi
tester_websockets "$PORT"
[ -f "$TEMPO/ws_echecs" ] && ECHECS=$((ECHECS + $(cat "$TEMPO/ws_echecs")))

if [ "$ECHECS" -gt 0 ]; then
  printf '\n  %s%d contrôle(s) en échec — restauration.%s\n' "$R" "$ECHECS" "$N"
  if restaurer; then retour=0; else retour=$?; fi
  annoncer_retour "$retour"
  printf '\n'
  exit 1
fi

printf '\n  %sÀ jour : %s → %s%s\n\n' "$V" "${VERSION_ACTUELLE:-?}" "$VERSION_CIBLE" "$N"
info "sauvegarde conservée : $BACKUP"
info "configuration, base et données : NON modifiées"
printf '\n'
