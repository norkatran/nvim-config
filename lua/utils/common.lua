-- utils/common.lua
-- common functionality

local M = {}

M.merge_tables = function (input)
  local out = {}
  for _, tbl in pairs(input) do
    for _, item in pairs(tbl) do
      table.insert(out, item)
    end
  end
  return out
end

M.string_split = function (s, delimiter, prefix)
    local result = { '' };
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, (prefix or '') .. match);
    end
    return result;
end

return M
