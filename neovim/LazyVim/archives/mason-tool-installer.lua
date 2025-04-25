--
-- Ensures that all my custom lsps and tools are installed.
--
-- I believe this can be necessary in two cases:
--
--  1) Something is not provided by LazyVim.
--  2) I don't want to use LazyVim's alternative.
--

return {
  {
    "marcelocra/mason-tool-installer.nvim",

    config = function()
      local servers = require("mcra.lib.lsp-servers")
      local ensure_installed = vim.tbl_keys(servers or {})

      vim.list_extend(ensure_installed, {
        ------------------------------------------------------------------------
        -- These are the packages that I installed before using LazyVim. Keeping
        -- them here for my future reference.
        ------------------------------------------------------------------------
        -- "stylua", -- Lua formatter.
        -- "ruff", -- Python formatter.
        -- "prettier", -- JavaScript, TypeScript, HTML, CSS, JSX formatter.
        -- "yamlfmt", -- YAML formatter (https://github.com/google/yamlfmt)

        -- -- F# --
        -- --------
        -- "fsautocomplete", -- Official LSP.
        -- "fantomas", -- Formatter.

        -- -- Clojure --
        -- -------------
        -- "clj-kondo", -- Static analyzer and linter.
        -- "cljfmt", -- Formatter.
        ------------------------------------------------------------------------
      })

      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
    end,
  },
}
