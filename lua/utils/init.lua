-- utils/init.lua
-- Core utility functions for Neovim configuration

local M = {}

-- Common function for setting keymaps with default options
M.map = function(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Common function for plugin configuration
M.setup_plugin = function(plugin, config)
    local status_ok, plugin_module = pcall(require, plugin)
    if not status_ok then
        return false
    end
    plugin_module.setup(config)
    return true
end

-- Check if a file or directory exists
M.exists = function(path)
    return (vim.uv or vim.loop).fs_stat(path) ~= nil
end

-- Safely require a module
M.safe_require = function(module)
    local status_ok, mod = pcall(require, module)
    if not status_ok then
        return nil
    end
    return mod
end

-- Merge tables
M.merge = function(...)
    local result = {}
    for _, t in ipairs({...}) do
        for k, v in pairs(t) do
            result[k] = v
        end
    end
    return result
end

return M
