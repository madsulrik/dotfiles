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
    -- local utils = require("telescope.utils")
    local builtin = require('telescope.builtin')

    local function telescope_live_grep_open_files()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end

    local function telescope_find_files_root()
      builtin.find_files {
        root = false
      }
    end

    local function telescope_git_files_untracked()
      builtin.git_files {
        show_untracked = true
      }
    end

    local function telescope_fuzzy_search_in_current_buffer()
      builtin.current_buffer_fuzzy_find()
      -- Old layout. like the default a lot better
      -- builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      --   layout_strategy='horizontal',
      --   winblend = 50,
      --   previewer = true,
      -- })
    end

    return {
      -- -- Buffers
      { "<leader>bb",      "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "[B]Buffers [ ] Find existing buffers" },
      --
      -- -- Find
      { "<C-s>",             telescope_fuzzy_search_in_current_buffer,                      desc = "Fuzzy [s]earch in current buffer" },
      { "<leader><space>", builtin.find_files,                                            desc = "Find files (root dir)" },
      { "<leader>ff",      builtin.find_files,                                            desc = "Find files (root dir)" },
      { "<leader>fF",      telescope_find_files_root,                                     desc = "Find files (cwd)" },
      { "<leader>fb",      "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      { "<leader>fr",      builtin.oldfiles,                                              desc = "Recent" },
      -- Search
      { "<leader>ss",      builtin.lsp_document_symbols,                                  desc = "Goto symbol" },
      { "<leader>sg",      builtin.live_grep,                                             desc = "Grep (root dir)" },
      { "<leader>sd",      "<cmd>Telescope diagnostics bufnr=0<cr>",                      desc = "Document Diagnostics" },
      --
      { "<leader>pf",      builtin.git_files,                                     desc = "Find files (git files)" },
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
