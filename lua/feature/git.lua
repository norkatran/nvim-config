local _local_1_ = require("utils")
local background_process = _local_1_["background_process"]
local _local_2_ = require("ui")
local create_menu = _local_2_["create_menu"]
local create_input = _local_2_["create_input"]
local _local_3_ = require("secret")
local repo_paths = _local_3_["repo_paths"]
local REPO_CHANGED = "repo-change"
local CURRENT_BRANCH_DELETED = "current-branch-deleted"
local function is_worktree_3f(repo)
  local path = (repo or Snacks.git.get_root())
  return (#vim.fn.glob((path .. "/.git/*")) == 0)
end
local function change_path(path)
  vim.cmd(("cd " .. path))
  return vim.api.nvim_exec_autocmds(REPO_CHANGED)
end
local function setup_branch(path, branch)
  background_process({"git", "push", "--set-upstream", "origin", branch}, {cwd = path})
  local npm_3f = (#vim.fn.glob(vim.fs.joinpath(path, "package.json")) > 0)
  local composer_3f = (#vim.fn.glob(vim.fs.joinpath(path, "composer.json")) > 0)
  local state = {}
  local state_finished_3f
  local function _4_(callback)
    local finished_3f = true
    if (npm_3f and not state.npm) then
      finished_3f = false
    else
    end
    if (composer_3f and not state.composer) then
      finished_3f = false
    else
    end
    if finished_3f then
      return callback()
    else
      return nil
    end
  end
  state_finished_3f = _4_
  if npm_3f then
    local function _8_()
      state["npm"] = true
      local function _9_()
        return change_path(path)
      end
      return state_finished_3f(_9_)
    end
    background_process({"npm", "ci"}, {cwd = path, ["on_success"] = _8_})
  else
  end
  if composer_3f then
    local function _11_()
      state["composer"] = true
      local function _12_()
        return change_path(path)
      end
      return state_finished_3f(_12_)
    end
    background_process({"composer", "install"}, {cwd = path, ["on_success"] = _11_})
  else
  end
  if (not composer_3f() and not npm_3f()) then
    return change_path(path)
  else
    return nil
  end
end
local function checkout_repo_branch(repo, branch)
  vim.notify(("Checking out branch " .. branch .. "@" .. repo))
  if is_worktree_3f(repo) then
    local function _15_()
      return setup_branch(vim.fs.joinpath(repo, branch))
    end
    return background_process({"git", "worktree", "add", "--track", "-b", branch, branch, ("origin/" .. branch)}, {cwd = repo, ["on_success"] = _15_})
  else
    local function _16_()
      return setup_branch(repo)
    end
    return background_process({"git", "checkout", branch}, {cwd = repo, ["on_sucess"] = _16_})
  end
end
local function create_branch(repo, branch)
  vim.notify(("Creating branch " .. branch .. "@" .. repo))
  if is_worktree_3f(repo) then
    local function _18_()
      return setup_branch(vim.fs.joinpath(repo, branch))
    end
    return background_process({"git", "worktree", "add", branch}, {cwd = repo, ["on_success"] = _18_})
  else
    local function _19_()
      return setup_branch(repo)
    end
    return background_process({"git", "checkout", "-b", branch}, {cwd = repo, ["on_success"] = _19_})
  end
end
local function is_current_branch_3f(repo, branch)
  local cwd = vim.uv.cwd()
  if ((cwd ~= repo) and (string.sub(cwd, 1, #repo) ~= repo)) then
    return false
  else
    local current_branch = vim.system({"git", "branch", "--show-current"}):wait().stdout
    if (string.sub(current_branch, 1, -2) == branch) then
      return true
    else
      return false
    end
  end
end
local function delete_branch(repo, branch)
  local is_current_branch = is_current_branch_3f(repo, branch)
  if is_worktree_3f(repo) then
    background_process({"git", "worktree", "remove", branch}, {cwd = repo})
  else
    background_process({"git", "branch", "-D", branch}, {cwd = repo})
  end
  if is_current_branch then
    return vim.api.nvim_exec_autocmds(CURRENT_BRANCH_DELETED)
  else
    return nil
  end
end
local function render_branches(repo, stdout)
  local branches = vim.split(stdout, "\n")
  local items = {}
  for _, b in pairs(branches) do
    local branch = string.sub(b, 3, -1)
    local function _25_()
      return checkout_repo_branch(repo, branch)
    end
    table.insert(items, {text = branch, action = _25_})
  end
  local function _26_()
    local function _27_(branch)
      return create_branch(repo, branch)
    end
    return create_input("New Branch", _27_)
  end
  local function _28_(branch)
    return delete_branch(repo, branch)
  end
  return create_menu("Select Branch", items, {mappings = {{"<C-n>", _26_, desc = "Create Branch"}, {"<C-D>", _28_, desc = "Delete Branch"}}})
end
local function view_branches(_3frepo)
  local repo = (_3frepo or vim.uv.cwd())
  local function _29_(stdout)
    return render_branches(repo, stdout)
  end
  return background_process({"git", "--no-pager", "branch", "--no-color"}, {cwd = repo, ["on_success"] = _29_})
end
local function view_repos()
  local menu_items = {}
  local only_path = (#repo_paths == 1)
  for _, r in pairs(repo_paths) do
    local prefix
    if only_path then
      prefix = (r .. "/")
    else
      prefix = ""
    end
    local paths = vim.split(vim.fn.glob((r .. "/*")), "\n")
    for _0, p in pairs(paths) do
      local function _31_()
        return view_branches(p)
      end
      table.insert(menu_items, {text = (prefix .. p), action = _31_})
    end
  end
  if (#menu_items == 0) then
    table.insert(menu_items, {text = "No Repos Found", separator = true})
  else
  end
  return create_menu("Select Repository", menu_items)
end
require("which-key").add({{"<leader>g", group = "Git"}, {"<leader>gr", view_repos, desc = "Git Repos"}, {"<leader>gb", view_branches, desc = "Git Branches"}})
vim.cmd(("autocmd User " .. CURRENT_BRANCH_DELETED .. " :Fnl ((. (require :feature.git) :view-branches))"))
vim.cmd(("autocmd User " .. REPO_CHANGED .. " :Fnl (do (vim.cmd \"%bd!\") (Snacks.dashboard.open) (Snacks.dashboard.update))"))
return {["view-repos"] = view_repos, ["view-branches"] = view_branches, ["REPO-CHANGED"] = REPO_CHANGED, ["CURRENT-BRANCH-DELETED"] = CURRENT_BRANCH_DELETED}
