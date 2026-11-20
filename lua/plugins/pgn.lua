return {
  {
    "vim-scripts/pgn.vim",
    ft = "pgn",
    init = function()
      vim.filetype.add({
        extension = {
          pgn = "pgn",
        },
      })
    end,
  },
}
