return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Tools installed by default (I think?).
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
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Written by a Nubanker. https://github.com/clojure-lsp/clojure-lsp
        clojure_lsp = {},

        -- Official LSP for F#, initially by FSharp Software Foundation, now
        -- maintained by Ionide.
        fsautocomplete = {},

        -- Official LSP. Requires opam (i.e. install OCaml before using this).
        -- https://github.com/ocaml/ocaml-lsp
        -- ocamllsp = {},

        -- Used by the official VSCode YAML extension, by RedHat.
        yamlls = {},

        -- Next lsp above.
      },
    },
  },

  -- {
  --   "neovim/nvim-lspconfig",
  --   dependencies = {
  --     -- Mason must be loaded before its dependents so we need to set it up here.
  --     -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
  --     { "williamboman/mason.nvim", opts = {} },
  --     "williamboman/mason-lspconfig.nvim",
  --     "marcelocra/mason-tool-installer.nvim",
  --   },
  --   -- opts = {
  --   --   servers = lsps,
  --   -- },
  --   opts = function(_, opts)
  --     -- Add here the LSPs and tools that you want automatically installed.
  --     -- Notice that they are listed separately, since LSPs also accept a
  --     -- configuration.
  --     --
  --     -- Add any additional override configuration in the following tables.
  --     -- Available keys are:
  --     --  - cmd (table): Override the default command used to start the server
  --     --  - filetypes (table): Override the default list of associated filetypes
  --     --    for the server
  --     --  - capabilities (table): Override fields in capabilities. Can be used
  --     --    to disable certain LSP features.
  --     --  - settings (table): Override the default settings passed when
  --     --    initializing the server.
  --     -- For example, to see the options for `lua_ls`, you could go to:
  --     -- https://luals.github.io/wiki/settings/
  --     local servers = {
  --       -- Written by a Nubanker. https://github.com/clojure-lsp/clojure-lsp
  --       clojure_lsp = {},
  --
  --       -- Official LSP for F#, initially by FSharp Software Foundation, now
  --       -- maintained by Ionide.
  --       fsautocomplete = {},
  --
  --       -- Official LSP.
  --       -- https://github.com/ocaml/ocaml-lsp
  --       ocamllsp = {},
  --
  --       -- Used by the official VSCode YAML extension, by RedHat.
  --       yamlls = {},
  --
  --       -- Next lsp above.
  --     }
  --
  --     -- For more examples of packages, see at the end of this file.
  --     local ensure_installed = vim.tbl_keys(servers or {})
  --     vim.list_extend(ensure_installed, {
  --
  --       -- Tools installed by default.
  --       "stylua",
  --       "shfmt",
  --
  --       -- Static Type Checker for Python, by Microsoft.
  --       -- https://github.com/microsoft/pyright
  --       "pyright",
  --
  --       -- Widely used Python linter and formatter.
  --       -- https://github.com/astral-sh/ruff
  --       "ruff",
  --
  --       -- From Borkdude, creator or Babashka and many widely used Clojure
  --       -- tools. https://github.com/clj-kondo/clj-kondo
  --       "clj-kondo",
  --
  --       -- From Wavejeaster, also creator of many widely used Clojure tools.
  --       -- https://github.com/weavejester/cljfmt
  --       "cljfmt",
  --
  --       -- Most commonly used F# formatter.
  --       -- https://github.com/fsprojects/fantomas
  --       "fantomas",
  --
  --       -- Next tool above this line.
  --     })
  --
  --     require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
  --     require("mason-lspconfig").setup({
  --       ensure_installed = {}, -- Install via mason-tool-installer, above.
  --       automatic_installation = false,
  --       handlers = {
  --         function(server_name)
  --           local default_server = opts.servers[server_name] or {}
  --           local server = servers[server_name] or {}
  --           -- This handles overriding only values explicitly passed by the
  --           -- server configuration above. Useful when disabling certain
  --           -- features of an LSP (for example, turning off formatting for
  --           -- ts_ls).
  --           server = vim.tbl_deep_extend("force", {}, default_server, server or {})
  --           require("lspconfig")[server_name].setup(server)
  --         end,
  --       },
  --     })
  --   end,
  -- },

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
        -- "bash",                 -- [Official] https://github.com/tree-sitter/tree-sitter-bash
        -- "diff",                 -- [Kickstart] https://github.com/the-mikedavis/tree-sitter-diff
        -- "html",                 -- [Official] https://github.com/tree-sitter/tree-sitter-html
        -- --,                     --   but changed to:
        -- --,                     --   https://github.com/tree-sitter-grammars/tree-sitter-lua
        -- "luadoc",               -- [Kickstart] It was: https://github.com/amaanq/tree-sitter-luadoc
        -- --,                     --   but changed to:
        -- --,                     --   https://github.com/tree-sitter-grammars/tree-sitter-luadoc
        ----------------------------------------------------------------------------------------------
        -- Added by me in my previous install (with Kickstart).
        ----------------------------------------------------------------------------------------------
        "c_sharp",                 -- [Official] https://github.com/tree-sitter/tree-sitter-c-sharp
        "css",                     -- [Official] https://github.com/tree-sitter/tree-sitter-css
        "fsharp",                  -- [Ionide] https://github.com/ionide/tree-sitter-fsharp
        -- "go",                   -- [Official] https://github.com/tree-sitter/tree-sitter-go
        -- "javascript",           -- [Official] https://github.com/tree-sitter/tree-sitter-javascript
        -- "rust",                 -- [Official] https://github.com/tree-sitter/tree-sitter-rust
        -- "regex",                -- [Official] https://github.com/tree-sitter/tree-sitter-regex
        -- -- The ones below have a LazyVim extra. No need to install manually
        -- -- if using the extra:
        -- "ocaml",                -- [Official] https://github.com/tree-sitter/tree-sitter-ocaml
        -- "python",               -- [Official] https://github.com/tree-sitter/tree-sitter-python
        -- "json",                 -- [Official] https://github.com/tree-sitter/tree-sitter-json
        -- "typescript",           -- [Official] https://github.com/tree-sitter/tree-sitter-typescript
        -- "tsx",                  -- [Official] https://github.com/tree-sitter/tree-sitter-typescript
        -- "yaml",                 -- https://github.com/tree-sitter-grammars/tree-sitter-yaml
        ----------------------------------------------------------------------------------------------
        -- Next below.
        ----------------------------------------------------------------------------------------------
        "clojure",                 -- Contributed by sogaiu and borkdude,
        -- --,                     --   both with more contributions in the community. Code:
        -- --,                     --   https://github.com/sogaiu/tree-sitter-clojure


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
