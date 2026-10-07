---@type LazySpec
return {
  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo", "Format" },
    keys = {
      { "<Leader>b", "<Cmd>Format<CR>", mode = { "n", "x" }, desc = "Format" },
    },
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      default_format_opts = { lsp_format = "fallback" },
      formatters_by_ft = {
        bib = { "bibclean" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        css = { "prettier" },
        javascript = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        lua = { "stylua" },
        markdown = { "prettier" },
        python = { "ruff_organize_imports", "ruff_format" },
        rust = { "rustfmt" },
        tex = { "latexindent" },
        toml = { "taplo" },
        xml = { "tidy" },
        yaml = { "prettier" },
      },
      formatters = {
        bibclean = { command = "bibclean", stdin = true },
        latexindent = { prepend_args = { "-g", "/dev/null", "-m", "-rv" } },
        tidy = {
          prepend_args = {
            "-xml",
            "--indent",
            "auto",
            "--indent-spaces",
            "2",
            "--vertical-space",
            "yes",
            "--tidy-mark",
            "no",
          },
        },
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)
      vim.api.nvim_create_user_command("Format", function(args)
        local range = args.count ~= -1
            and { start = { args.line1, 0 }, ["end"] = { args.line2, #vim.fn.getline(args.line2) } }
          or nil
        require("conform").format({ async = true, range = range })
      end, { range = true, desc = "Format the buffer or range" })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        c = { "clangtidy" },
        cpp = { "clangtidy" },
        lua = { "luacheck" },
        python = { "ruff" },
      }
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
        group = vim.api.nvim_create_augroup("victorballester7-lint", { clear = true }),
        callback = function()
          lint.try_lint(nil, { ignore_errors = true })
        end,
      })
    end,
  },
}
