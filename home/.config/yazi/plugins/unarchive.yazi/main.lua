--- @since 26.9.1
-- Extract the selected (or hovered) archives into the current directory as yazi
-- background tasks, with a live progress gauge in the status bar and task list
-- (`w`). Multi-volume rars extract once from part1, whichever parts are picked.
-- Password-protected archives ask for the password in a yazi input box.
-- Existing files are never overwritten: 7z renames the new ones, tar keeps the
-- old ones as `name.~1~`.

local TAR = { "%.tar%.gz$", "%.tgz$", "%.tar%.bz2$", "%.tbz2?$", "%.tar%.xz$", "%.txz$", "%.tar%.zst$", "%.tzst$" }

local targets = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, url in pairs(tab.selected) do
		paths[#paths + 1] = tostring(url)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.url)
	end
	return paths, tostring(tab.current.cwd)
end)

local function exists(path) return fs.cha(Url(path)) ~= nil end

-- Any part of a multi-volume rar maps to its first volume.
local function first_volume(path)
	local stem = path:match("^(.*%.[pP][aA][rR][tT])%d+%.[rR][aA][rR]$")
	if not stem then
		return path
	end
	for _, n in ipairs { "1", "01", "001", "0001" } do
		for _, ext in ipairs { ".rar", ".RAR" } do
			if exists(stem .. n .. ext) then
				return stem .. n .. ext
			end
		end
	end
	return path
end

local function is_tar(path)
	local lower = path:lower()
	for _, pat in ipairs(TAR) do
		if lower:find(pat) then
			return true
		end
	end
	return false
end

-- Returns "header" if even the file list needs a password, "content" if only
-- the data does, nil otherwise.
local function encryption(path)
	local out = Command("7z"):arg({ "l", "-slt", "-p", path }):stdin(Command.NULL):output()
	if not out then
		return nil
	elseif out.stderr:find(" Wrong password", 1, true) then
		return "header"
	elseif out.stdout:find("\nEncrypted = %+") then
		return "content"
	end
end

local function command(path, dest, pwd)
	if is_tar(path) then
		return Command("bash"):arg({
			"-c",
			'set -o pipefail; 7z x -so -bsp2 -p"$3" "$1" | tar -xf - -C "$2" --backup=numbered',
			"bash",
			path,
			dest,
			pwd,
		})
	end
	return Command("7z"):arg({ "x", "-bso0", "-bsp1", "-bse1", "-aou", "-p" .. pwd, "-o" .. dest, path })
end

-- Runs the extraction, feeding 7z's percentage into the task gauge.
-- Returns the exit status and the non-progress output (for error messages).
local function run(task, path, dest, pwd)
	local child, err = command(path, dest, pwd)
		:stdin(Command.NULL)
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()
	if not child then
		return nil, tostring(err)
	end

	local last, log = -1, ""
	while true do
		local chunk, event = child:read(4096)
		if event == 2 then
			break
		elseif type(chunk) == "table" then
			chunk = string.char(table.unpack(chunk))
		end
		-- 7z redraws its progress in place with backspaces, not newlines.
		for match in chunk:gmatch("(%d+)%%") do
			local pct = tonumber(match)
			if pct ~= last then
				last = pct
				task:progress { total = 1, workload = 100, processed = pct }
			end
		end
		log = (log .. chunk):sub(-4096)
	end

	local status = child:wait()
	local lines = {}
	for line in log:gsub("\b+", "\n"):gmatch("[^\n]+") do
		if not line:match("^%s*%d+%%") and not line:match("^%s*%d+M Scan%s*$") and line:match("%S") then
			lines[#lines + 1] = line
		end
	end
	return status, table.concat(lines, "\n")
end

local function extract(task, path, dest)
	local name = path:match("[^/]+$")
	local pwd = ""
	if encryption(path) then
		local value, event = ya.input {
			pos = { "top-center", y = 2, w = 50 },
			title = string.format('Password for "%s":', name),
			obscure = true,
		}
		if event ~= 1 then
			return task:fail("Cancelled: no password given for " .. name)
		end
		pwd = value
	end

	local status, output = run(task, path, dest, pwd)
	if status and status.success then
		task:progress { total = 1, success = 1, workload = 100, processed = 100 }
		task:succeed()
	else
		local reason = output:find(" Wrong password", 1, true) and "Wrong password" or output
		task:fail(string.format("Failed to extract %s:\n%s", name, reason))
		ya.notify { title = "Extract", content = "Failed to extract " .. name, timeout = 5, level = "error" }
	end
end

return {
	entry = function()
		local paths, dest = targets()

		local seen, archives = {}, {}
		for _, path in ipairs(paths) do
			path = first_volume(path)
			if not seen[path] then
				seen[path] = true
				archives[#archives + 1] = path
			end
		end

		for _, path in ipairs(archives) do
			local task = ya.task("custom", { pool = "plugin", scope = rt.scope(), progress = true })
				:name("Extract " .. path:match("[^/]+$"))
				:spawn()
			if task:acquire() then
				extract(task, path, dest)
			end
		end
	end,
}
