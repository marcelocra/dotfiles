print("Loading my-plugins.lua")

return {
  -- Amazing Git support.
  { "tpope/vim-fugitive" },

  -- Improve mappings for default stuff.
  { "tpope/vim-unimpaired", vscode = true },

  -- Simplify handling "wrappings" (parens, [curly]braces, quotes, etc).
  { "tpope/vim-surround", vscode = true },

  -- Improve repeat support (e.g. for surrounding stuff).
  { "tpope/vim-repeat", vscode = true },

  {
    -- Copilot support.
    "github/copilot.vim",
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
    config = function()
      -- Insert the full suggestion.
      vim.keymap.set("i", "<Tab>", 'copilot#Accept("\\<Tab>")', {
        expr = true,
        replace_keycodes = false,
      })
      vim.keymap.set("i", "<C-y>", 'copilot#Accept("\\<Tab>")', {
        expr = true,
        replace_keycodes = false,
      })

      -- Insert only the next world.
      vim.keymap.set("i", "<C-l>", "<Plug>(copilot-accept-word)")

      -- Suggestion colors (ghost text).
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "solarized",
        -- group = ...,
        callback = function()
          vim.api.nvim_set_hl(0, "CopilotSuggestion", {
            fg = "#555555",
            ctermfg = 8,
            force = true,
          })
        end,
      })

      -- Default mappings:
      -- <C-]>       Dismiss the current suggestion.                               <Plug>(copilot-dismiss)
      -- <M-]>       Cycle to the next suggestion, if one is available.            <Plug>(copilot-next)
      -- <M-[>       Cycle to the previous suggestion.                             <Plug>(copilot-previous)
      -- <M-\>       Explicitly request a suggestion, even if Copilot is disabled. <Plug>(copilot-suggest)
      -- <M-Right>   Accept the next word of the current suggestion.               <Plug>(copilot-accept-word)
      -- <M-C-Right> Accept the next line of the current suggestion.               <Plug>(copilot-accept-line)
    end,
  },

  {
    "junegunn/vim-easy-align",
    vscode = true,

    init = function()
      -- Default: vim.g.easy_align_ignore_groups = { "Comment",  "String" }
      -- But I want to align at least in comments. Not sure if strings make
      -- sense though.
      vim.g.easy_align_ignore_groups = { "String" }
    end,

    config = function()
      -- Start interactive EasyAlign in visual mode (e.g. vipga)
      vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")

      -- Start interactive EasyAlign for a motion/text object (e.g. gaip)
      vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")
    end,
  },

  {
    -- Change the default (gpt-4o) Copilot model to use in chat.
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      model = "claude-3.7-sonnet",
    },
  },

  -- Next plugin above.
}
