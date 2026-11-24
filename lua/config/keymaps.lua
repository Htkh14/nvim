-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--
-- Ctrl+ö toggles the floating terminal (root dir)
vim.keymap.set({ "n", "t" }, "<C-ö>", function()
  Snacks.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Toggle terminal" })

vim.g.diag_errors_only = true

vim.keymap.set("n", "<leader>ue", function()
  vim.g.diag_errors_only = not vim.g.diag_errors_only
  local min = vim.g.diag_errors_only and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.HINT
  vim.diagnostic.config({
    virtual_text = { spacing = 4, prefix = "●", severity = { min = min } },
    underline = { severity = { min = min } },
    signs = { severity = { min = min } },
  })
  vim.notify(vim.g.diag_errors_only and "Diagnostics: errors only" or "Diagnostics: everything")
end, { desc = "Toggle errors-only diagnostics" })

local function toggle_blink()
  vim.g.blink_enabled = not (vim.g.blink_enabled ~= false)
  if vim.g.blink_enabled == false then
    pcall(function()
      require("blink.cmp").hide()
    end)
  end
  vim.notify("blink.cmp: " .. (vim.g.blink_enabled == false and "off" or "on"))
end

local function toggle_copilot()
  local s = require("copilot.suggestion")
  s.toggle_auto_trigger()
  s.dismiss()
  vim.notify("Copilot ghost text toggled")
end

vim.keymap.set({ "n", "i" }, "<M-b>", toggle_blink, { desc = "Toggle blink completion" })
vim.keymap.set({ "n", "i" }, "<M-c>", toggle_copilot, { desc = "Toggle Copilot ghost text" })

local langs = { "en", "de", "en,de" } -- adjust to your languages

vim.keymap.set("n", "<leader>uW", function()
  vim.ui.select(langs, { prompt = "Spell language" }, function(choice)
    if not choice then
      return
    end
    vim.opt_local.spelllang = choice
    vim.opt_local.spell = true
    vim.notify("spelllang = " .. choice)
  end)
end, { desc = "Select spell language" })

vim.keymap.set("n", "<leader>z", function()
  Snacks.picker.spelling()
end, { desc = "Spelling suggestions" })
