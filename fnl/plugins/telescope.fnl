[{1 :nvim-telescope/telescope.nvim
  :dependencies [:nvim-lua/plenary.nvim
                 {1 :nvim-telescope/telescope-fzf-native.nvim :build :make}
                 :nvim-treesitter/nvim-treesitter
                 :nvim-tree/nvim-web-devicons]
  :config (fn []
            (do
              ((. (require :telescope) :setup) {:defaults {:prompt_prefix "/"
                                                           :mappings {:i {:<esc> (. (require :telescope.actions)
                                                                                    :close)}}}
                                                :extensions {:fzf {}}})))}]
