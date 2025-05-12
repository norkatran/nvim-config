vim.g.mapleader = " "

-- Leader key is used to set mnemonic groups of functionality

local wk = require('which-key')

local my_graph_cache = {
  graph = nil,
  mrs = {},
  reviews = {},
  notifications = {},
  time = nil
}

local notifications_cache = {}

local function graphql_for_user(user)
  local content = vim.fn.system("glab api graphql -f query=' query { root: user(username: \""..user.."\") { MRs: assignedMergeRequests(state: opened) { nodes { title, webUrl } }, Issues: reviewRequestedMergeRequests(state: opened) { nodes { title, webUrl } }, ToDos: todos(state: pending) { nodes { action, body, targetUrl } } } }' | jq .data.root")
  local json = vim.json.decode(content)
  return json
end

local function my_graphql(use_cache)
  if my_graph_cache.graph ~= nil and use_cache then
    return my_graph_cache.graph
  end
  local content = vim.fn.system("glab api graphql -f query=' query { root: currentUser { MRs: assignedMergeRequests(state: opened) { nodes { title, webUrl } }, Issues: reviewRequestedMergeRequests(state: opened) { nodes { title, webUrl } }, ToDos: todos(state: pending) { nodes { action, body, targetUrl } } } }' | jq .data.root")
  local json = vim.json.decode(content)
  my_graph_cache.graph = json
  return json
end

local function get_graph_mrs(resp)
  local Menu = require('nui.menu')
  local json = resp.MRs.nodes
  local lines = {}
  table.insert(lines, Menu.separator('Open MRs', {
    char = '-',
    text_align = 'center'
  }))
  if json[1] then
    for _, obj in pairs(json) do
        table.insert(lines, Menu.item(obj.title, { target = obj.webUrl }))
    end
  end
  return lines
end

local function get_graph_reviews(resp)
  local Menu = require('nui.menu')
  local json = resp.Issues.nodes
  local lines = {}
  table.insert(lines, Menu.separator('Pending Reviews', {
    char = '-',
    text_align = 'center'
  }))
  if json[1] then
    for _, obj in pairs(json) do
        table.insert(lines, Menu.item(obj.title, { target = obj.webUrl }))
    end
  end
  return lines
end

local function get_graph_notifications(resp)
  local Menu = require('nui.menu')
  local json = resp.ToDos.nodes
  local lines = {}
  table.insert(lines, Menu.separator('Notifications', {
    char = '-',
    text_align = 'center'
  }))
  if next(json) then
    for _, obj in pairs(json) do
        table.insert(lines, Menu.item(obj.action .. ': ' .. obj.body, { target = obj.targetUrl }))
    end
  end
  return lines
end

local function glab_popup(lines)
  local Menu = require('nui.menu')

  local menu = Menu({
    border = {
      style = {
        top_left    = "╭", top    = "─",    top_right = "╮",
        left        = "│",                      right = "│",
        bottom_left = "╰", bottom = "─", bottom_right = "╯",
      },
      text = {
        top = 'Choose Item',
        top_align = 'center',
      }
    },
    position = '50%',
    relative = 'editor',
    size = {
      width = '80%',
      height = '20%',
    },
  }, {
    lines = lines,
    on_submit = function (item)
      if item.target then
        vim.ui.open(item.target)
      end
    end
  })

  menu:mount()
end

local function display_gitlab_graph(user, use_cache)
  local items = {}
  local mrs = {}
  local reviews = {}
  local notifications = {}
  if not user then
    local graph = my_graphql(use_cache)
    mrs = get_graph_mrs(graph)
    reviews = get_graph_reviews(graph)
    notifications = get_graph_notifications(graph)
  else
    local graph = graphql_for_user(user)
    mrs = get_graph_mrs(graph)
    reviews = get_graph_reviews(graph)
  end
  for _, obj in pairs(mrs) do
    table.insert(items, obj)
  end

  for _, obj in pairs(reviews) do
    table.insert(items, obj)
  end

  for _, obj in pairs(notifications) do
    table.insert(items, obj)
  end
  glab_popup(items)
end

local function glab_input()
  local Input = require('nui.input')

  local input = Input({
    border = {
      style = {
        top_left    = "╭", top    = "─",    top_right = "╮",
        left        = "│",                      right = "│",
        bottom_left = "╰", bottom = "─", bottom_right = "╯",
      },
      text = {
        top = 'Enter username',
        top_align = 'center',
      }
    },
    position = '50%',
    relative = 'editor',
    size = {
      width = '40%',
      height = '20%',
    },
  }, {
    prompt = '> ',
    on_submit = function (value)
      display_gitlab_graph(value, false)
    end,
  })

  input:map('n', '<Esc>', function ()
    input:unmount()
  end, { noremap = true })

  input:mount()
end

local function notify_gitlab_notifications()
  local group = 'gitlab'
  local fidget = require('fidget.notification')

  local graph = my_graphql(false)
  local notifications = get_graph_notifications(graph)

  for i, notif in pairs(notifications) do
    if i > 1 then
      if not notifications_cache[notif.text] then
        fidget.notify(notif.text, vim.log.levels.INFO, { group = group })
        notifications_cache[notif.text] = true
      end
    end
  end

  require('fidget.progress').poll()
end

wk.add({
  { '<leader><leader>', function () require('telescope.builtin').find_files{} end, desc = 'Browse Files', },
  { '<leader>/', function() require('telescope.builtin').live_grep{} end, desc = 'Live Grep', },
  { '<leader>?', function () require('telescope.builtin').keymaps{} end, desc = 'View Keymaps', },

  { '<leader>w', group = 'Windows', },
  { '<leader>wh', function () vim.cmd.wincmd('h') end, desc = 'Window Left', },
  { '<leader>wj', function () vim.cmd.wincmd('j') end, desc = 'Window Down', },
  { '<leader>wk', function () vim.cmd.wincmd('k') end, desc = 'Window Up', },
  { '<leader>wl', function () vim.cmd.wincmd('l') end, desc = 'Window Right', },

  -- { '<leader>f, group = 'Files', },

  { '<leader>g', group = 'GitLab' },
  { '<leader>gg', function ()
    display_gitlab_graph(nil, true)
  end, desc = 'Display GitLab (mlysander)' },
  { '<leader>gu', function ()
    glab_input()
  end, desc = 'Display GitLab - other user' },
  { '<leader>gn', function ()
    notify_gitlab_notifications()
  end, desc = 'Gitlab notifications (fidget)' },

  { '<leader>n', group = 'Notifications' },
  { '<leader>nn', function () require('telescope').extensions.fidget.fidget() end, desc = 'View Notification History' },

  { '<leader>b', group = 'Buffers', },
  { '<leader>bb', '<Cmd>Telescope buffers<CR>', desc = 'View Buffers', },
  { '<leader>bn', '<Cmd>BufferNext<CR>', desc = 'Next Buffer', },
  { '<leader>bN', '<Cmd>BufferPrevious<CR>', desc = 'Previous Buffer', },
  { '<leader>bp', '<Cmd>BufferPick<CR>', desc = 'Pick Buffer', },
  { '<leader>bd', '<Cmd>BufferClose<CR>', desc = 'Close Buffer', },

  { '<leader>ft', '<Cmd>Neotree position=float<CR>', desc = 'View Directory', },

  { '<leader>%', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], desc = "Find/Replace all under cursor", },
})

-- Check for notifications every 5 minutes
local timer = vim.uv.new_timer()
timer:start(0, 5 * 60 * 1000, vim.schedule_wrap(function ()
  notify_gitlab_notifications()
end))
