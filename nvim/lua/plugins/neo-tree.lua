return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  keys = {
    {"<leader>op",
    "<cmd>Neotree toggle=true<cr>",
    desc = "Open Neotree"}
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      window = {
        mappings = {
          ["<tab>"] = {
            "toggle_node",
            nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
          },
        }
      },
      filesystem = {

        hijack_netrw_behavior = "disabled"
      }
    })
  end
}
