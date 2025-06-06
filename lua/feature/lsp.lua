local group = vim.api.nvim_create_augroup("lsp", { clear = true })

local listOptions = {
  on_list = function(options)
    vim.fn.setqflist({}, ' ', options)
      require("telescope.builtin").quickfix()
  end
}

local locationOptions = {
  on_list = listOptions.on_list,
  reuse_win = true,
}

local function format_on_save(bufnr, client_id)
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    buffer = bufnr,
    callback = function(args)
      vim.lsp.buf.format({ bufnr = bufnr, id = client_id })
    end
  })
end

local function enable_autocomplete(bufnr, client_id)
  vim.lsp.completion.enable(true, client_id, bufnr, { autotrigger = true })
end

local function enable_inlay_hints(bufnr, client_id)
  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
end

local function enable_diagnostics(bufnr, client_id)
  vim.diagnostic.enable(true, { bufnr = bufnr })
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = group,
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method("textDocument/formatting") then
      format_on_save(args.buf, client.id)
    end
    if client:supports_method("textDocument/completion") then
      enable_autocomplete(args.buf, client.id)
    end
    if client:supports_method('textDocument/inlayHint') then
      enable_inlay_hints(args.buf, client.id)
    end
    if client:supports_method('textDocument/publishDiagnostics') then
      enable_diagnostics(args.buf, client.id)
    end
  end
})

local M = {}

local function get_mode_bindings()
  return {
    ["textDocument/definition"] = { 'd', function() return vim.lsp.buf.definition(locationOptions) end, desc = 'Go To Definition' },
    ["textDocument/documentSymbol"] = { 's', function() return vim.lsp.buf.document_symbol(listOptions) end, desc = 'Symbols' },
    ["typeHierarchy/subTypes"] = { '-', function() return vim.lsp.buf.typehierarchy('subtypes') end, desc = 'Sub Types' },
    ["typeHierarchy/superTypes"] = { '+', function() return vim.lsp.buf.typehierarchy('supertypes') end, desc = 'Super Types' },
    ['callHierarchy/incomingCalls'] = { 'i', vim.lsp.buf.incoming_calls, desc = 'Incoming Calls' },
    ['callHierarchy/outgoingCalls'] = { 'o', vim.lsp.buf.outgoing_calls, desc = 'Outgoing Calls' },
    ['textDocument/references'] = {
      'r',
      function()
        return vim.lsp.buf.references({ includeDeclaration = false },
          listOptions)
      end,
      desc = 'References'
    },
    ['textDocument/rename'] = {
      'm',
      function()
        require("ui").create_input("Rename Buffer", function(rename)
          vim.lsp.buf.rename(rename)
        end)
      end,
      desc = "Rename"
    },
  }
end


function M.get_lsp_mode_keybinds()
  local keybinds = {}
  local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  for _, client in ipairs(clients) do
    for capability, keymap in pairs(get_mode_bindings()) do
      if client:supports_method(capability) then
        table.insert(keybinds, keymap)
      end
    end
  end
  return keybinds
end

return M
