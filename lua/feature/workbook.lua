local ui = require("ui")
local fidget = require("fidget.notification")
local notification_group = "workbook"
local workbook_location = (vim.fn.stdpath("data") .. "/workbook/")
local function workbook_dir_exists()
  local ok, err, code = os.rename(workbook_location, workbook_location)
  if (not ok and (code == 13)) then
    return true
  else
    return ok
  end
end
local function pad(n)
  if (n < 10) then
    return ("0" .. tostring(n))
  else
    return tostring(n)
  end
end
local function default_title()
  local date = os.date("*t")
  local title = (date.year .. "_" .. pad(date.month) .. "_" .. pad(date.day) .. ".md")
  return title
end
local function workbook_exists(title)
  local f = io.open((workbook_location .. title), "r")
  if (f ~= nil) then
    io.close(f)
    return true
  else
    return false
  end
end
local function save_to_workbook(content, title)
  local title0
  if title then
    title0 = title
  else
    title0 = default_title()
  end
  local f = assert(io.open((workbook_location .. title0), "a"))
  f:write(content)
  io.close(f)
  return fidget.notify(("Wrote to workbook " .. title0), vim.log.levels.INFO, {group = notification_group})
end
local function workbook()
  local title = default_title()
  local function _5_(buf)
    local str = table.concat(buf, "\n")
    if not str:match("^%s*$") then
      local date = os.date("*t")
      local time = (pad(date.hour) .. "-" .. pad(date.min) .. "-" .. pad(date.sec))
      return save_to_workbook(("\n" .. time .. "--------------\n\n" .. str))
    else
      return nil
    end
  end
  return ui["create-textbox"](("Workbook " .. title), {}, _5_, {syntax = "md"})
end
local function view_workbooks()
  return require("telescope.builtin").find_files({cwd = workbook_location})
end
local function grep_workbooks()
  return require("telescope.builtin").live_grep({cwd = workbook_location})
end
if not workbook_dir_exists() then
  fidget.notify("Created workbook directory", vim.log.levels.INFO, {group = notification_group})
  vim.system({"mkdir", "-p", workbook_location})
else
end
local function _8_()
  return require("feature.workbook").workbook()
end
local function _9_()
  return require("feature.worbook")["grep-workbooks"]()
end
local function _10_()
  return require("feature.workbook")["view-workbooks"]()
end
require("which-key").add({{"<leader>wo", group = "Workbook"}, {"<leader>wo<leader>", _8_, desc = "Open workbook"}, {"<leader>wo/", _9_, desc = "Search workbooks"}, {"<leader>wow", _10_, desc = "Browse workbooks"}})
return {workbook = workbook, ["view-workbooks"] = view_workbooks, ["grep-workbooks"] = grep_workbooks}