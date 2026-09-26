# hyprland-monitor-profiles

> ⚠️ Gran parte del código de este plugin fue creado con Claude Code (Sonnet 5). 
Con el plugin solo busco dar solución a un problema puntual de mi sistema, 
pero lo dejo público en caso de que sea útil para alguien más.

Cambia rápido entre 3 configuraciones de monitores en Hyprland (config nativa
en Lua), con un widget en la barra de [Noctalia](https://noctalia.dev) y 3
atajos de teclado directos. Pensado originalmente para un setup de 2
monitores + TV, pero sirve como plantilla para cualquier combinación de
salidas fijas.

Perfiles incluidos (editables en `hypr/monitor-profile.sh`):

1. **dual** — solo monitor1 + monitor2, la TV apagada.
2. **extended** — los 3 activos, TV extendida sobre el monitor2.
3. **mirror** — TV en espejo del monitor2.

## Por qué existe

No hay plugin oficial ni comunitario de Noctalia para esto. Se evaluaron dos
externos y ninguno sirve: uno es exclusivo de Niri, el otro usa una
arquitectura de plugin QML incompatible con el sistema de plugins Luau
(`plugin.toml` + `.luau`) que usa Noctalia desde la v5. Este repo es una
implementación propia, sobre esa arquitectura Luau.

## Cómo funciona

- `hypr/monitor-profile.sh` reescribe `~/.config/hypr/config/monitors.lua`
  con el bloque de la TV correspondiente al perfil elegido, y hace
  `hyprctl reload`. Se reescribe el archivo (en vez de aplicar el cambio solo
  en vivo con `hyprctl eval`) porque un reload posterior —manual o
  disparado por otra cosa, como un cambio de wallpaper/tema— vuelve a leer
  ese archivo desde cero y descartaría cualquier cambio hecho solo en
  memoria. Así el perfil activo persiste entre reloads.
- El plugin de Noctalia (`plugin/monitor-profile-switcher/`) no aplica la
  lógica por su cuenta: su `service.luau` sondea `hyprctl monitors all -j`
  cada segundo para detectar qué perfil está activo realmente (por si se
  cambió con los atajos o a mano), y llama al mismo script cuando se hace
  clic en el widget o llega un evento IPC. Lógica en un solo lugar, no
  duplicada en Lua (Hyprland) y Luau (Noctalia).
- Los atajos de teclado (`hypr/binds-snippet.lua`) llaman al script
  directamente, así que funcionan aunque la barra de Noctalia esté caída.

Nota sobre Hyprland con config Lua nativa: `hyprctl keyword monitor ...` no
funciona ahí ("keyword can't work with non-legacy parsers") — el equivalente
en vivo es `hyprctl eval` ejecutando `hl.monitor({...})`, la misma función
que usa `monitors.lua`. El script usa esa función tanto para aplicar en vivo
como para lo que escribe en el archivo.

## Requisitos

- Hyprland con config nativa en Lua (el estilo `hl.monitor({...})`,
  `hl.bind(...)`), **no** el `hyprland.conf` clásico.
- Noctalia v5+ (sistema de plugins Luau).
- 3 salidas de video fijas, mismo concepto que este setup (2 monitores + 1
  TV); si tu combinación es distinta, el script es la plantilla a adaptar.

## Instalación

```sh
git clone https://github.com/JDLeongomez/hyprland-monitor-profiles ~/Documents/GitHub/hyprland-monitor-profiles
cd ~/Documents/GitHub/hyprland-monitor-profiles
./install.sh
```

`install.sh` copia el script a `~/.config/hypr/scripts/monitor-profile.sh` y
registra el plugin como fuente local de desarrollo en Noctalia
(`noctalia msg plugins source add ... path`). Lo que no automatiza, porque
depende de tu config y tu hardware:

1. **Editar las salidas.** Averigua las tuyas con `hyprctl monitors` y
   ajusta `MON1`/`MON2`/`MON3` al inicio de
   `~/.config/hypr/scripts/monitor-profile.sh`.
2. **Agregar los atajos.** Copia el contenido de `hypr/binds-snippet.lua`
   dentro de tu `config/binds.lua` (o el archivo de keybinds que uses), y
   `hyprctl reload`.
3. **Agregar el widget.** En Noctalia: Settings → Bar → agrega
   "Monitor Profile Switcher → toggle" a la sección que quieras.

## Uso

- Atajos: `SUPER+CONTROL+ALT+1` (dual), `+2` (extended), `+3` (mirror).
- Clic en el widget de la barra: cicla dual → extended → mirror → dual.
- IPC directo:
  ```sh
  noctalia msg plugin jdl/monitor-profile-switcher:poller all dual
  noctalia msg plugin jdl/monitor-profile-switcher:poller all extended
  noctalia msg plugin jdl/monitor-profile-switcher:poller all mirror
  noctalia msg plugin jdl/monitor-profile-switcher:poller all cycle
  ```
- Directo por shell: `~/.config/hypr/scripts/monitor-profile.sh {dual|extended|mirror}`.

## Verificación

```sh
~/.config/hypr/scripts/monitor-profile.sh dual
hyprctl monitors all -j   # la TV debe salir con "disabled": true
~/.config/hypr/scripts/monitor-profile.sh extended
hyprctl monitors all -j   # "disabled": false, "mirrorOf": "none"
~/.config/hypr/scripts/monitor-profile.sh mirror
hyprctl monitors all -j   # "mirrorOf" apunta al monitor2
```

`hyprctl monitors` (sin `all`) omite las salidas deshabilitadas — usa
siempre `all` para confirmar el estado real.

## Limitaciones conocidas

- Los nombres de salida (`DP-2`, `DP-3`, `HDMI-A-1`) están codificado de forma fija al
  inicio de `monitor-profile.sh`. En otra máquina, con otro hardware, hay que
  editarlos a mano, y no es una configuración que se pueda cambiar desde la UI de Noctalia
  (generalizarlo así solo tendría sentido para publicarlo en el
  catálogo comunitario, que no es el objetivo de este repo).
- Requiere que tu config de Hyprland use el estilo Lua nativo
  (`hl.monitor`, `hl.bind`); no aplica a un `hyprland.conf` clásico sin
  adaptar los comandos.
