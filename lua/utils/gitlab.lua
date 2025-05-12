-- utils/gitlab.lua
-- GitLab utility functions

local merge = require('utils.common').merge_tables

-- TODO: store graph cache under this path
-- vim.fn.stdpath('cache')

local M = {}

-- Cache for GitLab data
M.graph_cache = {
  graph = nil,
  time = nil
}

-- Check if current repository is a GitLab repo
M.is_glab_repo = nil

M.check_glab_repo = function()
  if M.is_glab_repo == true or M.is_glab_repo == false then
    return M.is_glab_repo
  end
  if not Snacks.git.get_root() then
    M.is_glab_repo = false
    return M.is_glab_repo
  end
  local obj = vim.system({ 'glab', 'mr', 'list' }):wait()
  M.is_glab_repo = obj.code == 0
  return M.is_glab_repo
end

M.execute_graphql = function(ql)
  local content = vim.fn.system("glab api graphql -f query='" .. ql .. "'")
  vim.notify('graphql response: ' .. content, vim.log.levels.DEBUG)
  return content
end

-- Get GraphQL data for current user
M.my_graphql = function(use_cache)
  if M.graph_cache.graph ~= nil and use_cache then
    return M.graph_cache.graph
  end
  local content = M.execute_graphql("query { root: currentUser { MRs: assignedMergeRequests(state: opened) { nodes { title, webUrl } }, Issues: reviewRequestedMergeRequests(state: opened) { nodes { title, webUrl } }, ToDos: todos(state: pending) { nodes { id, action, body, targetUrl } } } }")
  local json = vim.json.decode(content).data.root
  M.graph_cache.graph = json
  return json
end

-- Get GraphQL data for specific user
M.graphql_for_user = function(user)
  local content = M.execute_graphql("query { root: user(username: \""..user.."\") { MRs: assignedMergeRequests(state: opened) { nodes { title, webUrl } }, Issues: reviewRequestedMergeRequests(state: opened) { nodes { title, webUrl } }, ToDos: todos(state: pending) { nodes { action, body, targetUrl } } } }")
  local json = vim.json.decode(content).data.root
  return json
end

-- Format MRs for display
M.get_graph_mrs = function(resp)
  if (not resp) or (not resp.MRs) or (not resp.MRs.nodes) then
    return {}
  end
  local json = resp.MRs.nodes
  local lines = { }
  table.insert(lines, { text = 'Opened MRs', separator = true })
  if json[1] then
    for _, obj in pairs(json) do
        table.insert(lines, { text = obj.title, action = function () vim.ui.open(obj.webUrl) end })
    end
  end
  return lines
end

-- Format reviews for display
M.get_graph_reviews = function(resp)
  if (not resp) or (not resp.Issues) or (not resp.Issues.nodes) then
    return {}
  end
  local json = resp.Issues.nodes
  local lines = {}
  table.insert(lines, { text = 'Pending Reviews', separator = true })
  if json[1] then
    for _, obj in pairs(json) do
        table.insert(lines, { text = obj.title, action = function () vim.ui.open(obj.webUrl) end })
    end
  end
  return lines
end

-- Format notifications for display
M.get_graph_notifications = function(resp)
  if (not resp) or (not resp.ToDos) or (not resp.ToDos.nodes) then
    return {}
  end
  local json = resp.ToDos.nodes
  local lines = {}
  table.insert(lines, { text = 'Notifications', separator = true })
  if next(json) then
    for _, obj in pairs(json) do
        table.insert(lines, { text = obj.action .. ': ' .. obj.body,  action = function () vim.ui.open(obj.targetUrl) end, id = obj.id })
    end
  end
  return lines
end

-- Display GitLab graph for user or current user
M.display_gitlab_graph = function(user, use_cache)
  local mrs = {}
  local reviews = {}
  local notifications = {}
  if not user then
    local graph = M.my_graphql(use_cache)
    mrs = M.get_graph_mrs(graph)
    reviews = M.get_graph_reviews(graph)
    notifications = M.get_graph_notifications(graph)
  else
    local graph = M.graphql_for_user(user)
    mrs = M.get_graph_mrs(graph)
    reviews = M.get_graph_reviews(graph)
  end
  require('utils.ui').create_menu('Choose Item', merge({ mrs, reviews, notifications }))
end

-- Show GitLab username input
M.glab_input = function()
  require('utils.ui').create_input('Enter username', function (value)
    M.display_gitlab_graph(value, false)
  end)
end

-- Notify GitLab notifications
M.notify_gitlab_notifications = function()
  if not M.check_glab_repo() then
    return
  end
  local group = 'status'
  local fidget = require('fidget.notification')

  fidget.clear(group)
  fidget.clear_history(group)

  local graph = M.my_graphql(false)
  local notifications = M.get_graph_notifications(graph)

  for i, notif in pairs(notifications) do
    if i > 1 then
      fidget.notify(notif.text, vim.log.levels.INFO)
    end
  end

  fidget.notify(
    "Gitlab notifications updated: " .. (#notifications - 1) .. " found",
    vim.log.levels.INFO,
    { group = group }
  )

  require('fidget.progress').poll()

  require('lualine').refresh()
end

-- Setup notification timer
M.setup_notification_timer = function()
  if M.check_glab_repo() then
    local timer = vim.uv.new_timer()
    timer:start(0, 5 * 60 * 1000, vim.schedule_wrap(function ()
      M.notify_gitlab_notifications()
    end))
  end
end

M.outstanding_gitlab_notifications = function ()
  if not M.check_glab_repo() then
    return nil
  end
  local graph = M.my_graphql(true)
  local mrs = 0
  if graph and graph.MRs and graph.MRs.nodes then
    mrs = #graph.MRs.nodes
  end
  local reviews = 0
  if graph and graph.Issues and graph.Issues.nodes then
    reviews = #graph.Issues.nodes
  end
  local notifications = 0
  if graph and graph.ToDos and graph.ToDos.nodes then
    notifications = #graph.ToDos.nodes
  end
  return {
    mrs = mrs,
    reviews = reviews,
    todos = notifications,
  }
end

return M
