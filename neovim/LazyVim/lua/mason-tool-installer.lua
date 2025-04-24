--
-- Ensures that all my custom lsps and tools are installed.
--
-- This will only be necessary when using something that is not already
-- provided by LazyVim.
--

return {
  {
    "marcelocra/mason-tool-installer.nvim",

    config = function()
      local servers = require("lsp-servers")
      local ensure_installed = vim.tbl_keys(servers or {})

      -- stylua: ignore
      vim.list_extend(ensure_installed, {
        -- Realign: `gaip,` with the cursor in the block below.

        "stylua",         -- Lua formatter.
        "ruff",           -- Python formatter.
        "prettier",       -- JavaScript, TypeScript, HTML, CSS, JSX formatter.
        "yamlfmt",        -- YAML formatter (https://github.com/google/yamlfmt)
        -- F#
        "fsautocomplete", -- Official LSP.
        "fantomas",       -- Formatter.
        -- Clojure
        "clj-kondo",      -- Static analyzer and linter.
        "cljfmt",         -- Formatter.

      })

      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
    end,
  },
}
