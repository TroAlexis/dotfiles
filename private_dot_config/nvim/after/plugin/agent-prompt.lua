local agent = vim.env.AI_AGENT or ""
-- Pi documents AI_AGENT=pi; Claude currently passes a claude-code_* marker to Ctrl+G editors.
-- ponytail: Claude's marker is not documented; update this check if its format changes.
if agent == "pi" or vim.startswith(agent, "claude-code_") then
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(args)
      require("config.agent-prompt").setup(args.buf)
    end,
  })
end
