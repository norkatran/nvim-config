# Neovim Configuration

This is a modular Neovim configuration that uses Lua for configuration and plugin management.

## Structure

The configuration is organized into the following structure:

```
.config/nvim/
├── init.lua                 # Main entry point
├── lua/
│   ├── bootstrap.lua        # Lazy.nvim bootstrap
│   ├── config/              # Configuration modules
│   │   └── init.lua         # Central configuration
│   ├── keybinds.lua         # Keybindings
│   ├── options.lua          # Neovim options
│   ├── plugins.lua          # Plugin specifications
│   └── utils/               # Utility modules
│       ├── init.lua         # Core utilities
│       ├── gitlab.lua       # GitLab integration utilities
│       ├── plugins.lua      # Plugin utilities
│       └── ui.lua           # UI utilities
```

## Utilities

The configuration uses a modular approach to reduce code duplication:

- `utils/init.lua`: Core utility functions for common operations
- `utils/gitlab.lua`: GitLab integration utilities
- `utils/plugins.lua`: Plugin configuration utilities
- `utils/ui.lua`: UI-related utilities
- `config/init.lua`: Central configuration for plugins and UI

## Key Features

- Modular configuration with utilities to reduce code duplication
- Lazy-loaded plugins with Lazy.nvim
- LSP integration with Mason
- GitLab integration
- Telescope for fuzzy finding
- Which-key for keybinding documentation
- Treesitter for syntax highlighting

## Usage

1. Clone this repository to `~/.config/nvim`
2. Start Neovim - plugins will be automatically installed

## Customization

To customize the configuration:

1. Edit `config/init.lua` to change common settings
2. Add new utility modules in the `utils/` directory
3. Modify `plugins.lua` to add or remove plugins
4. Update `keybinds.lua` to change keybindings
