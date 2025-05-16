(local ui (require :ui))
(local fidget (require :fidget.notification))

(local notification-group :workbook)
(local workbook-location (.. (vim.fn.stdpath :data) :/workbook/))

(fn workbook-dir-exists []
  (let [(ok err code) (os.rename workbook-location workbook-location)]
    (if (and (not ok) (= code 13)) true ok)))

(fn pad [n]
  (if (< n 10) (.. :0 (tostring n)) (tostring n)))

(fn default-title []
  (let [date (os.date :*t)
        title (.. date.year "_" (pad date.month) "_" (pad date.day) :.md)]
    title))

(fn workbook-exists [title]
  (let [f (io.open (.. workbook-location title) :r)]
    (if (not= f nil) (do
                       (io.close f) true) false)))

(fn save-to-workbook [content title]
  (let [title (if title title (default-title))
        f (assert (io.open (.. workbook-location title) :a))]
    (do
      (f:write content)
      (io.close f)
      (fidget.notify (.. "Wrote to workbook " title) vim.log.levels.INFO
                     {:group notification-group}))))

(fn workbook []
  (let [title (default-title)]
    (ui.create-textbox (.. "Workbook " title) []
                       (fn [buf]
                         (let [str (table.concat buf "\n")]
                           (if (not (str:match "^%s*$"))
                               (let [date (os.date :*t)
                                     time (.. (pad date.hour) "-"
                                              (pad date.min) "-" (pad date.sec))]
                                 (save-to-workbook (.. "\n" time "--------------

" str)))))) {:syntax :md})))

(fn view-workbooks []
  ((. (require :telescope.builtin) :find_files) {:cwd workbook-location}))

(fn grep-workbooks []
  ((. (require :telescope.builtin) :live_grep) {:cwd workbook-location}))

(if (not (workbook-dir-exists))
    (do
      (fidget.notify "Created workbook directory" vim.log.levels.INFO
                     {:group notification-group})
      (vim.system [:mkdir :-p workbook-location])))

((. (require :which-key) :add) [{1 :<leader>wo :group :Workbook}
                                {1 :<leader>wo<leader>
                                 2 (fn []
                                     ((. (require :feature.workbook) :workbook)))
                                 :desc "Open workbook"}
                                {1 :<leader>wo/
                                 2 (fn []
                                     ((. (require :feature.worbook)
                                         :grep-workbooks)))
                                 :desc "Search workbooks"}
                                {1 :<leader>wow
                                 2 (fn []
                                     ((. (require :feature.workbook)
                                         :view-workbooks)))
                                 :desc "Browse workbooks"}])

{: workbook : view-workbooks : grep-workbooks}
