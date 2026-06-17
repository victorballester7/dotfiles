---@type LazySpec
return {
	{
	  "numtostr/comment.nvim",
	  -- event = "VeryLazy",
	  -- opts = { ignore = "^$" },
	},
	-- In typing.lua:
	-- {
	-- 	"numtostr/Comment.nvim",
	-- 	event = "VeryLazy",
	-- 	opts = {
	-- 		ignore = "^$",
	-- 		pre_hook = function()
	-- 			if vim.bo.filetype == "tex" then
	-- 				return "% %s"
	-- 			end
	-- 		end,
	-- 	},
	-- },
	{
		"windwp/nvim-autopairs",
		event = "VeryLazy",
		config = true,
	},
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		config = true,
	},
	{
		"tpope/vim-sleuth",
		event = { "BufReadPre", "BufNewFile", "VeryLazy" },
	},
}
