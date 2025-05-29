return {
  {
    'echasnovski/mini.nvim',
    dependencies = {"nvim-treesitter/nvim-treesitter"},
    version = false,
    opts = false,
    config = function ()
      require('mini.ai').setup()
      require('mini.comment').setup()
      require('mini.operators').setup()
      require('mini.pairs').setup()
      require('mini.surround').setup()
      require('mini.git').setup()
    end
  }
}
