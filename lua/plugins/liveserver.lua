return {
  {
    "barrett-ruth/live-server.nvim",
    build = "npm add -g live-server",
    cmd = { "LiveServerStart", "LiveServerStop" },
    keys = {
      { "<leader>ls", "<cmd>LiveServerStart<cr>", desc = "Live server start" },
      { "<leader>lS", "<cmd>LiveServerStop<cr>", desc = "Live server stop" },
    },
    init = function()
      vim.g.live_server = {
        port = 8080,
      }
    end,
  },
}
