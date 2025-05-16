(macro cmd! [x] (.. :<Cmd> x :<CR>))

(macro wincmd! [x]
  `(fn [] (vim.cmd.wincmd ,x)))

(macro module-call! [module method args]
  `(fn []
     ((. (require ,module) ,method) (if ,args ,args {}))))

(macro leader! [binding]
  (let [(k1# c1# a1#) (unpack binding)]
    [(.. :<leader> k1#) c1# a1#]))

(macro leader-group! [group# bindings# ?shortcut#]
  (let [mnemonic# (if ?shortcut# ?shortcut# (string.sub group# 1 1))
        expansions# []
        grouping# [(.. :<leader> mnemonic#)
                   ""
                   {:group group# :expansions expansions#}]]
    (each [_ v# (pairs bindings#)]
      (let [(k2# c2# a2#) (unpack v#)]
        (table.insert expansions# [(.. :<leader> mnemonic# k2#) c2# a2#])))
    grouping#))

(fn add-mapping [mappings binding]
  (case binding
    (where [key _ opts] (?. opts :expansions)) (do
                                                 (table.insert mappings
                                                               (doto {}
                                                                 (tset 1 key)
                                                                 (tset :group
                                                                       (. opts
                                                                          :group))))
                                                 (each [_ binding2 (pairs (. opts
                                                                             :expansions))]
                                                   (add-mapping binding2)))
    [key callback opts] (table.insert mappings
                                      (do
                                        (tset opts 1 key)
                                        (tset opts 2 callback)
                                        opts))))

(fn add-mappings [mappings bindings]
  (each [_ binding (pairs bindings)] (add-mapping mappings binding)))

[{1 :folke/which-key.nvim
  :event :VeryLazy
  :config (fn []
            (let [whichkey (require :which-key)]
              (do
                ((. whichkey :setup) {:preset :modern
                                      :filter (fn [m]
                                                (let [desc (?. m :desc)]
                                                  (and desc)
                                                  (not= desc "Dashboard action")))})
                ((. whichkey :add) [{1 :<leader>w :group :Window}
                                    {1 :<leader>wh
                                     2 (wincmd! :h)
                                     :desc "Window Left"}
                                    {1 :<leader>wj
                                     2 (wincmd! :j)
                                     :desc "Window Down"}
                                    {1 :<leader>wk
                                     2 (wincmd! :k)
                                     :desc "Window Up"}
                                    {1 :<leader>wl
                                     2 (wincmd! :l)
                                     :desc "Window Right"}
                                    {1 :<leader>wh
                                     2 (wincmd! :h)
                                     :desc "Window Left"}
                                    {1 :<leader>y
                                     2 "\"+y"
                                     :desc :Copy
                                     :mode [:n :v]}
                                    {1 :<leader>Y
                                     2 "\"+yg_"
                                     :desc "Copy (EOL)"
                                     :mode [:n :v]}]
                                   {1 "<leader>%"
                                    2 ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>"
                                    :desc "Replace Symbol"}
                                   {1 :<leader>c :group :Config}
                                   {1 :<leader>cs
                                    2 "<Cmd>source %<CR>"
                                    :desc "Source File"}))))}]
