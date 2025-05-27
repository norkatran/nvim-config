local function _1_()
  local leap = require("leap")
  local user = require("leap.user")
  leap.set_default_mappings()
  leap.opts["equivalence_classes"] = {" \9\13\n", "([{", ")]}", "'\"`"}
  return user.set_repeat_keys("<enter>", "<backspace>")
end
return {{"ggandor/leap.nvim", dependencies = {"tpope/vim-repeat"}, config = _1_}}