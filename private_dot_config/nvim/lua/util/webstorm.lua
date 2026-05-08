--
-- WebStorm opener.
--
-- This module keeps editor-launching logic out of the Snacks picker spec.
-- It supports two entry points:
--   1. Open the current buffer in WebStorm.
--   2. Open the currently selected Snacks picker file in WebStorm.
--
-- The command expects JetBrains' `webstorm` launcher to be available in PATH.
--

---@class util.WebStorm
local M = {}

-- ─── Notifications ───────────────────────────────────────────────────────────

---@param message string
---@param level? integer
local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "WebStorm" })
end

-- ─── Path helpers ────────────────────────────────────────────────────────────

---@param file? string
---@return string?
local function normalize_file(file)
  if not file or file == "" then
    return nil
  end

  return vim.fs.normalize(file)
end

---@param file string
---@return string
local function project_root(file)
  return vim.fs.root(file, ".git") or vim.fn.getcwd()
end

---@param picker snacks.Picker
---@param item snacks.picker.Item
---@return string?
local function picker_item_file(picker, item)
  local file = item.file or item.path or item.filename

  if not file then
    return nil
  end

  if not vim.startswith(file, "/") then
    file = vim.fs.joinpath(picker:cwd() or vim.fn.getcwd(), file)
  end

  return vim.fs.normalize(file)
end

-- ─── Public API ──────────────────────────────────────────────────────────────

---Open a file in WebStorm at a specific cursor location.
---
---When `file`, `line`, or `col` are omitted, the current buffer location is
---used. This is the function backing the normal-mode `<leader>fW` mapping.
---@param file? string File to open. Defaults to the current buffer.
---@param line? integer Line number to focus. Defaults to the cursor line.
---@param col? integer Column number to focus. Defaults to the cursor column.
function M.open(file, line, col)
  file = normalize_file(file or vim.api.nvim_buf_get_name(0))
  line = line or vim.fn.line(".")
  col = col or vim.fn.col(".")

  if not file then
    notify("No file in current buffer", vim.log.levels.WARN)
    return
  end

  if vim.fn.executable("webstorm") ~= 1 then
    notify("'webstorm' executable was not found in PATH", vim.log.levels.ERROR)
    return
  end

  local job_id = vim.fn.jobstart({
    "webstorm",
    vim.fs.normalize(project_root(file)),
    "--line",
    tostring(line),
    "--column",
    tostring(col),
    file,
  }, {
    detach = true,
  })

  if job_id <= 0 then
    notify("Failed to launch WebStorm", vim.log.levels.ERROR)
  end
end

---Open the current Snacks picker item in WebStorm.
---
---Relative picker files are resolved against the picker's cwd. Location-aware
---items such as grep results keep their line and column when WebStorm opens.
---@param picker snacks.Picker
---@param item? snacks.picker.Item Defaults to `picker:current()`.
function M.open_picker_item(picker, item)
  item = item or picker:current()

  if not item then
    notify("No picker item selected", vim.log.levels.WARN)
    return
  end

  local file = picker_item_file(picker, item)

  if not file then
    notify("Could not determine file from picker item", vim.log.levels.WARN)
    return
  end

  local line = item.line or item.lnum or (item.pos and item.pos[1]) or 1
  local col = item.col or (item.pos and item.pos[2]) or 1

  picker:close()
  M.open(file, line, col)
end

return M
