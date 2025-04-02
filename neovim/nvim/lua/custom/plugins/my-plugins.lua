-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    dir = os.getenv 'HOME' .. '/.config/nvim/lua/custom/comment_width',
    config = function()
      -- TODO: There's a function in the module that's being called on nil.
      -- Figure out why.
      -- require('custom.comment_width').config()
    end,
  },
  {
    dir = os.getenv 'HOME' .. '/.config/nvim/lua/custom/night-owl',
    config = function()
      -- TODO: This seems to be on all the time, making every colorscheme look
      -- weird. Figure out why before reenabling.
      -- require('custom.night-owl').config()
    end,
  },
}

-- return { dir = '~/.config/nvim/lua/custom/plugins/comment_width' }

-- return {
--   -- {
--   --   -- TODO: Figure out why this is not working.
--   --   dir = '~/dotfiles/neovim/nvim/my-plugins/night-owl',
--   --   name = 'night-owl',
--   --   priority = 1000,
--   --   config = function()
--   --     require 'night-own'.setup()
--   --   end,
--   -- },
-- }
