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
vim.opt.runtimepath:prepend({lazy_path})
vim.loader.enable()
require("lazy").setup({spec = {import = "plugins"}})

require("options.keybinds")

require("feature.init")

require("options.commands")
