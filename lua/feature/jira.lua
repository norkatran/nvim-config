local USER = vim.env.JIRA_USER
local URL = vim.env.JIRA_API
local cache = require("cache")
local cache_file = "jira.json"
local state = {issues = {}, ids = {}}
local _local_1_ = require("utils")
local map = _local_1_["map"]
local without = _local_1_["without"]
local insert_at = _local_1_["insert-at"]
local pad_truncate = _local_1_["pad_truncate"]
local background_process = _local_1_["background_process"]
local function parse_issue(json)
  local obj = vim.json.decode(json)
  local names = obj["names"]
  local fields = obj["fields"]
  return {summary = fields.summary, description = fields.description, status = fields.status.name, key = obj.key, id = obj.id, ["due-date"] = obj.fields.duedate}
end
local function curl(resource, id, cb_3f)
  local cmd = {"curl", (URL .. resource .. "/" .. id), "--user", USER}
  return background_process(cmd, {silent = true, ["on_success"] = (cb_3f or nil)})
end
local function task_list()
  local function _2_(width)
    local key_width = 8
    local due_date_width = 8
    local status_width = 12
    local summary_width = (width - key_width - due_date_width - status_width - 8)
    local function _3_(i)
      local _5_
      do
        local t_4_ = i
        if (nil ~= t_4_) then
          t_4_ = t_4_.status
        else
        end
        _5_ = t_4_
      end
      return (pad_truncate(i.key, key_width) .. " | " .. pad_truncate(i.summary, summary_width) .. " | " .. pad_truncate((_5_ or ""), status_width) .. " | " .. pad_truncate((" " .. vim.trim(vim.system({"date", "-j", "-f", "%Y-%m-%d", i["due-date"], "+%b %d"}):wait().stdout)), due_date_width))
    end
    return map(state.issues, _3_)
  end
  return require("ui")["create-pin"]("Jira", _2_)
end
local function issue_input(on_submit)
  local function _7_(key)
    local function _8_(stdout)
      on_submit(parse_issue(stdout))
      return task_list()
    end
    return curl("issue", key, _8_)
  end
  return require("ui")["create_input"]("Issue", _7_)
end
local function drop_issue(issue)
  local _10_
  do
    local t_9_ = state.ids
    if (nil ~= t_9_) then
      t_9_ = t_9_[issue.id]
    else
    end
    _10_ = t_9_
  end
  if not _10_ then
    return nil
  else
    state.ids[issue.id] = nil
    local function _12_(i)
      return (i.id ~= issue.id)
    end
    state["issues"] = without(state.issues, _12_)
    return nil
  end
end
local function drop_issue_input()
  return issue_input(drop_issue)
end
local function start_issue()
  local function _14_(issue)
    local _16_
    do
      local t_15_ = state.ids
      if (nil ~= t_15_) then
        t_15_ = t_15_[issue.id]
      else
      end
      _16_ = t_15_
    end
    if not _16_ then
      state["issues"] = insert_at(state.issues, issue, 1)
      state.ids[issue.id] = true
    else
    end
    return vim.cmd(("silent exec \"!kitten @ set-window-title '" .. vim.fs.basename(vim.fs.dirname(vim.uv.cwd())) .. ": " .. issue.key .. " -> " .. issue.summary .. "'\""))
  end
  return issue_input(_14_)
end
local function list_issues()
  local items
  if (#state.issues > 0) then
    local function _19_(issue)
      local out = {id = issue.id, text = (issue.key .. " -> " .. issue.summary), issue = issue}
      return out
    end
    items = map(state.issues, _19_)
  else
    items = {}
  end
  local function _21_(node)
    drop_issue(node.issue)
    return task_list()
  end
  return require("ui")["create_menu"]("tasks", items, {desc = {"Currently stored issues"}, mappings = {{"<C-d>", _21_, desc = "Drop Issue"}}})
end
return require("which-key").add({{"<leader><leader>j", group = "Jira"}, {"<leader><leader>js", start_issue, desc = "Start Issue"}, {"<leader><leader>jd", drop_issue_input, desc = "Drop Issue"}, {"<leader><leader>j<leader>", list_issues, desc = "List Current Issues"}})
