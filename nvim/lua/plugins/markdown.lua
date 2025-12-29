return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
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
  {
    "andrewferrier/wrapping.nvim",
    ft = "markdown",
    config = function()
      require("wrapping").setup()

      local function copy_flatten_visual()
        -- yank visual selection to system clipboard
        vim.cmd('normal! "+y')

        local reg = vim.fn.getreg("+")
        reg = reg:gsub("\r", "\n")

        -- 1) Protect markdown hard line breaks:
        --    "  \n" (two spaces + newline)
        --    "\\\n" (backslash + newline)
        reg = reg:gsub("  \n", "§§HARD_BR§§")
        reg = reg:gsub("\\\n", "§§HARD_BR§§")

        -- 2) Protect paragraph breaks (blank lines)
        reg = reg:gsub("\n\n+", "§§PARA_BREAK§§")

        -- 3) Flatten remaining single newlines (normal wraps) to spaces
        reg = reg:gsub("\n", " ")

        -- 4) Restore paragraph breaks and hard line breaks
        reg = reg:gsub("§§PARA_BREAK§§", "\n\n")
        reg = reg:gsub("§§HARD_BR§§", "\n")

        vim.fn.setreg("+", reg)
      end

      local function copy_flatten_paragraph()
        -- select inner paragraph and yank to system clipboard
        vim.cmd('normal! vipy"+y')

        local reg = vim.fn.getreg("+")
        reg = reg:gsub("\r", "\n")

        -- same protection logic as visual, in case the paragraph has hard breaks
        reg = reg:gsub("  \n", "§§HARD_BR§§")
        reg = reg:gsub("\\\n", "§§HARD_BR§§")

        -- we don't expect paragraph breaks here, but it doesn't hurt to be safe:
        reg = reg:gsub("\n\n+", "§§PARA_BREAK§§")

        reg = reg:gsub("\n", " ")
        reg = reg:gsub("§§PARA_BREAK§§", "\n\n")
        reg = reg:gsub("§§HARD_BR§§", "\n")

        vim.fn.setreg("+", reg)
      end

      vim.keymap.set("x", "<localleader>y", copy_flatten_visual, { desc = "Copy (flatten wraps, keep breaks)" })
      vim.keymap.set("n", "<localleader>Y", copy_flatten_paragraph, { desc = "Copy paragraph (flatten wraps, keep breaks)" })
    end,
  },
  {
    "folke/zen-mode.nvim",
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
    }
  }
}
