---@type LazySpec
return {
	{
		"mhartington/formatter.nvim",
		cmd = { "Format", "FormatWrite", "FormatLock", "FormatWriteLock" },
		event = "VeryLazy",
		config = function()
			require("formatter").setup({
				log_level = vim.log.levels.INFO,
				filetype = {
					bib = {
						function()
							return {
								exe = "bibclean",
								stdin = true,
							}
						end,
					},
					c = { require("formatter.filetypes.c").clangformat },
					cpp = { require("formatter.filetypes.cpp").clangformat },
					css = { require("formatter.filetypes.css").prettier },
					javascript = { require("formatter.filetypes.javascript").prettier },
					json = { require("formatter.filetypes.json").prettier },
					jsonc = { require("formatter.filetypes.json").prettier },
					lua = { require("formatter.filetypes.lua").stylua },
					markdown = { require("formatter.filetypes.markdown").prettier },
					python = { require("formatter.filetypes.python").ruff },
					rust = { require("formatter.filetypes.rust").rustfmt },
					-- sh = { require("formatter.filetypes.sh").shfmt },
					tex = {
						function()
							return {
								exe = "latexindent",
								args = { "-g", "/dev/null", "-m", "-rv" },
								stdin = true,
							}
						end,
					},
					toml = { require("formatter.filetypes.toml").taplo },
					xml = {
						function()
							return {
								exe = "tidy",
								args = {
									"-quiet",
									"-xml",
									"--indent auto",
									"--indent-spaces 2",
									"--vertical-space yes",
									"--tidy-mark no",
								},
								stdin = true,
								try_node_exe = true,
							}
						end,
					},
					yaml = { require("formatter.filetypes.yaml").prettier },
					-- zsh = { require("formatter.filetypes.sh").shfmt },
				},
			})
			-- format on save
			-- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			-- 	callback = function()
			-- 		vim.cmd("FormatWrite")
			-- 	end,
			-- 	group = vim.api.nvim_create_augroup("victorballester7-formatOnSave", { clear = true }),
			-- })
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = "VeryLazy",
		config = function()
			require("lint").linters_by_ft = {
				c = { "clangtidy" },
				cpp = { "clangtidy" },
				lua = { "luacheck" },
				python = { "ruff" },
			}
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					require("lint").try_lint()
				end,
				group = vim.api.nvim_create_augroup("victorballester7-nvimlint", { clear = true }),
			})
		end,
	},
}
