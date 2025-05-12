[:rktjmp/hotpot.nvim
  :nvim-tree/nvim-web-devicons
  {1 :nvim-lua/plenary.nvim :lazy true }
  :nvim-telescope/telescope.nvim
  {1 :sontungexpt/witch :priority 1000 :lazy false :config (fn [_ x] ((. (require :witch) :setup) x))}
  :rcarriga/nvim-notify
  :nvim-treesitter/nvim-treesitter
  {1 :ellisonleao/glow.nvim :config true :cmd :Glow}
  {1 :m4xshen/hardtime.nvim :dependencies [:MunifTanjim/nui.nvim] :opts {}}
  :airblade/vim-rooter
  {1 :j-hui/fidget.nvim :opts { :notification { :override_vim_notify true }}}
  {1 :nvim-neo-tree/neo-tree.nvim :branch :v3.x :dependencies [:nvim-lua/plenary.nvim :nvim-tree/nvim-web-devicons :MunifTanjim/nui.nvim] :lazy false :opts {}}
  {1 :nvim-lualine/lualine.nvim :config (fn [] ((. (require :lualine) :setup) { :theme :powerline_dark :sections { :lualine_a [ :mode ] :lualine_b [ :branch :diff :diagnostics ] :lualine_c [ :filename ] } })) }
  {1 :romgrk/barbar.nvim :dependencies [:lewis6991/gitsigns.nvim :nvim-tree/nvim-web-devicons] :init (fn [] (tset vim.g :barbar_auto_setup false)) :opts {} :version :^1.0.0}
  {1 :folke/which-key.nvim :event :VeryLazy :opts { :preset :modern :filter (fn [m] (and (?. m :desc) (~= (. m :desc) "Dashboard action")))}}
  :yorickpeterse/nvim-window
  :echasnovski/mini.surround
  {1 :m-lysa/nvit :dependencies [:MunifTanjim/nui.nvim] :dev true :opts { :repo_paths [ "~/worktrees" "~/projects" ]}}
  ]
