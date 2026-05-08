return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- LazyVim default lualine_c:
      -- root_dir, diagnostics, filetype icon, pretty_path
      opts.sections.lualine_c[4] = {
        LazyVim.lualine.pretty_path({
          length = 0,
        }),
      }
    end,
  },
}
