#!/usr/bin/env bash
# Usage: monitor-profile.sh {dual|extended|mirror}
#
# Reescribe config/monitors.lua con el bloque de MONITOR3 correspondiente al
# perfil elegido y recarga con `hyprctl reload`. Se reescribe el archivo (en
# vez de aplicar el cambio solo en vivo con `hyprctl eval`) porque un reload
# posterior -manual o disparado por otra cosa (ej. cambio de wallpaper/tema)-
# vuelve a leer este archivo desde cero y descartaría cualquier cambio hecho
# solo en memoria, regresando siempre al perfil "extended" que quedaría
# declarado en el archivo. Así el perfil activo persiste entre reloads.
set -euo pipefail

MONITORS_LUA="$HOME/.config/hypr/config/monitors.lua"

case "${1:-}" in
  dual)
    MON3_BLOCK='hl.monitor({
    output    = MONITOR3,
    disabled  = true,
    mirror    = "",
})'
    ;;
  extended)
    MON3_BLOCK='hl.monitor({
    output    = MONITOR3,
    mode      = "1920x1080@60",
    position  = "1920x-1080",
    scale     = "1",
    disabled  = false,
    mirror    = "",
})'
    ;;
  mirror)
    MON3_BLOCK='hl.monitor({
    output    = MONITOR3,
    mode      = "1920x1080@60",
    position  = "0x0",
    scale     = "1",
    disabled  = false,
    mirror    = MONITOR2,
})'
    ;;
  *)
    echo "Usage: $0 {dual|extended|mirror}" >&2
    exit 1
    ;;
esac

cat > "$MONITORS_LUA" <<EOF
-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Example: output can be found with hyprctl monitors. Edit variables.lua for the monitor outputs instead of here directly
-- hl.monitor({
--     output    = "MONITOR1",
--     mode      = "1920x1080@60",
--     position  = "0x0",
--     scale     = "1",
-- })

hl.monitor({
    output    = MONITOR1,
    mode      = "preferred",
    position  = "0x0",
    scale     = "auto",
})

hl.monitor({
    output    = MONITOR2,
    mode      = "preferred",
    position  = "1920x0",
    scale     = "auto",
})

-- Perfil activo: ${1}. Cambiar con scripts/monitor-profile.sh {dual|extended|mirror}
$MON3_BLOCK
EOF

hyprctl reload
