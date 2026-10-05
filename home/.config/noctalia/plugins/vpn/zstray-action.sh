#!/usr/bin/env sh
# Trigger an entry of the Zscaler tray menu (ZSTray) by its label, e.g. "Open Zscaler" or "Export Logs".
# Goes through the tray's dbusmenu so it runs exactly what the official right-click menu does.
label="$1"

find_tray() {
  busctl --user get-property org.kde.StatusNotifierWatcher /StatusNotifierWatcher \
    org.kde.StatusNotifierWatcher RegisteredStatusNotifierItems 2>/dev/null |
    grep -oE '"[^"]+"' | tr -d '"' | while read -r item; do
      service=${item%%/*}
      if busctl --user get-property "$service" /StatusNotifierItem org.kde.StatusNotifierItem Id 2>/dev/null |
        grep -q '"ZSTray"'; then
        echo "$service"
        return
      fi
    done
}

service=$(find_tray)
if [ -z "$service" ]; then
  # Tray not running: start it and give it a moment to register.
  systemctl --user start ZSTray.service
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    sleep 1
    service=$(find_tray)
    [ -n "$service" ] && break
  done
fi
[ -z "$service" ] && { echo "ZSTray tray icon not found" >&2; exit 1; }

# One menu item per line: "(ia{sv}av) <id> <nprops> ..." -> pick the id of the item with this label.
id=$(busctl --user -- call "$service" /MenuBar com.canonical.dbusmenu GetLayout iias 0 -1 0 |
  sed 's/(ia{sv}av)/\n/g' | grep -F "\"label\" s \"$label\"" | awk '{print $1}' | head -1)
[ -z "$id" ] && { echo "menu entry '$label' not found" >&2; exit 1; }

busctl --user -- call "$service" /MenuBar com.canonical.dbusmenu Event isvu "$id" clicked s "" 0
