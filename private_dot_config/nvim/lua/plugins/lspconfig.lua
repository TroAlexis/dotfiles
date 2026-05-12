return {
  {
    "neovim/nvim-lspconfig",
    opts = {
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
