local _local_1_ = require("utils")
local background_process = _local_1_["background_process"]
local function to_list(output, formatter)
  local list = {}
  for _, item in ipairs(vim.fn.split(output, "\n")) do
    table.insert(list, formatter(vim.json.decode(item)))
  end
  return list
end
local function get_images(callback)
  local function _2_(images)
    local function _3_(image)
      local repo = image["Repository"]
      local id = image["ID"]
      return {text = repo, repo = repo, id = id}
    end
    return callback(to_list(images, _3_))
  end
  return background_process({"docker", "images", "--format", "json"}, {["on_success"] = _2_})
end
local function get_containers(callback)
  local function _4_(containers)
    local function _5_(container)
      local id = container["ID"]
      local image = container["Image"]
      local state = container["State"]
      local _6_
      if (state == "running") then
        _6_ = "* "
      else
        _6_ = "  "
      end
      return {text = (_6_ .. image), image = image, id = id}
    end
    return callback(to_list(containers, _5_))
  end
  return background_process({"docker", "container", "ls", "--format", "json"}, {["on_success"] = _4_})
end
local function delete_image(image)
  return background_process({"docker", "image", "rm", "-f", image.id})
end
local function docker_purge()
  local function _8_()
    return background_process({"docker", "volume", "prune", "-f"})
  end
  return background_process({"docker", "system", "prune", "-af"}, {["on_success"] = _8_})
end
local function list_images()
  local ui = require("ui")
  local function _9_(images)
    return ui["create-menu"]("Docker Images", images, {desc = "Currently available Docker Images", mappings = {{"<C-d>", delete_image, desc = "Delete image"}, {"<C-a><C-k>", docker_purge, desc = "Purge docker"}}})
  end
  return get_images(_9_)
end
local function launch_kitty(cmd, _3ftype)
  local launchtype = (_3ftype or "tab")
  local args = {"kitty", "@", "launch", "--type", launchtype, "--cwd", vim.uv.cwd(), "/opt/homebrew/bin/fish", "-c", ("'" .. cmd .. "'")}
  vim.cmd((":silent exec \"!" .. table.concat(args, " ") .. "\""))
  return vim.notify(("Opened kitty " .. launchtype .. " running " .. cmd))
end
local function shell_into_container(container)
  return launch_kitty(("docker container attach " .. container.id), "os-window")
end
local function stop_container(container)
  return background_process({"docker", "container", "stop", container.id})
end
local function container_command(cmd)
  local function _10_(container)
    return background_process({"docker", "container", cmd, container.id})
  end
  return _10_
end
local function list_containers()
  local ui = require("ui")
  local function _11_(containers)
    return ui["create_menu"]("Docker Containers", containers, {desc = {"Docker Containers", "* denotes a running container"}, mappings = {{"<C-s>", shell_into_container, desc = "Shell into"}, {"<C-d>", container_command("stop"), desc = "Down"}}})
  end
  return get_containers(_11_)
end
local function docker_compose(cmd, opts)
  local profile_3f
  do
    local t_12_ = opts
    if (nil ~= t_12_) then
      t_12_ = t_12_.profile
    else
    end
    profile_3f = t_12_
  end
  local service_3f
  do
    local t_14_ = opts
    if (nil ~= t_14_) then
      t_14_ = t_14_.service
    else
    end
    service_3f = t_14_
  end
  local external_3f
  do
    local t_16_ = opts
    if (nil ~= t_16_) then
      t_16_ = t_16_.external
    else
    end
    external_3f = t_16_
  end
  local args
  local _19_
  do
    local t_18_ = opts
    if (nil ~= t_18_) then
      t_18_ = t_18_.args
    else
    end
    _19_ = t_18_
  end
  args = (_19_ or {})
  local state = {}
  local get_profile
  local function _21_(_3fcb)
    local function _22_(x)
      if (x ~= "") then
        state["profile"] = ("--profile=" .. x)
      else
      end
      if _3fcb then
        return _3fcb()
      else
        return nil
      end
    end
    return require("ui")["create_input"]("--profile", _22_)
  end
  get_profile = _21_
  local get_service
  local function _25_(_3fcb)
    local function _26_(x)
      state["service"] = x
      if _3fcb then
        return _3fcb()
      else
        return nil
      end
    end
    return require("ui")["create_input"]("Service", _26_)
  end
  get_service = _25_
  local run_cmd
  local function _28_()
    local dc = {"docker", "compose"}
    local _30_
    do
      local t_29_ = state
      if (nil ~= t_29_) then
        t_29_ = t_29_.profile
      else
      end
      _30_ = t_29_
    end
    if _30_ then
      table.insert(dc, state.profile)
    else
    end
    table.insert(dc, cmd)
    for _, arg in ipairs(args) do
      table.insert(dc, arg)
    end
    local _34_
    do
      local t_33_ = state
      if (nil ~= t_33_) then
        t_33_ = t_33_.service
      else
      end
      _34_ = t_33_
    end
    if _34_ then
      table.insert(dc, state.service)
    else
    end
    if external_3f then
      return launch_kitty(table.concat(dc, " "), (opts.type or "os-window"))
    else
      return background_process(dc)
    end
  end
  run_cmd = _28_
  if ((_G.type(opts) == "table") and (opts.service == true) and (opts.profile == true)) then
    local function _38_()
      local function _39_()
        return run_cmd()
      end
      return get_service(_39_)
    end
    return get_profile(_38_)
  elseif ((_G.type(opts) == "table") and (opts.service == true)) then
    local function _40_()
      return run_cmd()
    end
    return get_service(_40_)
  elseif ((_G.type(opts) == "table") and (opts.profile == true)) then
    local function _41_()
      return run_cmd()
    end
    return get_profile(_41_)
  else
    local _ = opts
    return run_cmd()
  end
end
local group
local function _43_(_3fk)
  local _44_
  if (_3fk ~= nil) then
    _44_ = _3fk
  else
    _44_ = ""
  end
  return ("<leader><leader>d" .. _44_)
end
group = _43_
local function _46_()
  return docker_compose("up", {profile = true, args = {"-d"}})
end
local function _47_()
  return docker_compose("run", {profile = true, service = true, external = "os-window"})
end
local function _48_()
  return docker_compose("down", {profile = true})
end
local function _49_()
  return docker_compose("attach", {profile = true, service = true})
end
vim.notify("BLAH")
print("BLAH")
return require("which-key").add({{group(), group = "Docker"}, {group("i"), list_images, desc = "Images"}, {group("<leader>"), list_containers, desc = "Containers"}, {group("c"), group = "Compose"}, {group("cu"), _46_, desc = "Up"}, {group("cR"), _47_, desc = "Run (Choose service)"}, {group("cd"), _48_, desc = "Down"}, {group("cA"), _49_, desc = "Attach (Choose Service"}})
