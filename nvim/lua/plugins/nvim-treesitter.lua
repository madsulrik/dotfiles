return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  build = ':TSUpdate',
  config = function()
    local status_ok, configs = pcall(require, "nvim-treesitter.configs")
    if not status_ok then
      return
    end

    local context_ok, context = pcall(require, "treesitter-context")
    if context_ok then
      context.setup()
    end

    local languages = {
      "bash",
      "comment",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "ruby",
      "embedded_template",
      "scss",
      "toml",
      "yaml",
      "vim",
      "elm",
      "haskell",
      "zig",
      "purescript",
    }
    configs.setup({
      ensure_installed = languages,

      auto_install = false,
      -- Install languages synchronously (only applied to `ensure_installed`)
      sync_install = false,
      -- List of parsers to ignore installing
      ignore_install = {},
      modules = {},
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          node_decremental = '<M-space>', -- TODO: Fix to a usefull command
          scope_incremental = '<c-s>',
        },
      },

    })
  end,
}
