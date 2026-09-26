-- Agrega esto a tu config/binds.lua (Hyprland con config nativa en Lua).
-- Perfiles de layout de monitores (lógica en scripts/monitor-profile.sh,
-- compartida con el plugin de Noctalia)
local monitorProfileScript = "$HOME/.config/hypr/scripts/monitor-profile.sh"
hl.bind(mainMod .. " + CONTROL + ALT + 1", hl.dsp.exec_cmd(monitorProfileScript .. " dual"))
hl.bind(mainMod .. " + CONTROL + ALT + 2", hl.dsp.exec_cmd(monitorProfileScript .. " extended"))
hl.bind(mainMod .. " + CONTROL + ALT + 3", hl.dsp.exec_cmd(monitorProfileScript .. " mirror"))
