---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- the main branch does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      -- parsers installed up front; any other parser available for a filetype is installed on first use
      ts.install({
        "bash",
        "c",
        "cpp",
        "css",
        "diff",
        "go",
        "gomod",
        "gosum",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
        "zsh",
      })
      vim.treesitter.language.register("bash", "sh")

      -- vimtex provides better highlighting for LaTeX than treesitter
      local skip = { tex = true, bigfile = true }
      local available ---@type string[]?

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("victorballester7-treesitter", { clear = true }),
        callback = function(args)
          local buf, ft = args.buf, args.match
          local lang = vim.treesitter.language.get_lang(ft)
          if skip[ft] or not lang then
            return
          end

          if not vim.treesitter.language.add(lang) then
            available = available or ts.get_available()
            if not vim.tbl_contains(available, lang) then
              return
            end
            -- install in the background and start highlighting once it is ready
            ts.install(lang):await(function()
              if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_exec_autocmds("FileType", { buffer = buf, group = args.group })
              end
            end)
            return
          end

          vim.treesitter.start(buf, lang)
          vim.wo[0][0].foldmethod = "expr"
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = { max_lines = 10, multiline_threshold = 4 },
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    init = function()
      -- disable the built-in ftplugin mappings to avoid conflicts
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          selection_modes = {
            ["@function.inner"] = "V",
            ["@function.outer"] = "V",
            ["@class.outer"] = "V",
            ["@class.inner"] = "V",
            ["@parameter.outer"] = "v",
          },
          include_surrounding_whitespace = false,
        },
      })

      local select = require("nvim-treesitter-textobjects.select").select_textobject
      local textobjects = {
        af = { "@function.outer", "Around function" },
        ["if"] = { "@function.inner", "Inside function" },
        ac = { "@class.outer", "Around class" },
        ic = { "@class.inner", "Inside class" },
        aa = { "@parameter.outer", "Around argument" },
        ia = { "@parameter.inner", "Inside argument" },
      }
      for lhs, obj in pairs(textobjects) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          select(obj[1], "textobjects")
        end, { desc = obj[2] })
      end
      vim.keymap.set({ "x", "o" }, "as", function()
        select("@local.scope", "locals")
      end, { desc = "Around scope" })
    end,
  },
}
