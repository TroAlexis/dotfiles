--
-- System opener.
--
-- Thin wrapper around `vim.ui.open()` for file-backed Snacks picker items.
-- This intentionally uses the operating system default application:
--   * macOS: Finder / Launch Services
--   * Linux: xdg-open-compatible handlers
--   * Windows: shell file association
--
-- For source files, the OS association may not be a code editor. That is
-- expected; use the WebStorm action when the intent is to edit code.
--

---@class util.SystemOpen
local M = {}

-- ─── Notifications ───────────────────────────────────────────────────────────

---@param message string
---@param level? integer
local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "System Open" })
end

-- ─── Picker path helpers ─────────────────────────────────────────────────────

---@param picker snacks.Picker
---@param item snacks.picker.Item
---@return string?
local function picker_item_path(picker, item)
  if item.file then
    return Snacks.picker.util.path(item)
  end

  local file = item.path or item.filename
  if not file then
    return nil
  end

  if vim.startswith(file, "/") then
    return vim.fs.normalize(file)
  end

  return vim.fs.normalize(vim.fs.joinpath(picker:cwd() or vim.fn.getcwd(), file))
end

---@param picker snacks.Picker
---@param item? snacks.picker.Item Defaults to `picker:current()`.
---@return string?
local function picker_current_path(picker, item)
  item = item or picker:current()

  if not item then
    notify("No picker item selected", vim.log.levels.WARN)
    return nil
  end

  local file = picker_item_path(picker, item)
  if not file then
    notify("Could not determine file from picker item", vim.log.levels.WARN)
    return nil
  end

  return file
end

-- ─── Public API ──────────────────────────────────────────────────────────────

---Open a path with the operating system default application.
---
---This mirrors LazyVim's `gx` behavior and Snacks explorer's `o` action by
---delegating to `vim.ui.open()`.
---@param file? string File or directory to open.
function M.open(file)
  if not file or file == "" then
    notify("No file to open", vim.log.levels.WARN)
    return
  end

  local _, err = vim.ui.open(file)
  if err then
    notify("Failed to open `" .. file .. "`:\n- " .. err, vim.log.levels.ERROR)
  end
end

---Open the current Snacks picker item with the system default application.
---@param picker snacks.Picker
---@param item? snacks.picker.Item Defaults to `picker:current()`.
function M.open_picker_item(picker, item)
  local file = picker_current_path(picker, item)
  if not file then
    return
  end

  M.open(file)
end

---Open the parent directory of the current Snacks picker item.
---
---On macOS this opens Finder for the selected file's containing folder.
---@param picker snacks.Picker
---@param item? snacks.picker.Item Defaults to `picker:current()`.
function M.open_picker_item_parent(picker, item)
  local file = picker_current_path(picker, item)
  if not file then
    return
  end

  M.open(vim.fs.dirname(file))
end

return M
