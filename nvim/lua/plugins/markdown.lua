return {

  -- {
  --   'vigoux/ltex-ls.nvim',
  --   -- dependencies = 'neovim/nvim-lspconfig',
  --   opts = {
  --     filetypes = {
  --       'bib',
  --       'gitcommit',
  --       'latex',
  --       'markdown',
  --       'rst',
  --       'tex',
  --       'text',
  --     },
  --     -- use_spellfile = true,
  --     settings = {
  --       ltex = {
  --         language = 'en_US',
  --         additionalRules = {
  --           enablePickyRules = true,
  --           motherTongue = 'en',
  --         },
  --       },
  --     },
  --   },
  -- },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      heading = {
        enabled = false,
        sign = false,
      }
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  -- Lua
  {
    "preservim/vim-pencil",
    ft = "markdown",
    config = function()
      -- Plugin settings for vim-pencil
      vim.g["pencil#wrapModeDefault"] = "soft"
      vim.g["pencil#autoformat"] = 1
      vim.g["pencil#textwidth"] = 100
      vim.cmd("call pencil#init({'wrap': 'soft', 'autoformat': 1})")

      -- Key mappings only for markdown files with descriptions
      local opts = { noremap = true, silent = true, buffer = true }
      vim.keymap.set("n", "Q", "gqap", vim.tbl_extend("force", opts, { desc = "Reformat paragraph (normal mode)" }))
      vim.keymap.set("x", "Q", "gq", vim.tbl_extend("force", opts, { desc = "Reformat selection (visual mode)" }))
      vim.keymap.set("n", "<leader>Q", "vapJgqap",
        vim.tbl_extend("force", opts, { desc = "Reformat and join paragraph" }))
      vim.keymap.set("n", "<localleader>jp", "vipJ",
        vim.tbl_extend("force", opts, { desc = "Join all lines in the current paragraph" }))
      vim.keymap.set("n", "<localleader>jb", ":%norm vipJ<CR>",
        vim.tbl_extend("force", opts, { desc = "Join all lines in all paragraphs in the buffer" }))
    end,
  },
  {
    "folke/twilight.nvim",
    -- ft = "markdown",
    opts = {
      context = 1,
    }
  },
  {
    "folke/zen-mode.nvim",
    dependencies = { 'folke/twilight.nvim' },
    keys = {
      {
        "<leader>tz",
        "<cmd>ZenMode<cr>",
        desc = "Toggle ZenMode"
      }
    },
    cmd = { "ZenMode" },
    opts = {
      window = {
        options = {
          signcolumn = "no",      -- disable signcolumn
          number = false,         -- disable number column
          relativenumber = false, -- disable relative numbers
        }
      },
      on_open = function(win)
        vim.g["pencil#wrapModeDefault"] = "soft"
        vim.g["pencil#autoformat"] = 1
        vim.cmd("Pencil") -- Activate Pencil mode
      end,
      on_close = function()
        vim.cmd("PencilOff")
      end,
    }
  }
}
