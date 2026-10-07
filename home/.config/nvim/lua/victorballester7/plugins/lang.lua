---@type LazySpec
return {
  {
    "lervag/vimtex",
    lazy = false, -- vimtex must not be lazy-loaded
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_complete_close_brackets = 1
    end,
    keys = {
      { "<LocalLeader>lc", "<Cmd>VimtexClean!<CR>", desc = "Clean auxiliary files", ft = "tex" },
      { "<LocalLeader>le", "<Cmd>VimtexErrors<CR>", desc = "Show errors", ft = "tex" },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = "markdown",
    build = "cd app && yarn install",
    keys = {
      { "<LocalLeader>mp", "<Cmd>MarkdownPreviewToggle<CR>", desc = "Toggle preview", ft = "markdown" },
    },
  },
  {
    "benomahony/uv.nvim",
    ft = "python",
    opts = {
      picker_integration = true,
      keymaps = { prefix = "<Leader>u" }, -- <Leader>x is "delete without yanking"
    },
  },
  { "fladson/vim-kitty", ft = "kitty" },
}
