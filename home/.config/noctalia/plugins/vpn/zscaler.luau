-- Zscaler bar toggle: icon reflects whether zstunnel is running; left click starts/stops it,
-- right click opens a menu mirroring the official tray menu.
local common = require("./common.luau")

local active = false
local busy = false

local function render()
  common.applyState(
    active,
    "cloud-lock",
    "cloud-off",
    active and "Zscaler: connected (click to stop, right-click for menu)" or "Zscaler: stopped (click to start)"
  )
end

local function refresh()
  common.isActive(common.ZSCALER, function(value)
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
  common.toggle(common.ZSCALER, common.TAILSCALE, active, function()
    busy = false
    refresh()
  end)
end

function onRightClick()
  noctalia.togglePanel("victor/vpn:zscaler-menu")
end

-- `noctalia msg plugin <id> focused toggle` acts like a left click (handy for keybinds).
function onIpc(event)
  if event == "toggle" then
    onClick()
  end
end

render()
