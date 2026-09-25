return {
  {
    "stevearc/overseer.nvim",
    opts = {
      disable_template_modules = { "overseer.template.npm" },
    },
    keys = {
      { "<leader>ow", "<cmd>OverseerToggle<cr>", desc = "Task list" },
      {
        "<leader>oo",
        function()
          local overseer = require("overseer")
          overseer.run_template({}, function(task)
            if task then overseer.open() end
          end)
        end,
        desc = "Run task",
      },
    },
  },
}
