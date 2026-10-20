local M = {}

function M.setup(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  vim.keymap.set("i", "@", function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    -- Leave email addresses and other embedded @ characters alone.
    if col > 0 and not line:sub(col, col):match("%s") then
      return "@"
    end

    vim.schedule(function()
      Snacks.picker.files({
        cwd = vim.fn.getcwd(),
        confirm = function(picker, item)
          picker:close()
          if not item or not vim.api.nvim_buf_is_valid(buf) then
            return
          end
          local path = item.file
          if not path then
            return
          end
          local cwd = vim.fn.getcwd()
          if vim.startswith(path, cwd .. "/") then
            path = path:sub(#cwd + 2)
          end
          local mention = path:find("%s") and ('@"%s"'):format(path) or "@" .. path
          -- Only replace the @ we inserted; don't overwrite edits made while the picker was open.
          if (vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""):sub(col + 1, col + 1) ~= "@" then
            return
          end
          vim.api.nvim_buf_set_text(buf, row - 1, col, row - 1, col + 1, { mention })
          vim.schedule(function()
            if vim.api.nvim_get_current_buf() ~= buf then
              return
            end
            vim.api.nvim_win_set_cursor(0, { row, col + #mention - 1 })
            vim.cmd("startinsert!")
          end)
        end,
      })
    end)
    return "@"
  end, { buffer = buf, expr = true, desc = "Pick agent prompt file" })
end

return M
