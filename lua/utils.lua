local M = {}

M.map = function (arr, cb)
  local out = {}
  for k, v in pairs(arr) do
    table.insert(out, cb(v, k))
  end
  return out
end

M.without = function (arr, item)
  local out = {}
  for k, v in ipairs(arr) do
    if type(item) == "function" then
      if not item(v, k) then
        table.insert(out, v)
      end
    else
      if item ~= v then
        table.insert(out, v)
      end
    end
  end
  return out
end

M.str_repeat = function (str, times)
  local out = {}
  for _ = 1, times, 1 do
    table.insert(out, str)
  end
  return table.concat(out)
end

M.truncate = function (str, len)
  if #str > len then
    return string.sub(str, 1, len - 2) .. ".."
  end
  return str
end

M.pad_or_truncate = function (str, len)
  if #str < len then
    return str .. M.str_repeat(" ", len - #str)
  elseif #str > len then
    return M.truncate(str, len)
  end
  return str
end

local state = { processes = {} }
local function render_processes ()
  require("ui").create_pin("Processes", function (width)
    M.map(state.processes, function (p)
      if type(p) == "string" then
        return M.pad_or_truncate(p, width)
      end
      M.pad_or_truncate(table.concat(p, " "), width)
    end)
  end)
end

M.background_process = function (process, options)
  local on_success = options.on_success or nil
  local cwd = options.cwd or nil
  local silent = options.silent or nil
  local sync = options.sync or nil
  local callback = function (out)
    if not sync then
      state.processes = M.without(state.processes, process)
      render_processes()
    end
    if out.code == 0 then
      if on_success then
        on_success(out.stdout)
      end
      if not silent then
        vim.notify("Finished running cmd: " .. table.concat(process, " "), vim.log.levels.INFO)
      end
    else
      vim.notify("Process " .. (silent and M.truncate(table.concat(process, " "), 20) or "") .. " returned error code: " .. tostring(out.code))
    end
  end
  if sync then
    local proc = vim.system(process)
    local out = proc:wait()
    callback(out)
    return
  end
  table.insert(state.processes, process)
  render_processes()
  vim.system(process, {}, function (out)
    vim.schedule(function ()
      callback(out)
    end)
  end)
end

M.merge = function (obj, obj2)
  for key, value in pairs(obj2) do
    obj[key] = value
  end
  return obj
end

return M
