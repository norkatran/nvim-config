(local cache-dir (vim.fs.joinpath (vim.fn.stdpath :cache) :init))

(fn read [file]
  (var out [])
  (vim.fn.mkdir cache-dir :-p)
  (let [cache-file (vim.fs.joinpath cache-dir file)]
    (let [f (io.open cache-file)
          check (if f true false)]
      (when check (f:close))
      (if check
          (with-open [reader (io.open cache-file)]
            (let [contents (reader:read :*all)]
              (when (not= contents "") (set out (vim.json.decode contents))))))))
  out)

(fn write [file ?data]
  (vim.fn.mkdir cache-dir :-p)
  (let [cache-file (vim.fs.joinpath cache-dir file)]
    (with-open [writer (io.open cache-file :w)]
      (writer:write (vim.json.encode (if (= ?data nil) [] [?data]))))))

(fn append [file data]
  (let [content (read file)]
    (table.insert content data)
    (write file content)))

(fn replace [file key value]
  (let [content (read file)]
    (tset content key value)
    (write file content)))

(fn clear [file]
  (write file nil))

(fn expired? [file ?ttl]
  (let [uv vim.uv
        ttl (or ?ttl 60)
        stat (uv.fs_stat (vim.fs.joinpath cache-dir file))
        exists? (and stat (= stat.type :file) (> stat.size 0))
        is-expired? (and stat stat (>= (- (os.time) stat.mtime.sec) ttl))]
    (if (not exists?) true
        (if is-expired? true false))))

{: read : write : append : clear : replace : expired?}
