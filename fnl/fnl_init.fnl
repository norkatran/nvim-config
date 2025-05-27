(require :options.vim)

((. (require :lazy) :setup) {:spec {:import :plugins}})

(require :options.keybinds)

(require :options.commands)
