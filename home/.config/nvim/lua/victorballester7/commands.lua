vim.api.nvim_create_user_command("TexWordCount", function()
  if vim.bo.filetype ~= "tex" then
    vim.notify("This command is only available for TeX files", vim.log.levels.WARN)
    return
  end
  local result = vim.system({ "texcount", vim.api.nvim_buf_get_name(0), "-inc", "-incbib", "-sum", "-1" }):wait()
  vim.notify("Word count: " .. vim.trim(result.stdout or ""))
end, { desc = "Count words in the current TeX document" })

vim.api.nvim_create_user_command("SudoW", function()
  vim.cmd("write !sudo tee % > /dev/null")
  vim.cmd("edit!")
end, { desc = "Write the file with sudo" })

vim.api.nvim_create_user_command("SudoX", function()
  vim.cmd("write !sudo tee % > /dev/null")
  vim.cmd("quit")
end, { desc = "Write the file with sudo and quit" })
