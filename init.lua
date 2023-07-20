require "options"
require "keybinds"
require "bootstrap"
require "dep" {
  {
    "nvim-tree/nvim-tree.lua",
    requires = { "nvim-tree/nvim-web-devicons" }
  },
  {
    "nvim-lualine/lualine.nvim",
    requires = { "nvim-tree/nvim-web-devicons" }
  }
}

require("nvim-tree").setup()
require("lualine").setup({
  options = {
    theme = 'wombat'
  }
})
