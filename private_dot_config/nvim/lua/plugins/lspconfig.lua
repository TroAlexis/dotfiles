return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        -- Replaces linting.eslint's setup: same formatter, but priority 50 instead of 200 so
        -- ESLint fixes run after conform (oxfmt) and get the last word, once per save.
        eslint = function()
          LazyVim.format.register(LazyVim.lsp.formatter({
            name = "eslint: lsp",
            primary = false,
            priority = 50,
            filter = "eslint",
          }))
        end,
      },
      servers = {
        vtsls = {
          keys = {
            {
              "<leader>sS",
              -- Transform search query to uppercase as fuzzy matching in vtsls only works with all uppercase
              function()
                Snacks.picker.lsp_workspace_symbols({
                  filter = vim.tbl_deep_extend("force", {}, LazyVim.config.kind_filter or {}, {
                    transform = function(_, filter)
                      filter.search = filter.search:upper()
                    end,
                  }),
                })
              end,
              desc = "LSP Workspace Symbols",
              has = "workspace/symbols",
            },
          },
          settings = {
            typescript = {
              workspaceSymbols = {
                scope = "allOpenProjects",
              },
            },
          },
        },
      },
    },
  },
}
