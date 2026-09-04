local oxfmt_roots = {
  ".oxfmtrc.json",
  ".oxfmtrc.jsonc",
  "oxfmt.config.ts",
}

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft.markdown = function(bufnr)
        if vim.fs.root(bufnr, oxfmt_roots) then
          return { "oxfmt", lsp_format = "never" }
        end
        return { "prettier", "markdownlint-cli2", "markdown-toc" }
      end
    end,
  },
}
