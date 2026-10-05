local function _word_count()
	if vim.bo.filetype ~= "tex" then
		vim.notify("This command is only available for Tex files")
		return
	end
	local _fn = vim.fn.expand("%")
	local _count = tonumber(vim.fn.system("texcount " .. _fn .. " -inc -incbib -sum -1"))
	vim.notify("Word count: " .. tostring(_count))
end

vim.api.nvim_create_user_command("TexWordCount", _word_count, {})

vim.api.nvim_create_user_command("SudoW", function()
	vim.cmd("write !sudo tee % > /dev/null")
	vim.cmd("edit!")
end, {})

vim.api.nvim_create_user_command("SudoX", function()
	vim.cmd("write !sudo tee % > /dev/null")
	vim.cmd("quit")
end, {})
