(fn map [arr cb]
  (let [out []]
    (each [k v (pairs arr)]
      (table.insert out (cb v k)))
    out))

(fn without [arr item]
  (let [out []]
    (each [_ v (ipairs arr)]
      (if (= (type item) :function)
          (when (not (item v)) (table.insert arr v))
          (when (not= item v) (table.insert arr v))))
    out))

(fn insert-at [arr item idx]
  (if (= (length arr) 0) [item] (let [out []]
                                  (each [k v (ipairs arr)]
                                    (when (= k idx) (table.insert arr item))
                                    (table.insert arr v))
                                  out)))

(fn str-repeat [str times]
  (let [out []]
    (for [_ 1 times 1] (table.insert out str))
    (table.concat out)))

(fn pad-truncate [str len]
  (if (= (length str) len)
      str
      (if (< (length str) len)
          (.. str (str-repeat " " (- len (length str))))
          (.. (string.sub str 1 (- len 2)) ".."))))

(local state {:processes []})
(fn render-processes []
  ((. (require :ui) :create-pin) :Processes
                                 (fn [width]
                                   (map state.processes
                                        (fn [p]
                                          (pad-truncate (if (= (type p) :string)
                                                            p
                                                            (table.concat p " "))
                                                        width))))))

(fn background-process [process ?opts]
  (let [opts (or ?opts {})
        on-success (or (?. opts :on-success) nil)
        silent? (or (?. opts :silent) false)]
    (table.insert state.processes process)
    (render-processes)
    (vim.system process {}
                (fn [out]
                  (vim.schedule (fn []
                                  (tset state :processes
                                        (without state.processes process))
                                  (render-processes)
                                  (if (= out.code 0)
                                      (do
                                        (when on-success
                                          (on-success out.stdout))
                                        (when (not silent?)
                                          (vim.notify (.. "Finished running cmd: "
                                                          (table.concat process
                                                                        " "))
                                                      vim.log.levels.INFO)))
                                      (vim.notify (.. :Process
                                                      (if silent? process "")
                                                      "returned error code:"
                                                      (tostring out.code))
                                                  vim.log.levels.ERROR))))))))

{: map : without : insert-at : str-repeat : pad-truncate : background-process}
