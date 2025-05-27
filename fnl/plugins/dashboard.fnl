(macro gitlab-defer! [function#]
  `(fn []
     (. (require :feature.gitlab) ,function#)))

(macro gitlab-call! [function#]
  `(fn []
     ((. (require :feature.gitlab) ,function#))))

{1 :folke/snacks.nvim
 :opts (fn []
         {:dashboard {:preset {:header " Marnie - NVIM "
                               :keys [{:action ":lua Snacks.dashboard.pick('files')"
                                       :desc "Find File"
                                       :icon " "
                                       :key :f}
                                      {:action ":Neotree position=float"
                                       :desc :Dir
                                       :icon " "
                                       :key :d}
                                      {:action ":lua Snacks.dashboard.pick('live_grep')"
                                       :desc "Find Text"
                                       :icon " "
                                       :key "/"}
                                      {:action ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})"
                                       :desc :Config
                                       :icon " "
                                       :key :c}
                                      {:action (fn []
                                                 ((. (require :feature.git)
                                                     :view-repos)))
                                       :desc "Git Repos"
                                       :icon " "
                                       :key :g}
                                      {:action (fn []
                                                 ((. (require :feature.git)
                                                     :view-branches)))
                                       :desc "Git Branches"
                                       :icon " "
                                       :key :b}
                                      {:action ":Lazy"
                                       :desc :Lazy
                                       :icon "󰒲 "
                                       :key :l}
                                      {:action ":qa"
                                       :desc :Quit
                                       :icon " "
                                       :key :q}]}
                      :sections [{:section :header}
                                 {:cmd :date
                                  :height 1
                                  :padding 1
                                  :pane 2
                                  :section :terminal
                                  :ttl 0}
                                 {:gap 1 :padding 1 :section :keys}
                                 {:action ":Telescope git_status"
                                  :cmd "git status --short --branch --renames"
                                  :enabled (fn []
                                             (not= (Snacks.git.get_root) nil))
                                  :height 5
                                  :icon " "
                                  :indent 3
                                  :key :s
                                  :padding 1
                                  :pane 2
                                  :section :terminal
                                  :title "Unstaged Files"
                                  :ttl 0}
                                 {:section :startup}]}})}
