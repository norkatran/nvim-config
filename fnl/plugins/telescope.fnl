(fn builtin [command opts]
  (fn []
    ((. (require :telescope.builtin) command) opts)))

[{1 :nvim-telescope/telescope.nvim
  :dependencies [:nvim-lua/plenary.nvim
                 {1 :nvim-telescope/telescope-fzf-native.nvim :build :make}
                 :nvim-treesitter/nvim-treesitter
                 :nvim-tree/nvim-web-devicons
                 :folke/which-key.nvim]
  :config (fn []
            (do
              ((. (require :telescope) :setup) {:defaults {:prompt_prefix "/"
                                                           :mappings {:i {:<esc> (. (require :telescope.actions)
                                                                                    :close)}}}
                                                :extensions {:fzf {}}})
              ((. (require :which-key) :add) [{1 :<leader>p :group :Project}
                                              {1 :<leader>p<leader>
                                               2 (builtin :find_files {})
                                               :desc "Project Files"}
                                              {1 :<leader>p/
                                               2 (builtin :live_grep {})
                                               :desc "Project Grep"}
                                              {1 :<leader>?
                                               2 (builtin :keymaps {})
                                               :desc :Keymaps}
                                              {1 :<leader>c :group :Config}
                                              {1 :<leader>cp
                                               2 (builtin :find_files
                                                          {:cwd (vim.fs.joinpath (vim.fn.stdpath :data)
                                                                                 :lazy)})
                                               :desc "Browse Packages"}
                                              {1 :<leader>c<leader>
                                               2 (builtin :find_files
                                                          {:cwd (vim.fn.stdpath :config)})
                                               :desc "Browse Config"}
                                              {1 :<leader>b :group :Buffers}
                                              {1 :<leader>b<leader>
                                               2 (builtin :buffers {})
                                               :desc "Browse Buffers"}
                                              {1 :<leader>r :group :Registers}
                                              {1 :<leader>r<leader>
                                               2 (builtin :registers {})
                                               :desc "Browse Registers"}
                                              {1 :<leader>h :group :Help}
                                              {1 :<leader>ht
                                               2 (builtin :help_tags {})
                                               :desc "Neovim :help"}])))}]
