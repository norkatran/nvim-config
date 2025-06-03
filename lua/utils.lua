local M = {}

-- Map function to transform array elements
M.map = function (arr, callback)
  local result = {}
  for k, v in pairs(arr) do
    table.insert(result, callback(v, k))
  end
  return result
end

-- Filter items from an array
M.without = function (arr, item)
  local result = {}
  for k, v in ipairs(arr) do
    if type(item) == "function" then
      if not item(v, k) then
        table.insert(result, v)
      end
    else
      if item ~= v then
        table.insert(result, v)
      end
    end
  end
  return result
end

-- Repeat a string multiple times
M.str_repeat = function (str, times)
  local result = {}
  for _ = 1, times, 1 do
    table.insert(result, str)
  end
  return table.concat(result)
end

-- Truncate a string to specified length
M.truncate = function (str, len)
  if #str > len then
    return string.sub(str, 1, len - 2) .. ".."
  end
  return str
end

-- Pad or truncate a string to exact length
M.pad_or_truncate = function (str, len)
  if #str < len then
    return str .. M.str_repeat(" ", len - #str)
  elseif #str > len then
    return M.truncate(str, len)
  end
  return str
end

-- Process management state
local state = { processes = {} }

-- Render active processes in UI
local function render_processes()
  require("ui").create_pin("Processes", function (width)
    return M.map(state.processes, function (p)
      if type(p) == "string" then
        return M.pad_or_truncate(p, width)
      end
      return M.pad_or_truncate(table.concat(p, " "), width)
    end)
  end)
end

-- Run a process in the background
M.background_process = function (process, options)
  options = options or {}
  local on_success = options.on_success or nil
  local cwd = options.cwd or nil
  local silent = options.silent or nil
  local sync = options.sync or nil
  
  local function handle_process_completion(out)
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
    handle_process_completion(out)
    return
  end
  
  table.insert(state.processes, process)
  render_processes()
  vim.system(process, {}, function (out)
    vim.schedule(function ()
      handle_process_completion(out)
    end)
  end)
end

-- Merge two tables
M.merge = function (obj, obj2)
  for key, value in pairs(obj2) do
    obj[key] = value
  end
  return obj
end

-- Insert an item at a specific index in an array
M.insert_at = function (arr, item, idx)
  table.insert(arr, idx, item)
  return arr
end

return M
