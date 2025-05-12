return {
  "nvim-tree/nvim-web-devicons",
  "nvim-tree/nvim-tree.lua",
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
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function ()
      require("dashboard").setup {
      }
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" }
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy"
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
  }
}
