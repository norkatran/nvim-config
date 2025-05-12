(fn get-buffer-name [?buf] (vim.api.nvim_buf_get_name (if ?buf ?buf (vim.api.nvim_get_current_buf))))

(fn format [?file] (do (let [file (if ?file ?file (get-buffer-name))] (: (vim.system [:fnlfmt :--fix file]) :wait))))

{ :format format :pattern :*.fnl}
