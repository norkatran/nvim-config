local function get_buffer_name(_3fbuf)
  local function _1_()
    if _3fbuf then
      return _3fbuf
    else
      return vim.api.nvim_get_current_buf()
    end
  end
  return vim.api.nvim_buf_get_name(_1_())
end
local function pint_3f()
  local root = Snacks.git.get_root()
  local pint = vim.fs.joinpath(root, "vendor/bin/pint")
  local stat = vim.uv.fs_stat(pint)
  if (stat and (stat.type == "file")) then
    print(pint)
    return pint
  else
    return nil
  end
end
local function format(_3ffile)
  local file
  if _3ffile then
    file = _3ffile
  else
    file = get_buffer_name()
  end
  local pint = pint_3f()
  if pint then
    return vim.system({pint, file}):wait()
  else
    return nil
  end
end
local function _5_()
  return pint_3f()
end
return {pattern = "*.php", formatter = _5_}
