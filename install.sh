#!/bin/sh
# Panel O11 — installation en une commande.
#
#   sh -c "$(curl -fsSL <BASE>/install.sh)"
#   sh -c "$(wget  -O-  <BASE>/install.sh)"
#   sh -c "$(fetch -o - <BASE>/install.sh)"
#
# Avec des options (noter le « -s -- » derrière un tube) :
#
#   curl -fsSL <BASE>/install.sh | sudo sh -s -- --upstream 1337 --port 8080
#
# Le script télécharge l'installateur, VÉRIFIE SA SOMME DE CONTRÔLE, puis
# l'exécute. Jamais l'inverse : un fichier dont l'empreinte ne correspond pas
# n'est jamais lancé.
#
# POSIX sh — ni bashisme, ni dépendance.

set -eu

# ═══════════════════════════════════════════════════════════════════════════
# L'EMPLACEMENT OFFICIEL — le seul endroit à changer pour publier ailleurs.
# ═══════════════════════════════════════════════════════════════════════════
PANEL_VERSION="1.3.1"
BASE_URL="https://raw.githubusercontent.com/ange900/ange900/main"

INSTALLER_URL="${O11_INSTALLER_URL:-$BASE_URL/install-panel.py}"
CHECKSUM_URL="${O11_CHECKSUM_URL:-$INSTALLER_URL.sha256}"
# ═══════════════════════════════════════════════════════════════════════════

V=''; R=''; J=''; G=''
if [ -t 1 ]; then V=$(printf '\033[32m'); R=$(printf '\033[31m'); J=$(printf '\033[33m'); G=$(printf '\033[0m'); fi

# printf %-34s compte des OCTETS : un libellé accentué décale la colonne.
# On complète nous-mêmes, d'après le nombre de CARACTÈRES.
etape() {
  printf '  %s' "$1"
  n=$(printf '%s' "$1" | wc -m | tr -d ' ')
  i=$n
  while [ "$i" -lt 34 ]; do printf ' '; i=$((i + 1)); done
}
faite()  { printf '%s%s%s\n' "$V" "${1:-OK}" "$G"; }
ratee()  { printf '%s%s%s\n' "$R" "${1:-ÉCHEC}" "$G"; }
note()   { printf '  %s·%s %s\n' "$J" "$G" "$1"; }
mourir() { printf '\n  %sInstallation interrompue.%s %s\n\n' "$R" "$G" "$1" >&2; exit 1; }

aide() {
  cat <<'AIDE'
Panel O11 — installation en une commande.

  curl -fsSL <BASE>/install.sh | sudo sh
  curl -fsSL <BASE>/install.sh | sudo sh -s -- --upstream 1337 --port 8080

Options (transmises telles quelles à l'installateur) :
  --upstream PORT   port d'o11pro ; détecté automatiquement s'il est omis
  --port PORT       port d'écoute du panel (8080 par défaut)
  --bind ADRESSE    adresse d'écoute (0.0.0.0 par défaut)
  --prefix CHEMIN   répertoire d'installation (/opt/o11-panel par défaut)
  --yes             ne pose aucune question
  --check           vérifie une installation existante
  --uninstall       retire le panel ; o11pro n'est pas touché
  --version         affiche la version

Options propres à ce script :
  --installer-url URL   emplacement de install-panel.py
  --no-verify           saute la vérification d'empreinte (DÉCONSEILLÉ)
AIDE
}

# ---------------------------------------------------------------- arguments
NO_VERIFY=0
ARGS=""
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)         aide; exit 0 ;;
    --version)         printf 'o11-panel install.sh %s\n' "$PANEL_VERSION"; exit 0 ;;
    --installer-url)   INSTALLER_URL="$2"; CHECKSUM_URL="$2.sha256"; shift 2 ;;
    --no-verify)       NO_VERIFY=1; shift ;;
    *)                 ARGS="$ARGS $1"; shift ;;
  esac
done

printf '\n  %sPanel O11%s  installation %s\n\n' "$V" "$G" "$PANEL_VERSION"

# ---------------------------------------------------------------- prérequis
etape "Droits root"
if [ "$(id -u)" -ne 0 ]; then
  case " $ARGS " in
    *" --check "*|*" --version "*) faite "non requis" ;;
    *) ratee; mourir "relancer avec sudo :  curl -fsSL <BASE>/install.sh | sudo sh" ;;
  esac
