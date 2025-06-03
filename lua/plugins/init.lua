local function _1_(_, x)
  return require("witch").setup(x)
end
local function _3_()
  vim.g["barbar_auto_setup"] = false
  return nil
end
return {
  "rktjmp/hotpot.nvim",
  "nvim-tree/nvim-web-devicons",
  {"sontungexpt/witch", priority = 1000, config = _1_, lazy = false},
  "rcarriga/nvim-notify",
  {"ellisonleao/glow.nvim", config = true, cmd = "Glow"},
  "airblade/vim-rooter",
  {"j-hui/fidget.nvim", opts = {notification = {override_vim_notify = true}}},
  {"romgrk/barbar.nvim", dependencies = {"lewis6991/gitsigns.nvim", "nvim-tree/nvim-web-devicons"}, init = _3_, opts = {}, version = "^1.0.0"},
}
