local picker_list_keys = { ["<M-o>"] = { "file_actions", mode = { "n", "x" } } }
local picker_input_keys = { ["<M-o>"] = { "file_actions", mode = { "n", "i" } } }

local function add_picker_keys(picker_opts)
  picker_opts.win = picker_opts.win or {}
  picker_opts.win.input = picker_opts.win.input or {}
  picker_opts.win.input.keys = picker_opts.win.input.keys or {}
  picker_opts.win.list = picker_opts.win.list or {}
  picker_opts.win.list.keys = picker_opts.win.list.keys or {}

  for key, action in pairs(picker_input_keys) do
    picker_opts.win.input.keys[key] = action
  end

  for key, action in pairs(picker_list_keys) do
    picker_opts.win.list.keys[key] = action
  end
end

return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.picker = opts.picker or {}
      opts.picker.actions = opts.picker.actions or {}

      opts.picker.actions.file_actions = function(picker, item)
        item = item or picker:current()
        if not item then
          return
        end

        local actions = {
          { name = "Open in WebStorm", run = function() require("util.webstorm").open_picker_item(picker, item) end },
          { name = "Open in system", run = function() require("util.system-open").open_picker_item(picker, item) end },
          { name = "Open parent in system", run = function() require("util.system-open").open_picker_item_parent(picker, item) end },
          {
            name = "Delete file on disk",
            run = function()
              local file = item.file or item.path or item.filename
              if not file then
                return vim.notify("No file selected", vim.log.levels.WARN)
              end
              if not vim.startswith(file, "/") then
                file = vim.fs.joinpath(item.cwd or picker:cwd() or vim.fn.getcwd(), file)
              end
              file = vim.fs.normalize(file)
              if not vim.uv.fs_lstat(file) or vim.fn.isdirectory(file) == 1 then
                return vim.notify("Not a file: " .. file, vim.log.levels.WARN)
              end
              vim.ui.select({ "Cancel", "Delete permanently" }, { prompt = "Delete " .. file .. "?" }, function(choice)
                if choice ~= "Delete permanently" then
                  return
                end
                if vim.fn.delete(file) ~= 0 then
                  return vim.notify("Failed to delete " .. file, vim.log.levels.ERROR)
                end
                picker:refresh()
              end)
            end,
          },
        }
        vim.ui.select(actions, {
          prompt = vim.fn.fnamemodify(item.file or item.path or item.filename or "File", ":t") .. " actions",
          format_item = function(action) return action.name end,
        }, function(action)
          if action then
            action.run()
          end
        end)
      end

      local config = opts.picker.config

      opts.picker.config = function(picker_opts)
        picker_opts = config and config(picker_opts) or picker_opts

        if picker_opts.format == "file" then
          add_picker_keys(picker_opts)
        end

        return picker_opts
      end
    end,
    keys = {
      {
        "<leader>fW",
        function()
          require("util.webstorm").open()
        end,
        desc = "Open current file in WebStorm",
      },
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>fW", desc = "Open current file in WebStorm", icon = { icon = "", color = "blue" } },
      },
    },
  },
}
