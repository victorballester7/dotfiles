---@type LazySpec
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<Leader>ff", "<Cmd>Telescope find_files<CR>", desc = "Files" },
      { "<Leader>fg", "<Cmd>Telescope git_files<CR>", desc = "Git files" },
      { "<Leader>fs", "<Cmd>Telescope live_grep<CR>", desc = "Grep" },
      { "<Leader>fw", "<Cmd>Telescope grep_string<CR>", desc = "Word under cursor", mode = { "n", "x" } },
      { "<Leader>fb", "<Cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<Leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "Help" },
      { "<Leader>fr", "<Cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<Leader>fd", "<Cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "<Leader>fk", "<Cmd>Telescope keymaps<CR>", desc = "Keymaps" },
      { "<Leader>f.", "<Cmd>Telescope resume<CR>", desc = "Resume last search" },
      {
        "<Leader>z",
        function()
          require("telescope.builtin").spell_suggest(require("telescope.themes").get_cursor({
            layout_config = { height = 12, width = 40 },
            prompt_title = "Spelling",
          }))
        end,
        desc = "Spelling suggestions",
      },
    },
    init = function()
      -- load telescope the first time something asks for a selection (e.g. code actions)
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "telescope.nvim" } })
        return vim.ui.select(...)
      end
    end,
    config = function()
      local telescope = require("telescope")
      local custom_pickers = require("victorballester7.telescope.custom_pickers")
      telescope.setup({
        pickers = {
          find_files = { hidden = true, no_ignore = true },
          grep_string = { disable_coordinates = true },
          live_grep = {
            path_display = { "smart" },
            vimgrep_arguments = {
              "rg",
              "--no-ignore",
              "--color=never",
              "--no-heading",
              "--with-filename",
              "--line-number",
              "--column",
              "--smart-case",
              "--hidden",
              "--glob=!**/.git/**",
            },
            mappings = {
              i = {
                ["<C-f>"] = custom_pickers.actions.set_extension,
                ["<C-l>"] = custom_pickers.actions.set_folders,
              },
            },
            -- do not search until the prompt has at least 3 characters
            on_input_filter_cb = function(prompt)
              return { prompt = #prompt < 3 and "" or prompt }
            end,
          },
        },
        extensions = { ["ui-select"] = { require("telescope.themes").get_dropdown() } },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle", "NvimTreeOpen" },
    keys = {
      { "<Leader>n", "<Cmd>NvimTreeFindFileToggle<CR>", desc = "File tree" },
    },
    init = function()
      -- `nvim <dir>` opens the tree in place of the directory buffer
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("victorballester7-nvimtree", { clear = true }),
        callback = function(data)
          if vim.fn.isdirectory(data.file) ~= 1 then
            return
          end
          vim.cmd.enew()
          vim.cmd.bwipeout(data.buf)
          vim.cmd.cd(data.file)
          require("nvim-tree.api").tree.open({ current_window = true })
        end,
      })
    end,
    opts = {
      actions = { open_file = { quit_on_open = false } },
      git = { ignore = false },
      modified = { enable = true, show_on_dirs = true, show_on_open_dirs = true },
      renderer = { icons = { modified_placement = "after" } },
      ui = { confirm = { default_yes = true } },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set("n", "<C-CR>", api.node.run.system, opts("Open with system app"))
        -- d trashes, D deletes permanently
        vim.keymap.set("n", "d", api.fs.trash, opts("Trash"))
        vim.keymap.set("n", "D", api.fs.remove, opts("Delete"))
      end,
    },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },
  {
    "tpope/vim-sleuth",
    event = { "BufReadPre", "BufNewFile" },
  },
  {
    "knubie/vim-kitty-navigator",
    build = "cp *.py ~/.config/kitty",
    event = "VeryLazy",
  },
  {
    "amitds1997/remote-nvim.nvim",
    version = "*",
    cmd = { "RemoteStart", "RemoteStop", "RemoteInfo", "RemoteCleanup", "RemoteConfigDel", "RemoteLog" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {},
  },
}
