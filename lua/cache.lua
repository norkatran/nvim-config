local cache_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "init")

local uv = vim.uv or vim.loop

local M = {}

M.read = function (file)
  vim.fn.mkdir(cache_dir, "-p")
  local filepath = vim.fs.joinpath(cache_dir, file)
  local f = io.open(filepath)
  if not f then
    return {}
  end
  local contents = f:read("*all")
  if contents ~= "" then
    return vim.json.decode(contents)
  end
  return {}
end

M.write = function (file, data)
  vim.fn.mkdir(cache_dir, "-p")
  local filepath = vim.fs.joinpath(cache_dir, file)
  local writer = assert(io.open(filepath, "w"))
  writer:write(vim.json.encode(data and {data} or {}))
  writer:close()
end

M.append = function (file, data)
  local content = M.read(file)
  table.insert(content, data)
  M.write(file, data)
end

M.is_expired = function (file, ttl)
  local filepath = vim.fs.joinpath(cache_dir, file)
  ttl = ttl or 60
  local stat = uv.fs_stat(filepath)
  if not stat then
    return true
  end
  return os.time() - stat.mtime.sec >= ttl
end

return M
