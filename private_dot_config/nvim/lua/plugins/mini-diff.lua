local function jump_hunk(direction)
  local lifecycle = package.loaded["codediff.ui.lifecycle"]
  if lifecycle and lifecycle.get_session(vim.api.nvim_get_current_tabpage()) then
    return require("codediff")[direction .. "_hunk"]()
  end
  MiniDiff.goto_hunk(direction)
end

return {
  {
    "nvim-mini/mini.diff",
    opts = {
      mappings = {
        apply = "gH",
        reset = "gh",
      },
    },
    keys = {
      { "<C-M-j>", function() jump_hunk("next") end, desc = "Next hunk" },
      { "<C-M-k>", function() jump_hunk("prev") end, desc = "Previous hunk" },
    },
  },
}
