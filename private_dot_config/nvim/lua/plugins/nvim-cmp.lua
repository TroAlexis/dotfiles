return {
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-cmdline",
    },
    opts = function(_, opts)
      local cmp = require("cmp")

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
          and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local snippet_active = function(direction)
        if vim.snippet and vim.snippet.active({ direction = direction }) then
          return true
        end

        local ok, luasnip = pcall(require, "luasnip")
        if not ok then
          return false
        end

        if direction == 1 then
          return luasnip.expand_or_locally_jumpable()
        end

        return luasnip.locally_jumpable(direction)
      end

      local snippet_jump = function(direction)
        if vim.snippet and vim.snippet.active({ direction = direction }) then
          return vim.schedule(function()
            vim.snippet.jump(direction)
          end)
        end

        local ok, luasnip = pcall(require, "luasnip")
        if ok then
          luasnip.jump(direction)
        end
      end

      opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
        ["<C-/>"] = cmp.mapping(function()
          if cmp.visible_docs() then
            cmp.close_docs()
          elseif cmp.visible() then
            cmp.open_docs()
          else
            cmp.complete()
          end
        end, { "i", "s" }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ select = true })
          elseif snippet_active(1) then
            snippet_jump(1)
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif snippet_active(-1) then
            snippet_jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" },
            },
          },
        }),
      })
      return opts
    end,
  },
}
