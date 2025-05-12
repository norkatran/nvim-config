-- Load core modules
require "options"
require "bootstrap"

-- Initialize lazy.nvim
require("lazy").setup("plugins")

-- Load utility modules
local utils = require("utils")
local ui_utils = require("utils.ui")
local plugin_utils = require("utils.plugins")
local config = require("config")

-- Load keybindings
require "keybinds"

-- Setup plugins with common configurations
local plugin_configs = {
  ["nvim-web-devicons"] = {},
  ["nvim-treesitter.configs"] = config.plugins.treesitter,
  ["fidget"] = {},
  ["telescope"] = config.plugins.telescope,
  ["lualine"] = config.plugins.lualine,
  ["Comment"] = config.plugins.comment,
  ["mini.surround"] = {}
}

-- Setup all plugins with their configurations
plugin_utils.setup_multiple(plugin_configs)

-- Load telescope extensions
require('telescope').load_extension('fidget')

-- Setup LSP
require("mason").setup()
require("mason-lspconfig").setup(config.plugins.mason)

-- Setup LSP handlers with improved configuration
require("mason-lspconfig").setup_handlers {
  function (server_name)
    local server_config = plugin_utils.lsp.server_configs[server_name] or {}

    -- Add default capabilities and on_attach if not specified
    if not server_config.on_attach then
      server_config.on_attach = plugin_utils.lsp.on_attach
    end

    if not server_config.capabilities then
      server_config.capabilities = plugin_utils.lsp.capabilities()
    end

    require("lspconfig")[server_name].setup(server_config)
  end,
}

-- Set up auto gitlab notification fetching
local gitlab = require("utils.gitlab")
gitlab.setup_notification_timer()
