local pending_file_navigation

local function jump_to_edge_hunk(direction, bufnr, winid)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local first_line = direction == "next" and 1 or line_count
  local last_line = direction == "next" and line_count or 1
  local step = direction == "next" and 1 or -1
  local target_line

  vim.api.nvim_win_call(winid, function()
    for line = first_line, last_line, step do
      if vim.fn.diff_hlID(line, 1) ~= 0 then
        target_line = line
        break
      end
    end
  end)

  target_line = target_line or first_line
  vim.api.nvim_win_set_cursor(winid, { target_line, 0 })
end

local function jump_hunk_or_file(direction)
  local hunk_key = direction == "next" and "]c" or "[c"
  local before = vim.api.nvim_win_get_cursor(0)

  vim.cmd.normal({ hunk_key, bang = true })

  local after = vim.api.nvim_win_get_cursor(0)
  local stayed_in_place = before[1] == after[1] and before[2] == after[2]

  if not stayed_in_place then
    return
  end

  pending_file_navigation = direction

  local view = require("diffview.lib").get_current_view()
  if not view then
    pending_file_navigation = nil
    return
  end

  local file = direction == "next" and view:next_file(true) or view:prev_file(true)
  if not file then
    pending_file_navigation = nil
  end
end

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  opts = {
    hooks = {
      diff_buf_win_enter = function(bufnr, winid)
        if not pending_file_navigation then
          return
        end

        local view = require("diffview.lib").get_current_view()
        local main_window = view and view.cur_layout and view.cur_layout:get_main_win()
        if not main_window or main_window.id ~= winid then
          return
        end

        local direction = pending_file_navigation
        pending_file_navigation = nil
        jump_to_edge_hunk(direction, bufnr, winid)
      end,
    },
    keymaps = {
      view = {
        {
          "n",
          "<C-M-j>",
          function()
            jump_hunk_or_file("next")
          end,
          { desc = "Next diff hunk" },
        },
        {
          "n",
          "<C-M-k>",
          function()
            jump_hunk_or_file("prev")
          end,
          { desc = "Previous diff hunk" },
        },
        {
          "n",
          "[c",
          function()
            vim.cmd.normal({ "[c", bang = true })
          end,
          { desc = "Previous diff hunk" },
        },
        {
          "n",
          "]c",
          function()
            vim.cmd.normal({ "]c", bang = true })
          end,
          { desc = "Next diff hunk" },
        },
        {
          "n",
          "[h",
          function()
            vim.cmd.normal({ "[c", bang = true })
          end,
          { desc = "Previous diff hunk" },
        },
        {
          "n",
          "]h",
          function()
            vim.cmd.normal({ "]c", bang = true })
          end,
          { desc = "Next diff hunk" },
        },
      },
    },
  },
  keys = {
    {
      "<leader>gA",
      "<cmd>DiffviewOpen<cr>",
      desc = "Diff working tree against HEAD",
    },
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
