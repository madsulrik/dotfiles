
return {
	-- tools
 {
    "nvim-lua/lsp-status.nvim",
    event = "BufReadPre",
  }, -- Used by other plugins for basic lsp info
  {
    "j-hui/fidget.nvim",
    event = "BufReadPre",
  },
  {
    "williamboman/mason.nvim",
    event = "BufReadPre",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      require("lsp").setup()
    end,
    build = ":MasonUpdate",
  },
  -- ruby stuff:  https://github.com/mihyaeru21/nvim-lspconfig-bundler/blob/main/lua/lspconfig-bundler/init.lua
  { "folke/neodev.nvim", opts = {} }
}
