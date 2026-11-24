-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
if vim.env.KITTY_WINDOW_ID and vim.env.KITTY_LISTEN_ON then
  local function set_padding(value)
    local out = vim.fn.system({
      "kitty",
      "@",
      "--to",
      vim.env.KITTY_LISTEN_ON,
      "set-spacing",
      "padding=" .. value,
    })
    if vim.v.shell_error ~= 0 then
      vim.notify("kitty padding failed: " .. out, vim.log.levels.WARN)
    end
  end

  set_padding("0") -- run now, VimEnter has already fired by the time this file loads

  local group = vim.api.nvim_create_augroup("kitty_padding", { clear = true })
  vim.api.nvim_create_autocmd("VimResume", {
    group = group,
    callback = function()
      set_padding("0")
    end,
  })
  vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
    group = group,
    callback = function()
      set_padding("default")
    end,
  })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit", "tex" },
  callback = function()
    vim.opt_local.spell = true
  end,
})
