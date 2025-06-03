return {
  {
    "ggandor/leap.nvim",
    dependencies = {"tpope/vim-repeat", "folke/which-key.nvim"},
    config = function ()
      local leap = require("leap")
      local user = require("leap.user")
      require("which-key").add({
        { 'f', '<Plug>(leap)', desc = 'Leap' }
      });
      leap.opts["equivalence_classes"] = {" \9\13\n", "([{", ")]}", "'\"`"}
      return user.set_repeat_keys("<enter>", "<backspace>")
    end
  }
}
