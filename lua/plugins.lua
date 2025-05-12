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
          lualine_c = { 'filename' }
        }
      }
    end
  },
  { "nvim-lua/plenary.nvim", lazy = true },
  "nvim-telescope/telescope.nvim",
  { "polarmutex/git-worktree.nvim", branch = "devel" },
  "rcarriga/nvim-notify",
  {
    "nvim-treesitter/nvim-treesitter",
  },
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
  --{
    --"saghen/blink.cmp",
    --enabled = false,
    --dependencies = {
      --"rafamadriz/friendly-snippets",
      --"folke/noice.nvim",
      --"mason-org/mason.nvim",
      --"mason-org/mason-lspconfig.nvim"
    --},
    --version = "1.*",
    --opts = {
      --keymap = { preset = "cmdline" },
      --completion = { ghost_text = { enabled = true } },
      --sources = {
        --default = { "lsp" }
      --},
    --},
    --opts_extend = { "keymap.preset", "sources.default" }
  --},
  { "mason-org/mason.nvim", version = "1.11.0" },
  { "mason-org/mason-lspconfig.nvim", version = "1.32.0" },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/nvim-cmp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "j-hui/fidget.nvim"
    },
    config = function()
      local cmp = require('cmp')
      local cmp_lsp = require("cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_lsp.default_capabilities()
      )

      -- require("fidget").setup()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "intelephense",
          "marksman"
        },
        automatic_enable = false,
        handlers = {
          function(server_name) -- default handler (optional)
            require("lspconfig")[server_name].setup {
              capabilities = capabilities
            }
          end,

          ["lua_ls"] = function()
            local lspconfig = require("lspconfig")
            lspconfig.lua_ls.setup {
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime = { version = "Lua 5.1" },
                  diagnostics = {
                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                  }
                }
              }
            }
          end,
        }
      })

      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
         { name = 'nvim_lsp' },
         { name = 'luasnip' }, -- For luasnip users.
        })
      })

      vim.diagnostic.config({
        virtual_text = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      vim.keymap.set("n", "K", function() -- Hopefully temporary, pending wider vim.o.winborder support
        vim.lsp.buf.hover { border = "rounded" }
      end)
      vim.keymap.set("n", "gf", vim.lsp.buf.format)
    end,
  },
  {
    "echasnovski/mini.surround"
  },
  {
    "folke/snacks.nvim",
    opts = function ()
      local nvit = require('nvit')
      local glab = require('nvit.glab')
      return {
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
              enabled = glab.is_gitlab_repo,
              title = 'Oustanding MRs',
              section = 'terminal',
              cmd = "glab api graphql -f query=' query { root: currentUser { MRs: assignedMergeRequests(state: opened) { nodes { project { name }, title, state } } } }' | jq -r '.data.root.MRs.nodes | .[] | [.project.name, .title, .state] | @tsv' | grep -n ' ' | cut -c 3-55",
              pane = 2,
              height = 5,
              padding = 1,
              ttl = 60,
              key = 'm',
              action = nvit.view_merge_requests
            },
            {
              enabled = glab.is_gitlab_repo,
              title = 'Oustanding Reviews',
              section = 'terminal',
              cmd = "glab api graphql -f query=' query { root: currentUser { Issues: reviewRequestedMergeRequests(state: opened) { nodes { project { name }, title, state } } } }' | jq -r '.data.root.Issues.nodes | .[] | [.project.name, .title, .state] | @tsv' | grep -n ' ' | cut -c 3-55",
              pane = 2,
              height = 5,
              padding = 1,
              ttl = 60,
              key = 'r',
              action = nvit.view_reviews,
            },
            {
              enabled = glab.is_gitlab_repo,
              title = 'Notifications',
              section = 'terminal',
              cmd = "glab api graphql -f query=' query { root: currentUser { ToDos: todos(state: pending) { nodes { action, body } } } }' | jq -r '.data.root.ToDos.nodes | .[] | [.action, .body] | @tsv' | grep -n ' ' | cut -c 3-55",
              pane = 2,
              height = 5,
              padding = 1,
              ttl = 60,
              key = 'n',
              action = nvit.view_notifications,
            },
            { section = 'startup' }
          },
          preset = {
            header = [[ Marnie - NVIM ]],
            keys = {
              { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
              { icon = " ", key = "d", desc = "Dir", action = ":Neotree position=float" },
              { icon = " ", key = "/", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
              --{ icon = " ", key = "c", desc = "Config", action = ":Neotree position=float dir=~/.config/nvim" },
              { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
              { icon = " ", key = "g", desc = "Git Repos", action = function () nvit.view_repos() end, },
              { icon = " ", key = "b", desc = "Git Branches", action = function () nvit.view_branches() end, },
              { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
              { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            },
          }
        }
      }
    end
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
  },
  {
    'm-lysa/nvit',
    dependencies = {
      "MunifTanjim/nui.nvim"
    },
    dev = true,
    opts = {
      repo_paths = { "~/worktrees", "~/projects", "~/src" },
    },
  },
}
