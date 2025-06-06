local function prefix(keys)
  return "<leader>" .. keys
end

local function command(cmd)
  return "<Cmd>" .. cmd .. "<CR>"
end

require("which-key").add({
  { prefix("b"),  group = "Buffers", },
  { prefix("bn"), command("BufferNext"),     desc = "Next Buffer", },
  { prefix("bN"), command("BufferPrevious"), desc = "Previous Buffer", },
  { prefix("bd"), command("BufferClose"),    desc = "Close Buffer" },
  { prefix("m"),  group = "Mode",            expand = function()
    return require("feature.lsp").get_lsp_mode_keybinds()
  end }
})
