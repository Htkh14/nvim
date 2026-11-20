return {
  {
    "saghen/blink.cmp",
    opts = {
      enabled = function()
        return vim.g.blink_enabled ~= false
      end,
      keymap = {
        preset = "super-tab",

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
