-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

local plugin_path = function(plugin_name)
  return (os.getenv 'MCRA_PROJECTS_FOLDER') .. '/dotfiles/neovim/nvim/lua/custom/my-plugins/' .. plugin_name
end

return {
  {
    dir = plugin_path 'night-owl',
    name = 'night-owl',
    config = function()
      require 'night-owl'
    end,
    priority = 1000,
  },
}
