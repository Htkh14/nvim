return {
  -- .ipynb <-> .qmd (markdown + fenced code cells); needs the quarto CLI
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style = "quarto",
      output_extension = "qmd",
      force_ft = "quarto",
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
    lazy = false,
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_output_virt_lines = true
      vim.g.molten_wrap_output = true
      vim.g.molten_output_win_max_height = 40
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

  -- LSP inside code cells + cell runner
  {
    "quarto-dev/quarto-nvim",
    dependencies = { "jmbuhr/otter.nvim", "nvim-treesitter/nvim-treesitter" },
    ft = { "quarto" },
    opts = {
      lspFeatures = {
        enabled = true,
        chunks = "all",
        languages = { "python" },
        completion = { enabled = true },
      },
      codeRunner = { enabled = true, default_method = "molten" },
    },
    config = function(_, opts)
      require("quarto").setup(opts)
      vim.treesitter.language.register("markdown", "quarto")

      local runner = require("quarto.runner")
      local fence_start = "^```{"

      -- jump to the next/previous cell and land on its first code line
      local function goto_cell(flags)
        local found = vim.fn.search(fence_start, flags)
        if found > 0 then
          local line = vim.fn.line(".") + 1
          local last = vim.fn.line("$")
          vim.api.nvim_win_set_cursor(0, { math.min(line, last), 0 })
        end
        return found
      end

      -- Split the buffer into cells. Code cell = fenced block, markdown cell = text
      -- between code cells. s/e = content range, rs/re = raw region incl. blank lines.
      -- The YAML front matter at the top is skipped, so it is never treated as a cell.
      local function parse_cells(lines)
        local cells = {}
        local n = #lines
        local i = 1
        if lines[1] == "---" then
          for j = 2, n do
            if lines[j] == "---" then
              i = j + 1
              break
            end
          end
        end
        while i <= n do
          if lines[i]:match("^```{") then
            local e = n
            for j = i + 1, n do
              if lines[j]:match("^```%s*$") then
                e = j
                break
              end
            end
            table.insert(cells, { kind = "code", s = i, e = e, rs = i, re = e })
            i = e + 1
          else
            local j = i
            while j + 1 <= n and not lines[j + 1]:match("^```{") do
              j = j + 1
            end
            local s, e = i, j
            while s <= e and lines[s]:match("^%s*$") do
              s = s + 1
            end
            while e >= s and lines[e]:match("^%s*$") do
              e = e - 1
            end
            if s <= e then
              table.insert(cells, { kind = "markdown", s = s, e = e, rs = i, re = j })
            end
            i = j + 1
          end
        end
        return cells
      end

      -- find the cell under the cursor; with fallback, use the closest cell above
      local function find_cell(cells, cur, fallback)
        for idx, c in ipairs(cells) do
          if cur >= c.rs and cur <= c.re then
            return idx, c
          end
        end
        if fallback then
          local found_idx, found
          for idx, c in ipairs(cells) do
            if c.e < cur then
              found_idx, found = idx, c
            end
          end
          return found_idx, found
        end
      end

      -- delete the cell under the cursor: code cell (plus its output) or markdown cell
      local function delete_cell()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local cells = parse_cells(lines)
        local _, c = find_cell(cells, vim.fn.line("."), false)
        if not c then
          vim.notify("Cursor is not inside a cell", vim.log.levels.WARN)
          return
        end
        if c.kind == "code" then
          pcall(vim.cmd, "MoltenDelete") -- remove the output while the cursor is still inside
        end
        local e = c.e
        if lines[e + 1] and lines[e + 1]:match("^%s*$") then
          e = e + 1 -- also remove one blank separator line
        end
        vim.api.nvim_buf_set_lines(0, c.s - 1, e, false, {})
        vim.api.nvim_win_set_cursor(0, { math.max(1, math.min(c.s, vim.fn.line("$"))), 0 })
      end

      -- insert an empty markdown cell between code cells and start typing in it
      -- Consecutive markdown cells merge into one in this format, so a new markdown
      -- cell is always placed next to a code cell.
      local function add_markdown(direction)
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local cells = parse_cells(lines)
        local idx, c = find_cell(cells, vim.fn.line("."), true)
        if not c then
          vim.notify("No cell found at the cursor", vim.log.levels.WARN)
          return
        end

        local ref
        if direction == "below" then
          ref = c
          if c.kind == "markdown" then
            ref = nil
            for k = idx + 1, #cells do
              if cells[k].kind == "code" then
                ref = cells[k]
                break
              end
            end
          end
          if not ref then
            vim.notify("No code cell below, add one first", vim.log.levels.WARN)
            return
          end
          vim.api.nvim_buf_set_lines(0, ref.e, ref.e, false, { "", "", "" })
          vim.api.nvim_win_set_cursor(0, { ref.e + 2, 0 })
        else
          ref = c
          if c.kind == "markdown" then
            ref = nil
            for k = idx - 1, 1, -1 do
              if cells[k].kind == "code" then
                ref = cells[k]
                break
              end
            end
          end
          if not ref then
            vim.notify("No code cell above, add one first", vim.log.levels.WARN)
            return
          end
          vim.api.nvim_buf_set_lines(0, ref.s - 1, ref.s - 1, false, { "", "", "" })
          vim.api.nvim_win_set_cursor(0, { ref.s + 1, 0 })
        end
        vim.cmd("startinsert")
      end

      local function map(lhs, fn, desc)
        vim.keymap.set("n", lhs, fn, { buffer = true, desc = desc })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "quarto",
        callback = function()
          map("<leader>jr", runner.run_cell, "Run cell")
          map("<leader>jA", runner.run_above, "Run cells above")
          map("<leader>ja", function()
            runner.run_all(true)
          end, "Run all cells")

          map("<leader>jj", function()
            runner.run_cell()
            goto_cell("W")
          end, "Run cell, move on")

          map("<leader>jn", function()
            goto_cell("W")
          end, "Next cell")

          map("<leader>jp", function()
            -- go to the current cell's fence first, then search for the one before it
            vim.fn.search(fence_start, "bcW")
            goto_cell("bW")
          end, "Previous cell")

          map("<leader>jb", function()
            vim.fn.search("^```\\s*$", "W") -- closing fence of the current cell
            local l = vim.fn.line(".")
            vim.api.nvim_buf_set_lines(0, l, l, false, { "", "```{python}", "", "```" })
            vim.api.nvim_win_set_cursor(0, { l + 3, 0 })
          end, "New code cell below")

          map("<leader>jm", function()
            add_markdown("below")
          end, "New markdown cell below")
          map("<leader>jM", function()
            add_markdown("above")
          end, "New markdown cell above")
          map("<leader>jx", delete_cell, "Delete current cell (code or markdown)")

          -- activate otter and start pyright for its hidden buffer
          vim.defer_fn(function()
            pcall(function()
              require("otter").activate({ "python" }, true, true)
            end)
            for _, b in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_get_name(b):match("%.otter%.py$") then
                local cfg = vim.deepcopy(vim.lsp.config["pyright"] or {})
                cfg.name = "pyright"
                cfg.cmd = cfg.cmd
                  or {
                    vim.fn.stdpath("data") .. "/mason/bin/pyright-langserver",
                    "--stdio",
                  }
                cfg.root_dir = vim.fs.root(b, { "pyproject.toml", "pyrightconfig.json", ".git" }) or vim.fn.getcwd()
                vim.lsp.start(cfg, { bufnr = b })
              end
            end
          end, 300)
        end,
      })

      -- the FileType event may already have fired for the first buffer
      if vim.bo.filetype == "quarto" then
        vim.cmd("doautocmd FileType quarto")
      end
    end,
  },

  -- rendered markdown in the buffer
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "quarto" },
    opts = { file_types = { "markdown", "quarto" } },
  },

  -- which-key group label
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>j", group = "Jupyter" } } },
  },
}
