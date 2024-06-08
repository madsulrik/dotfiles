return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local whichkey = require("which-key")



    local tele_utils = require("telescope.utils")
    local tele_built = require('telescope.builtin')

    local function telescope_live_grep_open_files()
      tele_built.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end

    local function telescope_fuzzy_search_in_current_buffer()
      tele_built.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end


    whichkey.register {
      ['<leader>?'] = { tele_built.oldfiles, "[?] Find recently opened files" },
      ['<leader><space>'] = { tele_built.find_files, "[ ] Find files" },
      ['<leader>/'] = { telescope_fuzzy_search_in_current_buffer, "[/] Fuzzy search in current buffer" },
      -- { "<leader>.",       require('telescope.builtin').find_files({ cwd = utils.buffer_dir }), desc = "[.] Find files in buffer directory" },
      ['<leader>b'] = {
        name = '[B]uffers', _ = 'which_key_ignore',
        b = { tele_built.buffers, "[B]uffers [B] Find existing buffers" },
        f = { "<cmd>Format<cr>", "Format" },
      },
      ['<leader>f'] = {
        name = '[F]ind', _ = 'which_key_ignore',
        ["/"] = { telescope_live_grep_open_files , "[F]ind [/] live in open files" },
        d = { tele_built.diagnostics, "[F]ind [D]iagnostics" },
        g = { tele_built.live_grep, "[F]iles Live [G]rep" },
        s = { tele_built.lsp_document_symbols, "[F]ind lsp document [S]ymbols" },
        t = { "<cmd>Neotree<CR>", "[F] Open Neo[T]ree" },
      },
      ['<leader>t'] = {
        name = "[T]ests", _ = 'which_key_ignore',
        t = {"<cmd>TestNearest<CR>", "[T]est [t] Nearest"},
        T = {"<cmd>TestFile<CR>", "[T]est [T] ile"}
      },
      ['<leader>x'] = {
        name = "[T]rouble",
        x = { "<cmd>Trouble<CR>", "[T]rouble Open" },
        w = { "<cmd>Trouble workspace_diagnostics<CR>", "[T]rouble [W]orkspace Diagnostics" },
        d = { "<cmd>Trouble document_diagnostics<CR>", "[T]rouble Document [D]iagnostics" },
        l = { "<cmd>Trouble loclist<CR>", "[T]rouble [L]oclist" },
        q = { "<cmd>Trouble quickfix<CR>", "[T]rouble [Q]uick Fix" },
        r = { "<cmd>Trouble lsp_references<CR>", "[T]rouble LSP [R]eferences" },
        _ = 'which_key_ignore',
      },
    }
  end
}
