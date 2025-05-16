;; init.fnl

(require :options.vim)
(require :mode)

(fn ensure-installed [plugin branch]
  (let [(_ repo) (string.match plugin "(.+)/(.+)")
        repo-path (.. (vim.fn.stdpath :data) :/lazy/ repo)]
    (when (not ((. (or vim.uv vim.loop) :fs_stat) repo-path))
      (vim.notify (.. "Installing " plugin " " branch))
      (local repo-url (.. "https://github.com/" plugin :.git))
      (local out (vim.fn.system [:git
                                 :clone
                                 "--filter=blob:none"
                                 (.. :--branch= branch)
                                 repo-url
                                 repo-path]))
      (when (not= vim.v.shell_error 0)
        (vim.api.nvim_echo [[(.. "Failed to clone " plugin ":\n") :ErrorMsg]
                            [out :WarningMsg]
                            ["\nPress any key to exit..."]]
                           true {})
        (vim.fn.getchar)
        (os.exit 1)))
    repo-path))

(local lazy-path (ensure-installed :folke/lazy.nvim :stable))
(local hotpot-path (ensure-installed :rktjmp/hotpot.nvim :v0.14.8))
(vim.opt.runtimepath:prepend [hotpot-path lazy-path])
(vim.loader.enable)

(require :hotpot)

((. (require :lazy) :setup) {:spec {:import :plugins}})

(let [hotpot (require :hotpot)
      setup hotpot.setup]
  (setup {:compiler {:modules {:correlate true}
                     :macros {:env :_COMPILER
                              :compilerEnv _G
                              :allowedGlobals false}}})

  (fn rebuild-on-save [{: buf}]
    (let [{: build} (require :hotpot.api.make)
          au-config {:buffer buf
                     :callback #(build (vim.fn.stdpath :config)
                                       {:verbose true
                                        :atomic true
                                        :compiler {:modules {:allowedGlobals (icollect [n _ (pairs _G)]
                                                                               n)}}}
                                       [[:init.fnl true]])}]
      (vim.api.nvim_create_autocmd :BufWritePost au-config)))

  (vim.api.nvim_create_autocmd :BufRead
                               {:pattern (-> (.. (vim.fn.stdpath :config)
                                                 :/init.fnl)
                                             (vim.fs.normalize))
                                :callback rebuild-on-save}))

;; My Config

(require :options.keybinds)
(require :feature.init)

(require :options.commands)
