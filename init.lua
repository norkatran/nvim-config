require "options"
require "bootstrap"

require("lazy").setup("plugins")

require "keybinds"

require("nvim-web-devicons").setup {}
require("nvim-treesitter.configs").setup {
  ensure_installed = { "lua", "vim", "vimdoc", "markdown", "markdown_inline", "php", "cpp", "diff", "phpdoc", "typescript" },

  sync_install = false
}

require('fidget').setup()

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
require('telescope').load_extension('fidget')

require("lualine").setup({
  options = {
    theme = "wombat"
  }
})

require("Comment").setup {
  ignore = "^$"
}

require("mini.surround").setup {}

require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = { "lua_ls", "phpactor" },
  automatic_installation = true,
}
require("mason-lspconfig").setup_handlers {
  function (server_name)
    require("lspconfig")[server_name].setup {}
  end,
}
