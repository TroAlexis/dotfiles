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
      if vim.g.colors_name == "material-darker" then
        opts.highlights = require("catppuccin.special.bufferline").get_theme()
      end
      local fallback = opts.highlights
      opts.highlights = function()
        local name = vim.g.colors_name or ""
        if name == "material-darker" or name:find("catppuccin") then
          return require("catppuccin.special.bufferline").get_theme()()
        end
        -- Preserve the existing behavior for unrelated themes, including when
        -- bufferline loaded before Material was selected for the first time.
        return type(fallback) == "function" and fallback() or fallback or {}
      end
    end,
  },
}
