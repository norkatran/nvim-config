local gitlab = require('utils/gitlab')

return {
  "nvim-tree/nvim-web-devicons",
  -- "nvim-tree/nvim-tree.lua",
  "nvim-lualine/lualine.nvim",
  { "nvim-lua/plenary.nvim", lazy = true },
  "nvim-telescope/telescope.nvim",
  { "polarmutex/git-worktree.nvim", branch = "devel" },
  "rcarriga/nvim-notify",
  "nvim-treesitter/nvim-treesitter",
  { "ellisonleao/glow.nvim", config = true, cmd = "Glow" },
  {
    "sontungexpt/witch",
    priority = 1000,
    lazy = false,
    config = function (_, opts)
      require("witch").setup(opts)
    end
  },
  {
    "romgrk/barbar.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "nvim-tree/nvim-web-devicons"
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {},
    version = "^1.0.0"
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = 'modern',
      filter = function (mapping)
        return mapping.desc and mapping.desc ~= 'Dashboard action'
      end,
    }
  },
  {
    "numToStr/Comment.nvim",
    opts = {}
  },
  {
    "yorickpeterse/nvim-window",
    keys = {
      { "<leader>ww", "<cmd>lua require('nvim-window').pick()<cr>", desc = "nvim-window: Jump to window" },
    },
    config = true
  },
  {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "1.*",
    opts = {
      keymap = { preset = "default" },
      sources = {
        default = { "lsp" }
      },
    },
    opts_extend = { "sources.default" }
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },

    -- example using `opts` for defining servers
    opts = {
      servers = {
        lua_ls = {}
      }
    },
    config = function(_, opts)
      local lspconfig = require('lspconfig')
      for server, config in pairs(opts.servers) do
        -- passing config.capabilities to blink.cmp merges with the capabilities in your
        -- `opts[server].capabilities, if you've defined it
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end
    end
  },
  {
    "williamboman/mason.nvim"
  },
  {
    "williamboman/mason-lspconfig.nvim"
  },
  {
    "echasnovski/mini.surround"
  },
  -- {
  --   "rmagatti/auto-session",
  --   lazy = false,
  --   opts = {
  --     suppressed_dirs = { "~/", "~/.config", "~/.config/*", "~/src", "~/worktrees" }
  --   }
  -- },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        sections = {
          { section = 'header' },
          {
            pane = 2,
            section = 'terminal',
            cmd = 'date',
            height = 1,
            padding = 1,
            ttl = 0,
          },
          { section = 'keys', gap = 1, padding = 1 },
          {
            pane = 2,
            icon = ' ',
            title = 'Unstaged Files',
            section = 'terminal',
            enabled = function ()
              return Snacks.git.get_root() ~= nil
            end,
            cmd = 'git status --short --branch --renames',
            height = 5,
            padding = 1,
            ttl = 0,
            indent = 3,
            key = 'g',
            action = ":Telescope git_status"
          },
          {
            enabled = gitlab.check_glab_repo,
            title = 'Oustanding MRs',
            section = 'terminal',
            cmd = "glab api graphql -f query=' query { root: user(username: \"mlysander\") { MRs: assignedMergeRequests(state: opened) { nodes { title, state } } } }' | jq -r '.data.root.MRs.nodes | .[] | [.title, .state] | @tsv'",
            pane = 2,
            height = 5,
            padding = 1,
            ttl = 60,
            key = 'm',
            action = function ()
              vim.ui.open('https://gitlab.corp.friendmts.com/dashboard/merge_requests?assignee_username=mlysander')
            end,
          },
          {
            enabled = gitlab.check_glab_repo,
            title = 'Oustanding Reviews',
            section = 'terminal',
            cmd = "glab api graphql -f query=' query { root: user(username: \"mlysander\") { Issues: reviewRequestedMergeRequests(state: opened) { nodes { title, state } } } }' | jq -r '.data.root.Issues.nodes | .[] | [.title, .state] | @tsv'",
            pane = 2,
            height = 5,
            padding = 1,
            ttl = 60,
            key = 'r',
            action = function ()
              vim.ui.open('https://gitlab.corp.friendmts.com/dashboard/merge_requests?reviewer_username=mlysander')
            end,
          },
          {
            enabled = gitlab.check_glab_repo,
            title = 'Notifications',
            section = 'terminal',
            cmd = "glab api graphql -f query=' query { root: user(username: \"mlysander\") { ToDos: todos(state: pending) { nodes { action, body } } } }' | jq -r '.data.root.ToDos.nodes | .[] | [.action, .body] | @tsv'",
            pane = 2,
            height = 5,
            padding = 1,
            ttl = 60,
            key = 'n',
            action = function ()
              vim.ui.open('https://gitlab.corp.friendmts.com/dashboard/todos')
            end,
          },
          { section = 'startup' }
        },
        preset = {
          header = [[ Marnie - NVIM ]],
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "d", desc = "Dir", action = ":Neotree position=float" },
            { icon = " ", key = "/", desc = "Find Text", action = ":lua Sancks.dashboard.pick('live_grep')" },
            { icon = " ", key = "c", desc = "Config", action = ":e ~/.config/nvim/init.lua | :next ~/.config/nvim/lua/*.lua" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            -- { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        }
      }
    }
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    lazy = false, -- neo-tree will lazily load itself
    ---@module "neo-tree"
    ---@type neotree.Config?
    opts = {
      -- fill any relevant options here
    },
  },
  { 'airblade/vim-rooter' },
  {
    'j-hui/fidget.nvim',
    opts = {
      notification = {
        configs = {
          default = {
            ttl = 300
          }
        }
      }
    }
  },
}
