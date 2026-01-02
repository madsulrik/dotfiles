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
    "ZkNotes",
    "ZkArchive",
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
        vim.cmd(("ZkNew { dir = 'field', title = %q }"):format(vim.fn.input("Title: ")))
      end,
      desc = "ZK: New Field Note (prompt title)",
    },
    {
      "<leader>zN",
      function()
        vim.cmd(("ZkNew { dir = 'pkm', title = %q }"):format(vim.fn.input("PKM Title: ")))
      end,
      desc = "ZK: New PKM Note (prompt title)",
    },
    {
      "<leader>zo",
      function()
        vim.cmd(("ZkNotes { hrefs = { 'field' }, sort = { 'modified' } }"))
      end,
      desc = "ZK: Search (field)",
    },
    {
      "<leader>zO",
      function()
        vim.cmd(("ZkNotes { hrefs = { 'pkm' }, sort = { 'modified' } }"))
      end,
      desc = "ZK: Search (pkm)",
    },
    {
      "<leader>z/",
      function()
        vim.cmd(("ZkNotes { sort = { 'modified' } }"))
      end,
      desc = "ZK: Search (all)",
    },
    { "<leader>zg", "<cmd>ZkGrep { scope = 'field' }<cr>",           desc = "ZK: Grep (field)" },
    { "<leader>zG", "<cmd>ZkGrep { scope = 'pkm' }<cr>",             desc = "ZK: Grep (pkm)" },
    { "<leader>z*", "<cmd>ZkGrep {}<cr>",                            desc = "ZK: Grep (all)" },

    { "<leader>zt", "<cmd>ZkTags<cr>",                               desc = "ZK: Tags" },
    { "<leader>zI", "<cmd>ZkIndex<cr>",                              desc = "ZK: Index" },

    -- Visual selection search

    { "<leader>zg", ":'<,'>ZkGrepSelection { scope = 'field' }<cr>", mode = "v",               desc = "ZK: Grep selection (field)" },
    { "<leader>zG", ":'<,'>ZkGrepSelection { scope = 'pkm' }<cr>",   mode = "v",               desc = "ZK: Grep selection (pkm)" },
    { "<leader>zf", ":'<,'>ZkMatch<cr>",                             mode = "v",               desc = "ZK: match notes from selection" },
  },
  config = function()
    local zk = require("zk")
    local util = require("zk.util")
    local commands = require("zk.commands")
    local zkx = require("zkx.commands")

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

    zkx.setup()

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(ev)
        local bufnr = ev.buf
        local path = vim.fn.expand("%:p")

        local root = util.notebook_root(path) or vim.env.ZK_NOTEBOOK_DIR
        if not root then
          return
        end

        local rel = zkx.relpath(root, path)

        local in_pkm = rel:match("^pkm/") ~= nil
        local in_field = rel:match("^field/") ~= nil

        local function bmap(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = false, desc = desc })
        end

        bmap("n", "<CR>", function() vim.lsp.buf.definition() end, "ZK: Open link under cursor")
        bmap("n", "K", function() vim.lsp.buf.hover() end, "ZK: Preview link")

        bmap("n", "<localleader>za", "<cmd>ZkArchive<cr>", "Field: Archive → field/archive/")

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

        if in_pkm then
          bmap("n", "<localleader>n", "<cmd>ZkNewLink {dir = 'pkm'}<cr>", "PKM: New note + link")
          bmap("v", "<localleader>n", ":'<,'>ZkNewLinkFromSelection {dir = 'pkm'}<cr>", "PKM: New note + link (selection)")

          bmap("n", "<localleader>i", "<cmd>ZkInsertLink {hrefs = {'pkm'}} <cr>", "PKM: Insert link")
          bmap("v", "<localleader>i", ":'<,'>ZkInsertLinkAtSelection {hrefs = {'pkm'}}<cr>", "PKM: Link selection")

          bmap("n", "<localleader>b", "<cmd>ZkBacklinks<cr>", "PKM: Backlinks")
          bmap("n", "<localleader>l", "<cmd>ZkLinks<cr>", "PKM: Links")
        end
      end
    })
  end,
}
