local utils = require("utils")
local background_process = utils.background_process
local ui = require("ui")
local create_menu = ui.create_menu
local create_input = ui.create_input
local secret = require("secret")
local repo_paths = secret.repo_paths

-- Event names
local REPO_CHANGED = "repo-change"
local CURRENT_BRANCH_DELETED = "current-branch-deleted"

-- Check if the repository is a worktree
local function is_worktree(repo)
  local path = (repo or Snacks.git.get_root())
  return (#vim.fn.glob((path .. "/.git/*")) == 0)
end

-- Change the current working directory and trigger repo change event
local function change_path(path)
  vim.cmd(("cd " .. path))
  return vim.api.nvim_exec_autocmds(REPO_CHANGED)
end

-- Setup a new branch with upstream and dependencies
local function setup_branch(path, branch)
  background_process({"git", "push", "--set-upstream", "origin", branch}, {cwd = path})
  
  -- Check for package managers
  local has_npm = (#vim.fn.glob(vim.fs.joinpath(path, "package.json")) > 0)
  local has_composer = (#vim.fn.glob(vim.fs.joinpath(path, "composer.json")) > 0)
  
  local state = {}
  
  -- Check if all dependency installations are finished
  local function check_dependencies_finished(callback)
    local finished = true
    if (has_npm and not state.npm) then
      finished = false
    end
    if (has_composer and not state.composer) then
      finished = false
    end
    if finished then
      return callback()
    end
    return nil
  end
  
  if has_npm then
    local function on_npm_success()
      state["npm"] = true
      local function on_all_finished()
        return change_path(path)
      end
      return check_dependencies_finished(on_all_finished)
    end
    background_process({"npm", "ci"}, {cwd = path, on_success = on_npm_success})
  end
  
  -- Rest of the function implementation...
end

-- Additional functions...

return {
  is_worktree = is_worktree,
  change_path = change_path,
  setup_branch = setup_branch,
  -- Other exported functions...
}
