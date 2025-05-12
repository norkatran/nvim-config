-- config/init.lua
-- Central configuration module

local gitlab = require('utils.gitlab')

local M = {}

-- Common plugin configurations
M.create_plugin_configs = function ()
  return {
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
        theme = "powerline_dark",
        sections = {
          -- left
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename', function () return [[aaa]] end, gitlab.outstanding_gitlab_notifications },

          -- right
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }

        }
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
end

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
