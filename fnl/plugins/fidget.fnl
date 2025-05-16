[{1 :j-hui/fidget.nvim
  :dependencies [:folke/which-key.nvim :nvim-telescope/telescope.nvim]
  :opts {:notification {:override_vim_notify true}}
  :config (fn []
            ((. (require :fidget) :setup) {:notification {:override_vim_notify true}}))}]
