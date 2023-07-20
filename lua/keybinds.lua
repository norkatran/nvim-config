vim.g.mapleader = " "

local find_git_path = function()
  local root_dir
  for dir in vim.fs.parents(vim.api.nvim_buf_get_name(0)) do
    if vim.fn.isdirectory(dir .. "/.git") == 1 then
      root_dir = dir
      break
    end
  end
  if root_dir then
    return vim.fs.normalize(root_dir)
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
  vim.notify(vim.inspect(root))
  local files = vim.fs.find(
    function (file, path)
      for token in string.gmatch(input, "[^%s]+") do
        if string.find(string.lower(file), string.lower(token)) then
          return true
        end
        if string.find(string.lower(path), string.lower(token)) then
          return true
        end
      end
    end,
    {
      type = 'file',
      limit = math.huge,
      path = root
    })
    file_selector(files, nil, 2)
end

-- normal mode
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
    local raw = vim.fn.system({ "rg", "-l", input })
    local files = {}
    for file in string.gmatch(raw, "[^%s]+") do
      table.insert(files, file)
    end
    table.sort(files)
    file_selector(files, nil, 1)
  end)
end)

-- insert mode

-- visual mode

-- replace mode
