local USER = vim.env.JIRA_USER
local DOMAIN = vim.env.JIRA_DOMAIN
local URL = vim.env.JIRA_API

local state = {issues = {}, ids = {}}
local utils = require("utils")
local map = utils["map"]
local without = utils["without"]
local insert_at = utils["insert_at"]
local pad_truncate = utils["pad_or_truncate"]
local background_process = utils["background_process"]

local function parse_issue(json)
  local obj = vim.json.decode(json)
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
  return require("ui")["create_pin"]("Jira", _2_)
end

local function issue_input(on_submit, input)
  local function _7_(key)
    local function _8_(stdout)
      on_submit(parse_issue(stdout))
      return task_list()
    end
    return curl("issue", key, _8_)
  end
  if input then
    _7_(input)
  else
    require("ui")["create_input"]("Issue", _7_)
  end
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

local function start_issue(input)
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
  issue_input(_14_, input)
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


-- If opening in a worktree that looks like a JIRA ticket, check.
do
  local jira_branch_pattern = "^([a-zA-Z]+-[0-9]+)"

  local branch = vim.fs.basename(vim.uv.cwd())
  local match = branch:match(jira_branch_pattern)
  if match then
    start_issue(match)
  end
end

require("which-key").add({{"<leader><leader>j", group = "Jira"}, {"<leader><leader>js", start_issue, desc = "Start Issue"}, {"<leader><leader>jd", drop_issue_input, desc = "Drop Issue"}, {"<leader><leader>j<leader>", list_issues, desc = "List Current Issues"}})
