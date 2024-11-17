return {
  -- {
  --   "barreiroleo/ltex_extra.nvim",
  --   ft = { "markdown", "tex" },
  --   dependencies = { "neovim/nvim-lspconfig" },
  --   -- yes, you can use the opts field, just I'm showing the setup explicitly
  --   config = function()
  --     require("ltex_extra").setup {
  --     --   {},
  --       server_opts = {
  --         capabilities = {},
  --         on_attach = function(client, bufnr)
  --           -- your on_attach process
  --         end,
  --         settings = {
  --           ltex = {  }
  --         }
  --       },
  --     }
  --   end
  -- },
  {
    "nvimtools/none-ls.nvim",
    lazy = true,
    -- event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason.nvim" },
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.root_dir = opts.root_dir
          or require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git")

      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.formatting.fish_indent,
        nls.builtins.diagnostics.fish,
        nls.builtins.formatting.stylua,
        nls.builtins.formatting.shfmt,

        nls.builtins.diagnostics.vale
      })
    end,
  }
}
