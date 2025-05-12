-- plugin/git/init.lua
-- Initiate base git

local ui = require('utils.ui')
local config = require('plugin.git.config')
local uv = vim.uv or vim.loop

local glab_repos = {}

local M = {}

M.get_worktree_branches = function (repo)
  local output = vim.split(vim.fn.system("cd " .. repo .. " && git worktree list"), '\n')
  local branches = {}
  for _, o in pairs(output) do
    local branch_path = vim.split(o, ' ')[1]
    if #branch_path > 0 then
      local trimmed_path = string.sub(branch_path, #repo + 2, -1)
      if #trimmed_path > 0 then
        table.insert(
          branches,
          { branch_name = trimmed_path, path = branch_path }
        )
      end
    end
  end
  return branches
end

M.get_branches = function (repo)
  local is_worktree = #(vim.fn.glob(repo..'/.git*')) == 0
  if is_worktree then
    return M.get_worktree_branches(repo)
  else
    vim.notify('Normal git repos are unsupported', vim.log.levels.WARN)
    return {}
  end
end

M.switch_to = function (path)
  vim.notify('Working directory switched to ' .. path, vim.log.levels.INFO)
  vim.cmd('Neotree position=float dir='..path)
end

M.list_branches = function (repo)
  if not repo then
    repo = vim.fs.dirname(Snacks.git.get_root())
  end
  local branches = M.get_branches(repo)
  local menu_items = {}
  for _, b in pairs(branches) do
    table.insert(menu_items, { text = b.branch_name, action = function () M.switch_to(b.path) end })
  end
  ui.create_menu_with_key('Select Branch', menu_items, {
    { '<C-n>', function (ctx) ctx.menu:unmount() ui.create_input('New branch', function (branch) M.create_branch(repo, branch) end) end, desc = 'New Branch' },
    { '<C-u>', function (ctx) ctx.menu:unmount() ui.create_input('Checkout branch', function (branch) M.checkout_branch(repo, branch) end) end, desc = 'Checkout Branch' },
    { '<C-d>', function (ctx) ctx.menu:unmount() M.delete_branch(repo, ctx.node.text) end, desc = 'Delete Branch' },
  })
end

M.delete_branch = function (repo, branch)
  vim.notify('Deleting branch "'..branch..'" for repo "'..repo..'"', vim.log.levels.INFO)
  vim.fn.system('cd '..repo..' && git worktree remove '..branch)
end

M.checkout_branch = function (repo, branch)
  vim.notify('Checking out branch "'..branch..'" for repo "'..repo..'"', vim.log.levels.INFO)
  vim.fn.system('cd '..repo..' && git worktree add '..branch..' '..branch)
  M._setup_new_branch(repo, branch)
end

M._setup_new_branch = function (repo, branch)
  local branch_path = repo .. '/' .. branch
  M.switch_to(branch_path)
  if #vim.fn.glob(branch_path..'/composer.json') > 0 then
    vim.notify(branch..': composer install', vim.log.levels.INFO)
    vim.fn.system('composer i &')
  end
  if #vim.fn.glob(branch_path..'/package.json') > 0 then
    vim.notify(branch..': npm ci', vim.log.levels.INFO)
    vim.fn.system('npm ci &')
  end
end

M.create_branch = function (repo, branch)
  vim.notify('Creating branch "'..branch..'" for repo "'..repo..'"', vim.log.levels.INFO)
  vim.fn.system('cd '..repo..' && git worktree add '..branch)
  M._setup_new_branch(repo, branch)
end

M.get_repos = function ()
  local repos = {}
  local paths = vim.split(vim.fn.glob(config.repo_path..'/*'), '\n')
  for _, path in pairs(paths) do
    table.insert(repos, path)
  end
  return repos
end

M.create_repo = function (url)
  vim.notify('Cloning bare repo "' .. url.. '"', vim.log.levels.INFO)
  vim.fn.system('cd ' .. config.repo_path .. ' && git clone --bare ' .. url)
  local repo_name = vim.fs.basename(url)
  local branch = vim.split(vim.fn.system('cd ' .. config.repo_path .. '/' .. repo_name .. " && git remote show origin | sed -n '/HEAD branch/s/.*: //p'"), '\n')[1]
  M.checkout_branch(config.repo_path .. '/' .. repo_name, branch)
end

M.list_repos = function ()
  local repos = M.get_repos()
  local menu_items = {}
  for _, repo in pairs(repos) do
    table.insert(menu_items, { text = repo, action = function () M.list_branches(repo) end, })
  end
  ui.create_menu_with_key('Select Repo', menu_items, {
    { '<C-n>', function (ctx) ctx.menu:unmount() ui.create_input('Repo Path', function (url) M.create_repo(url)  end) end, desc = 'Clone Repo' }
  })
end

M._query_gitlab = function (user, parts)
  local graphql_root = 'currentUser'
  if user then
    graphql_root = 'user(username: "'..user..'")'
  end
  local filters = ''
  for _,v in pairs(parts) do
    if #filters > 0 then
      filters = filters .. ','
    end
    filters = filters .. v
  end
  local ql = "query { root: "..graphql_root.." { "..filters.." }}"
  local content = vim.fn.system("glab api graphql -f query='" .. ql .. "'")
  local json = vim.json.decode(content)
  return json.data.root
end

local cache_ttl = 60 -- seconds
local cache_dir = vim.fn.stdpath('cache') .. '/git'
local cache_file = cache_dir .. '/grapql_cache.json'

M._write_to_cache = function (graph)
  vim.fn.mkdir(cache_dir, 'p')
  local fout = assert(uv.fs_open(cache_file, 'w', 438))
  uv.fs_write(fout, vim.json.encode({ graph = graph }))
  uv.fs_close(fout)
end

M._read_from_cache = function ()
  local stat = uv.fs_stat(cache_file)
  local has_cache = stat and stat.type == 'file' and stat.size > 0
  if not has_cache then
    vim.notify('GitLab graphql cache miss', vim.log.levels.DEBUG)
    return false
  end
  local is_expired = stat and os.time() - stat.mtime.sec >= cache_ttl
  if is_expired then
    vim.notify('GitLab graphql cache miss', vim.log.levels.DEBUG)
    return false
  end
  local fd = assert(uv.fs_open(cache_file, 'r', 438))
  local cache_contents = assert(uv.fs_read(fd, stat.size, 0))
  assert(uv.fs_close(fd))
  local json = vim.json.decode(cache_contents)
  return json
end

M._graphql = function (user)
  if not M.is_gitlab_repo() then
    local c = M._read_from_cache()
    if c then
      return c.graph
    else
      return {}
    end
  end
  local mrs = 'MRs: assignedMergeRequests(state: opened) { nodes { title, webUrl } }'
  local reviews = 'Issues: reviewRequestedMergeRequests(state: opened) { nodes { title, webUrl } }'
  local todos = 'ToDos: todos(state: pending) { nodes { action, body, targetUrl } }'
  if user then
    return M._query_gitlab(user, { mrs, reviews, })
  end
  local read_cache = M._read_from_cache()
  if read_cache then
    return read_cache.graph
  end
  local graph = M._query_gitlab(nil, { mrs, reviews, todos, })
  M._write_to_cache(graph)
  return graph
end

M.get_mrs = function (user)
  local graph = M._graphql(user)
  if graph and graph.MRs and graph.MRs.nodes then
    local json = graph.MRs.nodes
    local mrs = {}
    for _,o in pairs(json) do
      table.insert(mrs, { o.title, o.webUrl })
    end
    return mrs
  end
  return {}
end

M.list_mrs = function (user)
  local mrs = M.get_mrs(user)
  if #mrs == 0 then
    vim.notify('No MRs found', vim.log.levels.INFO)
    return
  end
  local items = {}
  for _,o in pairs(mrs) do
    table.insert(items, { text = o[1], action = function () vim.ui.open(o[2]) end })
  end
  require('utils.ui').create_menu('Open MRs', items)
end

M.get_review_requests = function (user)
  local graph = M._graphql(user)
  if graph and graph.Issues and graph.Issues.nodes then
    local json = graph.Issues.nodes
    local reviews = {}
    for _,o in pairs(json) do
      table.insert(reviews, { o.title, o.webUrl })
    end
    return reviews
  end
  return {}
end

M.list_review_requests = function (user)
  local reviews = M.get_review_requests(user)
  if #reviews == 0 then
    vim.notify('No Requested Reviews found', vim.log.levels.INFO)
    return
  end
  local items = {}
  for _,o in pairs(reviews) do
    table.insert(items, { text = o[1], action = function () vim.ui.open(o[2]) end })
  end
  require('utils.ui').create_menu('Awaiting Review', items)
end

M.get_todos = function (user)
  local graph = M._graphql(user)
  if graph and graph.ToDos and graph.ToDos.nodes then
    local json = graph.ToDos.nodes
    local todos = {}
    for _,o in pairs(json) do
      table.insert(todos, { o.action..':'..o.body, o.targetUrl })
    end
    return todos
  end
  return {}
end

M.list_todos = function (user)
  local todos = M.get_todos(user)
  if #todos == 0 then
    vim.notify('No To Dos found', vim.log.levels.INFO)
    return
  end
  local items = {}
  for _,o in pairs(todos) do
    table.insert(items, { text = o[1], action = function () vim.ui.open(o[2]) end })
  end
  require('utils.ui').create_menu('To Dos', items)
end


M.is_gitlab_repo = function ()
  local cwd = uv.cwd()
  if glab_repos[cwd] then
    return glab_repos[cwd].is
  end
  local cache_item = {}
  if not Snacks.git.get_root() then
    cache_item.is = false
  else
    local obj = vim.system({ 'glab', 'mr', 'list' }):wait()
    cache_item.is = obj.code == 0
  end
  glab_repos[cwd] = cache_item
  return cache_item.is
end

return M
