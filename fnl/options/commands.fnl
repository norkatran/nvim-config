(local event (require :nvit.event))
(vim.cmd (.. "autocmd User " event.REPO_CHANGED
             " :lua require('snacks.dashboard').update()"))
(vim.cmd (.. "autocmd User " event.CURRENT_BRANCH_DELETED
             " :lua require('nvit').view_branches()"))
