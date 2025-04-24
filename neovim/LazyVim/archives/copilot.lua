return {
  {
    -- Copilot support.
    "github/copilot.vim",
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
    config = function()
      -- Good alternative to tab: <C-y>.
      vim.keymap.set("i", "<Tab>", 'copilot#Accept("\\<Tab>")', {
        expr = true,
        replace_keycodes = false,
      })

      vim.keymap.set("i", "<C-y>", 'copilot#Accept("\\<Tab>")', {
        expr = true,
        replace_keycodes = false,
      })

      vim.keymap.set("i", "<C-l>", "<Plug>(copilot-accept-word)")

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

      --
    end,
  },
}
