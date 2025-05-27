local function _1_()
  return {ensure_installed = {"lua", "fennel", "vim", "markdown", "php", "typescript"}, auto_install = true, highlight = {enable = true, additional_vim_regex_highlighting = true}}
end
return {{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate", config = _1_}}