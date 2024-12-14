return {
  'ziglang/zig.vim',
  ft = "zig", -- load only for Zig files
  lazy = true,
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "zig",
      callback = function()
        -- Key mapping for Zig build with a description
        vim.keymap.set("n", "<localleader>b", ":make!<CR>",
          { desc = "Run make", noremap = true, silent = true, buffer = true })

        vim.keymap.set("n", "<localleader>r", ":make! run<CR>",
          { desc = "Run make run", noremap = true, silent = true, buffer = true })
      end,

    })
  end,
}
