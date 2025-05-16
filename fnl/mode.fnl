(macro get-buffer-name [?buf#]
  `(vim.api.nvim_buf_get_name (if ,?buf# ,?buf# 0)))

(macro format! [formatter# file#]
  `(if ,formatter#
       (let [fmt# (if (= (type ,formatter#) :string) ,formatter# (,formatter#))]
         (if fmt# (do
                    (vim.cmd (.. "! " fmt# " " ,file#))
                    (vim.cmd :e!)
                    nil)))))

(local modes {:fennel (require :modes.fennel) :php (require :modes.php)})

(each [name mode (pairs modes)]
  (if (and (?. mode :pattern) (?. mode :formatter))
      (let [group (vim.api.nvim_create_augroup name {:clear true})]
        (vim.api.nvim_create_autocmd :BufWritePost
                                     {:pattern mode.pattern
                                      : group
                                      :callback (fn [args]
                                                  (do
                                                    (format! mode.formatter
                                                             (get-buffer-name args.buf))))}))))

(macro matches [mode# ?file#]
  `(let [file# (if ,?file# ,?file# (get-buffer-name))]
     (string.match file# (string.sub (. ,mode# :pattern) 2))))

(macro run-mode-cmd! [method#]
  `(let [file# (get-buffer-name)]
     (each [_# mode# (pairs modes)]
       (if (and (matches mode# file#) (?. mode# ,method#))
           ((. mode# ,method#) file#)))))

(fn expand-which-key []
  (let [mappings []
        file (get-buffer-name)]
    (do
      (each [_ mode (pairs modes)]
        (do
          (if (matches mode file)
              (each [k v (pairs mode)]
                (do
                  (if (= k :formatter)
                      (table.insert mappings
                                    {1 :f
                                     2 (fn [] (format! v (get-buffer-name)))
                                     :desc :Format})))))))
      mappings)))

;; Monitor file types we open that we haven't made a mode for yet
(vim.api.nvim_create_autocmd :BufNew
                             {:group (vim.api.nvim_create_augroup :unknown-modes
                                                                  {:clear true})
                              :callback (fn [args]
                                          (let [file (get-buffer-name args.buf)]
                                            (if (> (length args.file) 0)
                                                (do
                                                  (var mode nil)
                                                  (each [_ m (pairs modes)]
                                                    (if (matches m file)
                                                        (set mode m)))
                                                  (if (not mode)
                                                      (vim.notify (.. "Unknown file type for "
                                                                      args.file
                                                                      " consider making a new mode")))))))})

{:expand (fn []
           (let [mappings (expand-which-key)]
             (do
               mappings)))}
