--
-- Defaults merging rules:
--  * cmd: the list of commands will be extended with your custom commands
--  * event: the list of events will be extended with your custom events
--  * ft: the list of filetypes will be extended with your custom filetypes
--  * keys: the list of keymaps will be extended with your custom keymaps
--  * opts: your custom opts will be merged with the default opts
--  * dependencies: the list of dependencies will be extended with your custom
--    dependencies any other property will override the defaults
--
-- For ft, event, keys, cmd and opts you can instead also specify a values
-- function that can make changes to the default values, or return new values to
-- be used instead.
--
-- Docs from:
-- https://www.lazyvim.org/configuration/plugins#%EF%B8%8F-customizing-plugin-specs
--

-- Add here the LSPs and tools that you want automatically installed. Notice
-- that they are listed separately, since LSPs also accept a configuration.

local lsps = {
  -- Written by a Nubanker. https://github.com/clojure-lsp/clojure-lsp
  clojure_lsp = {},

  -- Official LSP for F#, initially by FSharp Software Foundation, now
  -- maintained by Ionide.
  fsautocomplete = {},

  -- Official LSP.
  -- https://github.com/ocaml/ocaml-lsp
  ocamllsp = {},

  -- Used by the official VSCode YAML extension, by RedHat.
  yamlls = {},
}

-- For more examples of packages, see at the end of this file.
local ensure_installed = vim.tbl_keys(lsps or {})
vim.list_extend(ensure_installed, {

  -- Tools installed by default.
  "stylua",
  "shfmt",

  -- Static Type Checker for Python, by Microsoft.
  -- https://github.com/microsoft/pyright
  "pyright",

  -- Widely used Python linter and formatter.
  -- https://github.com/astral-sh/ruff
  "ruff",

  -- From Borkdude, creator or Babashka and many widely used Clojure
  -- tools. https://github.com/clj-kondo/clj-kondo
  "clj-kondo",

  -- From Wavejeaster, also creator of many widely used Clojure tools.
  -- https://github.com/weavejester/cljfmt
  "cljfmt",

  -- Most commonly used F# formatter.
  -- https://github.com/fsprojects/fantomas
  "fantomas",

  -- Next tool above this line.
})

return {
  -- {
  --   -- [note] kept here to simplify adding configs eventually.
  --   "williamboman/mason.nvim",
  --   opts = {},
  -- },

  {
    "marcelocra/mason-tool-installer.nvim",
    opts = { ensure_installed = ensure_installed },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = lsps,
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- WARN: This is necessary, to avoid overwriting the default options, as
      -- Lua lists cannot be merged like tables can[1]. It was mentioned in
      -- lazyvim examples config[2].
      -- Links:
      --  [1]: https://neovim.io/doc/user/lua.html#vim.tbl_deep_extend()
      --  [2]: https://github.com/LazyVim/lazyvim.github.io/blob/485d853b1e52533c4e360d036f2d27f7c0dc06e1/docs/configuration/examples.md?plain=1#L146

      -- TODO: Double check which tree-sitter languages are required.
      -- :checkhealth mentions that the following are not installed (maybe they
      -- are just not loaded?): css, latex, norg, scss, svelte, typst, vue.

      -- stylua: ignore
      vim.list_extend(opts.ensure_installed, {

        ----------------------------------------------------------------------------------------------
        -- Comes with nvim 0.11.0, no need to install.
        ----------------------------------------------------------------------------------------------
        -- "c",                    -- [Official] https://github.com/tree-sitter/tree-sitter-c
        -- "lua",                  -- [Kickstart] It was: https://github.com/MunifTanjim/tree-sitter-lua
        -- "markdown",             -- [Kickstart] https://github.com/tree-sitter-grammars/tree-sitter-markdown
        -- "markdown_inline",      -- [Kickstart] https://github.com/tree-sitter-grammars/tree-sitter-markdown
        -- "query",                -- [Kickstart] It was: https://github.com/nvim-treesitter/tree-sitter-query
        -- --,                     --     but changed to:
        -- --,                     --     https://github.com/tree-sitter-grammars/tree-sitter-query
        -- "vim",                  -- https://github.com/neovim/tree-sitter-vim
        -- "vimdoc",               -- https://github.com/neovim/tree-sitter-vimdoc
        ----------------------------------------------------------------------------------------------
        -- Added by Kickstart.
        ----------------------------------------------------------------------------------------------
        -- "bash",                    -- [Official] https://github.com/tree-sitter/tree-sitter-bash
        -- "diff",                    -- [Kickstart] https://github.com/the-mikedavis/tree-sitter-diff
        -- "html",                    -- [Official] https://github.com/tree-sitter/tree-sitter-html
        -- --,                        --     but changed to:
        -- --,                        --     https://github.com/tree-sitter-grammars/tree-sitter-lua
        -- "luadoc",                  -- [Kickstart] It was: https://github.com/amaanq/tree-sitter-luadoc
        -- --,                        --     but changed to:
        -- --,                        --     https://github.com/tree-sitter-grammars/tree-sitter-luadoc
        ----------------------------------------------------------------------------------------------
        -- Added by me.
        ----------------------------------------------------------------------------------------------
        "c_sharp",                 -- [Official] https://github.com/tree-sitter/tree-sitter-c-sharp
        "css",                     -- [Official] https://github.com/tree-sitter/tree-sitter-css
        "fsharp",                  -- [Ionide] https://github.com/ionide/tree-sitter-fsharp
        -- "go",                      -- [Official] https://github.com/tree-sitter/tree-sitter-go
        -- "javascript",              -- [Official] https://github.com/tree-sitter/tree-sitter-javascript
        -- "rust",                    -- [Official] https://github.com/tree-sitter/tree-sitter-rust
        -- "regex",                   -- [Official] https://github.com/tree-sitter/tree-sitter-regex
        -- Have a LazyVim extra, so no need to install manually:
        -- "ocaml",                   -- [Official] https://github.com/tree-sitter/tree-sitter-ocaml
        -- "python",                  -- [Official] https://github.com/tree-sitter/tree-sitter-python
        -- "json",                    -- [Official] https://github.com/tree-sitter/tree-sitter-json
        -- "typescript",              -- [Official] https://github.com/tree-sitter/tree-sitter-typescript
        -- "tsx",                     -- [Official] https://github.com/tree-sitter/tree-sitter-typescript
        -- "yaml",                    -- https://github.com/tree-sitter-grammars/tree-sitter-yaml


      })
    end,
  },
}

-- Packages I have installed at 6mai25. Most of these are automatically
-- installed either by LazyVim or by the associated LazyVim extra.
--
-- eslint-lsp eslint (keywords: javascript, typescript)
-- gofumpt (keywords: go)
-- goimports (keywords: go)
-- gopls (keywords: go)
-- json-lsp jsonls (keywords: json)
-- lua-language-server lua_ls (keywords: lua)
-- markdown-toc (keywords: markdown)
-- markdownlint-cli2 (keywords: markdown)
-- marksman (keywords: markdown)
-- ocaml-lsp ocamllsp (keywords: ocaml)
-- prettier (keywords: angular, css, flow, graphql, html, json, jsx, javascript, less, markdown, scss, typescript, vue, yaml)
-- pyright (keywords: python)
-- ruff (keywords: python)
-- shfmt (keywords: bash, mksh, shell)
-- stylua (keywords: lua, luau)
-- tailwindcss-language-server tailwindcss (keywords: css)
-- taplo (keywords: toml)
-- vtsls (keywords: javascript, typescript)
-- yaml-language-server yamlls (keywords: yaml)
