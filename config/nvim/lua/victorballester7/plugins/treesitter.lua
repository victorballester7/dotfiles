---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    branch = "main",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
      "windwp/nvim-ts-autotag",
    },
    config = function()
      -- a list of filetypes to install treesitter parsers and queries
      local nvim_treesitter = require("nvim-treesitter")

      local ensure_installed = {
        "bash",
        "c",
        "cpp",
        "diff",
        "go",
        "gomod",
        "gosum",
        "javascript",
        "json",
        "lua",
        "markdown",
        "python",
        "sh",
        "toml",
        "typescript",
        "vim",
        "yaml",
        "zsh",
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = ensure_installed,
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft)
          if lang == nil then
            return
          end

          -- check if parser is available
          local is_parser_available = vim.treesitter.language.add(lang)
          if not is_parser_available then
            local available_langs = vim.g.ts_available or nvim_treesitter.get_available()
            if not vim.g.ts_available then
              vim.g.ts_available = available_langs
            end

            if vim.tbl_contains(available_langs, lang) then
              -- install treesitter parsers and queries
              local install_msg = string.format("Installing parsers and queries for %s", lang)
              vim.print(install_msg)
              require("nvim-treesitter").install(lang)
            end
          end

          if vim.treesitter.language.add(lang) then
            -- start treesitter highlighting
            vim.treesitter.start(args.buf, lang)

            -- the following two statements will enable treesitter folding
            -- vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
            -- vim.wo[0][0].foldmethod = "expr"

            -- enable treesitter-based indentation
            -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      require("nvim-ts-autotag").setup()
      vim.treesitter.language.register("jsonc", "json")
      require("treesitter-context").setup({ max_lines = 10, multiline_threshold = 4 })

      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt.foldenable = false
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    branch = "main",
    init = function()
      -- Disable entire built-in ftplugin mappings to avoid conflicts.
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require("nvim-treesitter-textobjects").setup {
        select = {
          lookahead = true,
          selection_modes = {
            ["@function.inner"] = "V", -- linewise
            ["@function.outer"] = "V", -- linewise
            ["@class.outer"] = "V", -- linewise
            ["@class.inner"] = "V", -- linewise
            ["@parameter.outer"] = "v", -- charwise
          },
          include_surrounding_whitespace = false,
        },
      }

      vim.keymap.set({ "x", "o" }, "af", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "if", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ac", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ic", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "as", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
      end)
    end,
  },
}
