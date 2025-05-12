[{1 :mason-org/mason.nvim :version :1.11.0}
 {1 :mason-org/mason-lspconfig.nvim :version :1.32.0}
 {1 :neovim/nvim-lspconfig
  :config (fn []
            (local cmp (require :cmp))
            (local cmp-lsp (require :cmp_nvim_lsp))
            (local capabilities
                   (vim.tbl_deep_extend :force {}
                                        (vim.lsp.protocol.make_client_capabilities)
                                        (cmp-lsp.default_capabilities)))
            ((. (require :mason) :setup))
            ((. (require :mason-lspconfig) :setup) {:automatic_enable false
                                                    :ensure_installed [:lua_ls
                                                                       :intelephense
                                                                       :marksman]
                                                    :handlers {1 (fn [server-name]
                                                                   ((. (require :lspconfig)
                                                                       server-name
                                                                       :setup) {: capabilities}))
                                                               :lua_ls (fn []
                                                                         (local lspconfig
                                                                                (require :lspconfig))
                                                                         (lspconfig.lua_ls.setup {: capabilities
                                                                                                  :settings {:Lua {:diagnostics {:globals [:bit
                                                                                                                                           :vim
                                                                                                                                           :it
                                                                                                                                           :describe
                                                                                                                                           :before_each
                                                                                                                                           :after_each]}
                                                                                                                   :runtime {:version "Lua 5.1"}}}}))}})
            (cmp.setup {:mapping (cmp.mapping.preset.insert {:<C-d> (cmp.mapping.scroll_docs 4)
                                                             :<C-u> (cmp.mapping.scroll_docs (- 4))
                                                             :<CR> (cmp.mapping.confirm {:select true})
                                                             :<Tab> (cmp.mapping.select_next_item)})
                        :snippet {:expand (fn [args]
                                            ((. (require :luasnip) :lsp_expand) args.body))}
                        :sources (cmp.config.sources [{:name :nvim_lsp}
                                                      {:name :luasnip}])})
            (vim.diagnostic.config {:float {:border :rounded
                                            :focusable false
                                            :header ""
                                            :prefix ""
                                            :source :always
                                            :style :minimal}
                                    :virtual_text true})
            (vim.keymap.set :n :K
                            (fn [] (vim.lsp.buf.hover {:border :rounded})))
            (vim.keymap.set :n :gf vim.lsp.buf.format))
  :dependencies [:mason-org/mason.nvim
                 :mason-org/mason-lspconfig.nvim
                 :hrsh7th/cmp-nvim-lsp
                 :hrsh7th/cmp-buffer
                 :hrsh7th/cmp-path
                 :hrsh7th/cmp-cmdline
                 :hrsh7th/nvim-cmp
                 :L3MON4D3/LuaSnip
                 :saadparwaiz1/cmp_luasnip
                 :j-hui/fidget.nvim]}
 {1 :atweiden/vim-fennel}]
