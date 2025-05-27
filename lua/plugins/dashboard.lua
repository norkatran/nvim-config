local function _1_()
  local function _2_()
    return require("feature.git")["view-repos"]()
  end
  local function _3_()
    return require("feature.git")["view-branches"]()
  end
  local function _4_()
    return (Snacks.git.get_root() ~= nil)
  end
  return {dashboard = {preset = {header = " Marnie - NVIM ", keys = {{action = ":lua Snacks.dashboard.pick('files')", desc = "Find File", icon = "\239\128\130 ", key = "f"}, {action = ":Neotree position=float", desc = "Dir", icon = "\239\147\147 ", key = "d"}, {action = ":lua Snacks.dashboard.pick('live_grep')", desc = "Find Text", icon = "\239\128\162 ", key = "/"}, {action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})", desc = "Config", icon = "\239\144\163 ", key = "c"}, {action = _2_, desc = "Git Repos", icon = "\238\153\157 ", key = "g"}, {action = _3_, desc = "Git Branches", icon = "\238\153\157 ", key = "b"}, {action = ":Lazy", desc = "Lazy", icon = "\243\176\146\178 ", key = "l"}, {action = ":qa", desc = "Quit", icon = "\239\144\166 ", key = "q"}}}, sections = {{section = "header"}, {cmd = "date", height = 1, padding = 1, pane = 2, section = "terminal", ttl = 0}, {gap = 1, padding = 1, section = "keys"}, {action = ":Telescope git_status", cmd = "git status --short --branch --renames", enabled = _4_, height = 5, icon = "\239\131\133 ", indent = 3, key = "s", padding = 1, pane = 2, section = "terminal", title = "Unstaged Files", ttl = 0}, {section = "startup"}}}}
end
return {"folke/snacks.nvim", opts = _1_}