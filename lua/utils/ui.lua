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
    end,
  })

  menu:mount()
end

M.create_menu_with_key = function (title, in_items, mappings)
  local Menu = require('nui.menu')
  local Layout = require('nui.layout')
  local Popup = require('nui.popup')
  local items = {}
  for _, obj in pairs(in_items) do
    if obj.separator then
      table.insert(items, Menu.separator(obj.text, { char = '-', text_align = 'center' }))
    else
      table.insert(items, Menu.item(obj))
    end
  end

  local current_node = nil
  local menu = Menu(M.centered_float_config(title), {
    lines = items,
    on_submit = function (item)
      if item.action then
        item.action()
      end
    end,
    on_change = function (item)
      current_node = item
    end
  })

  local get_keymap_args = function ()
    return { node = current_node, menu = menu }
  end

  for _, map in pairs(mappings) do
    menu:map('n', map[1], function () map[2](get_keymap_args()) end)
  end

  local popup = Popup(M.centered_float_config('Key'))

  for i,map in ipairs(mappings) do
    local text = map[1] .. '\t' .. map.desc
    vim.api.nvim_buf_set_lines(popup.bufnr, i, -1, false, { text })
  end

  local layout = Layout(
    M.centered_float_config(title),
    Layout.Box({
      Layout.Box(menu, { size = '75%' }),
      Layout.Box(popup, { size = '25%' })
    }, { dir = 'row' })
  )

  layout:mount()
end

-- Create a floating scratchpad
M.create_textbox = function (title, default, handler, opts)
  local Popup = require('nui.popup')
  local event = require('nui.utils.autocmd').event

  local config = M.centered_float_config(title)
  config.enter = true
  config.focusable = true
  local popup = Popup(config)

  local close_popup = function ()
    handler(vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false))
    popup:unmount()
  end

  popup:on(event.BufLeave, close_popup)

  if default then
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, default)
  end

  opts = opts or {}
  if not opts.modifiable then
    opts.modifiable = true
  end

  for k, v in pairs(opts) do
    vim.api.nvim_set_option_value(k, v, { buf = popup.bufnr })
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
