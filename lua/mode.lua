local utils = require('utils')

-- Get the name of the current buffer or specified buffer
local function get_buffer_name(buf)
  return vim.api.nvim_buf_get_name(buf or 0)
end

-- Format a file using the specified formatter
local function format(formatter, file)
  if formatter then
    local fmt = (type(formatter) == "string") and formatter or formatter()
    if fmt then
      utils.background_process({ fmt, file }, {
        on_success = function()
          vim.cmd("e!")
        end,
        silent = true,
      })
    end
  end
end

local function get_modes()
  local config_path = vim.fn.stdpath("config")
  local modes_dir = vim.fs.joinpath(config_path, "lua", "modes")

  local modes = {}
  for name, _ in vim.fs.dir(modes_dir) do
    local filename = string.sub(name, 1, -5) -- Remove .lua extension
    modes[filename] = require("modes." .. filename)
  end
  return modes
end

-- Load mode-specific configurations
local modes = get_modes()

  vim.api.nvim_create_autocmd("BufWritePost", {
    --pattern = mode.pattern,
    --group = group,
    callback = function(args)
      vim.lsp.buf.format()
      -- format(mode.formatter, get_buffer_name(args.buf))
    end
  })

local function get_mode()
  for _, mode in pairs(modes) do
      if mode.pattern and vim.fn.match(get_buffer_name(), string.sub(mode.pattern, 2)) > -1 then
        return mode
      end
  end
  return nil
end

local function expand_mode_keybindings(mode)
  local keybinds = {}
  if mode.formatter and mode.formatter() then
    table.insert(keybinds, {'f', function () format(mode.formatter, get_buffer_name()) end, desc = "Format"})
  end
  return keybinds
end

local M = {}

function M.expand_keybindings()
  local mode = get_mode()
  if not mode then
    return {}
  end
  return expand_mode_keybindings(mode)
end

return M
