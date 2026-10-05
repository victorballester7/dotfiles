-- Tailscale bar toggle: glyph reflects whether tailscaled is running; click starts/stops it.
local common = require("./common.luau")

local active = false
local busy = false

local function render()
  common.applyState(
    active,
    "grid-dots",
    "network-off",
    active and "Tailscale: running (click to stop)" or "Tailscale: stopped (click to start)"
  )
end

local function refresh()
  common.isActive(common.TAILSCALE, function(value)
    active = value
    render()
  end)
end

function update()
  noctalia.setUpdateInterval(common.pollMs())
  if not busy then
    refresh()
  end
end

function onClick()
  if busy then
    return
  end
  busy = true
  common.toggle(common.TAILSCALE, common.ZSCALER, active, function()
    busy = false
    refresh()
  end)
end

-- `noctalia msg plugin <id> focused toggle` acts like a left click (handy for keybinds).
function onIpc(event)
  if event == "toggle" then
    onClick()
  end
end

render()
