local _local_1_ = require("secret")
local vpn_pattern = _local_1_["vpn_pattern"]
local gitlab_domain = _local_1_["gitlab_domain"]
local _local_2_ = require("utils")
local background_process = _local_2_["background_process"]
local map = _local_2_["map"]
local _local_3_ = require("ui")
local create_menu = _local_3_["create_menu"]
local cache = require("cache")
local cache_file = "gitlab.json"
local state = {}
local expired_3f
local function _4_(...)
  return cache["expired?"](cache_file, ...)
end
expired_3f = _4_
local read
local function _5_(...)
  return cache.read(cache_file, ...)
end
read = _5_
local write
local function _6_(...)
  return cache.write(cache_file, ...)
end
write = _6_
local function is_vpn_3f()
  local out = false
  local function _7_(stdout)
    local connected_3f = (string.find(stdout, vpn_pattern) ~= nil)
    if connected_3f then
      out = true
      return nil
    else
      return nil
    end
  end
  background_process({"ifconfig"}, {["on_success"] = _7_, sync = true, silent = true})
  return out
end
local function is_gitlab_repo_3f()
  local out = false
  local function _9_(stdout)
    local gitlab_repo_3f = (string.find(stdout, gitlab_domain) ~= nil)
    if gitlab_repo_3f then
      out = true
      return nil
    else
      return nil
    end
  end
  background_process({"git", "remote", "get-url", "origin"}, {["on_success"] = _9_, sync = true, silent = true})
  return out
end
local function setup_gitlab_21()
  do
    local _11_ = state.gitlab
    if (_11_ == true) then
    elseif (_11_ == false) then
    else
      local _ = _11_
      state["gitlab"] = (is_gitlab_repo_3f() and is_vpn_3f())
    end
  end
  return state.gitlab
end
local _14_
do
  local t_13_ = state
  if (nil ~= t_13_) then
    t_13_ = t_13_.gitlab
  else
  end
  _14_ = t_13_
end
if not _14_ then
  setup_gitlab_21()
else
end
local function format_merge_requests(merge_requests)
  local function _17_(merge_request)
    return {text = (merge_request.project.name .. ": " .. merge_request.title), actionUrl = merge_request.webUrl}
  end
  return map(merge_requests, _17_)
end
local function format_reviews(reviews)
  local function _18_(review)
    return {text = (review.project.name .. ": " .. review.title), actionUrl = review.webUrl}
  end
  return map(reviews, _18_)
end
local function format_notifications(notifications)
  local function _19_(notification)
    return {text = (notification.action .. ": " .. notification.body), actionUrl = notification.targetUrl}
  end
  return map(notifications, _19_)
end
local function call_glab(_3fcallback)
  local mrs = "MRs: assignedMergeRequests(state:opened){nodes{project{name},title,webUrl}}"
  local reviews = "Reviews:reviewRequestedMergeRequests(state:opened){nodes{project{name},title,webUrl}}"
  local notifications = "Notifications:todos(state:pending){nodes{action,body,targetUrl}}"
  local query = ("query{root:currentUser{" .. table.concat({mrs, reviews, notifications}, ",") .. "}}")
  local function _20_(stdout)
    local data = vim.json.decode(stdout)
    local graph = data.data.root
    local merge_requests = format_merge_requests(graph.MRs.nodes)
    local reviews0 = format_reviews(graph.Reviews.nodes)
    local notifications0 = format_notifications(graph.Notifications.nodes)
    if _3fcallback then
      return _3fcallback({["merge-requests"] = merge_requests, reviews = reviews0, notifications = notifications0})
    else
      return nil
    end
  end
  return background_process({"glab", "api", "graphql", "-f", ("query=" .. query)}, {silent = true, ["on_success"] = _20_})
end
local function get_graph(_3fcallback)
  local gitlab_3f = state.gitlab
  local is_expired_3f = expired_3f()
  local _22_ = {gitlab_3f, is_expired_3f}
  if ((_22_[1] == true) and (_22_[2] == true)) then
    local function _23_(graph)
      write(graph)
      if _3fcallback then
        return _3fcallback(graph)
      else
        return nil
      end
    end
    return call_glab(_23_)
  elseif (true and (_22_[2] == false)) then
    local _ = _22_[1]
    if _3fcallback then
      return _3fcallback(read()[1])
    else
      return nil
    end
  else
    local _ = _22_
    return nil
  end
end
local function view_reviews()
  local function _27_(graph)
    local reviews = graph.reviews
    local items = {}
    if (#reviews == 0) then
      table.insert(items, {text = "No Reviews Found", separator = true})
    else
    end
    for _, r in pairs(reviews) do
      local function _29_()
        return vim.ui.open(r.actionUrl)
      end
      table.insert(items, {text = r.text, action = _29_})
    end
    return create_menu("Review Requests", items)
  end
  return get_graph(_27_)
end
local function view_merge_requests()
  local function _30_(graph)
    local merge_requests = graph["merge-requests"]
    local items = {}
    if (#merge_requests == 0) then
      table.insert(items, {text = "No Merge Requests Found", separator = true})
    else
    end
    for _, r in pairs(merge_requests) do
      local function _32_()
        return vim.ui.open(r.actionUrl)
      end
      table.insert(items, {text = r.text, action = _32_})
    end
    return create_menu("Merge Requests", items)
  end
  return get_graph(_30_)
end
local function view_notifications()
  local function _33_(graph)
    local notifications = graph.notifications
    local items = {}
    if (#notifications == 0) then
      table.insert(items, {text = "No Notifications Found", separator = true})
    else
    end
    for _, r in pairs(notifications) do
      local function _35_()
        return vim.ui.open(r.actionUrl)
      end
      table.insert(items, {text = r.text, action = _35_})
    end
    return create_menu("Notifications", items)
  end
  return get_graph(_33_)
end
require("which-key").add({{"<leader>gl", group = "Gitlab"}, {"<leader>glm", view_merge_requests, desc = "View Merge Requests"}, {"<leader>glr", view_reviews, desc = "View Review Requests"}, {"<leader>gln", view_notifications, desc = "View Notifications"}})
local function _36_()
  return state.gitlab
end
return {check = _36_, ["view-merge-requests"] = view_merge_requests, ["view-reviews"] = view_reviews, ["view-notifications"] = view_notifications}
