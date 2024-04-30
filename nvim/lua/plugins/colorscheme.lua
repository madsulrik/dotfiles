return {
  -- tokyonight
  {
    "folke/tokyonight.nvim",
    opts = { style = "moon" },
  },

  -- dracula
  {
    "Mofiqul/dracula.nvim",
    -- priority = 1000,
    config = function()
      -- vim.cmd.colorscheme('dracula')
    end,
  },

  -- Doom
  {
    'NTBBloodbath/doom-one.nvim',
    -- priority = 1000,
    config = function()
      -- vim.cmd.colorscheme('doom-one')
    end
  },

  -- catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
    config = function()
      vim.cmd.colorscheme('catppuccin')
    end,
  },
}