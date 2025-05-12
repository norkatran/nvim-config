[{1 :nvim-treesitter/nvim-treesitter
  :build ":TSUpdate"
  :config (fn []
            {:ensure_installed [:lua :fennel :vim :markdown :php :typescript]
             :auto_install true
             :highlight {:enable true :additional_vim_regex_highlighting true}})}]
