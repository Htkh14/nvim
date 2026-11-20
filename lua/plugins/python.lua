return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = {
          spacing = 4,
          prefix = "●",
          severity = { min = vim.diagnostic.severity.ERROR },
        },
        underline = { severity = { min = vim.diagnostic.severity.ERROR } },
        signs = { severity = { min = vim.diagnostic.severity.ERROR } },
      },
      servers = {
        pyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic", -- or "off"
              },
            },
          },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
      },
    },
  },
}
