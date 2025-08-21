---@type LazySpec
return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local custom_pickers = require("victorballester7.telescope_custom_pickers")
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
								["<c-f>"] = custom_pickers.actions.set_extension,
								["<c-l>"] = custom_pickers.actions.set_folders,
							},
						},
						-- do not show anything if the string is less than 3 characters in live grep
						on_input_filter_cb = function(prompt)
							if #prompt < 3 then
								return { prompt = "" } -- Clear the prompt to disable the search
							end
							return { prompt = prompt } -- Continue with the input
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
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local function my_on_attach(bufnr)
				local map = vim.keymap.set
				local api = require("nvim-tree.api")

				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				-- default mappings
				api.config.mappings.default_on_attach(bufnr)

				-- custom mappings
				map("n", "<C-CR>", api.node.run.system, opts("Help"))
				-- invert functionality of d and D
				map("n", "d", api.fs.trash, opts("Trash"))
				map("n", "D", api.fs.remove, opts("Delete"))
			end

			require("nvim-tree").setup({
				actions = {
					open_file = { quit_on_open = false },
				},
				git = { ignore = false },
				modified = {
					enable = true,
					show_on_dirs = true,
					show_on_open_dirs = true,
				},
				on_attach = my_on_attach,
				renderer = { icons = { modified_placement = "after" } },
				ui = { confirm = { default_yes = true } },
			})

			vim.api.nvim_create_autocmd({ "VimEnter" }, {
				callback = function(data)
					-- check if it's a directory
					if vim.fn.isdirectory(data.file) ~= 1 then
						return
					end
					vim.cmd.enew() -- create a new, empty buffer
					vim.cmd.bw(data.buf) -- wipe the directory buffer
					vim.cmd.cd(data.file) -- cd to the directory
					require("nvim-tree.api").tree.open({ current_window = true }) -- open the tree in the current buffer
				end,
				group = vim.api.nvim_create_augroup("victorballester7-nvimtree", { clear = true }),
			})
		end,
	},
	{
		"knubie/vim-kitty-navigator",
		build = "cp *.py ~/.config/kitty",
		event = "VeryLazy",
	},
	{
		"linux-cultist/venv-selector.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"mfussenegger/nvim-dap",
			"mfussenegger/nvim-dap-python", --optional
			{ "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
		},
		lazy = false,
		branch = "regexp", -- This is the regexp branch, use this for the new version
		keys = {
			{ "<Leader>v", "<cmd>VenvSelect<cr>" },
		},
		opts = {
			-- Your settings go here
		},
	},
}
