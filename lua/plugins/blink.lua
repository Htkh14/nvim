return {
  {
    "saghen/blink.cmp",
    opts = {
      enabled = function()
        return vim.g.blink_enabled ~= false
      end,
      keymap = {
        preset = "super-tab",

        -- Tab: Copilot ghost text -> Copilot NES -> blink -> snippet jump -> normal Tab
        ["<Tab>"] = {
          function()
            local ok, sug = pcall(require, "copilot.suggestion")
            if ok and sug.is_visible() then
              sug.accept()
              return true
            end
            if vim.b.nes_state then
              local nes = require("copilot-lsp.nes")
              local _ = nes.walk_cursor_start_edit() or (nes.apply_pending_nes() and nes.walk_cursor_end_edit())
              return true
            end
          end,
          "select_and_accept",
          "snippet_forward",
          "fallback",
        },

        -- Ctrl+y: always accept from the blink menu
        ["<C-y>"] = { "select_and_accept", "fallback" },

        -- Ctrl+Space: open the menu if closed, close it if open
        ["<C-space>"] = {
          function(cmp)
            if cmp.is_visible() then
              cmp.hide()
              return true
            end
          end,
          "show",
        },

        -- Ctrl+d: toggle the documentation window
        ["<C-d>"] = { "show_documentation", "hide_documentation" },
      },
      completion = {
        menu = {
          auto_show = function()
            return vim.g.blink_menu_auto ~= false
          end,
        },
      },
    },
  },
}
