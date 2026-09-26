--!nonstrict

local glyphs = {
  dual     = "device-desktop",
  extended = "device-tv",
  mirror   = "switch-horizontal",
}

local labels = {
  dual     = "Dual",
  extended = "Extended",
  mirror   = "Mirror",
}

local current = noctalia.state.get("profile") or "extended"

local function render()
  barWidget.setGlyph(glyphs[current] or "devices")
  barWidget.setText(labels[current] or current)
  barWidget.setTooltip({
    { key = "Profile", value = labels[current] or current },
    { key = "", value = "Click to cycle: dual → extended → mirror" },
  })
end

noctalia.state.watch("profile", function(value)
  if value then
    current = value
    render()
  end
end)

function onClick()
  noctalia.runAsync("noctalia msg plugin jdl/monitor-profile-switcher:poller all cycle")
end

render()
