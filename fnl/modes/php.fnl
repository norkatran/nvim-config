(fn get-buffer-name [?buf] (vim.api.nvim_buf_get_name (if ?buf ?buf (vim.api.nvim_get_current_buf))))

(fn pint? [] (let [root (Snacks.git.get_root)
                    pint (vim.fs.joinpath root :vendor/bin/pint)
                    stat (vim.uv.fs_stat pint)]
               (if (and stat (= stat.type :file)) pint nil)))

(fn format [?file] (let [file (if ?file ?file (get-buffer-name))
                     pint (pint?)] (if pint (: (vim.system [pint file]) :wait))))

{:pattern :*.php :format format}
