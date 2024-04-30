return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      -- NOTE: If you are having trouble with this installation,
      --       refer to the README for telescope-fzf-native for more instructions.
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
  },
  keys = function()
    local utils = require("telescope.utils")

    local function telescope_live_grep_open_files()
      require('telescope.builtin').live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end

    local function telescope_fuzzy_search_in_current_buffer()
      require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end

    return {
      -- { "<leader>?",       require('telescope.builtin').oldfiles,                               desc = "[?] Find recently opened files" },
      -- { "<leader>/",       telescope_fuzzy_search_in_current_buffer,                            desc = "[/] Fuzzy search in current buffer" },
      -- { "<leader>s/",      telescope_live_grep_open_files,                                      desc = "[S]earch [/] in Open Files" },

      --
      -- { "<leader><space>", require('telescope.builtin').find_files,                             desc = "[ ] Find existing buffers" },
      --
      -- { "<leader>bf",      require('telescope.builtin').buffers,                                desc = "[B]Buffers [ ] Find existing buffers" },
      { "<leader>gf",      require('telescope.builtin').git_files,                                desc = "[B]Buffers [ ] Find existing buffers" },
      --
    }
  end,
  opts = function()
    local actions = require("telescope.actions")
    return {
      defaults = {
        mappings = {
          i = {
            ["<esc>"] = actions.close,
          },
          n = {},
        },
      },
    }
  end
}