else
  faite
fi

etape "Python 3"
PY=""
for c in python3 python3.13 python3.12 python3.11 python3.10 python3.9 python3.8; do
  if command -v "$c" >/dev/null 2>&1; then PY="$c"; break; fi
done
[ -n "$PY" ] || { ratee; mourir "python3 est requis (apt install python3 / dnf install python3)"; }
faite "$("$PY" -c 'import sys;print("%d.%d"%sys.version_info[:2])')"

etape "Outil de téléchargement"
DL=""
if   command -v curl  >/dev/null 2>&1; then DL="curl"
elif command -v wget  >/dev/null 2>&1; then DL="wget"
elif command -v fetch >/dev/null 2>&1; then DL="fetch"
fi
[ -n "$DL" ] || { ratee; mourir "curl, wget ou fetch est requis"; }
faite "$DL"

telecharger() { # $1 = url, $2 = destination
  case "$DL" in
    curl)  curl  -fsSL --retry 3 --connect-timeout 15 "$1" -o "$2" ;;
    wget)  wget  -q --tries=3 --timeout=15 -O "$2" "$1" ;;
    fetch) fetch -q -o "$2" "$1" ;;
  esac
}

# ------------------------------------------------------- fichier temporaire
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t o11panel)"
TMP_INSTALLER="$TMP_DIR/install-panel.py"
TMP_SUM="$TMP_DIR/install-panel.py.sha256"
# Nettoyage quoi qu'il arrive : succès, erreur, interruption.
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM HUP

etape "Téléchargement de l'installateur"
telecharger "$INSTALLER_URL" "$TMP_INSTALLER" 2>/dev/null || { ratee; mourir "impossible de récupérer $INSTALLER_URL"; }
[ -s "$TMP_INSTALLER" ] || { ratee; mourir "fichier vide : $INSTALLER_URL"; }
faite "$(wc -c < "$TMP_INSTALLER" | tr -d ' ') octets"

# ------------------------------------------------------------- empreinte
somme() { # empreinte SHA-256 du fichier $1, quel que soit l'outil disponible
  if   command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
  elif command -v shasum    >/dev/null 2>&1; then shasum -a 256 "$1" | cut -d' ' -f1
  elif command -v sha256    >/dev/null 2>&1; then sha256 -q "$1"
  else "$PY" - "$1" <<'PYSUM'
import hashlib, sys
h = hashlib.sha256()
with open(sys.argv[1], "rb") as f:
    for bloc in iter(lambda: f.read(1 << 20), b""):
        h.update(bloc)
print(h.hexdigest())
PYSUM
  fi
}

if [ "$NO_VERIFY" -eq 1 ]; then
  etape "Vérification de l'empreinte"; faite "sautée (--no-verify)"
  note "un installateur non vérifié ne devrait jamais être exécuté."
else
  etape "Empreinte de référence"
  telecharger "$CHECKSUM_URL" "$TMP_SUM" 2>/dev/null || { ratee; mourir "empreinte introuvable : $CHECKSUM_URL"; }
  # Le fichier peut être « <sha256>  install-panel.py » ou l'empreinte seule.
  EXPECTED_SHA256="$(cut -d' ' -f1 < "$TMP_SUM" | tr -d '\r\n\t ')"
  case "$EXPECTED_SHA256" in
    [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]*) ;;
    *) ratee; mourir "empreinte de référence illisible" ;;
  esac
  [ "${#EXPECTED_SHA256}" -eq 64 ] || { ratee; mourir "empreinte de référence de longueur inattendue"; }
  faite "${EXPECTED_SHA256%"${EXPECTED_SHA256#????????????????}"}…"

  etape "Vérification de l'empreinte"
  ACTUAL_SHA256="$(somme "$TMP_INSTALLER")"
  if [ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]; then
    ratee
    printf '\n  %sChecksum verification FAILED.%s\n' "$R" "$G" >&2
    printf '    attendu : %s\n    obtenu  : %s\n' "$EXPECTED_SHA256" "$ACTUAL_SHA256" >&2
    mourir "l'installateur n'a PAS été exécuté."
  fi
  faite
fi

# ------------------------------------------------------------- exécution
printf '\n'
# shellcheck disable=SC2086
"$PY" "$TMP_INSTALLER" $ARGS
