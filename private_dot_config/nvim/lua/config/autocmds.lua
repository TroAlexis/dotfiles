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
local function dim_diff_delete()
  local fg = vim.api.nvim_get_hl(0, { name = "NonText", link = false }).fg
  vim.api.nvim_set_hl(0, "DiffDelete", { fg = fg, bg = "NONE" })
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = dim_diff_delete })
dim_diff_delete()
