return {
  {
    dir = "~/Documents/projects/rails.nvim",
    opts = {},
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "ruby",
        callback = function()
          require("which-key").add({
            { "<localleader>f", group = "find" }
          })
          vim.keymap.set("n", "<localleader>fc", require("rails").find_controllers,
            { desc = "Rails find: Controller", noremap = true, silent = true, buffer = true })

          vim.keymap.set("n", "<localleader>fm", require("rails").find_models,
            { desc = "Rails find: Model", noremap = true, silent = true, buffer = true })

          vim.keymap.set("n", "<localleader>fv", require("rails").find_views,
            { desc = "Rails find: View", noremap = true, silent = true, buffer = true })

          vim.keymap.set("n", "<localleader>fs", require("rails").find_stimulus,
            { desc = "Rails find: Stimulus controller", noremap = true, silent = true, buffer = true })

          vim.keymap.set("n", "<localleader>fb", require("rails").find_view_components,
            { desc = "Rails find: Bliss View Componenet", noremap = true, silent = true, buffer = true })
        end,
      })
    end,
  },
}
--sdf asdf 
