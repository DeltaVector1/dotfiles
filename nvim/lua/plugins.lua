return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'  -- Packer manages itself
  use 'rebelot/kanagawa.nvim'
  use {
  'nvim-tree/nvim-tree.lua',
  requires = { 'nvim-tree/nvim-web-devicons' },
}
use {
  'nvim-lualine/lualine.nvim',
  requires = { 'nvim-tree/nvim-web-devicons', opt = true }
}
use {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    local function read_ascii(path)
      local lines = {}
      for line in io.lines(vim.fn.expand(path)) do
        table.insert(lines, line)
      end
      return lines
    end

    require('dashboard').setup {
      theme = 'doom',
      config = {
        header = read_ascii('~/.config/nvim/ascii.txt'),
        center = {
          { icon = '  ', desc = 'Find File', key = 'f', action = 'Telescope find_files' },
          { icon = '  ', desc = 'Recent Files', key = 'r', action = 'Telescope oldfiles' },
          { icon = '  ', desc = 'Config', key = 'c', action = 'edit ~/.config/nvim/init.lua' },
          { icon = '  ', desc = 'Quit', key = 'q', action = 'quit' },
        },
        footer = { '', 'To the nameless planet and the primordial land.' }
      }
    }
  end,
  requires = {'nvim-tree/nvim-web-devicons'}
}
end)
