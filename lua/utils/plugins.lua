-- utils/plugins.lua
-- Plugin configuration utilities

local M = {}


-- Common LSP configuration
M.lsp = {
  -- Default on_attach function for LSP
  on_attach = function(client, bufnr)
    local wk = require('which-key')
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Common LSP keymappings
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    wk.add({
      { '<leader>l', group = 'LSP' },
      { '<leader>lD', vim.lsp.buf.declaration, buffer = bufnr, desc = 'Declaration' },
      { '<leader>ld', vim.lsp.buf.definition, buffer = bufnr, desc = 'Definition' },
      { '<leader>lh', vim.lsp.buf.hover, buffer = bufnr, desc = 'Hover' },
      { '<leader>li', vim.lsp.buf.implementation, buffer = bufnr, desc = 'Hover' },
      { '<leader>ls', vim.lsp.buf.signature_help, buffer = bufnr, desc = 'Signature Help' },
      { '<leader>lR', vim.lsp.buf.rename, buffer = bufnr, desc = 'Rename' },
      { '<leader>lcc', vim.lsp.buf.code_action, buffer = bufnr, desc = 'Code Action' },
      { '<leader>lr', vim.lsp.buf.references, buffer = bufnr, desc = 'References' },
    })
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
            globals = { 'vim', 'Snacks' }
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
