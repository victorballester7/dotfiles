-- Shared helpers for the VPN widgets: query and switch systemd units.
local M = {}

-- `units` are switched in order; `status` decides whether the VPN counts as up.
-- zsaservice watches zstunnel and restarts it within a second, so it must go down first.
M.TAILSCALE = { name = "Tailscale", status = "tailscaled.service", units = { "tailscaled.service" } }
M.ZSCALER = { name = "Zscaler", status = "zstunnel.service", units = { "zsaservice.service", "zstunnel.service" } }

function M.isActive(vpn, cb)
  noctalia.runAsync({ "systemctl", "is-active", "--quiet", vpn.status }, function(result)
    cb(result.exitCode == 0)
  end)
end

-- runAsync kills commands after 5s by default; tailscaled alone takes ~5s to stop and
-- zstunnel allows itself 10s (TimeoutStopSec), so give systemctl room to finish.
local SYSTEMCTL_TIMEOUT_MS = 30000

-- --no-ask-password: fail instead of popping a polkit prompt if the rule is missing.
local function setUnits(vpn, start, index, cb)
  local unit = vpn.units[index]
  if unit == nil then
    cb()
    return
  end
  local verb = start and "start" or "stop"
  noctalia.runAsync({ "systemctl", "--no-ask-password", verb, unit }, function(result)
    if result.exitCode ~= 0 then
      local reason = result.stderr
      if result.timedOut then
        reason = `{unit} did not {verb} within {SYSTEMCTL_TIMEOUT_MS // 1000}s`
      elseif reason == "" then
        reason = `systemctl {verb} {unit} exited with code {result.exitCode}`
      end
      noctalia.notifyError(`Could not {verb} {vpn.name}`, reason)
      cb()
      return
    end
    setUnits(vpn, start, index + 1, cb)
  end, SYSTEMCTL_TIMEOUT_MS)
end

-- Toggle `vpn`, refusing to start it while `other` is up.
function M.toggle(vpn, other, active, cb)
  if active then
    setUnits(vpn, false, 1, cb)
    return
  end
  M.isActive(other, function(otherActive)
    if otherActive then
      noctalia.notify(`{other.name} is connected`, `Manually disable {other.name} to enable {vpn.name}.`)
      cb()
    else
      setUnits(vpn, true, 1, cb)
    end
  end)
end

-- Same colouring as the built-in caffeine toggle: primary when on, the normal icon colour when off.
function M.applyState(active, onGlyph, offGlyph, tooltip)
  barWidget.setGlyph(active and onGlyph or offGlyph)
  barWidget.setGlyphColor(active and "primary" or "on_surface")
  barWidget.setTooltip(tooltip)
end

function M.pollMs()
  return (noctalia.getConfig("poll_seconds") or 3) * 1000
end

return M
