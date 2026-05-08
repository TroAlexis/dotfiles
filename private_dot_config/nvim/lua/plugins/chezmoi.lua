return {
  "xvzc/chezmoi.nvim",
  opts = {
    events = {
      on_apply = {
        --- On apply - commit and push
        --- Cause this issue is still unresolved
        --- https://github.com/xvzc/chezmoi.nvim/issues/34
        override = function(bufnr)
          vim.schedule(function()
            local source_path = vim.api.nvim_buf_get_name(bufnr)

            local target = vim.fn.system("chezmoi target-path " .. source_path):gsub("\n", "")
            local filename = target:match(".+/(.+)$") or target
            local commit_msg = "Update " .. filename

            vim.fn.jobstart("chezmoi git commit -- -am '" .. commit_msg .. "' && chezmoi git push", {
              stderr_buffered = true,
              on_stderr = function(_, data)
                if data then
                  vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR)
                end
              end,
              on_exit = function(_, code)
                if code == 0 then
                  vim.notify("chezmoi: " .. commit_msg)
                end
              end,
            })
          end)
        end,
      },
    },
  },
}
