local map = vim.keymap.set
local silent = { silent = true }

-- basic
map("n", "<Leader>w", "<Cmd>w<CR>", silent)
map("n", "<Leader>q", "<Cmd>q<CR>", silent)
map("n", "Q", "<Nop>", silent)
map("n", "<Space>", "<Nop>", silent)
-- because the keys [, ], are very unaccessible in the spanish keyboard
map({ "n", "v" }, "+", "]", silent)
map({ "n", "v" }, "-", "[", silent)

map("i", "<Up>", "<C-o>gk", silent)
map("i", "<Down>", "<C-o>gj", silent)
map("n", "k", "gk", silent)
map("n", "j", "gj", silent)
map("n", "<Up>", "gk", silent)
map("n", "<Down>", "gj", silent)

-- select all
map("n", "<C-a>", "ggVG", silent)

-- delete words
map("i", "<C-BS>", "<C-w>", silent)
map("i", "<C-Del>", "<C-o>dw", silent)

-- move between words in insert mode
-- map("i", "<C-Left>", "<C-o>b", silent)
-- map("i", "<C-Right>", "<C-o>e", silent)

-- navigation
map("n", "J", "<C-d>", silent)
map("n", "K", "<C-u>", silent)
map("v", "J", ":m '>+1<CR>gv=gv", silent)
map("v", "K", ":m '<-2<CR>gv=gv", silent)

map("n", "<Leader>ss", "<C-w>v", silent)
map("n", "<Leader>sv", "<C-w>s", silent)
map({ "n", "v" }, "<M-j>", "<C-d>zz", silent)
map({ "n", "v" }, "<M-k>", "<C-u>zz", silent)
map("n", "n", "nzz")
map("n", "N", "Nzz")

map({ "n", "v" }, "<Leader>y", '"+y', silent)
map("n", "x", '"_x', silent)
map("v", "<Leader>x", '"_x', silent)
map({ "n", "v" }, "<Leader>c", '"_c', silent)
map({ "n", "v" }, "<Leader>d", '"_d', silent)
map("v", "<Leader>p", '"_dP', silent)

-- window resizing
map("n", "<C-S-Up>", "<Cmd>resize +2<CR>", silent)
map("n", "<C-S-Down>", "<Cmd>resize -2<CR>", silent)
map("n", "<C-S-Left>", "<Cmd>vertical resize +2<CR>", silent)
map("n", "<C-S-Right>", "<Cmd>vertical resize -2<CR>", silent)

-- diagnostic
map("n", "<Leader>e", vim.diagnostic.open_float, silent)
map("n", "[d", vim.diagnostic.goto_prev, silent)
map("n", "]d", vim.diagnostic.goto_next, silent)

-- plugins
map("n", "<Leader>n", "<Cmd>NvimTreeFindFileToggle<CR>", silent)
map({ "n", "v" }, "<Leader>b", ":Format<CR>", silent)
map("n", "<Leader>o", "<Cmd>NoiceDismiss<CR>", silent)

-- git
map("n", "<Leader>vd", "<Cmd>Gvdiffsplit!<CR>", silent)

-- telescope
map("n", "<Leader>ff", "<Cmd>Telescope find_files<CR>", silent)
map("n", "<Leader>fg", "<Cmd>Telescope git_files<CR>", silent)
-- map("n", "<Leader>fs", '<Cmd>Telescope grep_string search=""<CR>', silent)
map("n", "<Leader>fs", "<Cmd>Telescope live_grep<CR>", silent)
map("n", "<Leader>fh", "<Cmd>Telescope help_tags<CR>", silent)
map("n", "<Leader>fb", "<Cmd>Telescope buffers<CR>", silent)

-- latex
map("n", "<localleader>lc", "VimtexClean!", silent)
map("n", "<localleader>le", "VimtexErrors", silent)
