-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.g.python3_host_prog = vim.fn.expand("~/.virtualenvs/neovim/bin/python")
vim.g.maplocalleader = ","
vim.g.vimtex_view_method = "zathura"
vim.g.ai_cmp = false
vim.opt.spelllang = { "en", "de" }
