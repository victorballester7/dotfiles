---@type LazySpec
return {
	"lunarvim/bigfile.nvim",
	{
		"iamcco/markdown-preview.nvim",
		cmd = {
			"MarkdownPreview",
			"MarkdownPreviewStop",
			"MarkdownPreviewToggle",
		},
		build = "cd app && yarn install",
		ft = "markdown",
	},
	{
		"lervag/vimtex",
		init = function()
			vim.g.vimtex_view_method = "zathura"
			vim.g.vimtex_quickfix_mode = 0
			vim.g.vimtex_complete_close_brackets = 1
		end,
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({
				"*", -- Highlight all files
			}, {
				RGB = false,
				RRGGBB = true,
				RRGGBBAA = true,
				names = false,
				rgb_fn = true,
				hsl_fn = true,
			})
		end,
	},
}
