--
-- List of LSP servers to be installed.
--

return {

  -- Written by a Nubanker.
  -- https://github.com/clojure-lsp/clojure-lsp
  clojure_lsp = {},

  -- Official LSP for F#, initially by FSharp Software Foundation, now maintained by Ionide.
  fsautocomplete = {},

  -- Official LSP.
  -- https://github.com/ocaml/ocaml-lsp
  ocamllsp = {},

  -- Static Type Checker for Python, by Microsoft.
  -- https://github.com/microsoft/pyright
  pyright = {},

  yamlls = {}, -- Used by the official VSCode YAML extension, by RedHat.

  ts_ls = {
    root_dir = require("lspconfig").util.root_pattern({ "package.json", "tsconfig.json" }),
    single_file_support = false,
    settings = {},
  },

  -- Official lsp from the Deno project.
  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#denols
  denols = {
    root_dir = require("lspconfig").util.root_pattern({ "deno.json", "deno.jsonc" }),
    single_file_support = false,
    settings = {},
  },

  -- Next lsp server here.
}
