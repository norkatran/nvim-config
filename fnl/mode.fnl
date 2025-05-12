(macro get-buffer-name [?buf#]
  `(vim.api.nvim_buf_get_name (if ,?buf# ,?buf# 0)))

(local modes {:fennel (require :modes.fennel) :php (require :modes.php)})

(each [name mode (pairs modes)]
  (if (and (?. mode :pattern) (?. mode :format))
    (let [group (vim.api.nvim_create_augroup name {:clear true})]
      (vim.api.nvim_create_autocmd :BufWritePost
                                   {:pattern mode.pattern
                                    :group group
                                    :callback (fn [args]
                                                (do
                                                  (mode.format (get-buffer-name args.buf))
                                                  (vim.cmd :e!)))}))))

(macro matches [mode# ?file#]
  `(let [file# (if ,?file# ,?file# (get-buffer-name))]
     (string.match file# (. ,mode# :pattern))))

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
        (if (matches mode file)
            (each [k v (pairs mode)]
              (if (and (not= k :match) (not= k :pattern))
                  (table.insert mappings
                                {1 (string.sub k 1 1) 2 (v file) :desc k})))))
      mappings)))

{:expand expand-which-key}
