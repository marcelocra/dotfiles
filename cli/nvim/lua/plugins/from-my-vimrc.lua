return {
  -- ===========================================================================
  -- Essential Legacy Plugins
  -- ===========================================================================

  -- The Git King. LazyVim uses gitsigns for gutter info, but Fugitive is
  -- unbeatable for commands (:G, :Gdiff, :Gblame).
  { "tpope/vim-fugitive" },

  -- Handy bracket mappings ([b, ]b, [q, ]q, etc).
  { "tpope/vim-unimpaired" },

  -- Alignment tool (ga).
  {
    "junegunn/vim-easy-align",
    config = function()
      -- Align interactively (gaip -> align inner paragraph)
      vim.keymap.set("n", "ga", "<Plug>(EasyAlign)", { desc = "Easy Align" })
      -- Align visually (select lines -> ga)
      vim.keymap.set("x", "ga", "<Plug>(EasyAlign)", { desc = "Easy Align" })
    end,
  },

  -- ===========================================================================
  -- Modern Replacements
  -- ===========================================================================

  -- Use LazyVim's official Copilot support instead of the old 'github/copilot.vim'.
  -- This uses 'zbirenbaum/copilot.lua' which is pure Lua and much faster/lighter.
  -- NOTE: Disabled in favor of CodeCompanion (OpenRouter) on Jan 13, 2026.
  -- { import = "lazyvim.plugins.extras.coding.copilot" },

  -- ===========================================================================
  -- Disabled / Legacy Plugins (Reference)
  -- ===========================================================================

  -- NOTE: Replaced by 'mini.surround' (LazyVim Default).
  -- Mappings are similar: sa (Add), sd (Delete), sr (Replace).
  -- { "tpope/vim-surround" },

  -- NOTE: Not strictly needed for 'mini.surround' (it has built-in repeat support).
  -- Keep this only if other legacy plugins require it.
  -- { "tpope/vim-repeat" },

  -- NOTE: Replaced by the native Lua version above (lazyvim.plugins.extras.coding.copilot).
  -- {
  -- 	-- Copilot support.
  -- 	"github/copilot.vim",
  -- 	init = function()
  -- 		vim.g.copilot_no_tab_map = true
  -- 	end,
  -- 	config = function()
  -- 		-- Insert the full suggestion.
  -- 		vim.keymap.set("i", "<Tab>", 'copilot#Accept("\\<Tab>")', {
  -- 			expr = true,
  -- 			replace_keycodes = false,
  -- 		})
  -- 		vim.keymap.set("i", "<C-y>", 'copilot#Accept("\\<Tab>")', {
  -- 			expr = true,
  -- 			replace_keycodes = false,
  -- 		})

  -- 		-- Insert only the next world.
  -- 		vim.keymap.set("i", "<C-l>", "<Plug>(copilot-accept-word)")

  -- 		-- Suggestion colors (ghost text).
  -- 		vim.api.nvim_create_autocmd("ColorScheme", {
  -- 			pattern = "solarized",
  -- 			-- group = ...,
  -- 			callback = function()
  -- 				vim.api.nvim_set_hl(0, "CopilotSuggestion", {
  -- 					fg = "#555555",
  -- 					ctermfg = 8,
  -- 					force = true,
  -- 				})
  -- 			end,
  -- 		})
  -- 	end,
  -- },
}
