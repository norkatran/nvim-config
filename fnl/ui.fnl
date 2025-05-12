(local border-style {
  :top_left     "╭"
  :top          "─"
  :top_right    "╮"
  :left         "│"
  :right        "│"
  :bottom_left  "╰"
  :bottom       "─"
  :bottom_right "╯"
})

(macro to-nui-item! [i# & Menu]
  `(if (?. ,i# :separator) (Menu.separator (. ,i# :text) {:char "-" :text_align :center})
    (Menu.item ,i#)))

(fn centered-float-config [title]
  {:border {
    :style border-style
    :text {
      :top title
      :top_align :center }}
    :position :50%
    :relative :editor
    :size {
      :width :80%
      :height :20% }})

(fn create-menu [title items]
  (let [Menu (require :nui.menu)
        lines {}]
    (do (each [_ i (pairs items)]
      (table.insert lines (to-nui-item! i)))
      (let [menu (Menu (centered-float-config title) {
                       :lines lines
                       :on_submit (fn [x] (if (?. x :action) ((. x :action))))})]
        (: menu :mount))
      )))

(fn create-menu-with-key [title items mappings]
  (let [Menu (require :nui.menu)
        Layout (require :nui.layout)
        Popup (require :nui.popup)
        lines {}]
    (do (each [_ i (pairs items)]
        (table.insert lines (to-nui-item! i)))
        (let [current-node nil
              menu (Menu (centered-float-config title) {
                         :lines lines
                         :on_submit (fn [x] (if (?. x :action) ((. x :action))))})
              popup (Popup (centered-float-config :Key))
              get-keymap-args (fn [] { :node current-node :menu menu})]
          (do (each [i2 m (ipairs mappings)]
                (do (menu:map :n (. m 1) ((. m 2) (get-keymap-args)))
                  (vim.api.nvim_buf_set_lines popup.bufnr i2 -1 false [(.. m.1 :\t m.desc)])))
            (let [layout (Layout (centered-float-config title) (Layout.Box [(Layout.Box menu { :size :75% }) (Layout.Box popup { :size :25% }) { :dir :row }]))]
              (layout:mount)))
      ))))

(fn create-textbox [title default handler opts]
  (let [Popup (require :nui.popup)
        event (. (require :nui.utils.autocmd) :event)
        config (centered-float-config title)]
    (do (doto config (tset :enter true) (tset :focusable true))
      (let [popup (Popup config)
            close (fn [] (do (handler (vim.api.nvim_buf_get_lines popup.bufnr 0 -1 false) (popup:unmount))))]
        (do (popup:on event.BufLeave close)
          (if default (vim.api.nvim_buf_set_lines popup.bufnr 0 -1 false default))
          (let [opts (or opts {})]
            (do (tset opts :modifiable true)
              (each [k v (pairs opts)]
                (vim.api.nvim_set_option_value k v { :buf popup.bufnr }))
              (popup:mount))))))))

(fn create-input [title handler]
  (let [Input (require :nui.input)
        input (Input (centered-float-config title) {
                     :prompt "> "
                     :on_submit handler
                     })]
    (do
      (input:map :i :<Esc> (fn [] (input:unmount)) { :noremap true })
      (input:mount))))

{ :create-input create-input :create-textbox create-textbox :create-menu-with-key create-menu-with-key :create-menu create-menu }
