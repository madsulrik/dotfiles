local M = {}

-- ── Helpers ──────────────────────────────────────────────────────────────────

M.default_on_attach = function(client, bufnr)
  local nmap = function(keys, func, desc)
    if desc then desc = "LSP: " .. desc end
    vim.keymap.set("n", keys, func, { silent = true, remap = true, buffer = bufnr, desc = desc })
  end

  nmap("K", vim.lsp.buf.hover, "Hover")
  nmap("<leader>k", vim.lsp.buf.signature_help, "Signature help")

  nmap("gd", require("telescope.builtin").lsp_definitions, "Goto definition")
  nmap("gr", require("telescope.builtin").lsp_references, "Goto references")
  nmap("gI", require("telescope.builtin").lsp_implementations, "Goto implementation")
  nmap("gt", require("telescope.builtin").lsp_type_definitions, "Goto type")
  nmap("gD", vim.lsp.buf.declaration, "Goto declaration")

  nmap("gj", vim.diagnostic.goto_next, "Next diagnostic")
  nmap("gk", vim.diagnostic.goto_prev, "Prev diagnostic")
  nmap("<leader>e", vim.diagnostic.open_float, "Floating line diagnostics")
  nmap("<leader>q", vim.diagnostic.setloclist, "Diagnostics list")

  vim.api.nvim_buf_create_user_command(bufnr, "LspFormat", function()
    vim.lsp.buf.format()
  end, { desc = "Format buffer with LSP" })
end

M.set_capabilities = function()
  local caps = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp = pcall(require, "cmp_nvim_lsp")
  if ok then caps = cmp.default_capabilities(caps) end
  return caps
end

-- ── Optional installers (Mason only for binaries) ────────────────────────────
M.import_dependencies = function()
  pcall(function()
    require("mason").setup()
  end)
  -- neodev should be set up before lua_ls
  pcall(function()
    require("neodev").setup({})
  end)
end


-- ── Main setup ───────────────────────────────────────────────────────────────
M.setup = function()
  M.import_dependencies()

  local defaults = {
    on_attach = M.default_on_attach,
    capabilities = M.set_capabilities(),
  }

  -- LUA
  vim.lsp.config("lua_ls", vim.tbl_deep_extend("force", {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace   = { checkThirdParty = false },
        telemetry   = { enable = false },
      },
    },
  }, defaults))
  vim.lsp.enable("lua_ls")

  -- RUBY (via Bundler; keeps standard + standard-rails working)
  vim.lsp.config("ruby_lsp", vim.tbl_deep_extend("force", {
    cmd = { "bundle", "exec", "ruby-lsp" },
    filetypes = { "ruby", "eruby" },
    init_options = {
      formatter       = "standard",
      linters         = { "standard" },
      enabledFeatures = { formatting = true },
    },
  }, defaults))
  vim.lsp.enable("ruby_lsp")

  -- HTML/CSS helpers
  vim.lsp.config("emmet_language_server", vim.tbl_deep_extend("force", {
    filetypes = { "eruby", "html", "svelte" },
  }, defaults))
  vim.lsp.enable("emmet_language_server")

  vim.lsp.config("somesass_ls", vim.tbl_deep_extend("force", {
    filetypes = { "scss", "sass" },
  }, defaults))
  vim.lsp.enable("somesass_ls")

  -- Purescript
  vim.lsp.config("purescriptls", defaults); vim.lsp.enable("purescriptls")

  -- Elm
  vim.lsp.config("elmls", defaults); vim.lsp.enable("elmls")

  -- Haskell
  vim.lsp.config("hls", defaults); vim.lsp.enable("hls")

  -- Zig
  vim.lsp.config("zls", vim.tbl_deep_extend("force", {
    settings = {
      zls = {
        enable_build_on_save = true,
        build_on_save_step = "check",
      },
    },
  }, defaults))
  vim.lsp.enable("zls")

  -- TS + JS + Svelte
  vim.lsp.config("vtsls", vim.tbl_deep_extend("force", {
    settings = {
      typescript = { format = { enable = false } },
      javascript = { format = { enable = false } },
    },
  }, defaults))
  vim.lsp.enable("vtsls")

  vim.lsp.config("eslint", vim.tbl_deep_extend("force", {
    filetypes = {
      "javascript", "javascriptreact",
      "typescript", "typescriptreact",
      "svelte",
    },
    settings = { format = false }, -- leave formatting to Prettier/Biome
  }, defaults))
  vim.lsp.enable("eslint")

  -- 3) Svelte
  vim.lsp.config("svelte", vim.tbl_deep_extend("force", {
    on_attach = function(client, bufnr)
      M.default_on_attach(client, bufnr)

      -- Make Svelte react to TS/JS changes (SvelteKit: +page.ts, hooks, etc.)
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.js", "*.ts" },
        callback = function(ctx)
          client.notify("$/onDidChangeTsOrJsFile", {
            uri = vim.uri_from_fname(ctx.file),
          })
        end,
      })
    end,
  }, defaults))
  vim.lsp.enable("svelte")

  vim.lsp.config("tailwindcss", vim.tbl_deep_extend("force", {
    filetypes = { "svelte" },
  }, defaults))
  vim.lsp.enable("tailwindcss")
end

return M
