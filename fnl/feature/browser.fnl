(local prefix-symbol "@")
(local google "https://www.google.com/search?q=%s")
(local jira (.. vim.env.JIRA_DOMAIN "/browse/%s"))
(local wikipedia "https://en.wikipedia.org/w/index.php?search=%s")
(local gitlab "https://gitlab.corp.friendmts.com/search?search=%s")

(local config {:default :google
               :query-map {:g [google :google]
                           :j [jira :jira]
                           :w [wikipedia :wikipedia]
                           :gl [gitlab :gitlab]}})

(fn url? [input] (not= (input:match "[%w%.%-_]+%.[%w%.%-_/]+") nil))

(fn extract-prefix [input]
  (let [pat (.. prefix-symbol "(%w+)")
        prefix (input:match pat)]
    (do
      (if (or (not prefix) (not (. config.query-map prefix)))
          [(vim.trim input) config.default]
          (let [query (input:gsub (.. "@" prefix) "")]
            [(vim.trim query) prefix])))))

(fn query-browser [input]
  (do
    (var q nil)
    (let [extraction (extract-prefix input)
          q2 (. extraction 1)
          prefix (. extraction 2)]
      (do
        (if (not (url? input))
            (let [format (. (. config.query-map prefix) 1)]
              (set q (format:format (vim.uri_encode q2))))
            (set q q2))
        (vim.notify (.. "Opening url " q) vim.log.levels.DEBUG)
        (vim.ui.open q)))))

(fn get-domain [url] (print url))

(fn create-config-key []
  (let [keys []]
    (do
      (each [prefix url (pairs config.query-map)]
        (table.insert keys [(.. prefix-symbol prefix " - " (. url 2))]))
      keys)))

(local ui (require :ui))
((. (require :which-key) :add) [{1 :<leader><leader>b
                                 2 (fn []
                                     (ui.create-input :Browser
                                                      (fn [input]
                                                        (if (> (length (vim.trim input))
                                                               0)
                                                            (query-browser input)))
                                                      (create-config-key)))
                                 :desc "Open Browser"}])
