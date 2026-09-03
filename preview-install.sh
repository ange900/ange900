#!/bin/sh
# Pose une PREVIEW du panel — l'interface, et le service qui la sert.
#
#   curl -fsSL <URL>/preview-install.sh | sudo sh
#
# Ce script remplace `dist` ET DEUX FICHIERS DE SERVICE, parce que l'écran EPG
# de cette preview parle à un moteur qui vit dans le service : poser l'interface
# seule afficherait un bandeau « Auto EPG » en erreur.
#
#   dist/                   l'interface, lecteur HLS compris
#   proxy-o11-panel.py      il expose /__panel/epg-auto, lance le moteur EPG,
#                           et relaie `/output/` d'o11-rebuild avec la session
#   moteur-epg.py           le moteur EPG (fichier nouveau)
#   adaptateur-rebuild.py   il rend désormais une adresse de lecture RELATIVE,
#                           sans quoi le navigateur sortirait de l'origine du
#                           panel et o11-rebuild répondrait 401
#
# Il ajoute aussi UN réglage au service : `StateDirectory=o11-panel`, par un
# drop-in systemd. Sans lui, `ProtectSystem=strict` ne laisse aucun chemin
# d'écriture, et le journal qui distingue « associé à la main » de « associé
# par le moteur » ne survivrait pas à un redémarrage. Le drop-in n'ouvre que
# `/var/lib/o11-panel`, et `--rollback` le retire.
#
# Il ne remplace PAS la couche de compatibilité, ni le pont temps réel, ni
# l'installateur, ni `etat.json`. Aucune donnée — providers, flux, EPG, logos,
# utilisateurs, réglages — n'est lue ni écrite : elles vivent dans le backend,
# que ce script ne connaît même pas.
#
# Chaque pièce remplacée est conservée en `.precedent`. Un retour arrière tient
# en une commande, affichée à la fin.
#
#   --rollback   remet `dist.precedent` et redémarre
#   --check      dit ce qui est en place, sans rien écrire

set -eu

PREVIEW_URL="${O11_PREVIEW_URL:-https://raw.githubusercontent.com/ange900/ange900/main/preview/panel-preview.tar.gz}"
SHA_ATTENDU="fe3911d800197c8ae64f4edb65d1c4573dcc4c30c86dcc22ab202b9ca3f608cf"
PREFIX="${O11_PREFIX:-/opt/o11-panel}"
SERVICE="o11-panel"
DROPIN="${O11_DROPIN:-/etc/systemd/system/o11-panel.service.d/10-etat-epg.conf}"

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

printf '\n  %sPreview du panel — interface + service%s\n\n' "$B" "$N"

[ -d "$PREFIX/dist" ] || echec "aucun panel installé dans $PREFIX"

if [ "$ACTION" = check ]; then
  ok "panel installé : $PREFIX/dist"
  [ -d "$PREFIX/dist.precedent" ] && ok "retour arrière disponible : dist.precedent" \
                                  || info "aucun dist.precedent : rien à restaurer"
  [ -f "$PREFIX/moteur-epg.py" ] && ok "moteur EPG présent" \
                                 || info "moteur EPG absent (panel antérieur à cette preview)"
  [ -f "$PREFIX/proxy-o11-panel.py.precedent" ] \
    && ok "service précédent conservé" || info "aucun service précédent conservé"
  [ -f "$DROPIN" ] && ok "chemin d'état ouvert (StateDirectory)" \
                   || info "aucun StateDirectory : l'état ne persisterait pas"
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
  ok "interface précédente restaurée"
  # Le service revient au même moment que l'interface : une interface ancienne
  # devant un service neuf, ou l'inverse, est un état que personne ne teste.
  if [ -f "$PREFIX/proxy-o11-panel.py.precedent" ]; then
    mv "$PREFIX/proxy-o11-panel.py" "$PREFIX/proxy-o11-panel.py.preview"
    mv "$PREFIX/proxy-o11-panel.py.precedent" "$PREFIX/proxy-o11-panel.py"
    mv "$PREFIX/proxy-o11-panel.py.preview" "$PREFIX/proxy-o11-panel.py.precedent"
    ok "service précédent restauré"
  fi
  if [ -f "$PREFIX/adaptateur-rebuild.py.precedent" ]; then
    mv "$PREFIX/adaptateur-rebuild.py" "$PREFIX/adaptateur-rebuild.py.preview"
    mv "$PREFIX/adaptateur-rebuild.py.precedent" "$PREFIX/adaptateur-rebuild.py"
    mv "$PREFIX/adaptateur-rebuild.py.preview" "$PREFIX/adaptateur-rebuild.py.precedent"
    ok "couche de compatibilité précédente restaurée"
  fi
  # `moteur-epg.py` reste : il n'est chargé que si le proxy le demande, et le
  # proxy précédent ne le demande pas. L'effacer casserait un retour en avant.
  if [ -f "$DROPIN" ]; then
    rm -f "$DROPIN"
    rmdir "$(dirname "$DROPIN")" 2>/dev/null || true
    systemctl daemon-reload 2>/dev/null || true
    ok "drop-in StateDirectory retiré"
  fi
  systemctl restart "$SERVICE" 2>/dev/null || true
  ok "service redémarré"
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

