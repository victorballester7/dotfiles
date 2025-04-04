---@type LazySpec
return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile", "VeryLazy" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"whoissethdaniel/mason-tool-installer.nvim",
			"folke/neodev.nvim",
			"simrat39/rust-tools.nvim",
			"b0o/schemastore.nvim",
			"pmizio/typescript-tools.nvim",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				automatic_installation = { exclude = { "clangd", "r_language_server" } },
			})
			require("mason-tool-installer").setup({
				ensure_installed = { "latexindent", "luacheck", "ruff", "prettier", "stylua", "taplo" },
			})
			require("mason-tool-installer").check_install(false) -- false stands for not updating, only installing

			require("neodev").setup({
				override = function(_, library)
					library.enabled = true
					library.plugins = true
				end,
			})

			vim.diagnostic.config({
				severity_sort = true,
				update_in_insert = false,
			})
			for name, icon in pairs(require("victorballester7.icons").diagnostics) do
				name = "DiagnosticSign" .. name
				vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
			end

			local lsp = require("lspconfig")
			local default_capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities()
			)

			--- @param custom_config? lspconfig.Config
			--- @return lspconfig.Config
			local function config(custom_config)
				return vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(default_capabilities),
					--- @type vim.lsp.client.on_attach_cb
					on_attach = function(client, bufnr)
						local bufopts = { noremap = true, silent = true, buffer = bufnr }
						local map = vim.keymap.set
						map("n", "gd", "<Cmd>Telescope lsp_definitions<CR>", bufopts)
						map("n", "gD", vim.lsp.buf.declaration, bufopts)
						map("n", "gi", "<Cmd>Telescope lsp_implementations<CR>", bufopts)
						map("n", "gy", "<Cmd>Telescope lsp_type_definitions<CR>", bufopts)
						map("n", "gr", "<Cmd>Telescope lsp_references<CR>", bufopts)
						-- map("n", "K", vim.lsp.buf.hover, bufopts)
						map("i", "<C-k>", vim.lsp.buf.signature_help, bufopts)
						map("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
						map("n", "<Leader>ca", function()
							vim.lsp.buf.code_action({ apply = true })
						end, bufopts)
						map("n", "<Leader>sd", "<Cmd>Telescope lsp_document_symbols<CR>", bufopts)
						map("n", "<Leader>sw", "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>", bufopts)
						if client.name == "texlab" then
							---@diagnostic disable-next-line: assign-type-mismatch
							client.server_capabilities.completionProvider = false -- we use `vimtex` completion!
							map("n", "<LocalLeader>lw", "<Cmd>w<CR><Cmd>TexWordCount<CR>", bufopts)
						end
						if client.name == "clangd" then
							map("n", "<LocalLeader>ls", "<Cmd>ClangdSwitchSourceHeader<CR>", bufopts)
						end
					end,
				}, custom_config or {})
			end

			local function get_python_path(root_dir)
				-- use active venv
				if vim.env.VIRTUAL_ENV then
					return lsp.util.path.join(vim.env.VIRTUAL_ENV, "bin", "python")
				end

				-- find venv in current dir
				for _, pattern in ipairs({ "*", ".*" }) do
					local match = vim.fn.glob(lsp.util.path.join(root_dir, pattern, "pyvenv.cfg"))
					if match ~= "" then
						return lsp.util.path.join(lsp.util.path.dirname(match), "bin", "python")
					end
				end

				-- fallback to system installation
				return nil
			end

			require("rust-tools").setup({ server = config() })
			require("typescript-tools").setup(config())

			lsp.clangd.setup(config())
			lsp.eslint.setup(config())
			lsp.lua_ls.setup(config())
			lsp.matlab_ls.setup(config())
			lsp.r_language_server.setup(config())
			lsp.vimls.setup(config())
			lsp.jsonls.setup(config({
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			}))
			-- lsp.pyright.setup(config({
			-- 	before_init = function(_, conf)
			-- 		conf.settings.python.pythonPath = get_python_path(conf.root_dir)
			-- 	end,
			-- }))
			lsp.pyright.setup(config({
				before_init = function(_, conf)
					local function find_main_py_dir(start_dir)
						local path = vim.fn.fnamemodify(start_dir, ":p") -- Get absolute path
						while path and path ~= "/" do
							if vim.fn.filereadable(path .. "/main.py") == 1 then
								return path
							end
							path = vim.fn.fnamemodify(path, ":h") -- Move up a directory
						end
						return nil
					end

					local main_py_dir = find_main_py_dir(conf.root_dir)
					if main_py_dir then
						conf.settings.python.pythonPath = get_python_path(main_py_dir)
						conf.settings.python.analysis = conf.settings.python.analysis or {}
						conf.settings.python.analysis.extraPaths = { main_py_dir }
					end
				end,
			}))

			lsp.texlab.setup(config({
				settings = { texlab = { chktex = { onEdit = true, onOpenAndSave = true } } },
			}))
			lsp.yamlls.setup(config({
				settings = {
					yaml = {
						schemaStore = { enable = false, url = "" },
						schemas = require("schemastore").yaml.schemas(),
					},
				},
			}))
		end,
	},
	{
		"github/copilot.vim",
		config = false,
		event = { "BufReadPre", "BufNewFile", "VeryLazy" },
		init = function()
			vim.keymap.set("i", "<C-j>", 'copilot#Accept("<CR>")', {
				noremap = true,
				silent = true,
				expr = true,
				replace_keycodes = false,
			})

			vim.g.copilot_no_tab_map = true
			vim.g.copilot_filetypes = { ["*"] = true }
			vim.g.copilot_assume_mapped = true
		end,
	},
}
