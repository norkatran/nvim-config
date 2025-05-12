vim.g.mapleader = " "

local excluded_dirs = { "node_modules", "vendor", "build", ".git" }

local find_git_path = function()
  local root_dir
  for dir in vim.fs.parents(vim.api.nvim_buf_get_name(0)) do
    if vim.fn.isdirectory(dir .. "/.git") == 1 then
      root_dir = dir
      break
    end
  end
  if root_dir then
    return root_dir
  else
    return vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  end
end

-- Leader key is used to set mnemonic groups of functionality

-- normal mode
-- <Space><Space> to open file finder
vim.keymap.set('n', '<Leader><Leader>', function()
  require('telescope.builtin').git_files()
end, { desc = 'Browse files' })
-- <Space>/ to grep a project
vim.keymap.set('n', '<Leader>/', function()
  require('telescope.builtin').live_grep()
end, { desc = 'Live grep' })
vim.api.nvim_set_keymap('n', '<Leader>?', '<Cmd>Telescope keymaps<CR>', { desc = 'View keymaps' })


-- w group -> windows
vim.keymap.set('n', '<Leader>w', function ()
end, {desc = 'Which key'})
vim.keymap.set('n', '<Leader>wh', function()
  vim.cmd.wincmd('h')
end, { desc = 'Window left'})
vim.keymap.set('n', '<Leader>wj', function()
  vim.cmd.wincmd('j')
end, { desc = 'Window down'})
vim.keymap.set('n', '<Leader>wk', function()
  vim.cmd.wincmd('k')
end, { desc = 'Window up'})
vim.keymap.set('n', '<Leader>wl', function()
  vim.cmd.wincmd('l')
end, { desc = 'Window right'})

-- f group -> files
vim.keymap.set('n', '<Leader>ft', function()
  local tree = require('nvim-tree.api').tree
  tree.toggle()
  if tree.is_visible() then
    tree.focus()
  end
end, { desc = 'Focus filetree'})

-- b group -> buffers
vim.api.nvim_set_keymap('n', '<Leader>bb', '<Cmd>Telescope buffers<CR>', { desc = 'View buffers'})
vim.api.nvim_set_keymap('n', '<Leader>bn', '<Cmd>BufferNext<CR>', { desc = 'Next buffer'})
vim.api.nvim_set_keymap('n', '<Leader>bN', '<Cmd>BufferPrevious<CR>', { desc = 'Previous buffer'})
vim.api.nvim_set_keymap('n', '<Leader>bp', '<Cmd>BufferPick<CR>', { desc = 'Pick buffer'})
vim.api.nvim_set_keymap('n', '<Leader>bd', '<Cmd>BufferClose<CR>', { desc = 'Close buffer'})

vim.keymap.set("n", "<leader>fr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Find/Replace all under cursor" })

-- insert mode

-- visual mode

-- replace mode


-- which-key
