-- Leader key is used to set mnemonic groups of functionality
vim.g.mapleader = " "

local wk = require('which-key')

wk.add({
  { '<leader><leader>', function () require('telescope.builtin').find_files{} end, desc = 'Browse Files', },
  { '<leader>/', function() require('telescope.builtin').live_grep{} end, desc = 'Live Grep', },
  { '<leader>?', function () require('telescope.builtin').keymaps{} end, desc = 'View Keymaps', },
  { '<leader>y', '"+y', desc = 'Copy', mode = { 'n', 'v' } },
  { '<leader>Y', '"+yg_', desc = 'Copy', mode = { 'n', 'v' } },

  { '<leader>w', group = 'Windows', },
  { '<leader>wh', function () vim.cmd.wincmd('h') end, desc = 'Window Left', },
  { '<leader>wj', function () vim.cmd.wincmd('j') end, desc = 'Window Down', },
  { '<leader>wk', function () vim.cmd.wincmd('k') end, desc = 'Window Up', },
  { '<leader>wl', function () vim.cmd.wincmd('l') end, desc = 'Window Right', },

  { '<leader>g', group = 'Git' },
  { '<leader>gr', function () require('nvit').view_repos() end, desc = 'Git Repos' },
  { '<leader>gb', function () require('nvit').view_branches() end, desc = 'Git Branches' },
  { '<leader>gv', group = 'Git Viewer', },
  { '<leader>gvf', function () require('telescope.builtin').git_files{} end, desc = 'Git files', },
  { '<leader>gvS', function () require('telescope.builtin').git_stash{} end, desc = 'Git stashes', },
  { '<leader>gvs', function () require('telescope.builtin').git_status{} end, desc = 'Git status', },

  { '<leader>gl', group = 'GitLab' },
  { '<leader>glm', function () require('nvit').view_merge_requests() end, desc = 'Merge Requests', },
  { '<leader>glr', function () require('nvit').view_reviews() end, desc = 'Review Requests', },
  { '<leader>glt', function () require('nvit').view_notifications() end, desc = 'Notifications', },

  { '<leader>n', group = 'Notifications' },
  { '<leader>nn', function () require('telescope').extensions.fidget.fidget() end, desc = 'View Notification History' },

  { '<leader>s', group = 'Scratchpad' },
  { '<leader>so', function () require('utils.workbook').open_scratchpad_in_window() end, desc = 'Open scratchpad as file' },
  { '<leader>ss', function () require('utils.workbook').scratchpad() end, desc = 'Open scratchpad' },
  { '<leader>s<leader>', function () require('utils.workbook').view_scratchpads() end, desc = 'View scratchpads' },
  { '<leader>s/', function () require('utils.workbook').grep_scratchpads() end, desc = 'Grep scratchpads' },

  { '<leader>b', group = 'Buffers', },
  { '<leader>bb', '<Cmd>Telescope buffers<CR>', desc = 'View Buffers', },
  { '<leader>bn', '<Cmd>BufferNext<CR>', desc = 'Next Buffer', },
  { '<leader>bN', '<Cmd>BufferPrevious<CR>', desc = 'Previous Buffer', },
  { '<leader>bp', '<Cmd>BufferPick<CR>', desc = 'Pick Buffer', },
  { '<leader>bd', '<Cmd>BufferClose<CR>', desc = 'Close Buffer', },

  { '<leader>r', group = 'Registers', },
  { '<leader>rr', '<Cmd>Telescope registers<CR>', desc = 'View Registers', },

  { '<leader>ft', '<Cmd>Neotree position=float<CR>', desc = 'View Directory', },

  { '<leader>%', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], desc = "Find/Replace all under cursor", },
})
