-- ~/.config/nvim/.hotpot.lua

-- By default, the Fennel compiler wont complain if unknown variables are
-- referenced, we can force a compiler error so we don't try to run faulty code.
local allowed_globals = {"Snacks", "vim"}
for key, _ in pairs(_G) do
  table.insert(allowed_globals, key)
end

return {
  -- by default, build all fnl/ files into lua/
  build = true,
  -- remove stale lua/ files
  clean = true,
  compiler = {
    modules = {
      -- enforce unknown variable errors
      allowedGlobals = allowed_globals
    }
  }
}
