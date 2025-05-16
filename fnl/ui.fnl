(local which-key (require :which-key))
(local border-style {:top_left "╭"
                     :top "─"
                     :top_right "╮"
                     :left "│"
                     :right "│"
                     :bottom_left "╰"
                     :bottom "─"
                     :bottom_right "╯"})

(local pin-width 80)

(local state {:pins []})

(fn to-nui-item! [i]
  (let [Menu (require :nui.menu)]
    (if (?. i :separator)
        (Menu.separator (. i :text) {:char "-" :text_align :center})
        (Menu.item i))))

(fn centered-float-config [title]
  (let [width (math.floor (* vim.o.columns 0.8))
        height (math.floor (* vim.o.lines 0.8))]
    {:border {:style border-style :text {:top title :top_align :center}}
     :position "50%"
     :relative :editor
     :size {: width : height}}))

(fn create-menu-with-key [title items opts]
  (let [Menu (require :nui.menu)
        Layout (require :nui.layout)
        Popup (require :nui.popup)
        mappings (or (?. opts :mappings) {})
        desc (or (?. opts :desc) {})
        lines {}]
    (do
      (each [_ i (pairs items)]
        (table.insert lines (to-nui-item! i)))
      (let [state {:current (. lines 1)}
            menu (Menu (centered-float-config title)
                       {: lines
                        :on_submit (fn [x]
                                     (if (?. x :action) ((. x :action))))
                        :on_change (fn [x]
                                     (tset state :current x))})
            popup (Popup (centered-float-config :Key))]
        (do
          (if desc
              (do
                (each [_ desc-part (ipairs desc)]
                  (vim.api.nvim_buf_set_lines popup.bufnr -1 -1 false
                                              [desc-part]))
                (vim.api.nvim_buf_set_lines popup.bufnr -1 -1 false [""])))
          (each [_ m (ipairs mappings)]
            (do
              (menu:map :n (. m 1)
                        (fn [ctx]
                          (menu:unmount)
                          ((. m 2) state.current)))
              (vim.api.nvim_buf_set_lines popup.bufnr -1 -1 false
                                          [(.. (. m 1) " " m.desc)])))
          (let [layout (Layout (centered-float-config title)
                               (Layout.Box [(Layout.Box menu {:size "75%"})
                                            (Layout.Box popup {:size "25%"})]
                                           {:dir :row}))]
            (do
              (menu:map :n :<esc> "<cmd>:x<cr>" {:noremap true})
              (menu:map :i :<esc> "<cmd>:x<cr>" {:noremap true})
              (layout:mount))))))))

(fn create-menu [title items ?opts]
  (if ?opts (create-menu-with-key title items ?opts)
      (let [Menu (require :nui.menu)
            lines {}]
        (do
          (each [_ i (pairs items)]
            (table.insert lines (to-nui-item! i)))
          (let [menu (Menu (centered-float-config title)
                           {: lines
                            :on_submit (fn [x]
                                         (if (?. x :action) ((. x :action))))})]
            (do
              (menu:map :n :<esc> "<cmd>:x<cr>" {:noremap true})
              (menu:map :i :<esc> "<cmd>:x<cr>" {:noremap true})
              (menu:mount)))))))

(fn create-textbox [title default handler opts]
  (let [Popup (require :nui.popup)
        event (. (require :nui.utils.autocmd) :event)
        config (centered-float-config title)]
    (do
      (doto config (tset :enter true) (tset :focusable true))
      (let [popup (Popup config)
            close (fn []
                    (do
                      (handler (vim.api.nvim_buf_get_lines popup.bufnr 0 -1
                                                           false)
                               (popup:unmount))))]
        (do
          (popup:on event.BufLeave close)
          (if default
              (vim.api.nvim_buf_set_lines popup.bufnr 0 -1 false default))
          (let [opts (or opts {})]
            (do
              (tset opts :modifiable true)
              (each [k v (pairs opts)]
                (vim.api.nvim_set_option_value k v {:buf popup.bufnr}))
              (popup:map :n :<esc> "<cmd>:x<cr>" {:noremap true})
              (popup:map :i :<esc> "<cmd>:x<cr>" {:noremap true})
              (popup:mount))))))))

