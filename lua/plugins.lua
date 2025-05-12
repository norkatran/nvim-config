local git = require('plugin.git.init')

return {
  "nvim-tree/nvim-web-devicons",
  {
    "nvim-lualine/lualine.nvim",
    config = function ()
      require("lualine").setup {
        theme = "powerline_dark",
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename', function ()
            local mrs = #git.get_mrs()
            local reviews = #git.get_review_requests()
            local todos = #git.get_todos()

            local msg = ''
            if mrs == 0 and reviews == 0 and todos == 0 then
              return msg
            end

            if mrs > 0 then
              msg = 'MRs ' .. mrs
            end
            if reviews > 0 then
              if msg ~= '' then
                msg = msg .. ' | '
              end
              msg = msg .. 'Reviews ' .. reviews
            end
            if todos > 0 then
              if msg ~= '' then
                msg = msg .. ' | '
              end
              msg = msg .. 'To Dos ' .. todos
            end
            return msg
          end },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        }
      }
    end
  },
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
            key = 's',
            action = ":Telescope git_status"
          },
          {
            enabled = git.is_gitlab_repo,
            title = 'Oustanding MRs',
            section = 'terminal',
            cmd = "glab api graphql -f query=' query { root: currentUser { MRs: assignedMergeRequests(state: opened) { nodes { title, state } } } }' | jq -r '.data.root.MRs.nodes | .[] | [.title, .state] | @tsv'",
            pane = 2,
            height = 5,
            padding = 1,
            ttl = 60,
            key = 'm',
            action = function ()
              git.list_mrs()
            end,
          },
          {
            enabled = git.is_gitlab_repo,
            title = 'Oustanding Reviews',
            section = 'terminal',
            cmd = "glab api graphql -f query=' query { root: currentUser { Issues: reviewRequestedMergeRequests(state: opened) { nodes { title, state } } } }' | jq -r '.data.root.Issues.nodes | .[] | [.title, .state] | @tsv'",
            pane = 2,
            height = 5,
            padding = 1,
            ttl = 60,
            key = 'r',
            action = function ()
              git.list_review_requests()
            end,
          },
          {
            enabled = git.is_gitlab_repo,
            title = 'Notifications',
            section = 'terminal',
            cmd = "glab api graphql -f query=' query { root: currentUser { ToDos: todos(state: pending) { nodes { action, body } } } }' | jq -r '.data.root.ToDos.nodes | .[] | [.action, .body] | @tsv'",
            pane = 2,
            height = 5,
            padding = 1,
            ttl = 60,
            key = 'n',
            action = function ()
              git.list_todos()
            end,
          },
          { section = 'startup' }
        },
        preset = {
          header = [[ Marnie - NVIM ]],
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "d", desc = "Dir", action = ":Neotree position=float" },
            { icon = " ", key = "/", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "c", desc = "Config", action = ":Neotree position=float dir=~/.config/nvim" },
            { icon = " ", key = "g", desc = "Git Repos", action = ":lua require('plugin.git.init').list_repos {}" },
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
        override_vim_notify = true,
      }
    }
  },
  {
    'm4xshen/hardtime.nvim',
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {}
  }
}
