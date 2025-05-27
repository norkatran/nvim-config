;; vim globals
(tset vim.g :loaded_netrw 1)
(tset vim.g :loaded_netrwPlugin 1)
(tset vim.g :mapleader " ")

;; vim windows
(tset vim.wo :number true)
(tset vim.wo :relativenumber true)

(tset vim.go :autochdir true)
(tset vim.go :autoread true)

(tset vim.bo :commentstring "/**%s*/")

(tset vim.o :expandtab true)

(tset vim.opt :termguicolors true)
(tset vim.opt :smartcase true)
(tset vim.opt :ignorecase true)
(tset vim.opt :grepprg "rg --vimgrep")
(tset vim.opt :swapfile false)

(tset vim.g :terminal_emulator :fish)
(tset vim.opt :shell :fish)
