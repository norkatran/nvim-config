(local {: background-process} (require :utils))

(fn to-list [output formatter]
  (let [list []]
    (each [_ item (ipairs (vim.fn.split output "\n"))]
      (table.insert list (formatter (vim.json.decode item))))
    list))

(fn get-images [callback]
  (background-process [:docker :images :--format :json]
                      {:on-success (fn [images]
                                     (callback (to-list images
                                                        (fn [image]
                                                          (let [{:Repository repo
                                                                 :ID id} image]
                                                            {:text repo
                                                             : repo
                                                             : id})))))}))

(fn get-containers [callback]
  (background-process [:docker :container :ls :--format :json]
                      {:on-success (fn [containers]
                                     (callback (to-list containers
                                                        (fn [container]
                                                          (let [{:ID id
                                                                 :Image image
                                                                 :State state} container]
                                                            {:text (.. (if (= state
                                                                              :running)
                                                                           "* "
                                                                           "  ")
                                                                       image)
                                                             : image
                                                             : id})))))}))

(fn delete-image [image]
  (background-process [:docker :image :rm :-f image.id]))

(fn docker-purge []
  (background-process [:docker :system :prune :-af]
                      {:on-success (fn []
                                     (background-process [:docker
                                                          :volume
                                                          :prune
                                                          :-f]))}))

(fn list-images []
  (let [ui (require :ui)]
    (get-images (fn [images]
                  (ui.create-menu "Docker Images" images
                                  {:desc "Currently available Docker Images"
                                   :mappings [{1 :<C-d>
                                               2 delete-image
                                               :desc "Delete image"}
                                              {1 :<C-a><C-k>
                                               2 docker-purge
                                               :desc "Purge docker"}]})))))

(fn launch-kitty [cmd ?type]
  (let [launchtype (or ?type :tab)
        args [:kitty
              "@"
              :launch
              :--type
              launchtype
              :--cwd
              (vim.uv.cwd)
              :/opt/homebrew/bin/fish
              :-c
              (.. "'" cmd "'")]]
    (vim.cmd (.. ":silent exec \"!" (table.concat args " ") "\""))
    (vim.notify (.. "Opened kitty " launchtype " running " cmd))))

(fn shell-into-container [container]
  (launch-kitty (.. "docker container attach " container.id) :os-window))

(fn stop-container [container]
  (background-process [:docker :container :stop container.id]))

(fn container-command [cmd]
  (fn [container]
    (background-process [:docker :container cmd container.id])))

(fn list-containers []
  (let [ui (require :ui)]
    (get-containers (fn [containers]
                      (ui.create-menu "Docker Containers" containers
                                      {:desc ["Docker Containers"
                                              "* denotes a running container"]
                                       :mappings [{1 :<C-s>
                                                   2 shell-into-container
                                                   :desc "Shell into"}
                                                  {1 :<C-d>
                                                   2 (container-command :stop)
                                                   :desc :Down}]})))))

(fn docker-compose [cmd opts]
  (let [profile? (?. opts :profile)
        service? (?. opts :service)
        external? (?. opts :external)
        args (or (?. opts :args) {})
        state {}
        get-profile (fn [?cb]
                      ((. (require :ui) :create-input) :--profile
                                                       (fn [x]
                                                         (if (not= x "")
                                                             (tset state
                                                                   :profile
                                                                   (.. :--profile=
                                                                       x)))
                                                         (when ?cb (?cb)))))
        get-service (fn [?cb]
                      ((. (require :ui) :create-input) :Service
                                                       (fn [x]
                                                         (tset state :service x)
                                                         (when ?cb (?cb)))))
        run-cmd (fn []
                  (let [dc [:docker :compose]]
                    (when (?. state :profile)
                      (table.insert dc state.profile))
                    (table.insert dc cmd)
                    (each [_ arg (ipairs args)]
                      (table.insert dc arg))
                    (when (?. state :service)
                      (table.insert dc state.service))
                    (if external?
                        (launch-kitty (table.concat dc " ")
                                      (or opts.type :os-window))
                        (background-process dc))))]
    (case opts
      {:service true :profile true} (get-profile (fn []
                                                   (get-service (fn []
                                                                  (run-cmd)))))
      {:service true} (get-service (fn [] (run-cmd)))
      {:profile true} (get-profile (fn [] (run-cmd)))
      _ (run-cmd))))

(let [group (fn [?k]
              (.. :<leader><leader>d (if (not= ?k nil) ?k "")))]
  ((. (require :which-key) :add) [{1 (group) :group :Docker}
                                  {1 (group :i) 2 list-images :desc :Images}
                                  {1 (group :<leader>)
                                   2 list-containers
                                   :desc :Containers}
                                  {1 (group :c) :group :Compose}
                                  {1 (group :cu)
                                   2 (fn []
                                       (docker-compose :up
                                                       {:profile true
                                                        :args [:-d]}))
                                   :desc :Up}
                                  {1 (group :cR)
                                   2 (fn []
                                       (docker-compose :run
                                                       {:profile true
                                                        :service true
                                                        :external :os-window}))
                                   :desc "Run (Choose service)"}
                                  {1 (group :cd)
                                   2 (fn []
                                       (docker-compose :down {:profile true}))
                                   :desc :Down}
                                  {1 (group :cA)
                                   2 (fn []
                                       (docker-compose :attach
                                                       {:profile true
                                                        :service true}))
                                   :desc "Attach (Choose Service"}]))

;; (images)
