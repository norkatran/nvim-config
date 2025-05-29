local utils = require("utils")
local whichkey = require("which-key")

local border_style = {
  top_left = "╭",
  top = "─",
  top_right = "╮",
  left = "│",
  right = "│",
  bottom_left = "╰",
  bottom = "─",
  bottom_right = "╯",
}
local pin_width = 80
local state = { pins = {} }

local map = utils.map;
local merge = utils.merge;

local M = {}

local function to_nui (item)
  local Menu = require("nui.menu")
  if item.separator then
    return Menu.separator(item.text, { char = "-", text_align = "center" })
  end
  return Menu.item(item)
end

local function centered_float_config (title, options)
  local width = options and options.width or math.floor(vim.o.columns * 0.8)
  local height = options and options.height or math.floor(vim.o.lines * 0.8)
  return {
    border = { style = border_style, text = { top = title, top_align = "center" } },
    position = "50%",
    relative = "editor",
    size = { width = width, height = height }
  }
end

local function menu_needs_popup (options)
  return options.mappings or options.desc
end

M.create_menu = function (title, items, options)
  local Menu = require("nui.menu")
  local Layout = require("nui.layout")
  local Popup = require("nui.popup")
  local mappings = options.mappings or {}
  local desc = options.desc or {}
  local menu_items = map(items, to_nui)
  local menu_state = { current = menu_items[1] }
  local menu = Menu(centered_float_config(title), {
    lines = menu_items,
    on_submit = function (x)
      if x.action then
        x.action()
      end
    end,
    on_change = function (x)
      menu_state.current = x
    end
  })
  menu:map("i", "<esc>", "<cmd>:x<cr>", { noremap = true })
  menu:map("n", "<esc>", "<cmd>:x<cr>", { noremap = true })
  if not menu_needs_popup(options) then
    menu:mount()
    return
  end
  local popup = Popup(centered_float_config(title))
  if desc then
    for _, desc_part in ipairs(desc) do
      vim.api.nvim_buf_set_lines(popup.bufnr, -1, -1, false, {desc_part})
    end
  else
    vim.api.nvim_buf_set_lines(popup.bufnr, -1, -1, false, {""})
  end
  for _, mapping in ipairs(mappings) do
    menu:map("n", mapping[1], function (ctx)
      menu:unmount()
      mapping[2](menu_state.current)
    end)
    vim.api.nvim_buf_set_lines(popup.bufnr, -1, -1, false, {mapping[1] .. " " .. mapping.desc})
  end
  local layout = Layout(centered_float_config(title), Layout.Box({Layout.Box(menu, { size = "75%" }), Layout.Box(popup, { size = "25%" })}, { dir = "row" }))
  layout:mount()
end

M.create_textbox = function (title, default, handler, options)
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event
  local popup = Popup(merge(centered_float_config(title), {
    enter = true,
    focusable = true
  }))
  popup:on(event.BufLeave, function ()
    handler(vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false))
    popup:unmount()
  end)
  if default then
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, default)
  end
  options = merge(options, {
    modifiable = true,
  })
  for k, v in pairs(options) do
    vim.api.nvim_set_option_value(k, v, { buf = popup.bufnr })
  end
  popup:map("i", "<esc>", "<cmd>:x<cr>", { noremap = true })
  popup:map("n", "<esc>", "<cmd>:x<cr>", { noremap = true })
end

local function input_needs_popup (options)
  return options.desc or options.mappings
end

M.create_input = function (title, handler, options)
  local Input = require("nui.input")
  local Popup = require("nui.popup")
  local Layout = require("nui.layout")
  options = options or {}
  local input = Input(centered_float_config(title, options), {
    prompt = "> ",
    on_submit = handler
  })
  input:map("i", "<esc>", function () input:unmount() end, { noremap = true })
  input:map("n", "<esc>", function () input:unmount() end, { noremap = true })
  if not input_needs_popup(options) then
    input:mount()
    return
  end
  local popup = Popup(centered_float_config(title, options))
  local layout = Layout(centered_float_config(title, options), Layout.Box({
    Layout.Box(input, { size = "25%" }),
    Layout.Box(popup, { size = "75%" })
  }, { dir = "col" }))
  for _, desc_part in ipairs(options.desc or {}) do
    vim.api.nvim_buf_set_lines(popup.bufnr, -1, -1, false, { desc_part })
  end
  layout:mount()
end

local function default_column(position, width)
  if position == "top-right" or position == "bottom-right" then
    return vim.o.columns - width - 2
  end
  return 1
end

local function default_row(position, height)
  if position == "bottom-right" or position == "bottom-left" then
    return vim.o.lines - height - 4
  end
  return 1
end

local function get_pin_position(position, width, height)
  local existing = {}
  local pos_state = { row = default_row(position, height), col = default_column(position, width) }
  for _, pin in pairs(state.pins) do
    if position == pin.position then
      table.insert(existing, pin)
    end
  end
  for _, pin in ipairs(existing) do
    local height = pin.max_height
    local width = pin.width
    if position == "top-right" or position == "top-left" then
      pos_state.row = pos_state.row + height + 3
    else
      pos_state.row = pos_state.row - width - 3
    end
  end
  return pos_state
end

local function remove_pin(title, rerender)
  local close = function (pin)
    vim.api.nvim_win_close(pin.win, true)
    vim.api.nvim_buf_delete(pin.buf, { force = true })
  end
  local old_state = state.pins
  state.pins = {}
  for t, v in pairs(old_state) do
    close(v)
    if title ~= t then
      rerender(v)
    end
  end
end

M.create_pin = function(title, get_items, options)
  options = options or {}
  local max_height = options.max_height or 4
  local position = options.position or "top-right"
  local keep = options.keep or false
  local width = pin_width
  local items = get_items(width)
  local height = math.min(math.max(#items, 1), max_height)
  local pos = get_pin_position(position, width, height)

  if not state.pins[title] then
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, false, {
      relative = "editor",
      height = height,
      width = width + 2,
      row = pos.row,
      col = pos.col,
      style = "minimal",
      border = "rounded",
      title = title,
      title_pos = "center",
      zindex = 45
    })
    state.pins[title] = {
      title = title,
      max_height = max_height,
      position = position,
      keep = keep,
      width = width,
      items = items,
      row = pos.row,
      col = pos.col,
      buf = buf,
      win = win
    }
  end
  for pin_title, pin in pairs(state.pins) do
    if title == pin_title then
      local lines = {}
      vim.api.nvim_win_set_height(pin.win, height)
      vim.api.nvim_buf_set_lines(pin.buf, 0, -1, false, {""})
      for i, item in ipairs(items) do
        table.insert(lines, item)
        vim.api.nvim_buf_set_lines(pin.buf, i - 1, i, false, {item})
      end
      if not keep and #lines == 0 then
        remove_pin(title, function (p)
          M.create_pin(p.title, function () return p.items end, {
            max_height = p.max_height,
            position = p.position,
            keep = p.keep
          })
        end)
      end
    end
  end
end

return M
