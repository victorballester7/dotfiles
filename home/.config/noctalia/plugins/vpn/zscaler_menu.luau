-- Right-click menu for the Zscaler widget. Entries are forwarded to the official ZSTray
-- menu over dbusmenu (zstray-action.sh), so they behave exactly like the tray's.
local function trayAction(label)
  noctalia.runAsync({ noctalia.pluginDir() .. "/zstray-action.sh", label }, function(result)
    if result.exitCode ~= 0 then
      noctalia.notifyError("Zscaler", result.stderr)
    end
  end)
  panel.close()
end

local function item(text, glyph, label)
  return ui.button({
    text = text,
    glyph = glyph,
    variant = "ghost",
    contentAlign = "start",
    onClick = function()
      trayAction(label)
    end,
  })
end

function onOpen()
  panel.render(ui.column({ gap = 4, padding = 6 }, {
    item("Open Zscaler", "external-link", "Open Zscaler"),
    item("Export Logs", "file-export", "Export Logs"),
  }))
end
