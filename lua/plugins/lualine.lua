local spotify = require("feature.spotify")
return {
  {
    "nvim-lualine/lualine.nvim",
    config = function ()
    return require("lualine").setup( {
      theme = "powerline_dark",
      sections = {
        lualine_a = {"mode", spotify.get_spotify_status},
        lualine_b = {"branch", "diff", "diagnostics"},
        lualine_c = {"filename"}
      }
    })
    end
  },
}
