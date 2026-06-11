-- Load custom modules
function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%d %b %H:%M", time)
	else
		time = os.date("%d %b  %Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

-- Plugin Configurations
local function setup_pref_by_location()
	local pref_by_location = require("pref-by-location")
	pref_by_location:setup({
		-- Disable this plugin completely.
		-- disabled = false -- true|false (Optional)

		-- Hide "enable" and "disable" notifications.
		-- no_notify = false -- true|false (Optional)

		-- Disable the fallback/default preference (values in `yazi.toml`).
		-- This mean if none of the saved or predifined perferences is matched,
		-- then it won't reset preference to default values in yazi.toml.
		-- For example, go from folder A to folder B (folder B matchs saved preference to show hidden files) -> show hidden.
		-- Then move back to folder A -> keep showing hidden files, because the folder A doesn't match any saved or predefined preference.
		-- disable_fallback_preference = false -- true|false|nil (Optional)

		-- You can backup/restore this file. But don't use same file in the different OS.
		-- save_path =  -- full path to save file (Optional)
		--       - Linux/MacOS: os.getenv("HOME") .. "/.config/yazi/pref-by-location"
		--       - Windows: os.getenv("APPDATA") .. "\\yazi\\config\\pref-by-location"

		-- https://github.com/MasouShizuka/projects.yazi compatibility
		-- If you use projects.yazi plugin and changed it's default yazi_load_event config, you have to set this value to equal projects.yazi > setup function > save > yazi_load_event. Default is "@projects-load"
		-- project_plugin_load_event = "@projects-load" -- string (Optional)

		-- This is predefined preferences.
		prefs = { -- (Optional)
			-- location: String | Lua pattern (Required)
			--   - Support literals full path, lua pattern (string.match pattern): https://www.lua.org/pil/20.2.html
			--     And don't put ($) sign at the end of the location. %$ is ok.
			--   - If you want to use special characters (such as . * ? + [ ] ( ) ^ $ %) in "location"
			--     you need to escape them with a percent sign (%) or use a helper funtion `pref_by_location.is_literal_string`
			--     Example: "/home/test/Hello (Lua) [world]" => { location = "/home/test/Hello %(Lua%) %[world%]", ....}
			--     or { location = pref_by_location.is_literal_string("/home/test/Hello (Lua) [world]"), .....}

			-- sort: {} (Optional) https://yazi-rs.github.io/docs/configuration/yazi#mgr.sort_by
			--   - extension: "none"|"mtime"|"btime"|"extension"|"alphabetical"|"natural"|"size"|"random", (Optional)
			--   - reverse: true|false (Optional)
			--   - dir_first: true|false (Optional)
			--   - translit: true|false (Optional)
			--   - sensitive: true|false (Optional)

			-- linemode: "none" |"size" |"btime" |"mtime" |"permissions" |"owner" (Optional) https://yazi-rs.github.io/docs/configuration/yazi#mgr.linemode
			--   - Custom linemode also work. See the example below

			-- show_hidden: true|false (Optional) https://yazi-rs.github.io/docs/configuration/yazi#mgr.show_hidden

			-- Some examples:
			-- Match any folder which has path start with "/mnt/remote/". Example: /mnt/remote/child/child2
			{ location = "^/mnt/remote/.*", sort = { "extension", reverse = false, dir_first = true, sensitive = false} },
			-- Match any folder with name "Downloads"
			{ location = ".*/Downloads", sort = { "btime", reverse = true, dir_first = true }, linemode = "btime" },
			-- Match exact folder with absolute path "/home/test/Videos".
			-- Use helper function `pref_by_location.is_literal_string` to prevent the case where the path contains special characters
			{ location = pref_by_location.is_literal_string("/home/test/Videos"), sort = { "btime", reverse = true, dir_first = true }, linemode = "btime" },

			-- show_hidden for any folder with name "secret"
			{
				location = ".*/secret",
				sort = { "natural", reverse = false, dir_first = true },
				linemode = "size",
				show_hidden = true,
			},

			-- Custom linemode also work
			{
				location = ".*/abc",
				linemode = "size_and_mtime",
			},
			-- DO NOT ADD location = ".*". Which currently use your yazi.toml config as fallback.
			-- That mean if none of the saved perferences is matched, then it will use your config from yazi.toml.
			-- So change linemode, show_hidden, sort_xyz in yazi.toml instead.
		},
	})
end

return {
	setup_pref_by_location = setup_pref_by_location,
}

