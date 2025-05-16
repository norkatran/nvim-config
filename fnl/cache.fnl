(local cache-dir (vim.fs.joinpath (vim.fn.stdpath :cache) :init))

(fn read [file]
  (vim.fn.mkdir cache-dir :-p)
  (let [cache-file (vim.fs.joinpath cache-dir file)]
    (let [f (io.open cache-file)
          check (if f true false)]
      (f:close)
      (if check
          (with-open [reader (io.open cache-file)]
            (let [contents (reader:read :*all)]
              (if (= contents "") [] (vim.json.decode contents))))
          []))))

(fn write [file ?data]
  (vim.fn.mkdir cache-dir :-p)
  (let [cache-file (vim.fs.joinpath cache-dir file)]
    (with-open [writer (io.open cache-file :w)]
      (writer:write (vim.json.encode (if (= ?data nil) [] [?data]))))))

(fn append [file data]
  (let [content (read file)]
    (table.insert content data)
    (write file content)))

(fn clear [file]
  (write file nil))

{: read : write : append : clear}
