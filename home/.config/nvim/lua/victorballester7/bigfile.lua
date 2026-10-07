-- Big files (e.g. simulation data) get the filetype "bigfile" instead of their real one, so treesitter,
-- LSP, colorizer and any other plugin that attaches on FileType never start for them.

local MAX_SIZE = 1.5 * 1024 * 1024 -- bytes
local MAX_LINE_LENGTH = 1000 -- average, catches minified files

vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, buf)
        if not path or not buf or vim.bo[buf].filetype == "bigfile" then
          return
        end
        if path ~= vim.api.nvim_buf_get_name(buf) then
          return
        end
        local size = vim.fn.getfsize(path)
        if size <= 0 then
          return
        end
        if size > MAX_SIZE then
          return "bigfile"
        end
        local lines = vim.api.nvim_buf_line_count(buf)
        return (size - lines) / lines > MAX_LINE_LENGTH and "bigfile" or nil
      end,
      { priority = math.huge },
    },
  },
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("victorballester7-bigfile", { clear = true }),
  pattern = "bigfile",
  callback = function(args)
    vim.notify("Big file: syntax highlighting, LSP and other features disabled", vim.log.levels.INFO)
    vim.b[args.buf].completion = false
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.spell = false
    vim.opt_local.undofile = false
    vim.opt_local.swapfile = false
  end,
})
