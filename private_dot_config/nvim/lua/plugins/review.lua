return {
  "georgeguimaraes/review.nvim",
  tag = "v1.10.0",
  dependencies = {
    {
      "esmuellert/codediff.nvim",
      opts = { diff = { layout = "inline" } },
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
}
