-- utils/git.lua
-- Git utility functions

local notification_group = 'workbook'
local ui = require('utils.ui')
local fidget = require('fidget.notification')
local split = require('utils.common').string_split

local workbook_location = vim.fn.stdpath("data") .. "/workbook/"

local M = {}

M._workbook_dir_exists = function ()
   local ok, err, code = os.rename(workbook_location, workbook_location)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

M._pad = function (num)
  if num < 10 then
    return 0 .. num
  else
    return num
  end
end

M._default_title = function ()
  local date = os.date('*t')
  local title = date.year .. '_' .. M._pad(date.month) .. '_' .. M._pad(date.day) .. '.md'
  return title
end

M._workbook_exists = function (title)
  local f = io.open(workbook_location .. title, 'r')
  if f ~= nil then
    io.close(f)
    return true
  end
  return false
end

M._save_to_workbook = function (content, title)
  if not title then
    title = M._default_title()
  end
  local f = assert(io.open(workbook_location .. title, 'a'))
  f:write(content)
  io.close(f)
  fidget.notify('Wrote to workbook ' .. title, vim.log.levels.INFO, { group = notification_group })
end

M.scratchpad = function (title)
  title = title or M._default_title()
  ui.create_textbox('Workbook Scratchpad', {}, function (buffer_content)
    local str = table.concat(buffer_content, '\n')
    if str:match('^%s*$') then
      return
    end
    local date = os.date('*t')
    local timestring = M._pad(date.hour) .. ':' .. M._pad(date.min) .. ':' .. M._pad(date.sec)
    M._save_to_workbook('\n'..timestring..' --------------\n\n' .. str)
  end, { syntax = 'md' })
end

M.view_scratchpads = function ()
  require('telescope.builtin').find_files { cwd = workbook_location }
end

M.grep_scratchpads = function ()
  require('telescope.builtin').live_grep { cwd = workbook_location }
end

M.open_scratchpad_in_window = function ()
  vim.cmd.e(workbook_location .. M._default_title())
end

if not M._workbook_dir_exists() then
  fidget.notify('Created workbook directory', vim.log.levels.INFO, { group =  notification_group })
  vim.system({ 'mkdir', '-p', workbook_location })
end

return M

