local picker_list_keys = {
  ["<M-o>w"] = { "webstorm_open", mode = { "n", "x" } },
  ["<M-o>x"] = { "system_open", mode = { "n", "x" } },
  ["<M-o>o"] = { "system_open_parent", mode = { "n", "x" } },
}

local picker_input_keys = {
  ["<M-o>w"] = { "webstorm_open", mode = { "n", "i" } },
  ["<M-o>x"] = { "system_open", mode = { "n", "i" } },
  ["<M-o>o"] = { "system_open_parent", mode = { "n", "i" } },
}

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

      opts.picker.actions.webstorm_open = function(...)
        return require("util.webstorm").open_picker_item(...)
      end

      opts.picker.actions.system_open = function(...)
        return require("util.system-open").open_picker_item(...)
      end

      opts.picker.actions.system_open_parent = function(...)
        return require("util.system-open").open_picker_item_parent(...)
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
