vim.g.mapleader = " "

-- Leader key is used to set mnemonic groups of functionality
local gitlab = require("utils.gitlab")
local git = require("utils.git")

local wk = require('which-key')

-- Use GitLab utilities from the utils.gitlab module

wk.add({
  { '<leader><leader>', function () require('telescope.builtin').find_files{} end, desc = 'Browse Files', },
  { '<leader>/', function() require('telescope.builtin').live_grep{} end, desc = 'Live Grep', },
  { '<leader>?', function () require('telescope.builtin').keymaps{} end, desc = 'View Keymaps', },

  { '<leader>w', group = 'Windows', },
  { '<leader>wh', function () vim.cmd.wincmd('h') end, desc = 'Window Left', },
  { '<leader>wj', function () vim.cmd.wincmd('j') end, desc = 'Window Down', },
  { '<leader>wk', function () vim.cmd.wincmd('k') end, desc = 'Window Up', },
  { '<leader>wl', function () vim.cmd.wincmd('l') end, desc = 'Window Right', },

  { '<leader>g', group = 'Git' },
  { '<leader>gv', group = 'Git Viewer', },
  { '<leader>gvf', function () require('telescope.builtin').git_files{} end, desc = 'Git files', },
  { '<leader>gvS', function () require('telescope.builtin').git_stash{} end, desc = 'Git stashes', },
  { '<leader>gvs', function () require('telescope.builtin').git_status{} end, desc = 'Git status', },

  { '<leader>ge', group = 'Git Editor', },
  { '<leader>geC', function () git.commit_multi_line() end, desc = 'Commit (multi line)'},
  { '<leader>gec', function () git.commit_single_line() end, desc = 'Commit (single line)'},

  { '<leader>gl', group = 'GitLab' },
  { '<leader>glg', function ()
    gitlab.display_gitlab_graph(nil, true)
  end, desc = 'Query Me', cond = gitlab.check_glab_repo },
  { '<leader>glu', function ()
    gitlab.glab_input()
  end, desc = 'Query Other User', cond = gitlab.check_glab_repo },
  { '<leader>gln', function ()
    gitlab.notify_gitlab_notifications()
  end, desc = 'Refresh notifications (fidget)', cond = gitlab.check_glab_repo },

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
