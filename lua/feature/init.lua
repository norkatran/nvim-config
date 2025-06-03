-- Dynamically load all feature modules
local function load_feature_modules()
  local config_path = vim.fn.stdpath("config")
  local feature_dir = vim.fs.joinpath(config_path, "lua", "feature")

  for name, _ in vim.fs.dir(feature_dir) do
    local filename = string.sub(name, 1, -5)  -- Remove .lua extension
    if (filename ~= "init") then
      local import = require("feature." .. filename)
      if import and type(import) == "table" and import.setup then
        import.setup()
      end
    end
  end
end

load_feature_modules()
return nil
