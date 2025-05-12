-- utils/git.lua
-- Git utility functions

local notification_group = 'git'
local ui = require('utils.ui')
local fidget = require('fidget.notification')
local split = require('utils.common').string_split

local M = {}

M.remove_commented_lines = function(input)
  local out = {}
  for _, line in pairs(input) do
    if not line:match('^#') then
      table.insert(out, line)
    end
  end
  return out
end

M._commit = function (message)
  vim.fn.system({ 'git', 'commit', '-m', message })
  fidget.notify('Committed `' .. message .. '`', vim.log.levels.INFO, { group = notification_group })
end

M.commit_multi_line = function ()
  local changes = vim.fn.system('git commit --dry-run')
  local default_msg = split(changes, '\n', '# ')
  ui.create_textbox('Commit Message', default_msg, function (message) M._commit(table.concat(M.remove_commented_lines(message), '\n')) end)
end

M.commit_single_line = function ()
  ui.create_input('Commit message', M._commit)
end

return M
