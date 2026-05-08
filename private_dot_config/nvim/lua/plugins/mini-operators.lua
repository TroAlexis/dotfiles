return {
  {
    "nvim-mini/mini.operators",
    version = false,
    event = "VeryLazy",
    opts = {
      evaluate = { prefix = "g=" },
      exchange = { prefix = "gX" },
      multiply = { prefix = "gm" },
      replace = { prefix = "gR" },
      sort = { prefix = "go" },
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          mode = { "n", "x" },

          { "g=", desc = "Evaluate", icon = { icon = "󰇬 ", color = "cyan" } },
          { "gX", desc = "Exchange", icon = { icon = "󰓡 ", color = "orange" } },
          { "gm", desc = "Multiply", icon = { icon = "󰐕 ", color = "green" } },
          { "gR", desc = "Replace with register", icon = { icon = "󰛔 ", color = "red" } },
          { "go", desc = "Sort", icon = { icon = "󰒺 ", color = "purple" } },
        },
      },
    },
  },
}
