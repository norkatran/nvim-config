vim.g.mapleader = " "

-- ~/.config/nvim/init.lua
-- Ensure lazy and hotpot are always installed
local function ensure_installed(plugin, branch)
  local user, repo = string.match(plugin, "(.+)/(.+)")
  local repo_path = vim.fn.stdpath("data") .. "/lazy/" .. repo
  if not (vim.uv or vim.loop).fs_stat(repo_path) then
    vim.notify("Installing " .. plugin .. " " .. branch)
    local repo_url = "https://github.com/" .. plugin .. ".git"
    local out = vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=" .. branch,
      repo_url,
      repo_path
    })
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { "Failed to clone " .. plugin .. ":\n", "ErrorMsg" },
        { out, "WarningMsg" },
        { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
  return repo_path
end
local lazy_path = ensure_installed("folke/lazy.nvim", "stable")
local hotpot_path = ensure_installed("rktjmp/hotpot.nvim", "v0.14.8")
-- As per Lazy's install instructions, but also include hotpot
vim.opt.runtimepath:prepend({hotpot_path, lazy_path})

-- You must call vim.loader.enable() before requiring hotpot unless you are
-- passing {performance = {cache = false}} to Lazy.
vim.loader.enable()


require('hotpot')


--require "bootstrap"
--require("lazy").setup({ spec = {import = "plugins"}})

if true then
  require("fnl_init")
  -- require("fennel").install().dofile("/Users/marnie/.config/nvim/init.fnl")
else
  -- Load core modules
  require "options"

  -- Initialize lazy.nvim


  ---- Load utility modules
  local plugin_utils = require("utils.plugins")
  local config = require("config.init")

  -- Load keybindings
  require "keybinds"

  local plugin_defaults = config.create_plugin_configs()
  -- Setup plugins with common configurations
  local plugin_configs = {
    ["nvim-web-devicons"] = {},
    ["nvim-treesitter.configs"] = plugin_defaults.treesitter,
    ["fidget"] = {},
    ["telescope"] = plugin_defaults.telescope,
    ["Comment"] = plugin_defaults.comment,
    ["mini.surround"] = {}
  }

  -- Setup all plugins with their configurations
  plugin_utils.setup_multiple(plugin_configs)

  -- Load telescope extensions
  require('telescope').load_extension('fidget')

  -- Setup LSP
  -- require("mason").setup()
  --require("mason-lspconfig").setup(plugin_defaults.mason)

  -- Setup LSP handlers with improved configuration
  --require("mason-lspconfig").setup_handlers {
    --function (server_name)
      --local server_config = plugin_utils.lsp.server_configs[server_name] or {}
  --
      ---- Add default capabilities and on_attach if not specified
      --if not server_config.on_attach then
        --server_config.on_attach = plugin_utils.lsp.on_attach
      --end
  --
      --if not server_config.capabilities then
        --server_config.capabilities = plugin_utils.lsp.capabilities()
      --end
  --
      --require("lspconfig")[server_name].setup(server_config)
    --end,
  --}

  local event = require('nvit.event')
  vim.cmd('autocmd User ' .. event.REPO_CHANGED .. ' :lua require(\'snacks.dashboard\').update()')
  vim.cmd('autocmd User ' .. event.CURRENT_BRANCH_DELETED .. ' :lua require(\'nvit\').view_branches()')
end
