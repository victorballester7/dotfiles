--- @since 26.9.1
-- One menu for every kind of mount: USB sticks and internal drives, phones (MTP)
-- and cameras (via gvfs), network shares (sftp://, smb://, ...), sshfs hosts and
-- custom mounts such as rclone. Keyboard and mouse driven.

local HOME = os.getenv("HOME")

local KEYS = {
	{ on = "q", run = "quit" },
	{ on = "<Esc>", run = "quit" },
	{ on = "k", run = "up" },
	{ on = "<Up>", run = "up" },
	{ on = "j", run = "down" },
	{ on = "<Down>", run = "down" },
	{ on = "<Enter>", run = "open" },
	{ on = "l", run = "open" },
	{ on = "<Right>", run = "open" },
	{ on = "m", run = "mount" },
	{ on = "u", run = "unmount" },
	{ on = "e", run = "eject" },
	{ on = "a", run = "add" },
	{ on = "r", run = "refresh" },
}

-- Footer: { key, description, action }. Each hint is also clickable.
local HINTS = {
	{ "↵", "open", "open" },
	{ "m", "mount", "mount" },
	{ "u", "unmount", "unmount" },
	{ "e", "eject", "eject" },
	{ "a", "add URI", "add" },
	{ "r", "refresh", "refresh" },
	{ "q", "close", "quit" },
}

local KINDS = {
	usb = { "󰕓", "USB" },
	disk = { "󰋊", "Disk" },
	phone = { "󰄜", "Phone" },
	camera = { "󰄀", "Camera" },
	optical = { "󰗮", "Optical" },
	ssh = { "󰣀", "SSH" },
	cloud = { "󰅟", "Cloud" },
	network = { "󰛳", "Network" },
	other = { "󰉋", "Mount" },
}

local SCHEME_KINDS = {
	sftp = "ssh",
	ssh = "ssh",
	smb = "network",
	ftp = "network",
	ftps = "network",
	dav = "network",
	davs = "network",
	nfs = "network",
	afp = "network",
	mtp = "phone",
	afc = "phone",
	gphoto2 = "camera",
	google = "cloud",
	onedrive = "cloud",
}

-- Sync state ------------------------------------------------------------------

local get_opts = ya.sync(function(self)
	return {
		remotes = self.remotes or {},
		ssh_config = self.ssh_config ~= false,
		hosts_dir = self.hosts_dir or (HOME .. "/hosts"),
		sshfs_opts = self.sshfs_opts or { "reconnect", "ServerAliveInterval=15", "ServerAliveCountMax=3" },
	}
end)

local show = ya.sync(function(self)
	if not self.children then
		self.children = Modal:children_add(self, 10)
	end
	self.cursor, self.offset, self.pending, self.status = self.cursor or 0, 0, nil, nil
	ui.render()
end)

local hide = ya.sync(function(self)
	if self.children then
		Modal:children_remove(self.children)
		self.children = nil
	end
	ui.render()
end)

local is_open = ya.sync(function(self) return self.children ~= nil end)

local set_entries = ya.sync(function(self, entries)
	-- Keep the cursor on the same entry when the list changes under it
	local id = self.entries and self.entries[(self.cursor or 0) + 1] and self.entries[self.cursor + 1].id
	self.entries = entries
	self.cursor = 0
	for i, e in ipairs(entries) do
		if e.id == id then
			self.cursor = i - 1
		end
	end
	ui.render()
end)

local move_cursor = ya.sync(function(self, step)
	local n = #(self.entries or {})
	self.cursor = n == 0 and 0 or ya.clamp(0, self.cursor + step, n - 1)
	ui.render()
end)

local current = ya.sync(function(self) return self.entries and self.entries[self.cursor + 1] end)

local take_pending = ya.sync(function(self)
	local run = self.pending
	self.pending = nil
	return run
end)

local set_status = ya.sync(function(self, status)
	self.status = status
	ui.render()
end)

local get_cwd = ya.sync(function() return tostring(cx.active.current.cwd) end)

-- Helpers ---------------------------------------------------------------------

local function expand(path) return (path:gsub("^~", HOME)) end

local function shorten(path)
	if path and path:sub(1, #HOME) == HOME then
		return "~" .. path:sub(#HOME + 1)
	end
	return path
end

local function unescape_uri(s) return (s:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)) end

local function concat(a, b)
	local t = {}
	for _, v in ipairs(a) do
		t[#t + 1] = v
	end
	for _, v in ipairs(b) do
		t[#t + 1] = v
	end
	return t
end

local function errmsg(out)
	local s = (out.stderr ~= "" and out.stderr or out.stdout):gsub("%s+$", "")
	return s ~= "" and s or ("exit code " .. tostring(out.status.code))
end

-- Run a command, returning stdout on success or nil + error message
local function run(cmd, args, input)
	local child, err = Command(cmd)
		:arg(args)
		:stdin(input and Command.PIPED or Command.NULL)
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()
	if not child then
		return nil, string.format("%s: %s", cmd, err)
	end
	if input then
		child:write_all(input)
		child:flush()
	end
	local out, err = child:wait_with_output()
	if not out then
		return nil, tostring(err)
	elseif not out.status.success then
		return nil, errmsg(out)
	end
	return out.stdout
end

-- Like `run`, for commands that daemonize (sshfs, rclone --daemon): their
-- background children inherit stdio, so a pipe would never reach EOF. Collect
-- stderr in a file instead.
local function run_daemon(cmd, args, input)
	local log = string.format("%s/yazi-mounts-%d.log", os.getenv("XDG_RUNTIME_DIR") or "/tmp", math.floor(ya.time() * 1000))
	local child, err = Command("sh")
		:arg(concat({ "-c", 'log=$1; shift; exec "$@" >/dev/null 2>"$log"', "sh", log, cmd }, args))
		:stdin(input and Command.PIPED or Command.NULL)
		:stdout(Command.NULL)
		:stderr(Command.NULL)
		:spawn()
	if not child then
		return nil, string.format("%s: %s", cmd, err)
	end
	if input then
		child:write_all(input)
		child:flush()
	end
	local status = child:wait()

	local msg = ""
	local f = io.open(log, "r")
	if f then
		msg = f:read("a"):gsub("%s+$", "")
		f:close()
		os.remove(log)
	end
	if status and status.success then
		return true
	end
	return nil, msg ~= "" and msg or ("exit code " .. tostring(status and status.code))
end

local function ask_password(what)
	local value, event = ya.input {
		title = "Password for " .. what .. ":",
		obscure = true,
		pos = { "center", w = 50 },
	}
	if event == 1 then
		return value
	end
end

local function notify(content, level)
	ya.notify { title = "Mounts", content = content, timeout = level == "error" and 8 or 3, level = level or "info" }
end

-- Translate a gvfs URI to the local FUSE path yazi can browse
local function local_path(uri)
	if not uri then
		return nil
	elseif uri:sub(1, 7) == "file://" then
		return unescape_uri(uri:sub(8))
	end
	local out = run("gio", { "info", "-a", "standard::name", uri })
	return out and out:match("\nlocal path: ([^\n]+)")
end

-- Discovery -------------------------------------------------------------------

-- Parse `gio mount -li` into a tree of Drive / Volume / Mount objects
local function gio_objects()
	local out = run("gio", { "mount", "-li" }) or ""
	local objs, stack, cur = {}, {}, nil
	for line in out:gmatch("[^\n]+") do
		local indent, typ, rest = line:match("^(%s*)(%u%l+)%(%d+%): (.*)$")
		if typ == "Drive" or typ == "Volume" or typ == "Mount" then
			while #stack > 0 and stack[#stack].depth >= #indent do
				table.remove(stack)
			end
			cur = { type = typ, depth = #indent, props = {}, children = {}, parent = stack[#stack] }
			if typ == "Mount" then
				cur.name, cur.uri = rest:match("^(.-) %-> (.*)$")
			else
				cur.name = rest
			end
			if cur.parent then
				table.insert(cur.parent.children, cur)
			end
			stack[#stack + 1], objs[#objs + 1] = cur, cur
		elseif cur then
			local k, v = line:match("^%s*([%w_]+)=(.*)$")
			if k then
				cur.props[k] = v
			end
			cur.device = cur.device or line:match("unix%-device: '(.-)'")
		end
	end
	return objs
end

local function volume_kind(vol, drive)
	local root, dev = vol.props.activation_root or "", vol.device or ""
	local scheme = root:match("^(%w+):")
	if scheme and SCHEME_KINDS[scheme] then
		return SCHEME_KINDS[scheme]
	elseif dev:match("^/dev/sr") then
		return "optical"
	elseif dev:match("^/dev/bus/usb") then
		return "phone"
	elseif drive and drive.props.is_removable == "1" then
		return "usb"
	end
	return "disk"
end

local function fuse_mounts()
	local t = {}
	for line in (run("findmnt", { "-rn", "-o", "TARGET,FSTYPE" }) or ""):gmatch("[^\n]+") do
		local target, fstype = line:match("^(%S+) (%S+)$")
		if target then
			t[target:gsub("\\x(%x%x)", function(h) return string.char(tonumber(h, 16)) end)] = fstype
		end
	end
	return t
end

local function ssh_hosts()
	local hosts, seen = {}, {}
	local f = io.open(HOME .. "/.ssh/config", "r")
	if not f then
		return hosts
	end
	for line in f:lines() do
		local names = line:match("^%s*[Hh][Oo][Ss][Tt]%s+(.-)%s*$")
		for name in (names or ""):gmatch("%S+") do
			if not name:find("[*?!]") and not seen[name] then
				seen[name], hosts[#hosts + 1] = true, name
			end
		end
	end
	f:close()
	return hosts
end

local function collect(opts)
	local mounted, objs = fuse_mounts(), gio_objects()
	local devices, others, remotes = {}, {}, {}
	local claimed = {} -- paths / URIs already represented by a remote entry

	-- Configured remotes
	local used_hosts = {}
	for _, r in ipairs(opts.remotes) do
		local e = { id = "remote:" .. r.name, name = r.name, remote = true }
		if r.uri then
			e.backend, e.uri, e.source = "gio-uri", r.uri, r.uri
			e.kind = r.kind or SCHEME_KINDS[r.uri:match("^(%w+):") or ""] or "network"
			claimed[r.uri:gsub("/*$", "")] = true
		elseif r.sshfs then
			e.backend, e.kind, e.source = "sshfs", r.kind or "ssh", r.sshfs
			e.path = expand(r.path or (opts.hosts_dir .. "/" .. r.name))
			used_hosts[r.sshfs:match("^[^@]*@?([^:]+):") or ""] = true
		else
			e.backend, e.kind, e.source = "cmd", r.kind or "other", r.source or ""
			e.path, e.mount_cmd, e.unmount_cmd = expand(r.path), r.mount, r.unmount
		end
		if e.path then
			e.mounted, claimed[e.path] = mounted[e.path] ~= nil, true
		end
		remotes[#remotes + 1] = e
	end

	-- Hosts from ~/.ssh/config not already covered by a configured remote
	if opts.ssh_config then
		for _, host in ipairs(ssh_hosts()) do
			local path = opts.hosts_dir .. "/" .. host
			if not used_hosts[host] and not claimed[path] then
				claimed[path] = true
				remotes[#remotes + 1] = {
					id = "ssh:" .. host,
					backend = "sshfs",
					kind = "ssh",
					name = host,
					source = host .. ":",
					path = path,
					mounted = mounted[path] ~= nil,
					remote = true,
				}
			end
		end
	end

	-- gvfs: volumes (block devices, phones, cameras) and stand-alone mounts
	for _, o in ipairs(objs) do
		if o.type == "Volume" then
			local drive = o.parent and o.parent.type == "Drive" and o.parent or nil
			local mount = o.children[1]
			devices[#devices + 1] = {
				id = "vol:" .. (o.device or o.props.activation_root or o.name),
				backend = "volume",
				kind = volume_kind(o, drive),
				name = o.name,
				source = (o.device and not o.device:match("^/dev/bus/")) and o.device
					or (drive and drive.name)
					or (o.props.activation_root or ""):match("^(%w+):")
					or "",
				device = o.device,
				activation = o.props.activation_root,
				uri = mount and mount.uri,
				path = mount and local_path(mount.uri),
				mounted = mount ~= nil,
				can_eject = (drive and drive.props.can_eject == "1") or o.props.can_eject == "1",
				drive_device = drive and drive.device,
			}
		elseif o.type == "Mount" and not o.parent and o.props.is_shadowed ~= "1" and o.uri then
			local path = o.uri:sub(1, 7) == "file://" and unescape_uri(o.uri:sub(8)) or nil
			local key = path or o.uri:gsub("/*$", "")
			if not claimed[key] then
				local fstype = path and mounted[path] or ""
				local kind = SCHEME_KINDS[o.uri:match("^(%w+):") or ""]
				if fstype == "fuse.sshfs" then
					kind = "ssh"
				elseif fstype == "fuse.rclone" then
					kind = "cloud"
				end
				others[#others + 1] = {
					id = "mount:" .. o.uri,
					backend = fstype:match("^fuse%.") and "fuse" or "gio-mount",
					kind = kind or "other",
					name = o.name,
					source = path and fstype or o.uri,
					uri = o.uri,
					path = path or local_path(o.uri),
					mounted = true,
				}
			end
		end
	end

	-- Mark gio-uri remotes mounted when gvfs reports a mount for them
	for _, e in ipairs(remotes) do
		if e.backend == "gio-uri" then
			for _, o in ipairs(objs) do
				if o.type == "Mount" and o.uri and o.uri:gsub("/*$", "") == e.uri:gsub("/*$", "") then
					e.mounted = true
				end
			end
		end
	end

	local all = {}
	for _, group in ipairs { devices, others, remotes } do
		for _, e in ipairs(group) do
			all[#all + 1] = e
		end
	end
	return all
end

local function refresh() set_entries(collect(get_opts())) end

-- Operations ------------------------------------------------------------------

local function gio_mount_uri(uri)
	local ok, err = run("gio", { "mount", uri })
	if ok or not (err:find("assword") or err:lower():find("auth")) then
		return ok, err
	end
	local pw = ask_password(uri)
	if not pw then
		return nil, "cancelled"
	end
	return run("gio", { "mount", uri }, pw .. "\n")
end

local function sshfs_mount(e, opts)
	fs.create("dir_all", Url(e.path))
	local args = { e.source, e.path }
	for _, o in ipairs(opts.sshfs_opts) do
		args[#args + 1], args[#args + 2] = "-o", o
	end

	local ok, err = run_daemon("sshfs", concat(args, { "-o", "BatchMode=yes" }))
	if ok or not err:lower():find("permission denied") then
		return ok, err
	end
	local pw = ask_password(e.source:match("^[^:]+"))
	if not pw then
		return nil, "cancelled"
	end
	return run_daemon("sshfs", concat(args, { "-o", "password_stdin" }), pw .. "\n")
end

local function do_mount(e)
	if e.mounted then
		return true
	elseif e.backend == "volume" then
		if e.activation then
			return run("gio", { "mount", e.activation })
		end
		return run("gio", { "mount", "-d", e.device })
	elseif e.backend == "gio-uri" then
		return gio_mount_uri(e.uri)
	elseif e.backend == "sshfs" then
		return sshfs_mount(e, get_opts())
	elseif e.backend == "cmd" and e.mount_cmd then
		fs.create("dir_all", Url(e.path))
		return run_daemon(e.mount_cmd[1], { table.unpack(e.mount_cmd, 2) })
	end
	return nil, "Don't know how to mount " .. e.name
end

-- Resolve where an entry is mounted, (re)querying gvfs if needed
local function path_of(e)
	if e.path then
		return e.path
	end
	for _, f in ipairs(collect(get_opts())) do
		if f.id == e.id then
			return local_path(f.uri)
		end
	end
	return local_path(e.uri)
end

-- Leave the mount first, otherwise it's busy and can't be unmounted
local function leave(path)
	local cwd = get_cwd()
	if path and (cwd == path or cwd:sub(1, #path + 1) == path .. "/") then
		ya.emit("cd", { HOME })
		ya.sleep(0.2)
	end
end

local function do_unmount(e, eject)
	if not e.mounted and not (eject and e.backend == "volume") then
		return true
	end
	leave(e.path or local_path(e.uri))

	if e.backend == "volume" then
		if eject and e.can_eject then
			if e.mounted then
				return run("gio", { "mount", "-e", e.uri })
			elseif e.drive_device then
				return run("udisksctl", { "power-off", "-b", e.drive_device })
			end
		end
		return run("gio", { "mount", "-u", e.uri })
	elseif e.backend == "gio-mount" then
		return run("gio", { "mount", "-u", e.uri })
	elseif e.backend == "gio-uri" then
		return run("gio", { "mount", "-u", e.uri })
	elseif e.backend == "cmd" and e.unmount_cmd then
		return run(e.unmount_cmd[1], { table.unpack(e.unmount_cmd, 2) })
	end
	return run("fusermount3", { "-u", e.path })
end

-- Returns true when the menu should close
local function act(action, e)
	if action == "add" then
		local uri, event = ya.input {
			title = "Mount URI (sftp://, smb://, ftp://, dav://…):",
			pos = { "center", w = 60 },
		}
		if event ~= 1 or uri == "" then
			return false
		end
		set_status("Mounting " .. uri .. "…")
		local ok, err = gio_mount_uri(uri)
		set_status(nil)
		if not ok then
			notify(err, "error")
			return false
		end
		local path = local_path(uri)
		if path then
			ya.emit("cd", { path })
			return true
		end
		refresh()
		return false
	end

	if not e then
		return false
	elseif action == "mount" or action == "open" then
		if not e.mounted then
			set_status("Mounting " .. e.name .. "…")
			local ok, err = do_mount(e)
			set_status(nil)
			if not ok then
				notify(string.format("Failed to mount %s:\n%s", e.name, err), "error")
				refresh()
				return false
			end
			notify("Mounted " .. e.name)
		end
		refresh()
		if action == "open" then
			local path = path_of(e)
			if path then
				ya.emit("cd", { path })
				return true
			end
			notify("Can't find a local path for " .. e.name, "warn")
		end
	elseif action == "unmount" or action == "eject" then
		local eject = action == "eject"
		set_status((eject and "Ejecting " or "Unmounting ") .. e.name .. "…")
		local ok, err = do_unmount(e, eject)
		set_status(nil)
		if ok then
			notify((eject and "Ejected " or "Unmounted ") .. e.name .. (eject and e.can_eject and ", safe to remove" or ""))
		else
			notify(string.format("Failed to %s %s:\n%s", action, e.name, err), "error")
		end
		refresh()
	end
	return false
end

-- Plugin ----------------------------------------------------------------------

local M = {}

function M:setup(opts)
	opts = opts or {}
	self.remotes = opts.remotes
	self.ssh_config = opts.ssh_config
	self.hosts_dir = opts.hosts_dir and expand(opts.hosts_dir)
	self.sshfs_opts = opts.sshfs_opts

	-- Yazi only forwards mouse events to components while the file manager
	-- has focus, but the menu holds a key prompt. Route them here ourselves.
	local st, click, scroll = self, Root.click, Root.scroll
	local function inside(event)
		local a = st._area
		return a and event.x >= a.x and event.x < a.x + a.w and event.y >= a.y and event.y < a.y + a.h
	end
	function Root:click(event, up)
		if not st.children then
			return click(self, event, up)
		elseif inside(event) then
			return st:click(event, up)
		elseif not up then
			st.pending = "quit" -- click outside closes the menu
			ya.emit("which:dismiss", {})
		end
	end
	function Root:scroll(event, step)
		if not st.children then
			return scroll(self, event, step)
		elseif inside(event) then
			return st:scroll(event, step)
		end
	end
end

function M:entry()
	if is_open() then
		return
	end
	show()
	refresh()

	local alive = true
	ya.join(function()
		-- Pick up plugged / unplugged devices while the menu is open
		local ticks = 0
		while alive do
			ya.sleep(0.25)
			ticks = ticks + 1
			if alive and ticks % 8 == 0 then
				refresh()
			end
		end
	end, function()
		while true do
			local action = take_pending()
			if not action then
				local idx = ya.which { cands = KEYS, silent = true }
				action = idx and KEYS[idx].run or take_pending()
			end

			if action == "quit" then
				break
			elseif action == "up" then
				move_cursor(-1)
			elseif action == "down" then
				move_cursor(1)
			elseif action == "refresh" then
				refresh()
			elseif action and act(action, current()) then
				break
			end
		end
		alive = false
		hide()
	end)
end

-- UI --------------------------------------------------------------------------

function M:new(area)
	self:layout(area)
	return self
end

function M:layout(area)
	local n = math.max(#(self.entries or {}), 1)
	local w = math.min(area.w - 4, 120)
	local h = math.min(area.h - 2, n + 6)
	self._area = ui.Rect {
		x = area.x + (area.w - w) // 2,
		y = area.y + (area.h - h) // 2,
		w = w,
		h = h,
	}
end

function M:reflow() return { self } end

function M:redraw()
	local inner = self._area:pad(ui.Pad(1, 2, 1, 2))
	local entries = self.entries or {}

	-- Scroll window: header row + visible entries
	local table_h = math.max(inner.h - 3, 2)
	local visible = table_h - 1
	local cursor = self.cursor or 0
	local offset = self.offset or 0
	if cursor < offset then
		offset = cursor
	elseif cursor >= offset + visible then
		offset = cursor - visible + 1
	end
	self.offset = offset
	self._table = ui.Rect { x = inner.x, y = inner.y, w = inner.w, h = table_h }

	-- Ellipsize sources that would run into the next column
	local src_w = math.floor((inner.w - 12) * 0.3) - 1
	local function fit(str)
		if utf8.len(str) <= src_w then
			return str
		end
		local half = (src_w - 1) // 2
		return str:sub(1, half) .. "…" .. str:sub(-(src_w - 1 - half))
	end

	local rows = {}
	for i = offset + 1, math.min(#entries, offset + visible) do
		local e = entries[i]
		local kind = KINDS[e.kind] or KINDS.other
		rows[#rows + 1] = ui.Row {
			e.mounted and ui.Span("●"):fg("green") or ui.Span("○"):style(ui.Style():fg("darkgray")),
			kind[1] .. " " .. kind[2],
			e.name or "",
			fit(e.source or ""),
			e.mounted and (shorten(e.path) or (e.uri and e.uri:gsub("^file://", "")) or "") or "",
		}
	end
	if #entries == 0 then
		rows[1] = ui.Row { "", "", "Nothing to mount", "", "" }
	end

	-- Footer hints, remembering where each sits so it can be clicked
	local spans, x = {}, inner.x
	self._hints, self._hint_y = {}, inner.y + inner.h - 1
	for _, hint in ipairs(HINTS) do
		local key, desc = " " .. hint[1] .. " ", " " .. hint[2]
		spans[#spans + 1] = ui.Span(key):style(ui.Style():fg("black"):bg("blue"):bold())
		spans[#spans + 1] = ui.Span(desc .. "   ")
		local width = utf8.len(key) + utf8.len(desc)
		self._hints[#self._hints + 1] = { x1 = x, x2 = x + width, run = hint[3] }
		x = x + width + 3
	end

	local status = self.status and ui.Line(self.status):style(ui.Style():fg("yellow"))
		or ui.Line("Click a row to select it, click it again to open"):style(ui.Style():fg("darkgray"))

	return {
		ui.Clear(self._area),
		ui.Border(ui.Edge.ALL)
			:area(self._area)
			:type(ui.Border.ROUNDED)
			:style(ui.Style():fg("blue"))
			:title(ui.Line(" Mounts "):align(ui.Align.CENTER)),
		ui.Table(rows)
			:area(self._table)
			:header(ui.Row({ "", "Type", "Name", "Source", "Mounted at" }):style(ui.Style():bold()))
			:row(#entries > 0 and cursor - offset or nil)
			:row_style(ui.Style():fg("blue"):reverse())
			:widths {
				ui.Constraint.Length(2),
				ui.Constraint.Length(10),
				ui.Constraint.Percentage(25),
				ui.Constraint.Percentage(30),
				ui.Constraint.Fill(1),
			},
		ui.Text(status):area(ui.Rect { x = inner.x, y = inner.y + inner.h - 2, w = inner.w, h = 1 }),
		ui.Text(ui.Line(spans)):area(ui.Rect { x = inner.x, y = self._hint_y, w = inner.w, h = 1 }),
	}
end

-- Mouse handlers run outside the plugin's async context: queue the action and
-- dismiss the pending key prompt so the main loop picks it up.
local function queue(self, action)
	self.pending = action
	ya.emit("which:dismiss", {})
end

function M:click(event, up)
	if up or not event.is_left or not self._table then
		return
	end
	if event.y == self._hint_y then
		for _, h in ipairs(self._hints or {}) do
			if event.x >= h.x1 and event.x < h.x2 then
				return queue(self, h.run)
			end
		end
		return
	end

	local row = event.y - self._table.y - 1 -- minus the header
	local idx = row + (self.offset or 0)
	if row >= 0 and row < self._table.h - 1 and idx < #(self.entries or {}) then
		if idx == self.cursor then
			queue(self, "open")
		else
			self.cursor = idx
			ui.render()
		end
	end
end

function M:scroll(event, step)
	local n = #(self.entries or {})
	if n > 0 then
		self.cursor = ya.clamp(0, (self.cursor or 0) + step, n - 1)
		ui.render()
	end
end

function M:touch() end

return M
