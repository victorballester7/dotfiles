-- Notify once when RAM usage crosses the threshold; re-arm after it drops back below
-- (threshold - rearm_margin) so a value hovering at the limit doesn't spam.
local threshold = noctalia.getConfig("threshold") or 85
local margin = noctalia.getConfig("rearm_margin") or 5
local armed = true

noctalia.setUpdateInterval((noctalia.getConfig("poll_seconds") or 5) * 1000)

local function readMeminfo()
  local text = noctalia.readFile("/proc/meminfo")
  if text == nil then
    return nil
  end
  local total = tonumber(string.match(text, "MemTotal:%s+(%d+)"))
  local available = tonumber(string.match(text, "MemAvailable:%s+(%d+)"))
  if total == nil or available == nil or total == 0 then
    return nil
  end
  return total, available
end

function update()
  local total, available = readMeminfo()
  if total == nil then
    return
  end
  local usedKiB = total - available
  local pct = usedKiB / total * 100

  if armed and pct >= threshold then
    armed = false
    noctalia.notifyError(
      "High memory usage",
      string.format("RAM at %.0f%% (%.1f / %.1f GiB used)", pct, usedKiB / 1048576, total / 1048576)
    )
  elseif not armed and pct < threshold - margin then
    armed = true
  end
end