mkdir -p "$TEMPO/x"
tar -xzf "$TEMPO/preview.tar.gz" -C "$TEMPO/x" || echec "archive illisible"
[ -f "$TEMPO/x/dist/index.html" ] || echec "l'archive ne contient pas un panel"
[ -f "$TEMPO/x/serveur/proxy-o11-panel.py" ] || echec "l'archive ne contient pas le service"
[ -f "$TEMPO/x/serveur/moteur-epg.py" ] || echec "l'archive ne contient pas le moteur EPG"
[ -f "$TEMPO/x/serveur/adaptateur-rebuild.py" ] || echec "l'archive ne contient pas la couche de compatibilité"
# Un fichier Python qui ne compile pas laisserait le service mort au
# redémarrage. On le vérifie AVANT de toucher à quoi que ce soit.
if command -v python3 >/dev/null 2>&1; then
  python3 -m py_compile "$TEMPO/x/serveur/proxy-o11-panel.py" \
                        "$TEMPO/x/serveur/moteur-epg.py" \
                        "$TEMPO/x/serveur/adaptateur-rebuild.py" \
    || echec "le service de la preview ne compile pas. Rien n'a été touché."
  ok "service de la preview : compile"
fi
ok "archive vérifiée et dépliée"

# Chaque pièce en place devient `.precedent` — on n'écrase jamais le seul
# exemplaire fonctionnel.
rm -rf "$PREFIX/dist.precedent"
mv "$PREFIX/dist" "$PREFIX/dist.precedent"
mv "$TEMPO/x/dist" "$PREFIX/dist"
cp -f "$PREFIX/proxy-o11-panel.py" "$PREFIX/proxy-o11-panel.py.precedent" 2>/dev/null || true
cp -f "$TEMPO/x/serveur/proxy-o11-panel.py" "$PREFIX/proxy-o11-panel.py"
cp -f "$TEMPO/x/serveur/moteur-epg.py" "$PREFIX/moteur-epg.py"
# La couche de compatibilité ne concerne qu'o11-rebuild ; on la conserve aussi
# en `.precedent`, parce qu'on la remplace.
cp -f "$PREFIX/adaptateur-rebuild.py" "$PREFIX/adaptateur-rebuild.py.precedent" 2>/dev/null || true
cp -f "$TEMPO/x/serveur/adaptateur-rebuild.py" "$PREFIX/adaptateur-rebuild.py"
chmod 0644 "$PREFIX/proxy-o11-panel.py" "$PREFIX/moteur-epg.py" "$PREFIX/adaptateur-rebuild.py"
ok "preview posée ; interface et service précédents conservés en .precedent"

# Le seul chemin d'écriture dont le moteur a besoin. Sans lui, le journal des
# associations repartirait de zéro à chaque démarrage — sans jamais écraser un
# choix manuel, mais en gelant aussi les siens.
if [ -d /etc/systemd/system ] && systemctl cat "$SERVICE" >/dev/null 2>&1; then
  if systemctl cat "$SERVICE" 2>/dev/null | grep -q '^StateDirectory='; then
    info "le service déclare déjà un StateDirectory"
  else
    mkdir -p "$(dirname "$DROPIN")"
    printf '[Service]\nStateDirectory=o11-panel\nStateDirectoryMode=0700\n' > "$DROPIN"
    systemctl daemon-reload 2>/dev/null || true
    ok "chemin d'état ouvert : /var/lib/o11-panel"
  fi
fi

systemctl restart "$SERVICE" 2>/dev/null && ok "service $SERVICE redémarré" \
  || info "service non géré ici : recharger la page suffit"

PORT=$(sed -n 's/.*"port"[^0-9]*\([0-9]*\).*/\1/p' "$PREFIX/etat.json" 2>/dev/null | head -1)
printf '\n  %sPreview en place.%s  http://<cette-machine>:%s/linear/\n' "$V" "$N" "${PORT:-8080}"
printf '\n  Le lecteur : cliquer l'\''icône TV bleue d'\''une carte Linear, Events ou VOD.\n'
printf '\n  L'\''auto EPG tourne dans le service, toutes les 6 h, sans navigateur.\n'
printf '  Il démarre dès la première connexion d'\''un administrateur ; pour ne\n'
printf '  dépendre d'\''aucune connexion, poser O11_AUTO_TOKEN sur le service.\n'
printf '  État : http://<cette-machine>:%s/__panel/epg-auto\n' "${PORT:-8080}"
printf '\n  Retour arrière :\n    sudo sh %s --rollback\n\n' "$0"
