return {
  {
    dir = "~/Documents/projects/rails.nvim",
    opts = {},
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "ruby",
        callback = function()
          require("which-key").add({
            { "<localleader>f", group = "find" }
          })
          vim.keymap.set("n", "<localleader>fc", require("rails").find_controllers,
            { desc = "Rails find Controllers", noremap = true, silent = true, buffer = true })
        end,
      })
    end,
  },
}
