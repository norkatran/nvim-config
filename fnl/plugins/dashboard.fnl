{1 :folke/snacks.nvim
 :opts (fn []
         (local nvit (require :nvit))
         (local glab (require :nvit.glab))
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
                                      {:action (fn [] (nvit.view_repos))
                                       :desc "Git Repos"
                                       :icon " "
                                       :key :g}
                                      {:action (fn [] (nvit.view_branches))
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
                                 {:action nvit.view_merge_requests
                                  :cmd "glab api graphql -f query=' query { root: currentUser { MRs: assignedMergeRequests(state: opened) { nodes { project { name }, title, state } } } }' | jq -r '.data.root.MRs.nodes | .[] | [.project.name, .title, .state] | @tsv' | grep -n ' ' | cut -c 3-55"
                                  :enabled glab.is_gitlab_repo
                                  :height 5
                                  :key :m
                                  :padding 1
                                  :pane 2
                                  :section :terminal
                                  :title "Oustanding MRs"
                                  :ttl 60}
                                 {:action nvit.view_reviews
                                  :cmd "glab api graphql -f query=' query { root: currentUser { Issues: reviewRequestedMergeRequests(state: opened) { nodes { project { name }, title, state } } } }' | jq -r '.data.root.Issues.nodes | .[] | [.project.name, .title, .state] | @tsv' | grep -n ' ' | cut -c 3-55"
                                  :enabled glab.is_gitlab_repo
                                  :height 5
                                  :key :r
                                  :padding 1
                                  :pane 2
                                  :section :terminal
                                  :title "Oustanding Reviews"
                                  :ttl 60}
                                 {:action nvit.view_notifications
                                  :cmd "glab api graphql -f query=' query { root: currentUser { ToDos: todos(state: pending) { nodes { action, body } } } }' | jq -r '.data.root.ToDos.nodes | .[] | [.action, .body] | @tsv' | grep -n ' ' | cut -c 3-55"
                                  :enabled glab.is_gitlab_repo
                                  :height 5
                                  :key :n
                                  :padding 1
                                  :pane 2
                                  :section :terminal
                                  :title :Notifications
                                  :ttl 60}
                                 {:section :startup}]}})}
