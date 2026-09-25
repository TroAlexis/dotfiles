-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.snacks_animate = false
vim.opt.spelllang = "ru,en"

-- tsgo instead of vtsls: tsserver waits a hardcoded 2.5s after any external file change
-- and then re-checks every open buffer cold (~1.2s each in this 5300-file monorepo);
-- tsgo answers the same scenario in ~0.5s. Revert by deleting this line.
vim.g.lazyvim_ts_lsp = "tsgo"
