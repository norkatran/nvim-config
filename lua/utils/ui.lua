-- utils/ui.lua
-- UI-related utility functions

local merge = require('utils.common').merge_tables

local M = {}

-- Common border style for floating windows
M.border_style = {
  top_left    = "╭", top    = "─",    top_right = "╮",
  left        = "│",                  right = "│",
  bottom_left = "╰", bottom = "─", bottom_right = "╯",
}

-- Create a centered floating window with title
M.centered_float_config = function(title)
  return {
    border = {
      style = M.border_style,
      text = {
        top = title,
        top_align = 'center',
      }
    },
    position = '50%',
    relative = 'editor',
    size = {
      width = '80%',
      height = '20%',
    },
  }
end

-- Create a floating menu with
M.create_menu = function (title, in_items)
  local Menu = require('nui.menu')
  local items = {}
  for _, obj in pairs(in_items) do
    if obj.separator then
      table.insert(items, Menu.separator(obj.text, { char = '-', text_align = 'center' }))
    else
      table.insert(items, Menu.item(obj))
    end
  end

  local menu = Menu(M.centered_float_config(title), {
    lines = items,
    on_submit = function (item)
      if item.action then
        item.action()
      end
    end
  })

  menu:mount()
end

-- Create a floating scratchpad
M.create_textbox = function (title, default, handler)
  local Popup = require('nui.popup')
  local event = require('nui.utils.autocmd').event

  local popup = Popup({ enter = true, focusable = true })

  popup:update_layout(M.centered_float_config(title))

  local close_popup = function ()
    handler(vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false))
    popup:unmount()
  end

  popup:map("n", "<esc>", close_popup, { noremap = true })
  popup:on(event.BufLeave, close_popup)

  if default then
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, default)
  end

  popup:mount()
end

-- Create a floating single-line input
M.create_input = function (title, on_submit)
  local Input = require('nui.input')

  local input = Input(M.centered_float_config(title), {
    prompt = '> ',
    on_submit = on_submit
  })

  input:map('i', '<Esc>', function () input:unmount() end, { noremap = true })

  input:mount()
end

-- Common plugin setup configurations
M.create_plugin_configs = function ()
  return {
    -- Common treesitter configuration
    treesitter = {
      ensure_installed = {
        "lua", "vim", "vimdoc", "markdown", "markdown_inline",
        "php", "cpp", "diff", "phpdoc", "typescript"
      },
      sync_install = false,
      highlight = { enable = true },
    },

    -- Common telescope configuration
    telescope = {
      defaults = {
        mappings = {
          i = {
            ["<esc>"] = require("telescope.actions").close
          }
        }
      }
    },

    -- Common lualine configuration
    lualine = {
      options = {
        theme = "wombat"
      }
    },

    -- Common Comment configuration
    comment = {
      ignore = "^$"
    }
  }
end

return M
