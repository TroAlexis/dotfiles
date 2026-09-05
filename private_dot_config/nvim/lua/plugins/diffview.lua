return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  opts = {},
  keys = {
    {
      "<leader>gU",
      function()
        for _, n in ipairs(Snacks.notifier.get_history({ reverse = true })) do
          local cmd = n.msg:match("Undo with (:.-)%s*$")
          if cmd then
            -- ":sp <file> | %!git show <blob>" would only edit a buffer in the current
            -- window; write the blob to disk instead so diffview picks it up again.
            local path, blob = cmd:match("^:sp (%S+) | %%!git show (%x+)$")
            if path then
              vim.fn.writefile(vim.fn.systemlist({ "git", "show", blob }), vim.fn.expand(path))
              vim.cmd("checktime")
              pcall(vim.cmd, "DiffviewRefresh")
            else
              vim.cmd(cmd)
            end
            return
          end
        end
        vim.notify("No diffview restore to undo", vim.log.levels.WARN)
      end,
      desc = "Undo last diffview restore",
    },
  },
}
