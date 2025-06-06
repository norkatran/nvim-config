local spotify = require("feature.spotify")
local gitlab = require("feature.gitlab")
return {
  {
    "nvim-lualine/lualine.nvim",
    config = function ()
    return require("lualine").setup( {
      theme = "powerline_dark",
      sections = {
        lualine_a = {"mode", spotify.get_spotify_status},
        lualine_b = {"branch", "diff", "diagnostics"},
        lualine_c = {"filename"},

        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {gitlab.statusline, 'location'}
      }
    })
    end
  },
}
