#!/usr/bin/env bash
# Instala el script de perfiles de monitor y registra el plugin de Noctalia
# como fuente de desarrollo local. No toca binds.lua automáticamente: eso se
# agrega a mano (ver hypr/binds-snippet.lua y el README).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.config/hypr/scripts"
cp "$REPO_DIR/hypr/monitor-profile.sh" "$HOME/.config/hypr/scripts/monitor-profile.sh"
chmod +x "$HOME/.config/hypr/scripts/monitor-profile.sh"
echo "-> Copiado a $HOME/.config/hypr/scripts/monitor-profile.sh"

if command -v noctalia >/dev/null 2>&1; then
    noctalia msg plugins source add monitor-profile-switcher-local path "$REPO_DIR/plugin"
    noctalia msg plugins enable jdl/monitor-profile-switcher
    echo "-> Plugin de Noctalia habilitado (jdl/monitor-profile-switcher)"
else
    echo "-> Noctalia no está en PATH; omití el registro del plugin. Hazlo a mano:"
    echo "     noctalia msg plugins source add monitor-profile-switcher-local path '$REPO_DIR/plugin'"
    echo "     noctalia msg plugins enable jdl/monitor-profile-switcher"
fi

cat <<EOF

Pasos que quedan (manuales, uno por máquina):

1. Verifica tus salidas reales con: hyprctl monitors
   Edita MON1/MON2/MON3 al inicio de
   $HOME/.config/hypr/scripts/monitor-profile.sh si no coinciden con
   DP-2 / DP-3 / HDMI-A-1.

2. Copia el contenido de hypr/binds-snippet.lua dentro de tu config/binds.lua
   (o el archivo de keybinds de tu config de Hyprland), y luego:
     hyprctl reload

3. En Noctalia: Settings -> Bar -> agrega el widget
   "Monitor Profile Switcher -> toggle" a la sección que quieras.
EOF
