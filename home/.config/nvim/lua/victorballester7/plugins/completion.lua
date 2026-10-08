-- Shell-like <Tab> for the cmdline: extend the word under the cursor to the longest prefix
-- shared by every candidate that starts with it. Returns nil when there is nothing to add.
---@param cmp blink.cmp.API
---@param force? boolean skip the visibility check (the menu was just requested)
local function cmdline_complete_common(cmp, force)
  if not force and not cmp.is_menu_visible() then
    return
  end
  local line, cursor = vim.fn.getcmdline(), vim.fn.getcmdpos() - 1
  local start, common
  for _, item in ipairs(cmp.get_items()) do
    local edit = item.textEdit
    local range = edit and (edit.insert or edit.range)
    if range then
      start = start or range.start.character
      local typed = line:sub(start + 1, cursor)
      local text = edit.newText
      if range.start.character == start and vim.startswith(text, typed) then
        if not common then
          common = text
        else
          local i = 0
          while i < #common and common:byte(i + 1) == text:byte(i + 1) do
            i = i + 1
          end
          common = common:sub(1, i)
        end
      end
    end
  end
  if not common or #common <= cursor - start then
    return
  end
  vim.fn.setcmdline(line:sub(1, start) .. common .. line:sub(cursor + 1), start + #common + 1)
  return true
end

---@type LazySpec
return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "L3MON4D3/LuaSnip",
      "moyiz/blink-emoji.nvim",
    },
    ---@module "blink.cmp"
    ---@type blink.cmp.Config
    opts = {
      enabled = function()
        return vim.b.completion ~= false
      end,
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show", "hide" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
      },
      completion = {
        list = { selection = { preselect = false, auto_insert = true } },
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
        menu = { border = "rounded", draw = { treesitter = { "lsp" } } },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      appearance = {
        kind_icons = vim.tbl_map(vim.trim, require("victorballester7.icons").kinds),
      },
      snippets = { preset = "luasnip" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "emoji" },
        per_filetype = {
          tex = { "omni", "snippets", "path", "buffer" }, -- vimtex completion through its omnifunc
          lua = { inherit_defaults = true, "lazydev" },
        },
        providers = {
          emoji = { module = "blink-emoji", name = "Emoji", score_offset = -5 },
          lazydev = { module = "lazydev.integrations.blink", name = "LazyDev", score_offset = 100 },
        },
      },
      cmdline = {
        keymap = {
          preset = "none",
          -- Tab accepts an item picked with the arrows, otherwise completes like a shell
          -- (up to the longest common prefix of the matches)
          ["<Tab>"] = {
            "accept",
            cmdline_complete_common,
            function(cmp)
              return cmp.show({ callback = function() cmdline_complete_common(cmp, true) end })
            end,
          },
          -- arrows move through the menu when it is open, otherwise browse history
          ["<Down>"] = { "select_next", "fallback" },
          ["<Up>"] = { "select_prev", "fallback" },
          ["<C-n>"] = { "select_next", "fallback" },
          ["<C-p>"] = { "select_prev", "fallback" },
          ["<C-Space>"] = { "show", "fallback" },
          ["<C-e>"] = { "cancel", "fallback" },
        },
        completion = {
          menu = { auto_show = true },
          list = { selection = { preselect = false, auto_insert = true } },
        },
      },
    },
  },
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    lazy = true,
    config = function()
      local ls = require("luasnip")
      local node_util = require("luasnip.nodes.util")

      ls.filetype_extend("typescript", { "javascript" })
      ls.filetype_extend("javascriptreact", { "javascript" })
      ls.filetype_extend("typescriptreact", { "javascript" })

      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        end
      end, { silent = true, desc = "Expand snippet / next placeholder" })
      vim.keymap.set({ "i", "s" }, "<C-h>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { silent = true, desc = "Previous snippet placeholder" })

      ls.setup({
        enable_autosnippets = true,
        history = true,
        update_events = "TextChanged,TextChangedI",
        -- select the whole placeholder text when jumping into a nested placeholder
        parser_nested_assembler = function(_, snippetNode)
          local select = function(snip, no_move, dry_run)
            if dry_run then
              return
            end
            snip:focus()
            -- make sure the inner nodes will all shift to one side when the
            -- entire text is replaced.
            snip:subtree_set_rgrav(true)
            -- fix own extmark-gravities, subtree_set_rgrav affects them as well.
            snip.mark:set_rgravs(false, true)

            -- SELECT all text inside the snippet.
            if not no_move then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
              node_util.select_node(snip)
            end
          end

          local original_extmarks_valid = snippetNode.extmarks_valid
          function snippetNode:extmarks_valid()
            -- the contents of this snippetNode are supposed to be deleted, and
            -- we don't want the snippet to be considered invalid because of
            -- that -> always return true.
            return true
          end

          function snippetNode:init_dry_run_active(dry_run)
            if dry_run and dry_run.active[self] == nil then
              dry_run.active[self] = self.active
            end
          end

          function snippetNode:is_active(dry_run)
            return (not dry_run and self.active) or (dry_run and dry_run.active[self])
          end

          function snippetNode:jump_into(dir, no_move, dry_run)
            self:init_dry_run_active(dry_run)
            if self:is_active(dry_run) then
              -- inside snippet, but not selected.
              if dir == 1 then
                self:input_leave(no_move, dry_run)
                return self.next:jump_into(dir, no_move, dry_run)
              else
                select(self, no_move, dry_run)
                return self
              end
            else
              -- jumping in from outside snippet.
              self:input_enter(no_move, dry_run)
              if dir == 1 then
                select(self, no_move, dry_run)
                return self
              else
                return self.inner_last:jump_into(dir, no_move, dry_run)
              end
            end
          end

          -- this is called only if the snippet is currently selected.
          function snippetNode:jump_from(dir, no_move, dry_run)
            if dir == 1 then
              if original_extmarks_valid(snippetNode) then
                return self.inner_first:jump_into(dir, no_move, dry_run)
              else
                return self.next:jump_into(dir, no_move, dry_run)
              end
            else
              self:input_leave(no_move, dry_run)
              return self.prev:jump_into(dir, no_move, dry_run)
            end
          end

          return snippetNode
        end,
      })
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
  },
  {
    "github/copilot.vim",
    event = "InsertEnter",
    cmd = "Copilot",
    init = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_filetypes = { ["*"] = true, bigfile = false }
    end,
    config = function()
      vim.keymap.set("i", "<C-j>", 'copilot#Accept("<CR>")', {
        expr = true,
        replace_keycodes = false,
        silent = true,
        desc = "Accept Copilot suggestion",
      })
      -- overrides the plain word motion from keymaps.lua, which it falls back to
      vim.keymap.set("i", "<M-Right>", 'copilot#AcceptWord("\\<C-Right>")', {
        expr = true,
        replace_keycodes = false,
        silent = true,
        desc = "Accept Copilot word / word forwards",
      })
    end,
  },
}
