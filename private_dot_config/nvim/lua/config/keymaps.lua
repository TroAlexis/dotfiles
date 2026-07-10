-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" })

local function current_file()
  local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
  local root = LazyVim and LazyVim.root and LazyVim.root.get({ normalize = true }) or vim.uv.cwd()
  return vim.startswith(file, root .. "/") and file:sub(#root + 2) or vim.fn.fnamemodify(file, ":.")
end

local function copy_selection_location()
  local mode = vim.fn.mode()
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getcurpos()
  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  if mode == "\22" then
    start_line, end_line = math.min(start_line, end_line), math.max(start_line, end_line)
    start_col, end_col = math.min(start_col, end_col), math.max(start_col, end_col)
  elseif start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  local file = current_file()
  local location
  if mode == "V" then
    location = start_line == end_line and ("%s:%d"):format(file, start_line)
      or ("%s:%d-%d"):format(file, start_line, end_line)
  elseif start_line == end_line then
    location = start_col == end_col and ("%s:%d:%d"):format(file, start_line, start_col)
      or ("%s:%d:%d-%d"):format(file, start_line, start_col, end_col)
  else
    location = ("%s:%d:%d-%d:%d"):format(file, start_line, start_col, end_line, end_col)
  end

  vim.fn.setreg("+", location)
  vim.notify(location)
end

vim.keymap.set("x", "<leader>y", copy_selection_location, { desc = "Copy selection location" })
