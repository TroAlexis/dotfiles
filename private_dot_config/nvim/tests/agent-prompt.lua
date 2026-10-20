-- Run: nvim --headless -u NONE -l ~/.config/nvim/tests/agent-prompt.lua
package.path = vim.fn.expand("~/.config/nvim/lua/?.lua;") .. package.path
local picker_opts
Snacks = { picker = {
  files = function(opts)
    picker_opts = opts
  end,
} }
require("config.agent-prompt").setup()
local buf = vim.api.nvim_get_current_buf()
local at = vim.fn.maparg("@", "i", false, true).callback
assert(at() == "@")
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "@" })
assert(vim.wait(1000, function()
  return picker_opts ~= nil
end))
assert(picker_opts.cwd == vim.fn.getcwd())
local closed = false
picker_opts.confirm({
  close = function()
    closed = true
  end,
}, { file = "src/file name.ts" })
assert(closed)
assert(vim.api.nvim_get_current_line() == '@"src/file name.ts"')
assert(vim.wait(1000, function()
  return vim.api.nvim_win_get_cursor(0)[2] == #'@"src/file name.ts"'
end))

picker_opts = nil
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "user@example" })
vim.api.nvim_win_set_cursor(0, { 1, 4 })
assert(at() == "@")
vim.wait(50)
assert(picker_opts == nil, "email address must not open picker")
print("agent prompt OK")
