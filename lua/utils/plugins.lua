-- utils/plugins.lua
-- Plugin configuration utilities

local M = {}

-- Common LSP configuration
M.lsp = {
  -- Default on_attach function for LSP
  on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
    -- Common LSP keymappings
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  end,
  
  -- Default capabilities
  capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    -- Add additional capabilities here if needed
    return capabilities
  end,
  
  -- Common server configurations
  server_configs = {
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' }
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false
          },
          telemetry = {
            enable = false
          }
        }
      }
    },
    -- Add other server configurations as needed
  }
}

-- Setup a plugin with default configuration
M.setup = function(plugin_name, config)
  local utils = require('utils')
  return utils.setup_plugin(plugin_name, config)
end

-- Setup multiple plugins with their configurations
M.setup_multiple = function(plugins_config)
  for plugin_name, config in pairs(plugins_config) do
    M.setup(plugin_name, config)
  end
end

return M
