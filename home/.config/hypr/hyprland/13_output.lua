-- Monitor layouts are machine-specific: they live in hosts/<hostname>.lua.
-- Machines without a file there just get Hyprland's defaults (preferred mode, auto position).
local function hostname()
  local ok, f = pcall(io.open, "/etc/hostname", "r")
  if not ok or not f then return nil end
  local name = f:read("*l")
  f:close()
  return name
end

local host = hostname()
if host then
  local ok, err = pcall(require, "hosts." .. host)
  if not ok and not tostring(err):find("not found", 1, true) then
    error(err)
  end
end

hl.on("monitor.added", function(monitor)
  hl.exec_cmd("~/.config/hypr/scripts/get_bing_image.sh")
end)
