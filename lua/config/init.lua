-- config/init.lua
-- Central configuration module

local M = {}

-- Common plugin configurations
M.plugins = {
  -- Treesitter configuration
  treesitter = {
    ensure_installed = { 
      "lua", "vim", "vimdoc", "markdown", "markdown_inline", 
      "php", "cpp", "diff", "phpdoc", "typescript" 
    },
    sync_install = false
  },
  
  -- Mason configuration
  mason = {
    ensure_installed = { "lua_ls", "phpactor" },
    automatic_installation = true,
  },
  
  -- Lualine configuration
  lualine = {
    options = {
      theme = "wombat"
    }
  },
  
  -- Comment configuration
  comment = {
    ignore = "^$"
  },
  
  -- Telescope configuration
  telescope = {
    defaults = {
      mappings = {
        i = {
          ["<esc>"] = require("telescope.actions").close
        }
      }
    }
  }
}

-- Common UI elements
M.ui = {
  -- Border style for floating windows
  border = {
    style = {
      top_left    = "╭", top    = "─",    top_right = "╮",
      left        = "│",                      right = "│",
      bottom_left = "╰", bottom = "─", bottom_right = "╯",
    }
  }
}

return M
