-- Servers to enable. Those not installed (cmd not executable) are skipped, so the list can hold servers
-- that only exist on some machines.
local servers = {
  "clangd",
  "eslint",
  "jsonls",
  "lua_ls",
  "matlab_ls",
  "pyright",
  "qmlls",
  "r_language_server",
  "rust_analyzer",
  "texlab",
  "vimls",
  "yamlls",
}

-- installed with mason (servers use their lspconfig names)
local mason_packages = {
  "eslint",
  "jsonls",
  "lua_ls",
  "pyright",
  "rust_analyzer",
  "texlab",
  "vimls",
  "yamlls",
  "latexindent",
  "luacheck",
  "prettier",
  "ruff",
  "stylua",
  "taplo",
}

local function on_attach(args)
  local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, silent = true, nowait = true, desc = desc })
  end

  map("n", "gd", "<Cmd>Telescope lsp_definitions<CR>", "Go to definition")
  map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  map("n", "gi", "<Cmd>Telescope lsp_implementations<CR>", "Go to implementation")
  map("n", "gy", "<Cmd>Telescope lsp_type_definitions<CR>", "Go to type definition")
  map("n", "gr", "<Cmd>Telescope lsp_references<CR>", "References")
  map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
  map("n", "<Leader>rn", vim.lsp.buf.rename, "Rename symbol")
  map({ "n", "x" }, "<Leader>ca", vim.lsp.buf.code_action, "Code action")
  map("n", "<Leader>sd", "<Cmd>Telescope lsp_document_symbols<CR>", "Document symbols")
  map("n", "<Leader>sw", "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>", "Workspace symbols")
  map("n", "<Leader>ih", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
  end, "Toggle inlay hints")

  if client.name == "texlab" then
    client.server_capabilities.completionProvider = nil -- vimtex provides completion
    map("n", "<LocalLeader>lw", "<Cmd>w<CR><Cmd>TexWordCount<CR>", "Word count")
  elseif client.name == "clangd" then
    map("n", "<LocalLeader>ls", "<Cmd>LspClangdSwitchSourceHeader<CR>", "Switch source/header")
  end
end

---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "b0o/schemastore.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local icons = require("victorballester7.icons").diagnostics
      vim.diagnostic.config({
        severity_sort = true,
        update_in_insert = false,
        virtual_text = { spacing = 2, prefix = "●" },
        float = { border = "rounded", source = "if_many" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = icons.Error,
            [vim.diagnostic.severity.WARN] = icons.Warn,
            [vim.diagnostic.severity.INFO] = icons.Info,
            [vim.diagnostic.severity.HINT] = icons.Hint,
          },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("victorballester7-lsp", { clear = true }),
        callback = on_attach,
      })

      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

      vim.lsp.config("jsonls", {
        settings = {
          json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
        },
      })
      vim.lsp.config("yamlls", {
        settings = {
          yaml = { schemaStore = { enable = false, url = "" }, schemas = require("schemastore").yaml.schemas() },
        },
      })
      vim.lsp.config("texlab", {
        settings = { texlab = { chktex = { onEdit = true, onOpenAndSave = true } } },
      })
      vim.lsp.config("qmlls", { cmd = { vim.fn.executable("qmlls6") == 1 and "qmlls6" or "qmlls" } })
      vim.lsp.config("pyright", {
        -- for projects with a main.py in a parent directory, add that directory to the import paths and
        -- use the virtual environment next to it
        before_init = function(_, config)
          local main_dir = config.root_dir and vim.fs.root(config.root_dir, "main.py")
          if not main_dir then
            return
          end
          config.settings = config.settings or {}
          local python = config.settings.python or {}
          local venv = vim.env.VIRTUAL_ENV
          if not venv then
            -- e.g. main_dir/.venv/pyvenv.cfg
            local cfg = vim.fn.glob(main_dir .. "/{*,.*}/pyvenv.cfg", false, true)[1]
            venv = cfg and vim.fs.dirname(cfg)
          end
          if venv then
            python.pythonPath = vim.fs.joinpath(venv, "bin", "python")
          end
          python.analysis = python.analysis or {}
          python.analysis.extraPaths = python.analysis.extraPaths or {}
          if not vim.list_contains(python.analysis.extraPaths, main_dir) then
            table.insert(python.analysis.extraPaths, main_dir)
          end
          config.settings.python = python
        end,
      })

      for _, server in ipairs(servers) do
        local cmd = vim.lsp.config[server] and vim.lsp.config[server].cmd
        if type(cmd) ~= "table" or vim.fn.executable(cmd[1]) == 1 then
          vim.lsp.enable(server)
        end
      end
    end,
  },
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = {
      "mason-org/mason.nvim",
      { "mason-org/mason-lspconfig.nvim", opts = { automatic_enable = false } },
    },
    opts = { ensure_installed = mason_packages, run_on_start = true },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
