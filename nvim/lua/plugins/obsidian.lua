return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- init = function()
  --   vim.opt_local.conceallevel = 1
  -- end,
  cmd = { "ObsidianTodayFull", "ObsidianNewFromTemplate" },
  keys = {
    { '<leader>oo', '<cmd>ObsidianQuickSwitch<cr>',     desc = 'Quick Switch',           mode = 'n' },
    { '<leader>og', '<cmd>ObsidianSearch<cr>',          desc = 'Grep Obsidian notes',    mode = 'n' },
    { '<leader>ot', '<cmd>ObsidianTags<cr>',            desc = 'Search Obsidian tags',   mode = 'n' },
    { '<leader>on', '<cmd>ObsidianNew<cr>',             desc = 'New Obsidian note',      mode = 'n' },
    { '<leader>om', '<cmd>ObsidianNewFromTemplate<cr>', desc = 'New note from template', mode = 'n' },
  },
  opts = {
    workspaces = {
      {
        name = "pkm",
        path = "~/Documents/notes/",
        overrides = {
          notes_subdir = "00 Inbox",
          new_notes_location = "notes_subdir",
        },
      },
    },
    open_app_foreground = true,
    templates = {
      folder = "99 Resources/Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      -- A map for custom variables, the key should be the variable and the value a function
      substitutions = {},
    },
    daily_notes = {
      folder = "20 Journal/",
      date_format = "%Y-%m-%d",
      alias_format = "%a %d %B %Y",
      default_tags = { "journal" },
      template = nil
    },
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    note_id_func = function(title)
      if title ~= nil then
        return title
      else
        return tostring(os.date("%Y%m%d%H%M"))
      end
    end,
    note_frontmatter_func = function(note)
      if note.title then
        note:add_alias(note.title)
      end

      local out = { aliases = note.aliases, tags = note.tags }

      -- `note.metadata` contains any manually added fields in the frontmatter.
      -- So here we just make sure those fields are kept in the frontmatter.
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end

      return out
    end,
    mappings = {
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      ["<cr>"] = {
        action = function()
          return require("obsidian").util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
      ["<localleader>o"] = {
        action = "<cmd>ObsidianOpen<cr>", opts = { buffer = true, desc = "Open note in obsidian" },
      },

      ["<localleader>f"] = {
        action = "<cmd>ObsidianFollowLink vsplit<cr>", opts = { buffer = true, desc = "Follow link in vsplit" },
      },

      ["<localleader>r"] = {
        action = "<cmd>ObsidianRename<cr>", opts = { buffer = true, desc = "Rename the current note and update backlinks." },
      },

      ["<localleader>x"] = {
        action = "<cmd>ObsidianToggleCheckbox<cr>", opts = { buffer = true, desc = "Toggle checkbox" },
      },
      ["<localleader>i"] = { -- Doesn't work for the moment
        action = "<cmd>ObsidianPasteImg<cr>", opts = { buffer = true, desc = "Paste an image into the current buffer" },
      },


      ["<localleader>b"] = {
        action = "<cmd>ObsidianBacklinks<cr>", opts = { buffer = true, desc = "Show the note backlinks" },
      },
      ["<localleader>l"] = {
        action = "<cmd>ObsidianLinks<cr>", opts = { buffer = true, desc = "Show the note links" },
      },
      ["<localleader>c"] = {
        action = "<cmd>ObsidianTOC<cr>", opts = { buffer = true, desc = "Show the note TOC" },
      },
      -- --- Note mangement
      -- ["<localleader>o"] = {
      --   action = ""
      -- }
    },
    ui = {
      enable = false,
    },
    attachments = {
      img_folder = "99 Resources/Attachments", -- This is the default

      -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
      ---@return string
      img_name_func = function()
        return string.format("%s-", os.date("%Y%m%d%H%M"))
      end,

      -- A function that determines the text to insert in the note when pasting an image.
      -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
      -- This is the default implementation.
      ---@param client obsidian.Client
      ---@param path obsidian.Path the absolute path to the image file
      ---@return string
      img_text_func = function(client, path)
        path = client:vault_relative_path(path) or path
        return string.format("![%s](%s)", path.name, path)
      end,
    },
  },
  config = function(_, opts)
    require("obsidian").setup(opts)

    local function update_daily_note()
      local current_time = "**" .. os.date("%H:%M") .. "**"
      local current_date = "# " .. os.date("%a %d %B %Y")

      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      if #lines == 0 or (#lines == 1 and lines[1] == "") then
        -- File is empty → insert header + time
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { current_date, "", "", current_time, "" })
      else
        -- Append time at the end
        vim.api.nvim_buf_set_lines(0, -1, -1, false, { "", current_time, "" })
      end

      local last_line = vim.api.nvim_buf_line_count(0)
      vim.api.nvim_win_set_cursor(0, { last_line, 0 })
    end

    vim.api.nvim_create_user_command("ObsidianTodayFull", function()
      vim.cmd("ObsidianToday")
      vim.defer_fn(update_daily_note, 100)
    end, {})
  end
}
