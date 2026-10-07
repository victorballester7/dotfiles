local icons = require("victorballester7.icons")

---@type LazySpec
return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = "soft"
      vim.g.gruvbox_material_diagnostic_text_highlight = 1
      vim.g.gruvbox_material_diagnostic_virtual_text = "highlighted"
      vim.g.gruvbox_material_enable_italic = 1
      vim.cmd.colorscheme("gruvbox-material")
      vim.cmd("highlight! link DiagnosticDeprecated HintText")
      for _, group in ipairs({ "NvimTreeNormal", "NvimTreeEndOfBuffer", "NvimTreeVertSplit", "NvimTreeCursorLine" }) do
        vim.cmd.highlight("clear " .. group)
      end
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.laststatus = 3
    end,
    opts = function()
      local diagnostic_symbols = {}
      for name, icon in pairs(icons.diagnostics) do
        diagnostic_symbols[name:lower()] = icon
      end
      local filename = { "filename", file_status = true, path = 4, symbols = icons.file_status }
      return {
        options = { globalstatus = true },
        extensions = { "fugitive", "lazy", "man", "nvim-tree", "quickfix" },
        sections = {
          lualine_b = {
            "branch",
            {
              "diff",
              symbols = icons.git,
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return { added = gitsigns.added, modified = gitsigns.changed, removed = gitsigns.removed }
                end
              end,
            },
            { "diagnostics", symbols = diagnostic_symbols },
            {
              function()
                return ("Remote: %s"):format(vim.uv.os_gethostname())
              end,
              cond = function()
                return vim.g.remote_neovim_host ~= nil
              end,
            },
          },
          lualine_c = { filename },
          lualine_x = { "lsp_status", "progress" },
          lualine_y = { "filetype" },
        },
        inactive_sections = { lualine_c = { filename } },
      }
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    keys = {
      { "<Leader>o", "<Cmd>NoiceDismiss<CR>", desc = "Dismiss notifications" },
    },
    opts = {
      routes = {
        { filter = { event = "notify", find = "No information available" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "written" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "yanked" }, opts = { skip = true } },
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        signature = { enabled = false }, -- blink.cmp shows the signature
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = 400,
      spec = {
        { "<Leader>f", group = "find" },
        { "<Leader>g", group = "git" },
        { "<Leader>l", group = "language" },
        { "<Leader>m", group = "markdown" },
        { "<Leader>r", group = "rename" },
        { "<Leader>s", group = "split/symbols" },
        { "<Leader>u", group = "uv (python)" },
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { show_start = false, show_end = false },
      exclude = { filetypes = { "bigfile" } },
    },
  },
  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      filetypes = { "*", "!bigfile", "!lazy", "!mason" },
      lazy_load = true, -- only highlight the visible lines
      user_default_options = {
        RGB = false,
        RRGGBB = true,
        RRGGBBAA = true,
        names = false,
        rgb_fn = true,
        hsl_fn = true,
      },
    },
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
}
