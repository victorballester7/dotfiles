vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.python3_host_prog = "/usr/bin/python3"
vim.g.tex_flavor = "latex"

-- nvim-tree replaces netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

-- ui
opt.title = true
opt.number = true
opt.relativenumber = true
opt.numberwidth = 1
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false -- shown by lualine
opt.cmdheight = 0 -- noice draws the cmdline
opt.scrolloff = 6
opt.smoothscroll = true
opt.splitright = true
opt.splitbelow = true
opt.breakindent = true
opt.linebreak = true

-- editing
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.clipboard = "unnamed"
opt.mouse = "a"
opt.mousetime = 0
opt.undofile = true
opt.writebackup = false
opt.completeopt = "menu,menuone,noselect"

-- search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.inccommand = "split"

-- timing
opt.updatetime = 250
opt.timeoutlen = 300

-- folding (treesitter sets 'foldexpr' per buffer); start with everything open
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldtext = ""

opt.shortmess:append("A") -- no swap file warnings
opt.spelllang = "en_gb"
