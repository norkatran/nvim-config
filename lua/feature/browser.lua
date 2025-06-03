local prefix_symbol = "@"
local google = "https://www.google.com/search?q=%s"
local jira = vim.env.JIRA_DOMAIN and (vim.env.JIRA_DOMAIN .. "/browse/%s") or nil
local wikipedia = "https://en.wikipedia.org/w/index.php?search=%s"
local gitlab = "https://gitlab.corp.friendmts.com/search?search=%s"
local config = {
  default = "google",
  ["query-map"] = {
    g = {google, "google"},
    w = {wikipedia, "wikipedia"},
    gl = {gitlab, "gitlab"}
  }
}
if jira then
  config["query-map"].j = {jira, "jira"};
end
local function url_3f(input)
  return (input:match("[%w%.%-_]+%.[%w%.%-_/]+") ~= nil)
end
local function extract_prefix(input)
  local pat = (prefix_symbol .. "(%w+)")
  local prefix = input:match(pat)
  if (not prefix or not config["query-map"][prefix]) then
    return {vim.trim(input), config.default}
  else
    local query = input:gsub(("@" .. prefix), "")
    return {vim.trim(query), prefix}
  end
end
local function query_browser(input)
  local q = nil
  local extraction = extract_prefix(input)
  local q2 = extraction[1]
  local prefix = extraction[2]
  if not url_3f(input) then
    local format = config["query-map"][prefix][1]
    q = format:format(vim.uri_encode(q2))
  else
    q = q2
  end
  vim.notify(("Opening url " .. q), vim.log.levels.DEBUG)
  return vim.ui.open(q)
end
local function get_domain(url)
  return print(url)
end
local function create_config_key()
  local keys = {}
  for prefix, url in pairs(config["query-map"]) do
    table.insert(keys, prefix_symbol .. prefix .. " - " .. url[2])
  end
  return keys
end
local ui = require("ui")
local function _3_()
  local function _4_(input)
    if (#vim.trim(input) > 0) then
      return query_browser(input)
    else
      return nil
    end
  end
  return ui["create_input"]("Browser", _4_, { desc = create_config_key(), height = 10 })
end
return require("which-key").add({{"<leader><leader>b", _3_, desc = "Open Browser"}})
