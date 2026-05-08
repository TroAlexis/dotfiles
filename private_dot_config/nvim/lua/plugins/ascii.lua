return {
  {
    "MaximilianLloyd/ascii.nvim",
    lazy = true,
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    keys = {
      {
        "<leader>uu",
        function()
          require("ascii").preview()
        end,
        desc = "Preview ASCII Art",
      },
    },
  },
}
