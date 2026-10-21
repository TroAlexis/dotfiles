-- Run: nvim --headless -u NONE -l ~/.config/nvim/tests/file-actions.lua
local opts = {}
assert(loadfile(vim.fn.expand("~/.config/nvim/lua/plugins/file-actions.lua")))()[1].opts(nil, opts)
local path = vim.fn.tempname()
vim.fn.writefile({ "test" }, path)
local refreshed = 0
local picker = { cwd = function() return "/wrong/cwd" end, refresh = function() refreshed = refreshed + 1 end }
local selected = 0
local original_select = vim.ui.select
vim.ui.select = function(items, _, callback)
  selected = selected + 1
  if selected == 1 then
    assert(items[4].name == "Delete file on disk")
    callback(items[4])
  else
    callback("Delete permanently")
  end
end
opts.picker.actions.file_actions(picker, { file = path })
assert(vim.uv.fs_stat(path) == nil and refreshed == 1)
vim.ui.select = original_select
print("file actions OK")
