-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.filetype.add({
  pattern = {
    ["Dockerfile_.*"] = "dockerfile",
  },
})

-- Dim diff filler lines (the ╱ hatching) instead of the theme's red DiffDelete block
local function hex(group, key)
  local h = vim.api.nvim_get_hl(0, { name = group, link = false })
  return h[key] and ("#%06x"):format(h[key]) or nil
end

local function blend(fg, bg, alpha)
  local out = {}
  for i = 2, 6, 2 do
    local f, b = tonumber(fg:sub(i, i + 1), 16), tonumber(bg:sub(i, i + 1), 16)
    out[#out + 1] = math.floor(f * alpha + b * (1 - alpha) + 0.5)
  end
  return ("#%02x%02x%02x"):format(out[1], out[2], out[3])
end

-- render-markdown derives heading backgrounds from unrelated groups: H4Bg from
-- DiffDelete (which dim_diff_delete below strips, for nvim's diff filler lines),
-- H5Bg from Visual, H6Bg from CursorColumn. Derive each from its own heading
-- colour instead. Theme-agnostic: reads whatever the active colorscheme defines.
local function markdown_heading_backgrounds()
  local bg = hex("Normal", "bg") or "#000000"
  for i = 1, 6 do
    local fg = hex("@markup.heading." .. i .. ".markdown", "fg")
    if fg then
      vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i .. "Bg", { bg = blend(fg, bg, 0.15) })
    end
  end
end

local function dim_diff_delete()
  local fg = vim.api.nvim_get_hl(0, { name = "NonText", link = false }).fg
  vim.api.nvim_set_hl(0, "DiffDelete", { fg = fg, bg = "NONE" })
end
local function theme_tweaks()
  dim_diff_delete()
  markdown_heading_backgrounds()
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = theme_tweaks })
theme_tweaks()
