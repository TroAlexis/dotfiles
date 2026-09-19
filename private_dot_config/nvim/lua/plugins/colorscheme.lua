return {
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "material-darker" },
  },
  {
    "catppuccin/nvim",
    opts = { transparent_background = true },
    config = function(_, opts)
      require("material-darker").setup(opts)
    end,
  },
  {
    "akinsho/bufferline.nvim",
    optional = true,
    opts = function(_, opts)
      -- LazyVim only recognizes names containing "catppuccin".
      opts.highlights = function()
        local name = vim.g.colors_name or ""
        if name == "material-darker" or name:find("catppuccin") then
          return require("catppuccin.special.bufferline").get_theme()()
        end
        return {}
      end
    end,
  },
}
