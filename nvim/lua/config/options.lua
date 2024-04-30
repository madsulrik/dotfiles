
-- Set the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

local options = {
  hlsearch = false,
	number = true,
	cursorline = true,
	mouse = 'a',
	clipboard = "unnamedplus",
	breakindent = true,
	undofile = true,
	ignorecase = true,
	smartcase = true,
	signcolumn = 'yes',
	updatetime = 250,
	timeoutlen = 300,
	completeopt = 'menuone,noselect',
	termguicolors = true,
  expandtab = true,
  shiftwidth = 2,
  tabstop = 2,
}


for k, v in pairs(options) do
  vim.opt[k] = v
end

