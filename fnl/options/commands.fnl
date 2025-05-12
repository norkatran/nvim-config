(local event (require :nvit.event))
(vim.cmd (.. "autocmd User " event.REPO_CHANGED
             " :lua require('snacks.dashboard').update()"))

(vim.cmd (.. "autocmd User " event.CURRENT_BRANCH_DELETED
             " :lua require('nvit').view_branches()"))

(vim.api.nvim_create_autocmd :TextYankPost {
                             :desc "Highlight yanked text"
                             :group (vim.api.nvim_create_augroup :highlight-yank { :clear true })
                             :callback vim.highlight.on_yank})
