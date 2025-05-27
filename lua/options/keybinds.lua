local bindings = {{"<leader>b", "", {expansions = {{"<leader>bn", "<Cmd>BufferNext<CR>", {desc = "Next Buffer"}}, {"<leader>bN", "<Cmd>Buffer Previous<CR>", {desc = "Previous Buffer"}}, {"<leader>bp", "<Cmd>BufferPick<CR>", {desc = "Pick Buffer"}}, {"<leader>bd", "<Cmd>BufferClose<CR>", {desc = "Close Buffer"}}}, group = "buffers"}}}
local mappings = {}
local function add_mapping(binding)
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
for _, binding in pairs(bindings) do
  add_mapping(binding)
end
local function _9_()
  local function _10_()
    if nil then
      return nil
    else
      return {}
    end
  end
  return require("mode").expand(_10_())
end
table.insert(mappings, {"<leader>m", group = "mode", expand = _9_})
return require("which-key").add(mappings)