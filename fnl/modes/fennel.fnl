(vim.api.nvim_create_autocmd :BufWritePre
                             {:group :fennel
                              :callback (fn [args]
                                          (if (string.match args.file :.fnl$)
                                              (let [fname (vim.uri_to_fname (vim.uri_from_bufnr args.buf))]
                                                (vim.fn.system [:fnlfmt
                                                                :--fix
                                                                fname]))))})
