(local {: vpn-pattern : gitlab-domain} (require :secret))
(local {: background-process : map} (require :utils))
(local {: create-menu} (require :ui))
(local cache (require :cache))
(local cache-file :gitlab.json)

(local state {})

(local expired? (partial cache.expired? cache-file))
(local read (partial cache.read cache-file))
(local write (partial cache.write cache-file))

(fn is-vpn? []
  (var out false)
  (background-process [:ifconfig]
                      {:on-success (fn [stdout]
                                     (let [connected? (not= (string.find stdout
                                                                         vpn-pattern)
                                                            nil)]
                                       (when connected?
                                         (set out true))))
                       :sync true
                       :silent true})
  out)

(fn is-gitlab-repo? []
  (var out false)
  (background-process [:git :remote :get-url :origin]
                      {:on-success (fn [stdout]
                                     (let [gitlab-repo? (not= (string.find stdout
                                                                           gitlab-domain)
                                                              nil)]
                                       (when gitlab-repo?
                                         (set out true))))
                       :sync true
                       :silent true})
  out)

(fn setup-gitlab! []
  (case state.gitlab
    true true
    false false
    _ (tset state :gitlab (and (is-gitlab-repo?) (is-vpn?))))
  state.gitlab)

(when (not (?. state :gitlab)) (setup-gitlab!))

(fn format-merge-requests [merge-requests]
  (map merge-requests
       (fn [merge-request]
         {:text (.. merge-request.project.name ": " merge-request.title)
          :actionUrl merge-request.webUrl})))

(fn format-reviews [reviews]
  (map reviews (fn [review]
                 {:text (.. review.project.name ": " review.title)
                  :actionUrl review.webUrl})))

(fn format-notifications [notifications]
  (map notifications
       (fn [notification]
         {:text (.. notification.action ": " notification.body)
          :actionUrl notification.targetUrl})))

(fn call-glab [?callback]
  (let [mrs "MRs: assignedMergeRequests(state:opened){nodes{project{name},title,webUrl}}"
        reviews "Reviews:reviewRequestedMergeRequests(state:opened){nodes{project{name},title,webUrl}}"
        notifications "Notifications:todos(state:pending){nodes{action,body,targetUrl}}"
        query (.. "query{root:currentUser{"
                  (table.concat [mrs reviews notifications] ",") "}}")]
    (background-process [:glab :api :graphql :-f (.. :query= query)]
                        {:silent true
                         :on-success (fn [stdout]
                                       (let [data (vim.json.decode stdout)
                                             graph data.data.root
                                             merge-requests (format-merge-requests graph.MRs.nodes)
                                             reviews (format-reviews graph.Reviews.nodes)
                                             notifications (format-notifications graph.Notifications.nodes)]
                                         (when ?callback
                                           (?callback {: merge-requests
                                                       : reviews
                                                       : notifications}))))})))

(fn get-graph [?callback]
  (let [gitlab? state.gitlab
        is-expired? (expired?)]
    (case [gitlab? is-expired?]
      ;; gitlab repo, cache needs regenerating
      [true true]
      (call-glab (fn [graph] (write graph)
                   (when ?callback (?callback graph))))
      ;; cache is valid (we don't care about repo status)
      [_ false]
      (when ?callback
        (?callback (. (read) 1)))
      ;; not a gitlab repo, no cache to use
      _
      nil)))

(fn view-reviews []
  (get-graph (fn [graph]
               (let [reviews graph.reviews
                     items {}]
                 (when (= (length reviews) 0)
                   (table.insert items
                                 {:text "No Reviews Found" :separator true}))
                 (each [_ r (pairs reviews)]
                   (table.insert items
                                 {:text r.text
                                  :action (fn [] (vim.ui.open r.actionUrl))}))
                 (create-menu "Review Requests" items)))))

(fn view-merge-requests []
  (get-graph (fn [graph]
               (let [merge-requests graph.merge-requests
                     items {}]
                 (when (= (length merge-requests) 0)
                   (table.insert items
                                 {:text "No Merge Requests Found"
                                  :separator true}))
                 (each [_ r (pairs merge-requests)]
                   (table.insert items
                                 {:text r.text
                                  :action (fn [] (vim.ui.open r.actionUrl))}))
                 (create-menu "Merge Requests" items)))))

(fn view-notifications []
  (get-graph (fn [graph]
               (let [notifications graph.notifications
                     items {}]
                 (when (= (length notifications) 0)
                   (table.insert items
                                 {:text "No Notifications Found"
                                  :separator true}))
                 (each [_ r (pairs notifications)]
                   (table.insert items
                                 {:text r.text
                                  :action (fn [] (vim.ui.open r.actionUrl))}))
                 (create-menu :Notifications items)))))

((. (require :which-key) :add) [{1 :<leader>gl :group :Gitlab}
                                {1 :<leader>glm
                                 2 view-merge-requests
                                 :desc "View Merge Requests"}
                                {1 :<leader>glr
                                 2 view-reviews
                                 :desc "View Review Requests"}
                                {1 :<leader>gln
                                 2 view-notifications
                                 :desc "View Notifications"}])

{:check (fn [] state.gitlab)
 : view-merge-requests
 : view-reviews
 : view-notifications}
