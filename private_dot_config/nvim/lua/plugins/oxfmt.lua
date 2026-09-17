local oxfmt_roots = {
  ".oxfmtrc.json",
  ".oxfmtrc.jsonc",
  "oxfmt.config.ts",
}

-- filetypes oxfmt handles that LazyVim doesn't already route to it
local extra_fts = { "markdown", "markdown.mdx", "yaml", "css", "scss", "less", "html" }

local fallbacks = {
  markdown = { "prettier", "markdownlint-cli2", "markdown-toc" },
  ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
}

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      for _, ft in ipairs(extra_fts) do
        opts.formatters_by_ft[ft] = function(bufnr)
          if vim.fs.root(bufnr, oxfmt_roots) then
            return { "oxfmt", lsp_format = "never" }
          end
          return fallbacks[ft] or {}
        end
      end
    end,
  },
}
