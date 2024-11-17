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
  keys = {
    { '<leader>oo', '<cmd>ObsidianQuickSwitch<cr>', desc = 'Quick Switch',        mode = 'n' },
    { '<leader>og', '<cmd>ObsidianSearch<cr>',      desc = 'Grep Obsidian notes', mode = 'n' },
    { '<leader>ot', '<cmd>ObsidianTags<cr>',      desc = 'Search Obsidian tags', mode = 'n' },
  },
  opts = {
    workspaces = {
      {
        name = "pkm",
        path = "~/Documents/pkm/",
        overrides = {
          notes_subdir = "00 Inbox",
          new_notes_location = "notes_subdir",
        },
      },
    },
    open_app_foreground = true,
    templates = {
      folder = "90 Resources/91 Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      -- A map for custom variables, the key should be the variable and the value a function
      substitutions = {},
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
      img_folder = "90 Resources/92 Attachments", -- This is the default

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
}
