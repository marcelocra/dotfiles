-- Ensures that all my custom lsps and tools are installed.
-- To see the servers, check the `my-lsp-servers.lua` file.

return {
  {

    "marcelocra/mason-tool-installer.nvim",
    config = function()
      local servers = require("my-lsp-servers")
      local ensure_installed = vim.tbl_keys(servers or {})

      vim.list_extend(ensure_installed, {
        -- TIP: Use 'gai<curlies>,' to re-aling.

        -- Original Kickstart provided tool
        -----------------------------------

        "stylua", -- Lua formatter.

        -- Other tools I installed
        --------------------------

        "ruff", -- Python formatter.
        "prettier", -- JavaScript, TypeScript, HTML, CSS, JSX formatter.
        "yamlfmt", -- YAML formatter (https://github.com/google/yamlfmt)

        -- F#.
        -- "fantomas", -- Formatter.
        -- "fsautocomplete", -- Official LSP.

        -- Clojure.
        "clj-kondo", -- Static analyzer and linter.
        "cljfmt", -- Formatter.

        -- Next tool here. Use 'gai<curlies>,' to re-aling.
      })

      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
    end,
  },
}
