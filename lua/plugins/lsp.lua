local function _1_()
  local cmp = require("cmp")
  local cmp_lsp = require("cmp_nvim_lsp")
  local capabilities = vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), cmp_lsp.default_capabilities())
  require("mason").setup()
  local function _2_(server_name)
    return require("lspconfig")[server_name].setup({capabilities = capabilities})
  end
  local function _3_()
    local lspconfig = require("lspconfig")
    return lspconfig.lua_ls.setup({capabilities = capabilities, settings = {Lua = {diagnostics = {globals = {"bit", "vim", "it", "describe", "before_each", "after_each"}}, runtime = {version = "Lua 5.1"}}}})
  end
  require("mason-lspconfig").setup({ensure_installed = {"lua_ls", "intelephense", "marksman", "fennel_ls"}, handlers = {_2_, lua_ls = _3_}, automatic_enable = false})
  local function _4_(args)
    return require("luasnip").lsp_expand(args.body)
  end
  cmp.setup({mapping = cmp.mapping.preset.insert({["<C-d>"] = cmp.mapping.scroll_docs(4), ["<C-u>"] = cmp.mapping.scroll_docs(( - 4)), ["<CR>"] = cmp.mapping.confirm({select = true}), ["<Tab>"] = cmp.mapping.select_next_item()}), snippet = {expand = _4_}, sources = cmp.config.sources({{name = "nvim_lsp"}, {name = "luasnip"}})})
  vim.diagnostic.config({float = {border = "rounded", header = "", prefix = "", source = "always", style = "minimal", focusable = false}, virtual_text = true})
  local function _5_()
    return vim.lsp.buf.hover({border = "rounded"})
  end
  vim.keymap.set("n", "K", _5_)
  return vim.keymap.set("n", "gf", vim.lsp.buf.format)
end
return {{"mason-org/mason.nvim", version = "1.11.0"}, {"mason-org/mason-lspconfig.nvim", version = "1.32.0"}, {"neovim/nvim-lspconfig", config = _1_, dependencies = {"mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline", "hrsh7th/nvim-cmp", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip", "j-hui/fidget.nvim"}}, {"atweiden/vim-fennel"}}