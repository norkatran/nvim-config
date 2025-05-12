-- Load core modules
require "options"
require "bootstrap"

-- Initialize lazy.nvim
require("lazy").setup("plugins")

-- Load utility modules
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
require("mason").setup()
require("mason-lspconfig").setup(plugin_defaults.mason)

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

require('plugin.git.init')

