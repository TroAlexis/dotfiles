local function setup_codediff_aliases()
  vim.defer_fn(function()
    local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
    if not ok then
      return
    end

    local original, modified = lifecycle.get_buffers(vim.api.nvim_get_current_tabpage())
    for _, buffer in ipairs({ original, modified }) do
      if buffer and vim.api.nvim_buf_is_valid(buffer) then
        vim.keymap.set("n", "<C-M-j>", require("codediff").next_hunk, {
          buffer = buffer,
          desc = "Next diff hunk",
        })
        vim.keymap.set("n", "<C-M-k>", require("codediff").prev_hunk, {
          buffer = buffer,
          desc = "Previous diff hunk",
        })
      end
    end
  end, 100)
end

vim.api.nvim_create_autocmd("User", {
  pattern = { "CodeDiffOpen", "CodeDiffFileSelect" },
  callback = setup_codediff_aliases,
})

return {
  {
    "georgeguimaraes/review.nvim",
    tag = "v1.10.0",
    dependencies = {
      {
        "esmuellert/codediff.nvim",
        opts = {
          diff = { layout = "inline" },
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
      { "<leader>gZ", "<cmd>Review branch<cr>", desc = "Review branch" },
    },
    opts = {
      branch = { base = "develop" },
    },
  },
}
