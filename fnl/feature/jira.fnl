(local USER vim.env.JIRA_USER)
(local URL vim.env.JIRA_API)

(local cache (require :cache))
(local cache-file :jira.json)
(local state {:issues [] :ids {}})

(local {: map : without : insert-at : pad-truncate : background-process}
       (require :utils))

(fn parse-issue [json]
  (let [obj (vim.json.decode json)
        {: names : fields} obj]
    {:summary fields.summary
     :description fields.description
     :status fields.status.name
     :key obj.key
     :id obj.id
     :due-date obj.fields.duedate}))

(fn curl [resource id cb?]
  (let [cmd [:curl (.. URL resource "/" id) :--user USER]]
    (background-process cmd {:silent true :on-success (or cb? nil)})))

(fn task-list []
  ((. (require :ui) :create-pin) :Jira
                                 (fn [width]
                                   (let [key-width 8
                                         due-date-width 8
                                         status-width 12
                                         summary-width (- width key-width
                                                          due-date-width
                                                          status-width 8)]
                                     (map state.issues
                                          (fn [i]
                                            (.. (pad-truncate i.key key-width)
                                                " | "
                                                (pad-truncate i.summary
                                                              summary-width)
                                                " | "
                                                (pad-truncate (or (?. i :status)
                                                                  "")
                                                              status-width)
                                                " | "
                                                (pad-truncate (.. " "
                                                                  (vim.trim (. (: (vim.system [:date
                                                                                               :-j
                                                                                               :-f
                                                                                               "%Y-%m-%d"
                                                                                               i.due-date
                                                                                               "+%b %d"])
                                                                                  :wait)
                                                                               :stdout)))
                                                              due-date-width))))))))

(fn issue-input [on-submit]
  ((. (require :ui) :create-input) :Issue
                                   (fn [key]
                                     (-> (curl :issue key
                                               (fn [stdout]
                                                 (-> stdout (parse-issue)
                                                     (on-submit))
                                                 (task-list)))))))

(fn drop-issue [issue]
  (if (not (?. state.ids issue.id)) nil
      (do
        (tset state.ids issue.id nil)
        (tset state :issues
              (without state.issues (fn [i] (not= i.id issue.id)))))))

(fn drop-issue-input []
  (issue-input drop-issue))

(fn start-issue []
  (issue-input (fn [issue]
                 (when (not (?. state.ids issue.id))
                   (tset state :issues (insert-at state.issues issue 1))
                   (tset state.ids issue.id true))
                 (vim.cmd (.. "silent exec \"!kitten @ set-window-title '"
                              (vim.fs.basename (vim.fs.dirname (vim.uv.cwd)))
                              ": " issue.key " -> " issue.summary "'\"")))))

(fn list-issues []
  (let [items (if (> (length state.issues) 0)
                  (map state.issues
                       (fn [issue]
                         (let [out {:id issue.id
                                    :text (.. issue.key " -> " issue.summary)
                                    : issue}]
                           out)))
                  [])]
    ((. (require :ui) :create-menu) :tasks items
                                    {:desc ["Currently stored issues"]
                                     :mappings [{1 :<C-d>
                                                 2 (fn [node]
                                                     (drop-issue node.issue)
                                                     (task-list))
                                                 :desc "Drop Issue"}]})))

((. (require :which-key) :add) [{1 :<leader><leader>j :group :Jira}
                                {1 :<leader><leader>js
                                 2 start-issue
                                 :desc "Start Issue"}
                                {1 :<leader><leader>jd
                                 2 drop-issue-input
                                 :desc "Drop Issue"}
                                {1 :<leader><leader>j<leader>
                                 2 list-issues
                                 :desc "List Current Issues"}])
