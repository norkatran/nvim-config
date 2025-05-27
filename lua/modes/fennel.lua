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
local function format(_3ffile)
  local file
  if _3ffile then
    file = _3ffile
  else
    file = get_buffer_name()
  end
  return vim.system({"fnlfmt", "--fix", file}):wait()
end
return {formatter = "fnlfmt --fix", pattern = "*.fnl"}