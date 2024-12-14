local M = {}

M.import_depdendencies = function()
  local loaded, mason = pcall(require, "mason")
  if not loaded then
    return
  end

  local loaded, mlsp = pcall(require, "mason-lspconfig")
  if not loaded then
    return
  end

  -- IMPORTANT: make sure to setup neodev BEFORE lspconfig
  local loaded, luadev = pcall(require, "neodev")
  if loaded then
    luadev.setup()
  end

  mason.setup()
  mlsp.setup()
end

M.setup_language_servers = function(defaults)
  local lspconfig = require("lspconfig")
  local lsputil = require("lspconfig.util")


  lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim" },
      },
      workspace = {
        -- -- Make the server aware of Neovim runtime files
        -- library = {
        --   [vim.fn.expand "$VIMRUNTIME/lua"] = true,
        --   [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
        -- },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    }
  }, defaults))

  -- Ruby
  lspconfig.ruby_lsp.setup(vim.tbl_deep_extend("force", {
    filetypes = { "ruby", "eruby" },
    init_options = {
      -- formatter = 'standard',
      linters = { 'standard' },
      enabledFeatures = {
        formating = false,
      }
    },
  }, defaults))


  lspconfig.html.setup(vim.tbl_deep_extend("force", {
    filetypes = { "html" },
  }, defaults))


  -- Purescript
  lspconfig.purescriptls.setup(defaults)

  -- Elm
  lspconfig.elmls.setup(defaults)

  -- Haskell
  lspconfig.hls.setup(defaults)

  -- Zig
  lspconfig.zls.setup(vim.tbl_deep_extend("force", {
    enable_build_on_save = true,
    build_on_save_step = "check"
  }, defaults))
end


M.default_on_attach = function(client, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { silent = true, remap = true, buffer = bufnr, desc = desc })
  end


  nmap("K", vim.lsp.buf.hover, "Hover documentation")
  nmap("<leader>k", vim.lsp.buf.signature_help, "Signature documentation")

  nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap("gt", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

  nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]efinition")

  -- Navigate diagnotis errors/mesages
  nmap("gj", vim.diagnostic.goto_next, "Go to next diagnostic message")
  nmap("gk", vim.diagnostic.goto_prev, "Go to preious diagnostic message")
  nmap("<leader>e", vim.diagnostic.open_float, "Open floating diagnostic message")
  nmap("<leader>q", vim.diagnostic.setloclist, "Open diagnostic list")

  vim.api.nvim_buf_create_user_command(bufnr, 'LspFormat', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

M.set_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local loaded, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if not loaded then
    return capabilities
  end

  return cmp_nvim_lsp.default_capabilities(capabilities)
end

M.setup = function()
  M.import_depdendencies()

  local defaults = {
    on_attach = M.default_on_attach,
    capabilities = M.set_capabilities(),
  }

  M.setup_language_servers(defaults)
end

return M
