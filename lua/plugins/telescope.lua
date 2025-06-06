local function builtin(command, opts)
  local function _1_()
    return require("telescope.builtin")[command](opts)
  end
  return _1_
end
local function _2_()
  require("telescope").setup({
    defaults = { prompt_prefix = "/", mappings = { i = { ["<esc>"] = require("telescope.actions").close } } }
    ,
    extensions = { fzf = {} }
  })
  return require("which-key").add({
    {
      "<leader>p", group = "Project"
    },
    {
      "<leader>p<leader>",
      builtin("find_files", {}),
      desc = "Project Files"
    },
    {
      "<leader>p/",
      builtin("live_grep", {}),
      desc = "Project Grep"
    },
    {
      "<leader>?",
      builtin("keymaps", {}),
      desc = "Keymaps"
    },
    {
      "<leader>c", group = "Config"
    },
    {
      "<leader>cp",
      builtin("find_files", { cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") }),
      desc =
      "Browse Packages"
    },
    {
      "<leader>c<leader>",
      builtin("find_files", { cwd = vim.fn.stdpath("config") }),
      desc = "Browse Config"
    },
    {
      "<leader>b", group = "Buffers" },
    {
      "<leader>b<leader>",
      builtin("buffers", {}),
      desc = "Browse Buffers"
    },
    {
      "<leader>r", group = "Registers" },
    {
      "<leader>r<leader>",
      builtin("registers", {}),
      desc = "Browse Registers"
    },
    { "<leader>h", group = "Help" },
    {
      "<leader>ht",
      builtin("help_tags", {}),
      desc = "Neovim :help"
    },
    { "<leader>q", group = "Quickfix" },
    {
      "<leader>q<space>",
      "<Cmd>Telescope quickfix<CR>",
      desc = "Quickfix List"
    },
    {
      "<leader>qn",
      "<Cmd>cnext<CR>",
      desc = "Next Item"
    },
    {
      "<leader>qN",
      "<Cmd>cprev<CR>",
      desc = "Prev Item"
    },
    {
      "<leader>q0",
      "<Cmd>crewind<CR>",
      desc = "First Item"
    },
    { "<leader>q/",
      function()
        require("ui").create_input("vimgrep", function(search)
          vim.cmd("silent grep '" .. search .. "' " .. Snacks.git.get_root())
          if #vim.fn.getqflist() > 1 then
            require("telescope.builtin").quickfix()
          end
        end)
      end }
  })
end
return { { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons", "folke/which-key.nvim" }, config = _2_ } }

