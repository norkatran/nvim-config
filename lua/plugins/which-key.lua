local function add_mapping(mappings, binding)
  local and_1_ = ((_G.type(binding) == "table") and (nil ~= binding[1]) and true and (nil ~= binding[3]))
  if and_1_ then
    local key = binding[1]
    local _ = binding[2]
    local opts = binding[3]
    local _4_
    do
      local t_3_ = opts
      if (nil ~= t_3_) then
        t_3_ = t_3_.expansions
      else
      end
      _4_ = t_3_
    end
    and_1_ = _4_
  end
  if and_1_ then
    local key = binding[1]
    local _ = binding[2]
    local opts = binding[3]
    local function _6_()
      local tmp_9_ = {}
      tmp_9_[1] = key
      tmp_9_["group"] = opts.group
      return tmp_9_
    end
    table.insert(mappings, _6_())
    for _0, binding2 in pairs(opts.expansions) do
      add_mapping(binding2)
    end
    return nil
  elseif ((_G.type(binding) == "table") and (nil ~= binding[1]) and (nil ~= binding[2]) and (nil ~= binding[3])) then
    local key = binding[1]
    local callback = binding[2]
    local opts = binding[3]
    local function _7_()
      opts[1] = key
      opts[2] = callback
      return opts
    end
    return table.insert(mappings, _7_())
  else
    return nil
  end
end
local function add_mappings(mappings, bindings)
  for _, binding in pairs(bindings) do
    add_mapping(mappings, binding)
  end
  return nil
end
local function _9_()
  local whichkey = require("which-key")
  local function _10_(m)
    local desc
    do
      local t_11_ = m
      if (nil ~= t_11_) then
        t_11_ = t_11_.desc
      else
      end
      desc = t_11_
    end
    do local _ = desc end
    return (desc ~= "Dashboard action")
  end
  whichkey.setup({preset = "modern", filter = _10_})
  local function _13_()
    return vim.cmd.wincmd("h")
  end
  local function _14_()
    return vim.cmd.wincmd("j")
  end
  local function _15_()
    return vim.cmd.wincmd("k")
  end
  local function _16_()
    return vim.cmd.wincmd("l")
  end
  local function _17_()
    return vim.cmd.wincmd("h")
  end
  return whichkey.add({{"<leader>w", group = "Window"}, {"<leader>wh", _13_, desc = "Window Left"}, {"<leader>wj", _14_, desc = "Window Down"}, {"<leader>wk", _15_, desc = "Window Up"}, {"<leader>wl", _16_, desc = "Window Right"}, {"<leader>wh", _17_, desc = "Window Left"}, {"<leader>y", "\"+y", desc = "Copy", mode = {"n", "v"}}, {"<leader>Y", "\"+yg_", desc = "Copy (EOL)", mode = {"n", "v"}}}, {"<leader>%", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", desc = "Replace Symbol"}, {"<leader>c", group = "Config"}, {"<leader>cs", "<Cmd>source %<CR>", desc = "Source File"})
end
return {{"folke/which-key.nvim", event = "VeryLazy", config = _9_}}