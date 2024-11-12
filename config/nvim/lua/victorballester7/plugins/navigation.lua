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
					find_files = { hidden = true },
					grep_string = { disable_coordinates = true },
          live_grep = { 
						path_display = { "shorten" },
						mappings = {
							i = {
								["<c-f>"] = custom_pickers.actions.set_extension,
								["<c-l>"] = custom_pickers.actions.set_folders,
							},
						},
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
			end

			require("nvim-tree").setup({
				actions = { open_file = { quit_on_open = false } },
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
}
