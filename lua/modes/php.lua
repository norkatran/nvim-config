local function pint()
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

return {pattern = "*.php", formatter = pint}
