for name, _ in vim.fs.dir(vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "feature")) do
  local filename = string.sub(name, 1, -5)
  if (filename ~= "init") then
    require(("feature" .. "." .. filename))
  else
  end
end
return nil
