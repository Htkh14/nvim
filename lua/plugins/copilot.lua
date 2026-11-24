return {
  {
    "zbirenbaum/copilot.lua",
    dependencies = {
      "copilotlsp-nvim/copilot-lsp",
    },
    init = function()
      vim.g.copilot_nes_debounce = 500
    end,
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = false, -- handled by the unified <S-Tab> in keymaps.lua
          accept_word = "<M-w>",
          next = "<M-n>",
          prev = "<M-p>",
          dismiss = "<M-e>",
        },
      },
      nes = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept_and_goto = false, -- handled by the unified <S-Tab> in keymaps.lua
          accept = false,
          dismiss = "<Esc>",
        },
      },
      panel = {
        enabled = false,
      },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      model = "auto",
      window = { layout = "vertical", width = 0.35 },
      sticky = { "#buffer:active" },
    },
  },
}
