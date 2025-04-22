return {
  -- LSP keymaps
  {
    "neovim/nvim-lspconfig",

    opts = require("my-lsp-servers"),

    -- NOTE: Docs (https://www.lazyvim.org/plugins/lsp) recommend the following
    -- to change an LSP keymap.
    --
    -- opts = function()
    --   local keys = require("lazyvim.plugins.lsp.keymaps").get()
    --   -- change a keymap
    --   keys[#keys + 1] = { "K", "<cmd>echo 'hello'<cr>" }
    --   -- disable a keymap
    --   keys[#keys + 1] = { "K", false }
    --   -- add a keymap
    --   keys[#keys + 1] = { "H", "<cmd>echo 'hello'<cr>" }
    -- end,
  },
}
