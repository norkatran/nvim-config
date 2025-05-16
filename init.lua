require("options.vim")
require("mode")
local function ensure_installed(plugin, branch)
  local _, repo = string.match(plugin, "(.+)/(.+)")
  local repo_path = (vim.fn.stdpath("data") .. "/lazy/" .. repo)
  if not (vim.uv or vim.loop).fs_stat(repo_path) then
    vim.notify(("Installing " .. plugin .. " " .. branch))
    local repo_url = ("https://github.com/" .. plugin .. ".git")
    local out = vim.fn.system({"git", "clone", "--filter=blob:none", ("--branch=" .. branch), repo_url, repo_path})
    if (vim.v.shell_error ~= 0) then
      vim.api.nvim_echo({{("Failed to clone " .. plugin .. ":\n"), "ErrorMsg"}, {out, "WarningMsg"}, {"\nPress any key to exit..."}}, true, {})
      vim.fn.getchar()
      os.exit(1)
    else
    end
  else
  end
  return repo_path
end
local lazy_path = ensure_installed("folke/lazy.nvim", "stable")
local hotpot_path = ensure_installed("rktjmp/hotpot.nvim", "v0.14.8")
vim.opt.runtimepath:prepend({hotpot_path, lazy_path})
vim.loader.enable()
require("hotpot")
require("lazy").setup({spec = {import = "plugins"}})
do
  local hotpot = require("hotpot")
  local setup = hotpot.setup
  setup({compiler = {modules = {correlate = true}, macros = {env = "_COMPILER", compilerEnv = _G, allowedGlobals = false}}})
  local function rebuild_on_save(_3_)
    local buf = _3_["buf"]
    local _let_4_ = require("hotpot.api.make")
    local build = _let_4_["build"]
    local au_config
    local function _5_()
      local _6_
      do
        local tbl_21_ = {}
        local i_22_ = 0
        for n, _ in pairs(_G) do
          local val_23_ = n
          if (nil ~= val_23_) then
            i_22_ = (i_22_ + 1)
            tbl_21_[i_22_] = val_23_
          else
          end
        end
        _6_ = tbl_21_
      end
      return build(vim.fn.stdpath("config"), {verbose = true, atomic = true, compiler = {modules = {allowedGlobals = _6_}}}, {{"init.fnl", true}})
    end
    au_config = {buffer = buf, callback = _5_}
    return vim.api.nvim_create_autocmd("BufWritePost", au_config)
  end
  vim.api.nvim_create_autocmd("BufRead", {pattern = vim.fs.normalize((vim.fn.stdpath("config") .. "/init.fnl")), callback = rebuild_on_save})
end
require("options.keybinds")
require("feature.init")
return require("options.commands")