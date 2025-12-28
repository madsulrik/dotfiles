return {
  "zk-org/zk-nvim",
  ft = "markdown",
  cmd = {
    "ZkNew",
    "ZkIndex",
    "ZkBacklinks",
    "ZkLinks",
    "ZkTags",
    "ZkMatch",
    "ZkMatch",

    "ZkPromote",
    "ZkArchive",
    "ZkDemote",
    "ZkGrep",
    "ZkGrepSelection",
  },
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    {
      "<leader>zn",
      function()
        vim.cmd(("ZkNew { dir = 'inbox', title = %q }"):format(vim.fn.input("Title: ")))
      end,
      desc = "ZK: New Note to Inbox (prompt title)",
    },
    {
      "<leader>zo",
      function()
        vim.cmd(("ZkNotes { sort = { 'modified' } }"))
      end,
      desc = "ZK: Quick search",
    },
    { "<leader>zg", "<cmd>ZkGrep<cr>",           desc = "ZK: Grep notes" },

    { "<leader>zt", "<cmd>ZkTags<cr>",           desc = "ZK: Tags" },

    { "<leader>zI", "<cmd>ZkIndex<cr>",           desc = "ZK: Index" },

    -- Visual selection search
    { "<leader>zg", ":'<,'>ZkGrepSelection<cr>", mode = "v",             desc = "ZK: Grep notes (selection)" },
    { "<leader>zf", ":'<,'>ZkMatch<cr>",         mode = "v",             desc = "ZK: Search notes from selection" },
  },
  config = function()
    local zk = require("zk")
    local util = require("zk.util")
    local commands = require("zk.commands")

    local lsp_defaults = require("lsp")

    zk.setup({
      picker = "telescope",
      lsp = {
        config = {
          name = "zk",
          cmd = { "zk", "lsp" },
          filetypes = { "markdown" },
          on_attach = lsp_defaults.default_on_attach,
          capabilities = lsp_defaults.set_capabilities(),
          -- on_attach = ...
          -- etc, see `:h vim.lsp.start()`
        },
        auto_attach = {
          enabled = true,
        },
      },
    })

    require("zkx/commands").setup()

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(ev)
        local bufnr = ev.buf
        local path = vim.fn.expand("%:p")
        if util.notebook_root(path) == nil and not vim.env.ZK_NOTEBOOK_DIR then
          return
        end

        local function bmap(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = false, desc = desc })
        end

        bmap("n", "<CR>", function() vim.lsp.buf.definition() end, "ZK: Open link under cursor")

        bmap("n", "<localleader>n", "<cmd>ZkNewLink { dir = 'inbox' }<cr>", "New note + link (inbox)")
        bmap("v", "<localleader>n", ":'<,'>ZkNewLinkFromSelection { dir = 'inbox' }<cr>",
          "New note + link (from selection)")


        bmap("n", "<localleader>i", "<cmd>ZkInsertLink<cr>", "Insert link")
        bmap("v", "<localleader>i", ":'<,'>ZkInsertLinkAtSelection<cr>", "Link selection")

        bmap("n", "<localleader>b", "<cmd>ZkBacklinks<cr>", "ZK: Backlinks")
        bmap("n", "<localleader>l", "<cmd>ZkLinks<cr>", "ZK: Links")

        bmap("n", "K", function() vim.lsp.buf.hover() end, "ZK: Preview link")

        bmap("n", "<localleader>a", function()
          vim.lsp.buf.code_action()
        end, "Code actions (cursor)")
        bmap("v", "<localleader>a", function()
          vim.lsp.buf.code_action({
            range = {
              ["start"] = vim.api.nvim_buf_get_mark(0, "<"),
              ["end"]   = vim.api.nvim_buf_get_mark(0, ">"),
            },
          })
        end, "ZK: Code actions (selection)")

        bmap("n", "<localleader>zp", "<cmd>ZkPromote<cr>", "ZK: Promote → notes/")
        bmap("n", "<localleader>za", "<cmd>ZkArchive<cr>", "ZK: Archive → archive/")
        bmap("n", "<localleader>zd", "<cmd>ZkDemote<cr>", "ZK: Demote → inbox/")
      end
    })
  end,
}
