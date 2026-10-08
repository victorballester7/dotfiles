-- General keymaps. Plugin keymaps live in each plugin's `keys` spec, LSP keymaps in plugins/lsp.lua.
local map = function(mode, lhs, rhs, desc, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true, desc = desc }, opts or {}))
end

map("n", "<Leader>w", "<Cmd>w<CR>", "Write")
map("n", "<Leader>q", "<Cmd>q<CR>", "Quit")
map("n", "Q", "<Nop>")
map("n", "<Space>", "<Nop>")

-- [ and ] are hard to reach on a Spanish keyboard; remap so that +d, -q, +c, ... trigger the ]/[ mappings
map({ "n", "x", "o" }, "+", "]", nil, { remap = true })
map({ "n", "x", "o" }, "-", "[", nil, { remap = true })

-- move by visual lines
map("n", "j", "gj")
map("n", "k", "gk")
map("n", "<Down>", "gj")
map("n", "<Up>", "gk")
map("i", "<Down>", "<C-o>gj")
map("i", "<Up>", "<C-o>gk")

map("n", "<C-a>", "ggVG", "Select all")
map("i", "<C-BS>", "<C-w>", "Delete word backwards")
map("i", "<C-Del>", "<C-o>dw", "Delete word forwards")

-- word motions / deletions with Alt, in insert and command-line mode
map({ "i", "c" }, "<M-Left>", "<C-Left>", "Word backwards", { silent = false })
map({ "i", "c" }, "<M-Right>", "<C-Right>", "Word forwards", { silent = false })
map({ "i", "c" }, "<M-BS>", "<C-w>", "Delete word backwards", { silent = false })
map("i", "<M-Del>", "<C-o>dw", "Delete word forwards")
map("c", "<M-Del>", function()
  local line, pos = vim.fn.getcmdline(), vim.fn.getcmdpos()
  local rest = line:sub(pos)
  local word = rest:match("^%s*[%w_]+") or rest:match("^%s*[^%w_%s]+") or rest:match("^%s+") or ""
  vim.fn.setcmdline(line:sub(1, pos - 1) .. rest:sub(#word + 1), pos)
end, "Delete word forwards")

-- scrolling
map("n", "J", "<C-d>", "Scroll down")
map("n", "K", "<C-u>", "Scroll up")
map({ "n", "x" }, "<M-j>", "<C-d>zz", "Scroll down (centered)")
map({ "n", "x" }, "<M-k>", "<C-u>zz", "Scroll up (centered)")

-- move selected lines
map("x", "J", ":m '>+1<CR>gv=gv", "Move selection down")
map("x", "K", ":m '<-2<CR>gv=gv", "Move selection up")

-- splits
map("n", "<Leader>ss", "<C-w>v", "Split vertically")
map("n", "<Leader>sv", "<C-w>s", "Split horizontally")
map("n", "<C-A-Up>", "<Cmd>resize +5<CR>", "Increase height")
map("n", "<C-A-Down>", "<Cmd>resize -5<CR>", "Decrease height")
map("n", "<C-A-Left>", "<Cmd>vertical resize -5<CR>", "Decrease width")
map("n", "<C-A-Right>", "<Cmd>vertical resize +5<CR>", "Increase width")
map("n", "<C-A-k>", "<Cmd>resize +5<CR>", "Increase height")
map("n", "<C-A-j>", "<Cmd>resize -5<CR>", "Decrease height")
map("n", "<C-A-h>", "<Cmd>vertical resize -5<CR>", "Decrease width")
map("n", "<C-A-l>", "<Cmd>vertical resize +5<CR>", "Increase width")

-- registers
map({ "n", "x" }, "<Leader>y", '"+y', "Yank to system clipboard")
map("n", "<Leader>p", '"+p', "Paste from system clipboard")
map("x", "<Leader>p", '"_dP', "Paste without yanking selection")
map("n", "x", '"_x')
map("x", "<Leader>x", '"_x', "Delete without yanking")
map({ "n", "x" }, "<Leader>c", '"_c', "Change without yanking")
map({ "n", "x" }, "<Leader>d", '"_d', "Delete without yanking")

-- diagnostics
map("n", "<Leader>e", vim.diagnostic.open_float, "Line diagnostics")
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, "Next diagnostic")
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, "Previous diagnostic")
map("n", "<Leader>k", vim.lsp.buf.hover, "Hover documentation")
