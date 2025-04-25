--
-- Customizing Plugin Specs
-- Defaults merging rules:
--
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

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- WARN: This is necessary to avoid overwriting default options, as Lua
      -- lists cannot be merged like tables. LazyVim docs about this here:
      --    https://github.com/LazyVim/lazyvim.github.io/blob/485d853b1e52533c4e360d036f2d27f7c0dc06e1/docs/configuration/examples.md?plain=1#L146
      -- Lua docs here:
      --    https://neovim.io/doc/user/lua.html#vim.tbl_deep_extend()

      -- NOTE: :checkhealth mentions that the following tree-sitter languages
      -- are not installed (maybe they are just not loaded?): css, latex, norg,
      -- scss, svelte, typst, vue.

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
        -- "c_sharp",                 -- [Official] https://github.com/tree-sitter/tree-sitter-c-sharp
        -- "css",                     -- [Official] https://github.com/tree-sitter/tree-sitter-css
        -- "fsharp",                  -- [Ionide] https://github.com/ionide/tree-sitter-fsharp
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
