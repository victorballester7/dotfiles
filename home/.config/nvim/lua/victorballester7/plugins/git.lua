---@type LazySpec
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile", "VeryLazy" },
    opts = {
      current_line_blame = true,
      current_line_blame_formatter = "<author>, <author_time:%R> - <summary> (<abbrev_sha>)",
      current_line_blame_opts = { delay = 500 },
    },
  },
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    opts = function()
      local actions = require("diffview.actions")

      -- open the file under the cursor with the system default app (as <C-CR> in nvim-tree)
      local function system_open()
        local view = require("diffview.lib").get_current_view()
        local file = view and view:infer_cur_file()
        if file and file.absolute_path then
          vim.ui.open(file.absolute_path)
        end
      end

      -- nvim-tree-like mappings for the file panels (added on top of the defaults)
      local panel_maps = {
        { "n", "<C-x>", actions.goto_file_split, { desc = "Open the file in a new split" } },
        { "n", "<C-t>", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
        { "n", "<BS>", actions.close_fold, { desc = "Collapse fold" } },
        { "n", "E", actions.open_all_folds, { desc = "Expand all folds" } },
        { "n", "W", actions.close_all_folds, { desc = "Collapse all folds" } },
        { "n", "<C-CR>", system_open, { desc = "Open the file with the system app" } },
        { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
        { "n", "<Leader>n", actions.toggle_files, { desc = "Toggle the file panel" } },
      }

      return {
        keymaps = {
          view = {
            { "n", "<Leader>n", actions.toggle_files, { desc = "Toggle the file panel" } },
          },
          file_panel = panel_maps,
          file_history_panel = panel_maps,
        },
      }
    end,
  },
}
