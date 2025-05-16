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

(local bindings [(leader-group! :git
                                [[:r
                                  (module-call! :nvit :view_repos)
                                  {:desc "Git Repos"}]
                                 [:b
                                  (module-call! :nvit :view_branches)
                                  {:desc "Git Branches"}]])
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
                 (leader-group! :buffers
                                [;;[:b
                                 ;;(cmd! "Telescope buffers")
                                 ;;{:desc "View Buffers"}]
                                 [:n (cmd! :BufferNext) {:desc "Next Buffer"}]
                                 [:N
                                  (cmd! "Buffer Previous")
                                  {:desc "Previous Buffer"}]
                                 [:p (cmd! :BufferPick) {:desc "Pick Buffer"}]
                                 [:d
                                  (cmd! :BufferClose)
                                  {:desc "Close Buffer"}]])])

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
