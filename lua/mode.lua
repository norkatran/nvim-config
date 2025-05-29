local utils = require('utils')


local function get_buffer_name(buf)
  return vim.api.nvim_buf_get_name(buf or 0)
end

local function format(formatter, file)
  if formatter then
    local fmt = (type(formatter) == "string") and formatter or formatter()
    if fmt then
      utils.background_process({ fmt, file }, {
        on_success = function ()
          vim.cmd("e!")
        end,
        silent = true,
      })
    end
  end
end

local modes = {
  fennel = require("modes.fennel"),
  php = require("modes.php")
}

for key, mode in pairs(modes) do
  if mode.pattern and mode.formatter then
    local group = vim.api.nvim_create_augroup(key, { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = mode.pattern,
      group = group,
      callback = function (args)
        format(mode.formatter, get_buffer_name(args.buf))
      end})
  end
end


