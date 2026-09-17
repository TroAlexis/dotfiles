local restore_group = vim.api.nvim_create_augroup("zdiff_restore", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = restore_group,
  callback = function(args)
    if vim.bo[args.buf].filetype ~= "zdiff" then
      return
    end

    local previous_buf = vim.fn.bufnr("#")
    if previous_buf > 0 and previous_buf ~= args.buf then
      vim.b[args.buf].zdiff_previous_buf = previous_buf
    end
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  group = restore_group,
  callback = function(args)
    if vim.bo[args.buf].filetype ~= "zdiff" then
      return
    end

    local previous_buf = vim.b[args.buf].zdiff_previous_buf
    local win = vim.fn.bufwinid(args.buf)
    if win ~= -1 and vim.api.nvim_buf_is_valid(previous_buf) then
      vim.api.nvim_win_set_buf(win, previous_buf)
    end
  end,
})

return {
  "martindur/zdiff.nvim",
  cmd = "Zdiff",
  keys = {
    { "<leader>gz", "<cmd>Zdiff<cr>", desc = "Zdiff (uncommitted)" },
    { "<leader>gZ", "<cmd>Zdiff develop<cr>", desc = "Zdiff (vs develop)" },
  },
  opts = {
    default_branch = "develop",
  },
}
