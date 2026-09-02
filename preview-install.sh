#!/bin/sh
# Pose une PREVIEW du panel — l'interface seulement.
#
#   curl -fsSL <URL>/preview-install.sh | sudo sh
#
# Ce script ne touche QUE le dossier `dist` du panel installé. Il ne remplace
# ni le proxy, ni la couche de compatibilité, ni le pont temps réel, ni
# l'installateur, ni `etat.json`. Aucune donnée — providers, flux, EPG, logos,
# utilisateurs, réglages — n'est lue ni écrite : elles vivent dans le backend,
# que ce script ne connaît même pas.
#
# Le panel en place est conservé dans `dist.precedent`. Un retour arrière tient
# en une commande, affichée à la fin.
#
#   --rollback   remet `dist.precedent` et redémarre
#   --check      dit ce qui est en place, sans rien écrire

set -eu

PREVIEW_URL="${O11_PREVIEW_URL:-https://raw.githubusercontent.com/ange900/ange900/main/preview/panel-preview.tar.gz}"
SHA_ATTENDU="4ad15232b64302d86abf25529fadcadbbc76c5549890a3b9f15d763590f79f68"
PREFIX="${O11_PREFIX:-/opt/o11-panel}"
SERVICE="o11-panel"

if [ -t 1 ]; then V=$(printf '\033[32m'); R=$(printf '\033[31m'); J=$(printf '\033[33m')
                 B=$(printf '\033[1m'); N=$(printf '\033[0m')
else V=""; R=""; J=""; B=""; N=""; fi
ok()    { printf '  %s✓%s %s\n' "$V" "$N" "$*"; }
ko()    { printf '  %s✗%s %s\n' "$R" "$N" "$*"; }
info()  { printf '  · %s\n' "$*"; }
echec() { printf '\n%sÉCHEC :%s %s\n\n' "$R" "$N" "$*" >&2; exit 1; }

ACTION=poser
for a in "$@"; do
  case "$a" in
    --rollback) ACTION=rollback ;;
    --check)    ACTION=check ;;
    --help|-h)  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echec "option inconnue : $a" ;;
  esac
done

printf '\n  %sPreview du panel — interface seulement%s\n\n' "$B" "$N"

[ -d "$PREFIX/dist" ] || echec "aucun panel installé dans $PREFIX"

if [ "$ACTION" = check ]; then
  ok "panel installé : $PREFIX/dist"
  [ -d "$PREFIX/dist.precedent" ] && ok "retour arrière disponible : dist.precedent" \
                                  || info "aucun dist.precedent : rien à restaurer"
  info "service : $(systemctl is-active "$SERVICE" 2>/dev/null || echo inconnu)"
  printf '\n  Rien n'\''a été modifié.\n\n'
  exit 0
fi

if [ "$ACTION" = rollback ]; then
  [ -d "$PREFIX/dist.precedent" ] || echec "aucun dist.precedent à restaurer"
  [ "$(id -u)" = 0 ] || echec "il faut être root"
  rm -rf "$PREFIX/dist.rollback-tmp"
  mv "$PREFIX/dist" "$PREFIX/dist.rollback-tmp"
  mv "$PREFIX/dist.precedent" "$PREFIX/dist"
  mv "$PREFIX/dist.rollback-tmp" "$PREFIX/dist.precedent"
  systemctl restart "$SERVICE" 2>/dev/null || true
  ok "panel précédent restauré, service redémarré"
  printf '\n  La preview est repartie dans dist.precedent : relancer ce script la remet.\n\n'
  exit 0
fi

[ "$(id -u)" = 0 ] || echec "il faut être root pour écrire dans $PREFIX"

if command -v curl >/dev/null 2>&1; then TEL="curl -fsSL -o"
elif command -v wget >/dev/null 2>&1; then TEL="wget -qO"
else echec "ni curl ni wget"; fi

TEMPO=$(mktemp -d); trap 'rm -rf "$TEMPO"' EXIT INT TERM

info "téléchargement : $PREVIEW_URL"
$TEL "$TEMPO/preview.tar.gz" "$PREVIEW_URL" || echec "téléchargement impossible"

# DOWNLOAD → VERIFY → EXTRACT. Jamais dans l'autre ordre.
REEL=$(sha256sum "$TEMPO/preview.tar.gz" 2>/dev/null | cut -d' ' -f1 \
       || shasum -a 256 "$TEMPO/preview.tar.gz" | cut -d' ' -f1)
if [ "$REEL" != "$SHA_ATTENDU" ]; then
  ko "empreinte NON conforme"
  info "attendu : $SHA_ATTENDU"
  info "obtenu  : $REEL"
  echec "archive refusée. Rien n'a été touché."
fi
ok "empreinte conforme — $(echo "$REEL" | cut -c1-16)…"

mkdir -p "$TEMPO/dist"
tar -xzf "$TEMPO/preview.tar.gz" -C "$TEMPO/dist" || echec "archive illisible"
[ -f "$TEMPO/dist/index.html" ] || echec "l'archive ne contient pas un panel"
ok "archive vérifiée et dépliée"

# Le panel en place devient dist.precedent — on n'écrase jamais le seul
# exemplaire fonctionnel.
rm -rf "$PREFIX/dist.precedent"
mv "$PREFIX/dist" "$PREFIX/dist.precedent"
mv "$TEMPO/dist" "$PREFIX/dist"
ok "preview posée ; panel précédent dans dist.precedent"

systemctl restart "$SERVICE" 2>/dev/null && ok "service $SERVICE redémarré" \
  || info "service non géré ici : recharger la page suffit"

PORT=$(sed -n 's/.*"port"[^0-9]*\([0-9]*\).*/\1/p' "$PREFIX/etat.json" 2>/dev/null | head -1)
printf '\n  %sPreview en place.%s  http://<cette-machine>:%s/linear/\n' "$V" "$N" "${PORT:-8080}"
printf '\n  Retour arrière :\n    sudo sh %s --rollback\n\n' "$0"
