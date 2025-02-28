local cmp = require 'cmp'

-- Values in parenthesis were the default.
-- See ./cmp-mappings-default.lua for more details.
return cmp.mapping.preset.insert {
  -- Select the [n]ext item (<C-n>).
  ['<C-j>'] = cmp.mapping.select_next_item(),
  -- Select the [p]revious item (<C-p>).
  ['<C-k>'] = cmp.mapping.select_prev_item(),

  -- Scroll the documentation window [b]ack / [f]orward (<C-b/f>).
  ['<C-u>'] = cmp.mapping.scroll_docs(-4),
  ['<C-d>'] = cmp.mapping.scroll_docs(4),

  -- Accept ([y]es) the completion (<C-y>).
  --  This will auto-import if your LSP supports it.
  --  This will expand snippets if the LSP sent a snippet.
  ['<Tab>'] = cmp.mapping.confirm { select = true },

  -- If you prefer more traditional completion keymaps,
  -- you can uncomment the following lines
  -- ['<CR>'] = cmp.mapping.confirm { select = true },
  -- ['<Tab>'] = cmp.mapping.select_next_item(),
  -- ['<S-Tab>'] = cmp.mapping.select_prev_item(),

  -- Manually trigger a completion from nvim-cmp.
  --  Generally you don't need this, because nvim-cmp will display
  --  completions whenever it has completion options available.
  ['<C-Space>'] = cmp.mapping.complete {},

  -- Think of <c-l> as moving to the right of your snippet expansion.
  --  So if you have a snippet that's like:
  --  function $name($args)
  --    $body
  --  end
  --
  -- <c-l> will move you to the right of each of the expansion locations.
  -- <c-h> is similar, except moving you backwards.
  -- ['<C-l>'] = cmp.mapping(function()
  --     if luasnip.expand_or_locally_jumpable() then
  --         luasnip.expand_or_jump()
  --     end
  -- end, { 'i', 's' }),
  -- ['<C-h>'] = cmp.mapping(function()
  --     if luasnip.locally_jumpable(-1) then
  --         luasnip.jump(-1)
  --     end
  -- end, { 'i', 's' }),

  -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
  --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
}
