local M = {}

function M.lua_pesc(s)
  return (s:gsub("([^%w])", "%%%1"))
end

function M.relpath(root, abs)
  if not root or root == "" then return abs end
  return abs:gsub("^" .. M.lua_pesc(root) .. "/", "")
end

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

  local function is_field_note(root, abs)
    local rel = M.relpath(root, abs)
    return rel:match("^field/") ~= nil
  end

  local function move_current_to_field_archive()
    local root = ensure_root()
    if not root then return end

    local src = current_path()
    if src == "" then return end

    -- Only archive field notes
    if not is_field_note(root, src) then
      vim.notify("Archive only works for field notes (field/…)", vim.log.levels.WARN)
      return
    end

    local filename = vim.fn.fnamemodify(src, ":t")
    local dst_dir = root .. "/field/archive"
    vim.fn.mkdir(dst_dir, "p")

    local dst = dst_dir .. "/" .. filename

    -- Use filesystem rename (atomic) rather than shelling out to mv
    local ok, err = vim.loop.fs_rename(src, dst)
    if not ok then
      vim.notify(("Archive failed: %s"):format(tostring(err)), vim.log.levels.ERROR)
      return
    end

    vim.cmd("edit " .. vim.fn.fnameescape(dst))
  end

  local function current_location()
    local bufnr = 0
    local uri = vim.uri_from_bufnr(bufnr)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    return {
      uri = uri,
      range = {
        start = { line = row - 1, character = col },
        ["end"] = { line = row - 1, character = col },
      },
    }
  end

  local function selection_location()
    local bufnr = 0
    local uri = vim.uri_from_bufnr(bufnr)
    local s = vim.api.nvim_buf_get_mark(bufnr, "<")
    local e = vim.api.nvim_buf_get_mark(bufnr, ">")
    return {
      uri = uri,
      range = {
        start = { line = s[1] - 1, character = s[2] },
        ["end"] = { line = e[1] - 1, character = e[2] },
      },
    }
  end

  local function get_zk_client()
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if c.name == "zk" then
        return c
      end
    end
    return nil
  end

  -- Executes zk.new via LSP.
  -- `locate_path` should be ANY file/dir within the notebook. We use notebook root by default.
  local function lsp_execute_zk_new(opts)
    local root = ensure_root()
    if not root then return end

    local zk_client = get_zk_client()
    if not zk_client then
      vim.notify("zk LSP client is not attached to this buffer", vim.log.levels.WARN)
      return
    end

    vim.lsp.buf_request(0, "workspace/executeCommand", {
      command = "zk.new",
      arguments = {
        root,
        opts or {},
      },
    })
  end


  -- --- Grep ---


  commands.add("ZkGrep", function(options)
    options = options or {}
    local root = ensure_root()
    if not root then return end

    local scope = options.scope -- "field" | "pkm" | nil
    local cwd = root
    if scope and scope ~= "" then
      cwd = root .. "/" .. scope
    end

    require("telescope.builtin").live_grep({
      cwd = cwd,
      prompt_title = scope and ("ZK Grep (" .. scope .. ")") or "ZK Grep",
      glob_pattern = { "*.md", "*.markdown", "*.mdown" },
    })
  end)

  commands.add("ZkGrepSelection", function(options)
    options = options or {}
    local root = ensure_root()
    if not root then return end

    local scope = options.scope
    local cwd = root
    if scope and scope ~= "" then
      cwd = root .. "/" .. scope
    end

    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.fn.getline(start_line, end_line)
    local text = table.concat(lines, "\n")

    require("telescope.builtin").live_grep({
      cwd = cwd,
      prompt_title = scope and ("ZK Grep (selection, " .. scope .. ")") or "ZK Grep (selection)",
      default_text = text,
      glob_pattern = { "*.md", "*.markdown", "*.mdown" },
    })
  end, { needs_selection = true })

  -- --- Lifecycle moves (optional) ---

  -- Old commands moved into inbox/notes/archive. Your model doesn't use that.
  -- I'd keep ONLY an archive for field notes, and even that can be done in your main plugin config.
  -- So by default: disable these to avoid accidental moves.
  commands.add("ZkPromote", function()
    vim.notify("ZkPromote is disabled (field is flat, PKM is rewrite-not-move).", vim.log.levels.INFO)
  end)

  commands.add("ZkDemote", function()
    vim.notify("ZkDemote is disabled (no inbox).", vim.log.levels.INFO)
  end)

  commands.add("ZkArchive", function()
    move_current_to_field_archive()
  end)

  -- --- New note + link (scoped) ---

  -- These support:
  --   :ZkNewLink pkm
  --   :ZkNewLink field
  -- and your mappings: <cmd>ZkNewLink pkm<cr>
  commands.add("ZkNewLink", function(opts)
    opts = opts or {}

    local title = opts.title or vim.fn.input("Title: ")
    if title == "" then return end

    local options = vim.tbl_deep_extend("force", opts, {
      title = title,
      dir = opts.dir, -- ensure note is created in the scoped dir
      insertLinkAtLocation = current_location(),
    })

    lsp_execute_zk_new(options)
  end)

  commands.add("ZkNewLinkFromSelection", function(opts)
    opts = opts or {}

    local title = opts.title or vim.fn.input("Title: ")
    if title == "" then return end

    local options = vim.tbl_deep_extend("force", opts, {
      title = title,
      dir = opts.dir,
      insertLinkAtLocation = selection_location(),
    })

    lsp_execute_zk_new(options)
  end, { needs_selection = true })
end

return M
