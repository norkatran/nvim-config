(vim.api.nvim_create_autocmd :TermOpen
                             {:group (vim.api.nvim_create_augroup :term-escape
                                                                  {:clear true})
                              :callback (fn [] (tset vim.opt :number false)
                                          (tset vim.opt :relativenumber false))})

(local state {})

(fn create-floating-window [name]
  (let [width (math.floor (* vim.o.columns 0.8))
        height (math.floor (* vim.o.lines 0.8))
        col (math.floor (/ (- vim.o.columns width) 2))
        row (math.floor (/ (- vim.o.lines height) 2))
        win-config {:relative :editor
                    : width
                    : height
                    : col
                    : row
                    :style :minimal
                    :border :rounded}]
    (do
      (var buf nil)
      (if (?. state name)
          (do
            (set buf (. (. state name) :buf))
            {: buf :win (. (. state name) :win)})
          (do
            (set buf (vim.api.nvim_create_buf false false))
            (let [win (vim.api.nvim_open_win buf true win-config)]
              (do
                (vim.api.nvim_buf_call buf (fn [] (vim.cmd "e term://fish")))
                (tset state name {})
                (doto (. state name)
                  (tset :buf buf)
                  (tset :win win)
                  (tset :channel (vim.api.nvim_open_term buf {})))
                (print (vim.inspect (. (. vim.bo buf) :channel)))
                {: buf : win})))))))

;;(fn open-term [name]
;;(fn []
;;(vim.cmd.vnew)
;;(vim.cmd.term)
;;(vim.cmd.wincmd :J)
;;(vim.api.nvim_win_set_height 0 5)
;;(let [floating-window (create-floating-window)]
;;(do
;;(tset state name {})
;;(doto (. state name) (tset :channel vim.bo.channel)
;;(tset :buf floating-window.buf)
;;(tset :win floating-window.win))))
;;(vim.fn.chansend (. (. state name) :channel) ["q\r\n"])))

(fn float-term [name command]
  (if (?. state name) (vim.api.nvim_win_hide (. (. state name) :win))
      (do
        (create-floating-window name)
        ;;(vim.fn.chansend (. (. state
        ;;name)
        ;;:channel)
        ;;[(.. command
        ;;"\r
        ;;")])
        )))

((. (require :which-key) :add) [{1 :<leader>t :group :Terminal}
                                {1 :<leader>tq
                                 2 (fn [] (float-term :Q :q))
                                 :desc :AmazonQ}
                                {1 :<leader>tf
                                 2 (fn [] (float-term :fennel :fennel))
                                 :desc "Fennel REPL"}])

(vim.keymap.set :t :<esc><esc> "<c-\\><c-n>")
