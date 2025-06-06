-- Load Vim options
require("options.vim")
-- require("mode")

-- Function to ensure a plugin is installed
local function ensure_plugin_installed(plugin, branch)
  local _, repo = string.match(plugin, "(.+)/(.+)")
  local repo_path = (vim.fn.stdpath("data") .. "/lazy/" .. repo)

  -- Check if plugin is already installed
  if not (vim.uv or vim.loop).fs_stat(repo_path) then
    vim.notify(("Installing " .. plugin .. " " .. branch))
    local repo_url = ("https://github.com/" .. plugin .. ".git")
    local out = vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      ("--branch=" .. branch),
      repo_url,
      repo_path
    })

    if (vim.v.shell_error ~= 0) then
      vim.api.nvim_echo({
        { ("Failed to clone " .. plugin .. ":\n"), "ErrorMsg" },
        { out,                                     "WarningMsg" },
        { "\nPress any key to exit..." }
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end

  return repo_path
end

-- Install and configure lazy.nvim
local lazy_path = ensure_plugin_installed("folke/lazy.nvim", "stable")
vim.opt.runtimepath:prepend({ lazy_path })

-- Enable Lua module loader
vim.loader.enable()

-- Setup plugins
require("lazy").setup({ spec = { import = "plugins" } })

-- Load keybindings
require("options.keybinds")

-- Load features
require("feature.init")

-- Load commands
require("options.commands")

vim.lsp.enable({
  "luals", -- lua
})
