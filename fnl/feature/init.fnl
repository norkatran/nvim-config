(each [name _ (vim.fs.dir (vim.fs.joinpath (vim.fn.stdpath :config) :fnl
                                           :feature))]
  (let [filename (string.sub name 1 -5)]
    (when (not= filename :init)
      (require (.. :feature "." filename)))))
