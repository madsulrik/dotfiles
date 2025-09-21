return {
  "stevearc/conform.nvim",
  cmd = { "ConformInfo", "Conform" },
  keys = {
    {
      "<C-c>i",
      "<CMD>Conform<CR>",
      mode = "",
      desc = "Format buffer",
    },
  },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        ruby  = { lsp_format = "prefer" },
        eruby = { "erb_format" },
        scss  = { "prettier" },
        css   = { "prettier" },
        sass  = { "prettier" },
      }
    })
    vim.api.nvim_create_user_command("Conform", function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, end_line:len() },
        }
      end
      require("conform").format({ async = true, lsp_format = "fallback", range = range })
    end, { range = true })
  end
}
