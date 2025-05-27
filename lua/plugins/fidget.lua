local function _1_()
  return require("fidget").setup({notification = {override_vim_notify = true}})
end
return {{"j-hui/fidget.nvim", dependencies = {"folke/which-key.nvim", "nvim-telescope/telescope.nvim"}, opts = {notification = {override_vim_notify = true}}, config = _1_}}