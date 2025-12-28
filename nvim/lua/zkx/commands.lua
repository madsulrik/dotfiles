local M = {}

function M.setup()
  local commands = require("zk.commands")
  local util = require("zk.util")

  local function notebook_root()
    local path = vim.fn.expand("%:p")
    return util.notebook_root(path) or vim.env.ZK_NOTEBOOK_DIR
  end

  local function ensure_root()
    local root = notebook_root()
    if not root or root == "" then
      vim.notify("ZK notebook not found (open a note in the notebook or set $ZK_NOTEBOOK_DIR)", vim.log.levels.WARN)
      return nil
    end
    return root
  end

  local function current_path()
    return vim.fn.expand("%:p")
  end

  local function move_current_to(subdir)
    local root = ensure_root()
    if not root then return end

    local src = current_path()
    if src == "" then return end

    local filename = vim.fn.fnamemodify(src, ":t")
    local dst = root .. "/" .. subdir .. "/" .. filename

    local out = vim.fn.system({ "mv", "-n", src, dst })
    if vim.v.shell_error ~= 0 then
      vim.notify(("Move failed: %s"):format(out), vim.log.levels.ERROR)
      return
    end

    vim.cmd("edit " .. vim.fn.fnameescape(dst))
  end

  local function current_location()
    local bufnr = 0
    local uri = vim.uri_from_bufnr(bufnr)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    -- LSP is 0-indexed lines
    local line = row - 1
    local character = col

    return {
      uri = uri,
      range = {
        start = { line = line, character = character },
        ["end"] = { line = line, character = character },
      },
    }
  end

  local function selection_location()
    local bufnr = 0
    local uri = vim.uri_from_bufnr(bufnr)
    local s = vim.api.nvim_buf_get_mark(bufnr, "<")
    local e = vim.api.nvim_buf_get_mark(bufnr, ">")

    -- marks are (row, col) with 1-indexed row
    return {
      uri = uri,
      range = {
        start = { line = s[1] - 1, character = s[2] },
        ["end"] = { line = e[1] - 1, character = e[2] },
      },
    }
  end

  local function lsp_execute_zk_new(opts)
    local root = ensure_root()
    if not root then return end

    -- Find zk LSP client
    local zk_client = nil
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if c.name == "zk" then
        zk_client = c
        break
      end
    end
    if not zk_client then
      vim.notify("zk LSP client is not attached to this buffer", vim.log.levels.WARN)
      return
    end

    -- `zk.new` wants "a path to any file/dir in the notebook" as first arg.
    -- We can pass current file path.
    local path = vim.fn.expand("%:p")

    vim.lsp.buf_request(0, "workspace/executeCommand", {
      command = "zk.new",
      arguments = {
        path,
        opts or {},
      },
    })
  end

  -- Grep notes (whole notebook)
  commands.add("ZkGrep", function(_opts)
    local root = ensure_root()
    if not root then return end
    require("telescope.builtin").live_grep({
      cwd = root,
      prompt_title = "ZK Grep",
      glob_pattern = { "*.md", "*.markdown", "*.mdown" },
    })
  end)

  -- Grep notes with visual selection as default query
  commands.add("ZkGrepSelection", function(_opts)
    local root = ensure_root()
    if not root then return end

    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.fn.getline(start_line, end_line)
    local text = table.concat(lines, "\n")

    require("telescope.builtin").live_grep({
      cwd = root,
      prompt_title = "ZK Grep (selection)",
      default_text = text,
      glob_pattern = { "*.md", "*.markdown", "*.mdown" },
    })
  end, { needs_selection = true })

  -- Promotion / archiving (lifecycle by folder)
  commands.add("ZkPromote", function(_opts)
    move_current_to("notes")
  end)

  commands.add("ZkArchive", function(_opts)
    move_current_to("archive")
  end)

  commands.add("ZkDemote", function(_opts)
    move_current_to("inbox")
  end)

  -- Create a new note and insert a link at the cursor
  commands.add("ZkNewLink", function(options)
    options = options or {}
    local title = options.title or vim.fn.input("Title: ")
    if title == "" then return end

    options.title = title
    options.insertLinkAtLocation = current_location()
    lsp_execute_zk_new(options)
  end)

  -- Create a new note and replace the visual selection with a link to it
  commands.add("ZkNewLinkFromSelection", function(options)
    options = options or {}
    local title = options.title or vim.fn.input("Title: ")
    if title == "" then return end

    options.title = title
    options.insertLinkAtLocation = selection_location()
    lsp_execute_zk_new(options)
  end, { needs_selection = true })
end

return M
