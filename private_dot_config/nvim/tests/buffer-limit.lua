-- Run: nvim --headless -u NONE -l nvim/tests/buffer-limit.lua
vim.opt.hidden = true
dofile("nvim/lua/config/autocmds.lua")
local first
for i = 1, 11 do
  vim.cmd("enew")
  vim.api.nvim_buf_set_name(0, "buffer-limit-" .. i)
  if i == 1 then first = vim.api.nvim_get_current_buf() end
  vim.wait(50)
end
assert(#vim.fn.getbufinfo({ buflisted = 1 }) == 10)
assert(not vim.api.nvim_buf_is_valid(first))

local protected = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(protected, 0, -1, false, { "unsaved" })
for i = 12, 22 do
  vim.cmd("enew")
  vim.api.nvim_buf_set_name(0, "buffer-limit-" .. i)
  vim.wait(50)
end
assert(#vim.fn.getbufinfo({ buflisted = 1 }) == 10)
assert(vim.api.nvim_buf_is_valid(protected) and vim.bo[protected].modified)
print("buffer limit OK")
