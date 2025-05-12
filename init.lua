require "options"
require "keybinds"
require "bootstrap"

require("lazy").setup("plugins")

require("nvim-web-devicons").setup {}
require("nvim-treesitter.configs").setup {
  ensure_installed = { "lua", "vim", "vimdoc", "markdown", "markdown_inline", "php", "cpp", "diff", "phpdoc", "typescript" },

  sync_install = false
}
require("nvim-tree").setup()

local actions = require("telescope.actions")
require("telescope").setup {
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close
      }
    }
  }
}
require("lualine").setup({
  options = {
    theme = "wombat"
  }
})

require("Comment").setup {
  ignore = "^$"
}
