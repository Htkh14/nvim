return {
  -- .ipynb <-> "# %%" text conversion
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style = "percent",
      output_extension = "py",
      force_ft = "python",
    },
  },

  -- inline images (kitty graphics protocol)
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      max_height_window_percentage = 40,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "scrollview", "" },
    },
  },

  -- kernel connection and output display
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_output_virt_lines = true
      vim.g.molten_wrap_output = true
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_use_border_highlights = true
    end,
    keys = {
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Init kernel" },
      { "<leader>jI", "<cmd>MoltenDeinit<cr>", desc = "Stop kernel" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Run line" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Run selection" },
      { "<leader>jo", "<cmd>noautocmd MoltenEnterOutput<cr>", desc = "Open output" },
      { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Hide output" },
      { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Delete cell output" },
      { "<leader>je", "<cmd>MoltenExportOutput<cr>", desc = "Export outputs to .ipynb" },
    },
  },

  -- cell navigation and running
  {
    "GCBallesteros/NotebookNavigator.nvim",
    dependencies = { "benlubas/molten-nvim", "nvim-mini/mini.hipatterns" },
    event = "VeryLazy",
    opts = { repl_provider = "molten", syntax_highlight = true },
    keys = {
      {
        "<leader>jr",
        function()
          require("notebook-navigator").run_cell()
        end,
        desc = "Run cell",
      },
      {
        "<leader>jj",
        function()
          require("notebook-navigator").run_and_move()
        end,
        desc = "Run cell, move on",
      },
      {
        "<leader>ja",
        function()
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local starts = {}
          for i, l in ipairs(lines) do
            if l:match("^# %%%%") then
              table.insert(starts, i)
            end
          end
          if #starts == 0 then
            starts = { 1 }
          end
          for idx, s in ipairs(starts) do
            local e = (starts[idx + 1] or (#lines + 1)) - 1
            if e >= s then
              vim.fn.MoltenEvaluateRange(s, e)
            end
          end
        end,
        desc = "Run all cells",
      },
      {
        "<leader>jb",
        function()
          require("notebook-navigator").add_cell_below()
        end,
        desc = "New cell below",
      },
      {
        "<leader>jB",
        function()
          require("notebook-navigator").add_cell_above()
        end,
        desc = "New cell above",
      },
      {
        "<leader>jn",
        function()
          require("notebook-navigator").move_cell("d")
        end,
        desc = "Next cell",
      },
      {
        "<leader>jp",
        function()
          require("notebook-navigator").move_cell("u")
        end,
        desc = "Previous cell",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>j", group = "jupyter", icon = "" },
      },
    },
  },
}
