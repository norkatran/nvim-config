vim.g["loaded_netrw"] = 1
vim.g["loaded_netrwPlugin"] = 1
vim.g["mapleader"] = " "
vim.wo["number"] = true
vim.wo["relativenumber"] = true
vim.go["autochdir"] = true
vim.go["autoread"] = true
vim.bo["commentstring"] = "/**%s*/"
vim.o["expandtab"] = true
vim.opt["termguicolors"] = true
vim.opt["smartcase"] = true
vim.opt["ignorecase"] = true
vim.opt["grepprg"] = "rg --vimgrep"
vim.opt["swapfile"] = false
vim.g["terminal_emulator"] = "fish"
vim.opt["shell"] = "fish"
return nil