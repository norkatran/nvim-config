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

local file_selector = function(files, root, additive)
  if root == nil then
    root = ''
  end
  vim.ui.select(files,
    {
      format_item = function (file)
        return string.sub(file, string.len(root) + additive)
      end
    },
    function (option)
      if option then
        vim.cmd { cmd = 'e', args = { option }}
      end
    end
  )
end

local fuzzy_finder = function(input)
  local root = find_git_path()
  local files = vim.fs.find(
    function (file, path)
      local local_path = path:sub(root:len() + 2)
      for _, value in pairs(excluded_dirs) do
        local idx = local_path:find(value)
        if idx == 1 then
          return nil
        end
      end
      for token in string.gmatch(input, "[^%s]+") do
        if string.find(file:lower(), token:lower()) then
          return true
        end
        if string.find(local_path:lower(), token:lower()) then
          return true
        end
      end
    end,
    {
      type = 'file',
      limit = 200, --math.huge,
      path = root
    })
    file_selector(files, root, 2)
end

-- normal mode
-- Leader key is used to set mnemonic groups of functionality

-- f group -> files
vim.keymap.set('n', '<Leader>ff', function()
  vim.ui.input({ prompt = 'File: ' }, function (input)
    if input then
      fuzzy_finder(input)
    end
  end)
end)
vim.keymap.set('n', '<Leader>ft', function()
  local tree = require('nvim-tree.api').tree
  tree.toggle()
  if tree.is_visible() then
    tree.focus()
  end
end)
vim.keymap.set('n', '<Leader>fs', function()
  vim.ui.input({ prompt = 'Needle: ' }, function (input)
    if input then
      local root = find_git_path()
      local raw = vim.fn.system({ "rg", "-l", input, root })
      local files = {}
      for file in string.gmatch(raw, "[^%s]+") do
        table.insert(files, file)
      end
      table.sort(files)
      file_selector(files, root, 2)
    end
  end)
end)

-- p group -> projects

-- insert mode

-- visual mode

-- replace mode
