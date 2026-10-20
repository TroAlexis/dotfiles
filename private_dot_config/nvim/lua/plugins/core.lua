return {
  {
    "LazyVim/LazyVim",
    version = false,
    opts = {
      kind_filter = {
        -- See all symbols instead of default kind_filter by lazyvim
        default = false,
      },
    },
  },
  -- render-markdown (from lang.markdown) previews in-buffer; no need for the browser one
  { "iamcco/markdown-preview.nvim", enabled = false },
}
