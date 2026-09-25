return {
  {
    -- Fork with fixes not yet upstream; `patches` = upstream main + fix/* branches.
    -- Local clone in ~/projects/review.nvim is used when present (lazy `dev`).
    "TroAlexis/review.nvim",
    branch = "patches",
    dev = true,
    dependencies = {
      {
        "esmuellert/codediff.nvim",
        opts = {
          diff = { layout = "inline", cycle_hunks_across_files = true },
          highlights = {
            -- Material's own DIFF_INSERTED, and the minus background delta
            -- already uses, so a review and a `git diff` in the pager match.
            line_insert = "#264b33",
            line_delete = "#4b3639",
            -- Character-level highlights default to the line colour x 1.4,
            -- which lands at #566048 -- the same luminance as Comment
            -- (#616161), so comments on those lines sit at 1.05:1 and vanish.
            -- Keep one flat band instead of brightening.
            char_brightness = 1.0,
          },
        },
      },
      "MunifTanjim/nui.nvim",
    },
    event = "VeryLazy",
    keys = {
      { "<leader>gz", "<cmd>Review<cr>", desc = "Review working tree" },
      {
        "<leader>gZ",
        function()
          local cmds = { "open", "commits", "branch", "note", "edit", "delete", "close", "export", "preview", "list", "clear", "toggle" }
          vim.ui.select(cmds, { prompt = "Review" }, function(cmd)
            if cmd then vim.cmd("Review " .. cmd) end
          end)
        end,
        desc = "Review command",
      },
    },
    opts = {
      branch = { base = "develop" },
    },
  },
}
