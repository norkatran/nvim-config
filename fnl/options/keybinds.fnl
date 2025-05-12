(   macro cmd! [x] (.. :<Cmd> x :<CR>))
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

(local bindings [(leader! [:<leader>
                           (module-call! :telescope.builtin :find_files)
                           {:desc "Browse Files"}])
                 (leader! ["/"
                           (module-call! :telescope.builtin :live_grep)
                           {:desc "Live Grep"}])
                 (leader! ["?"
                           (module-call! :telescope.builtin :keymaps)
                           {:desc :Keymaps}])
                 (leader! [:y "\"+y" {:desc :Copy :mode [:n :v]}])
                 (leader! [:Y "\"+yg_" {:desc "Copy (EOL)" :mode [:n :v]}])
                 (leader-group! :config
                                [[:p
                                  (module-call! :telescope.builtin :find_files
                                                {:cwd (vim.fs.joinpath (vim.fn.stdpath :data)
                                                                       :lazy)})
                                  {:desc "Browse Packages"}]
                                 [:<leader>
                                  (module-call! :telescope.builtin :find_files
                                                {:cwd (vim.fn.stdpath :config)})
                                  {:desc "Browse Config"}]])
                 (leader-group! :window
                                [[:h (wincmd! :h) {:desc "Window Left"}]
                                 [:j (wincmd! :j) {:desc "Window Down"}]
                                 [:k (wincmd! :k) {:desc "Window Up"}]
                                 [:l (wincmd! :l) {:desc "Window Right"}]]
                                :w)
                 (leader-group! :git
                                [[:r
                                  (module-call! :nvit :view_repos)
                                  {:desc "Git Repos"}]
                                 [:b
                                  (module-call! :nvit :view_branches)
                                  {:desc "Git Branches"}]
                                 [:f
                                  (module-call! :telescope.builtin :git_files)
                                  {:desc "Git Files"}]
                                 [:s
                                  (module-call! :telescope-builtin :git_status)
                                  {:desc "Git Status"}]
                                 [:S
                                  (module-call! :telescope-builtin :git_stash)
                                  {:desc "Git Stashes"}]])
                 (leader-group! :gitlab
                                [[:m
                                  (module-call! :nvit :view_merge_requests)
                                  {:desc "Merge Requests"}]
                                 [:r
                                  (module-call! :nvit :view_reviews)
                                  {:desc "Review Requests"}]
                                 [:n
                                  (module-call! :nvit :view_notifications)
                                  {:desc :Notifications}]]
                                :gl)
                 ;; oh god i hate this line
                 (leader! [:n
                           (fn []
                             (: (. (. (require :telescope) :extensions) :fidget)
                                :fidget))
                           {:desc :Notifications}])
                 (leader-group! :workbook
                                [[:s
                                  (module-call! :feature.workbook :workbook)
                                  {:desc "Open workbook"}]
                                 ["/"
                                  (module-call! :feature.workbook
                                                :grep-workbooks)
                                  {:desc "Grep workbooks"}]
                                 [:<leader>
                                  (module-call! :feature.workbook
                                                :view-workbooks)
                                  {:desc "View workbooks"}]]
                                :wo)
                 (leader-group! :help
                                [[:t
                                  (module-call! :telescope.builtin :help_tags)
                                  {:desc "Help Tags"}]])
                 (leader-group! :buffers
                                [[:b
                                  (cmd! "Telescope buffers")
                                  {:desc "View Buffers"}]
                                 [:n (cmd! :BufferNext) {:desc "Next Buffer"}]
                                 [:N
                                  (cmd! "Buffer Previous")
                                  {:desc "Previous Buffer"}]
                                 [:p (cmd! :BufferPick) {:desc "Pick Buffer"}]
                                 [:d
                                  (cmd! :BufferClose)
                                  {:desc "Close Buffer"}]])
                 ;;(leader-group! :mode [
                 ;;[:f (module-call! :mode :format) {:desc :Format}]
                 ;;])
                 (leader! [:r
                           (cmd! "Telescope registers")
                           {:desc "View Registers"}])
                 (leader! [:f
                           (cmd! "Neotree position=float")
                           {:desc "View Directory"}])
                 (leader! ["%"
                           ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>"
                           {:desc "Find/Replace symbol"}])])

(local mappings [])
(fn add-mapping [binding]
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

(each [_ binding (pairs bindings)] (add-mapping binding))

(table.insert mappings
              {1 :<leader>m :group :mode :expand (module-call! :mode :expand)})

(do
  ((. (require :which-key) :add) mappings))
