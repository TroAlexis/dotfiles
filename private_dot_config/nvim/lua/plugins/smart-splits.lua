-- Alt+h/j/k/l moves across nvim splits and tmux panes as one grid; Alt+H/J/K/L resizes.
-- Normal mode only, so LazyVim's Alt+j/k move-line still works in insert and visual mode.
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
      { "<M-h>", split("move_cursor_left"), desc = "Window/pane left" },
      { "<M-j>", split("move_cursor_down"), desc = "Window/pane down" },
      { "<M-k>", split("move_cursor_up"), desc = "Window/pane up" },
      { "<M-l>", split("move_cursor_right"), desc = "Window/pane right" },
      { "<M-H>", split("resize_left"), desc = "Resize left" },
      { "<M-J>", split("resize_down"), desc = "Resize down" },
      { "<M-K>", split("resize_up"), desc = "Resize up" },
      { "<M-L>", split("resize_right"), desc = "Resize right" },
    },
  },
}
