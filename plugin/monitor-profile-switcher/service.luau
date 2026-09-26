--!nonstrict
-- Polls real Hyprland state to detect which monitor profile is active
-- (independent of whether it was set via this plugin, the Hyprland keybinds,
-- or a raw hyprctl call), and applies profile changes via the same shared
-- script the keybinds use, so the logic lives in one place.

local SCRIPT = "$HOME/.config/hypr/scripts/monitor-profile.sh"
local STATE_KEY = "profile"
local order = { "dual", "extended", "mirror" }
local lastProfile = nil

noctalia.setUpdateInterval(1000)

local function detect(data)
  local tv = nil
  for _, m in ipairs(data) do
    if m.name == "HDMI-A-1" then
      tv = m
    end
  end
  if tv == nil then
    return "unknown"
  end
  if tv.disabled == true then
    return "dual"
  end
  if tv.mirrorOf ~= nil and tv.mirrorOf ~= "none" then
    return "mirror"
  end
  return "extended"
end

local function poll()
  if not noctalia.commandExists("hyprctl") then
    return
  end
  -- "all" is required: a disabled monitor is omitted from the default listing.
  noctalia.runAsync("hyprctl monitors all -j", function(result)
    if result.exitCode ~= 0 then
      return
    end
    local data = noctalia.json.decode(result.stdout)
    if data == nil then
      return
    end
    local profile = detect(data)
    if profile ~= lastProfile then
      lastProfile = profile
      noctalia.state.set(STATE_KEY, profile)
    end
  end)
end

local function apply(profile)
  noctalia.runAsync(SCRIPT .. " " .. profile)
  lastProfile = profile
  noctalia.state.set(STATE_KEY, profile) -- optimistic; poll() confirms next tick
end

local function cycle()
  local idx = 1
  for i, p in ipairs(order) do
    if p == lastProfile then
      idx = (i % #order) + 1
      break
    end
  end
  apply(order[idx])
end

function onIpc(event)
  if event == "cycle" then
    cycle()
  elseif event == "dual" or event == "extended" or event == "mirror" then
    apply(event)
  end
end

function update()
  poll()
end

poll()
