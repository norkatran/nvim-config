[{1 :ggandor/leap.nvim
  :dependencies [:tpope/vim-repeat]
  :config (fn []
            (let [leap (require :leap)
                  user (require :leap.user)]
              (do
                ((. leap :set_default_mappings))
                (tset leap.opts :equivalence_classes
                      [" \t\r\n" "([{" ")]}" "'\"`"])
                ((. user :set_repeat_keys) :<enter> :<backspace>))))}]
