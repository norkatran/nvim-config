(local {: background-process} (require :utils))
(local {: create-menu : create-input} (require :ui))
(local {: repo-paths} (require :secret))
(local REPO-CHANGED :repo-change)
(local CURRENT-BRANCH-DELETED :current-branch-deleted)

(fn is-worktree? [repo]
  (let [path (or repo (Snacks.git.get_root))]
    (= (length (vim.fn.glob (.. path :/.git/*))) 0)))

(fn change-path [path]
  (vim.cmd (.. "cd " path))
  (vim.api.nvim_exec_autocmds REPO-CHANGED))

(fn setup-branch [path branch]
  (background-process [:git :push :--set-upstream :origin branch] {:cwd path})
  (let [npm? (> (length (vim.fn.glob (vim.fs.joinpath path :package.json))) 0)
        composer? (> (length (vim.fn.glob (vim.fs.joinpath path :composer.json)))
                     0)
        state {}
        state-finished? (fn [callback]
                          (var finished? true)
                          (when (and npm? (not state.npm))
                            (set finished? false))
                          (when (and composer? (not state.composer))
                            (set finished? false))
                          (when finished? (callback)))]
    (when npm?
      (background-process [:npm :ci]
                          {:cwd path
                           :on-success (fn []
                                         (tset state :npm true)
                                         (state-finished? (fn []
                                                            (change-path path))))}))
    (when composer?
      (background-process [:composer :install]
                          {:cwd path
                           :on-success (fn []
                                         (tset state :composer true)
                                         (state-finished? (fn []
                                                            (change-path path))))}))
    (when (and (not (composer?)) (not (npm?)))
      (change-path path))))

(fn checkout-repo-branch [repo branch]
  (vim.notify (.. "Checking out branch " branch "@" repo))
  (if (is-worktree? repo)
      (background-process [:git
                           :worktree
                           :add
                           :--track
                           :-b
                           branch
                           branch
                           (.. :origin/ branch)]
                          {:cwd repo
                           :on-success (fn []
                                         (setup-branch (vim.fs.joinpath repo
                                                                        branch)))})
      (background-process [:git :checkout branch]
                          {:cwd repo :on-sucess (fn [] (setup-branch repo))})))

(fn create-branch [repo branch]
  (vim.notify (.. "Creating branch " branch "@" repo))
  (if (is-worktree? repo)
      (background-process [:git :worktree :add branch]
                          {:cwd repo
                           :on-success (fn []
                                         (setup-branch (vim.fs.joinpath repo
                                                                        branch)))})
      (background-process [:git :checkout :-b branch]
                          {:cwd repo :on-success (fn [] (setup-branch repo))})))

(fn is-current-branch? [repo branch]
  (let [cwd (vim.uv.cwd)]
    (if (and (not= cwd repo) (not= (string.sub cwd 1 (length repo)) repo))
        false
        (let [current-branch (. (: (vim.system [:git :branch :--show-current])
                                   :wait)
                                :stdout)]
          (if (= (string.sub current-branch 1 -2) branch) true false)))))

(fn delete-branch [repo branch]
  (let [is-current-branch (is-current-branch? repo branch)]
    (if (is-worktree? repo)
        (background-process [:git :worktree :remove branch] {:cwd repo})
        (background-process [:git :branch :-D branch] {:cwd repo}))
    (when is-current-branch
      (vim.api.nvim_exec_autocmds CURRENT-BRANCH-DELETED))))

(fn render-branches [repo stdout]
  (let [branches (vim.split stdout "\n")
        items []]
    (each [_ b (pairs branches)]
      (let [branch (string.sub b 3 -1)]
        (table.insert items
                      {:text branch
                       :action (fn [] (checkout-repo-branch repo branch))})))
    (create-menu "Select Branch" items
                 {:mappings [{1 :<C-n>
                              2 (fn []
                                  (create-input "New Branch"
                                                (fn [branch]
                                                  (create-branch repo branch))))
                              :desc "Create Branch"}
                             {1 :<C-D>
                              2 (fn [branch] (delete-branch repo branch))
                              :desc "Delete Branch"}]})))

(fn view-branches [?repo]
  (let [repo (or ?repo (vim.uv.cwd))]
    (background-process [:git :--no-pager :branch :--no-color]
                        {:cwd repo
                         :on-success (fn [stdout] (render-branches repo stdout))})))

(fn view-repos []
  (let [menu-items []
        only-path (= (length repo-paths) 1)]
    (each [_ r (pairs repo-paths)]
      (let [prefix (if only-path (.. r "/") "")
            paths (vim.split (vim.fn.glob (.. r "/*")) "\n")]
        (each [_ p (pairs paths)]
          (table.insert menu-items
                        {:text (.. prefix p) :action (fn [] (view-branches p))}))))
    (when (= (length menu-items) 0)
      (table.insert menu-items {:text "No Repos Found" :separator true}))
    (create-menu "Select Repository" menu-items)))

((. (require :which-key) :add) [{1 :<leader>g :group :Git}
                                {1 :<leader>gr 2 view-repos :desc "Git Repos"}
                                {1 :<leader>gb
                                 2 view-branches
                                 :desc "Git Branches"}])

(vim.cmd (.. "autocmd User " CURRENT-BRANCH-DELETED
             " :Fnl ((. (require :feature.git) :view-branches))"))

(vim.cmd (.. "autocmd User " REPO-CHANGED
             " :Fnl (do (vim.cmd \"%bd!\") (Snacks.dashboard.open) (Snacks.dashboard.update))"))

{: view-repos : view-branches : REPO-CHANGED : CURRENT-BRANCH-DELETED}
