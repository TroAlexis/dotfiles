-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" })

local function diffget(side)
  if vim.wo.diff then
    vim.cmd("diffget //" .. side)
  end
end

local function configure_diff_keymaps()
  local buffer = vim.api.nvim_get_current_buf()

  if vim.wo.diff then
    vim.keymap.set("n", "dl", function()
      diffget(2)
    end, { buffer = buffer, desc = "Diff: take LOCAL" })
    vim.keymap.set("n", "dr", function()
      diffget(3)
    end, { buffer = buffer, desc = "Diff: take REMOTE" })
  else
    pcall(vim.keymap.del, "n", "dl", { buffer = buffer })
    pcall(vim.keymap.del, "n", "dr", { buffer = buffer })
  end
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "OptionSet" }, {
  pattern = "*",
  callback = configure_diff_keymaps,
})

local function current_file()
  local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
  local root = LazyVim and LazyVim.root and LazyVim.root.get({ normalize = true }) or vim.uv.cwd()

  -- Copy project-relative paths; fall back to cwd-relative if LazyVim has no root.
  return vim.startswith(file, root .. "/") and file:sub(#root + 2) or vim.fn.fnamemodify(file, ":.")
end

local function copy_selection_location()
  local mode = vim.fn.mode()

  -- In a visual mapping, '< and '> still point at the previous selection.
  -- Use the live visual anchor and cursor so <leader>y copies this selection.
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getcurpos()
  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  -- Visual block mode is rectangular, so normalize lines and columns independently.
  if mode == "\22" then
    start_line, end_line = math.min(start_line, end_line), math.max(start_line, end_line)
    start_col, end_col = math.min(start_col, end_col), math.max(start_col, end_col)
  elseif start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  local file = current_file()
  local location

  -- Keep linewise selections compact; otherwise preserve exact columns for LLMs/tools.
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

vim.keymap.set("n", "<leader>fD", function()
  Snacks.terminal(nil, { cwd = vim.fn.expand("%:p:h") })
end, { desc = "Terminal (buffer dir)" })

vim.keymap.set("n", "<leader>fo", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or not vim.uv.fs_stat(file) then
    vim.notify("Current buffer has no file on disk", vim.log.levels.WARN)
    return
  end
  local open_parent = function()
    require("util.system-open").open(vim.fs.dirname(file))
  end
  local cmd
  if vim.fn.has("mac") == 1 then
    cmd = { "open", "-R", file }
  elseif vim.fn.executable("gdbus") == 1 then
    cmd = {
      "gdbus", "call", "--session", "--timeout", "5",
      "--dest", "org.freedesktop.FileManager1",
      "--object-path", "/org/freedesktop/FileManager1",
      "--method", "org.freedesktop.FileManager1.ShowItems",
      vim.json.encode({ vim.uri_from_fname(file) }), "",
    }
  end
  if not cmd then
    return open_parent()
  end
  vim.system(cmd, {}, function(result)
    if result.code ~= 0 then
      vim.schedule(open_parent)
    end
  end)
end, { desc = "Reveal current file in file manager" })
