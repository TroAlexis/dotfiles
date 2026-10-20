-- Alt+h/j/k/l moves across nvim splits and tmux panes as one grid; Alt+H/J/K/L resizes.
-- Normal and terminal mode; LazyVim's Alt+j/k move-line still works in insert and visual mode.
local function split(fn)
  return function()
    require("smart-splits")[fn]()
  end
end

return {
  {
    "smart-splits-nvim/smart-splits.nvim",
    lazy = false, -- sets tmux's @pane-is-vim on startup; the tmux bindings check it
    dependencies = {
      { "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux" },
    },
    -- at_edge must match the tmux bindings, which stop at the window edge
    opts = { move = { at_edge = "stop" }, mux = { backend = "smart-splits-backend-tmux" } },
    keys = {
      { "<M-h>", split("move_cursor_left"), desc = "Window/pane left", mode = { "n", "t" } },
      { "<M-j>", split("move_cursor_down"), desc = "Window/pane down", mode = { "n", "t" } },
      { "<M-k>", split("move_cursor_up"), desc = "Window/pane up", mode = { "n", "t" } },
      { "<M-l>", split("move_cursor_right"), desc = "Window/pane right", mode = { "n", "t" } },
      { "<M-H>", split("resize_left"), desc = "Resize left", mode = { "n", "t" } },
      { "<M-J>", split("resize_down"), desc = "Resize down", mode = { "n", "t" } },
      { "<M-K>", split("resize_up"), desc = "Resize up", mode = { "n", "t" } },
      { "<M-L>", split("resize_right"), desc = "Resize right", mode = { "n", "t" } },
    },
  },
}
