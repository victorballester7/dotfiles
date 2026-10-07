local group = vim.api.nvim_create_augroup("victorballester7", { clear = true })
local autocmd = function(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", { group = group }, opts))
end

-- do not continue comments on new lines (ftplugins set 'formatoptions', so this must run after them)
autocmd("FileType", {
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

autocmd("FileType", {
  pattern = { "tex", "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
  end,
})

autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- reopen files at the last cursor position
autocmd("BufReadPost", {
  callback = function(args)
    if vim.bo[args.buf].filetype == "gitcommit" then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd("VimResized", {
  command = "tabdo wincmd =",
})