(fn create-input-with-key [title handler keys]
  (let [Input (require :nui.input)
        Popup (require :nui.popup)
        Layout (require :nui.layout)
        input (Input (centered-float-config title)
                     {:prompt "> " :on_submit handler})
        popup (Popup (centered-float-config title))
        layout (Layout (centered-float-config title)
                       (Layout.Box [(Layout.Box input {:size "75%"})
                                    (Layout.Box popup {:size "25%"})]))]
    (do
      (input:map :i :<Esc> (fn [] (input:unmount)) {:noremap true})
      (input:map :n :<Esc> (fn [] (input:unmount)) {:noremap true})
      (each [i key (ipairs keys)]
        (vim.api.nvim_buf_set_lines popup.bufnr i -1 false key))
      (layout:mount))))

(fn create-input [title handler ?key]
  (if ?key (create-input-with-key title handler ?key)
      (let [Input (require :nui.input)
            input (Input (centered-float-config title)
                         {:prompt "> " :on_submit handler})]
        (do
          (input:map :i :<Esc> (fn [] (input:unmount)) {:noremap true})
          (input:map :n :<Esc> (fn [] (input:unmount)) {:noremap true})
          (input:mount)))))

(fn default-col [position width]
  (case position
    :top-right (- vim.o.columns width 2)
    :top-left 1
    :bottom-right (- vim.o.columns width 2)
    :bottom-left 1))

(fn default-row [position height]
  (case position
    :top-right 1
    :top-left 1
    :bottom-right (- vim.o.lines height 4)
    :bottom-left (- vim.o.lines height 4)))

(fn get-pin-position [position width height]
  (let [existing []
        pos-state {:row (default-row position height)
                   :col (default-col position width)}]
    (each [_ pin (pairs state.pins)]
      (when (= position pin.position) (table.insert existing pin))
      (each [_ pin (ipairs existing)]
        (let [height pin.max-height
              width pin.width]
          (case position
            :top-right (tset pos-state :row (+ 3 pos-state.row height))
            :top-left (tset pos-state :row (+ 3 pos-state.row height))
            :bottom-left (tset pos-state :row (- 3 pos-state.row width))
            :bottom-right (tset pos-state :row (- 3 pos-state.row width))))))
    pos-state))

(fn update-pin-positions [deleted]
  (each [_ pin (ipairs state.pins)]
    (when (= deleted.position pin.position)
      (case deleted.position
        :top-right nil
        :top-left nil
        :bottom-right nil
        :bottom-left nil))))

;;(do
;;(vim.api.nvim_win_close win true)
;;(vim.api.nvim_buf_delete buf {:force true})
;;(tset state.pins title nil))
;;
(fn remove-pin [title re-render]
  (let [close (fn [pin]
                (vim.api.nvim_win_close pin.win true)
                (vim.api.nvim_buf_delete pin.buf {:force true}))
        removed [(. state.pins title)]
        old-state state.pins]
    (tset state :pins [])
    (each [title2 pin (pairs old-state)]
      (close pin)
      (when (not= title title2)
        (re-render pin)))))

(fn create-pin [title get-items ?max-height ?position ?keep]
  (let [max-height (or ?max-height 4)
        position (or ?position :top-right)
        keep (or ?keep false)
        width pin-width
        items (get-items width)
        height (math.min (math.max (length items) 1) max-height)
        {: row : col} (get-pin-position position width height)]
    (when (not (?. state.pins title))
      (let [buf (vim.api.nvim_create_buf false true)
            win (vim.api.nvim_open_win buf false
                                       {:relative :editor
                                        : height
                                        :width (+ width 2)
                                        : row
                                        : col
                                        :style :minimal
                                        :border :rounded
                                        : title
                                        :title_pos :center
                                        :zindex 45})]
        (tset state.pins title {: title
                                : max-height
                                : position
                                : keep
                                : width
                                : items
                                : max-height
                                : row
                                : col
                                : buf
                                : win})))
    (each [pin-title pin (pairs state.pins)]
      (let [{: win : buf} pin]
        (when (= pin-title title)
          (let [lines []]
            (vim.api.nvim_win_set_height win height)
            (vim.api.nvim_buf_set_lines buf 0 -1 false [""])
            (each [i item (ipairs items)]
              (table.insert lines item)
              (vim.api.nvim_buf_set_lines buf (- i 1) i false [item]))
            (when (and (not keep) (= (length lines) 0))
              (remove-pin title
                          (fn [pin]
                            (create-pin pin.title (fn [] pin.items)
                                        pin.max-height pin.position pin.keep))))))))))

{: create-input
 : create-textbox
 : create-menu-with-key
 : create-menu
 : create-pin}
