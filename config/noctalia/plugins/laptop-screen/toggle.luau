-- Laptop screen toggle: glyph reflects whether the internal output is enabled in Hyprland;
-- click flips it. Refuses to turn it off when it is the only enabled screen.
local output = noctalia.getConfig("output") or "eDP-1"

local enabled = true
local othersEnabled = 0
local busy = false

local function render()
  if enabled then
    barWidget.setGlyph("device-laptop")
    barWidget.setGlyphColor("on_surface")
    barWidget.setTooltip("Laptop screen: on (click to turn off)")
  else
    barWidget.setGlyph("device-laptop-off")
    barWidget.setGlyphColor("on_surface")
    barWidget.setTooltip("Laptop screen: off (click to turn on)")
  end
end

local function refresh(cb)
  noctalia.runAsync({ "hyprctl", "-j", "monitors", "all" }, function(result)
    local monitors = result.exitCode == 0 and noctalia.json.decode(result.stdout)
    if type(monitors) == "table" then
      othersEnabled = 0
      for _, monitor in monitors do
        if monitor.name == output then
          enabled = not monitor.disabled
        elseif not monitor.disabled then
          othersEnabled += 1
        end
      end
      render()
    end
    if cb then
      cb()
    end
  end)
end

function update()
  noctalia.setUpdateInterval(2000)
  if not busy then
    refresh()
  end
end

function onClick()
  if busy then
    return
  end
  if enabled and othersEnabled == 0 then
    noctalia.notify("Laptop screen", "No external monitor is active, keeping the laptop screen on.")
    return
  end
  busy = true
  local expr = string.format('hl.monitor({output="%s", disabled = %s})', output, enabled and "true" or "false")
  noctalia.runAsync({ "hyprctl", "eval", expr }, function()
    refresh(function()
      busy = false
    end)
  end)
end

-- `noctalia msg plugin <id> focused toggle` acts like a left click (handy for keybinds).
function onIpc(event)
  if event == "toggle" then
    onClick()
  end
end

render()
