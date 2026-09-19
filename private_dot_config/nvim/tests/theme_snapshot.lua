-- Run in a real UI (e.g. tmux), not --headless:
-- nvim -i NONE -c 'lua dofile(vim.fn.stdpath("config") .. "/tests/theme_snapshot.lua").run("/path/to/snapshots", "before", "catppuccin-macchiato")'
-- Repeat with "after", "material-darker". Compares every highlight, not screenshots.
local M = {}

local function capture()
  local namespaces = { global = 0 }
  for name, id in pairs(vim.api.nvim_get_namespaces()) do
    namespaces[name] = id
  end
  local highlights = {}
  for name, id in pairs(namespaces) do
    local raw = vim.api.nvim_get_hl(id, {})
    if next(raw) then
      local resolved = {}
      -- Bulk link=false can collapse aliases onto the same dictionary key.
      for group in pairs(raw) do
        resolved[group] = vim.api.nvim_get_hl(id, { name = group, link = false })
      end
      highlights[name] = { raw = raw, resolved = resolved }
    end
  end
  local terminal = {}
  for i = 0, 15 do
    terminal[tostring(i)] = vim.g["terminal_color_" .. i] or vim.NIL
  end
  local loaded = {}
  for name, plugin in pairs(require("lazy.core.config").plugins) do
    if plugin._.loaded then
      loaded[#loaded + 1] = name
    end
  end
  table.sort(loaded)
  local queries = {}
  for _, lang in ipairs({ "typescript", "tsx", "yaml", "regex", "markdown", "markdown_inline" }) do
    queries[lang] = {}
    for _, file in ipairs(vim.treesitter.query.get_files(lang, "highlights")) do
      local key = vim.startswith(file, vim.fn.stdpath("config"))
          and "$CONFIG" .. file:sub(#vim.fn.stdpath("config") + 1)
        or file
      queries[lang][key] = vim.fn.sha256(table.concat(vim.fn.readfile(file), "\n"))
    end
  end
  return {
    colors_name = vim.g.colors_name,
    highlights = highlights,
    terminal = terminal,
    loaded = loaded,
    queries = queries,
    background = vim.o.background,
    termguicolors = vim.o.termguicolors,
    integrations = require("catppuccin").options.integrations,
    styles = require("catppuccin").options.styles,
    palette = require("catppuccin.palettes").get_palette(),
  }
end

local function comparable(state)
  state = vim.deepcopy(state)
  for _, namespace in pairs(state.highlights) do
    for _, groups in pairs(namespace) do
      local sections = {}
      for group, value in pairs(groups) do
        local section, id = group:match("^(lualine_[^_]+)_(%d+)")
        if section and next(value) then
          sections[section] = sections[section] or {}
          sections[section][tonumber(id)] = true
        end
      end
      for section, ids in pairs(sections) do
        local sorted = vim.tbl_keys(ids)
        table.sort(sorted)
        for rank, id in ipairs(sorted) do
          sections[section][id] = rank
        end
      end
      local generated = {}
      for group, value in pairs(groups) do
        if group:match("lualine_[abcxyz]_%d+") then
          -- IDs vary with section initialization order; preserve component order
          -- within each section, including references in separator group names.
          if next(value) then
            local stable = group:gsub("(lualine_[abcxyz])_(%d+)", function(section, id)
              return section .. "_" .. sections[section][tonumber(id)]
            end)
            generated[stable] = value
          end
          groups[group] = nil
        end
      end
      for group, value in pairs(generated) do
        groups[group] = value
      end
    end
  end
  for name, value in pairs(state.integrations) do
    -- Compilation expands `true` to default options; a cache hit leaves it bool.
    if value == true then
      state.integrations[name] =
        vim.tbl_extend("force", require("catppuccin").default_options.integrations[name] or {}, { enabled = true })
    end
  end
  return state
end

function M.run(directory, mode, material)
  assert(mode == "before" or mode == "after", "mode must be before or after")
  vim.fn.mkdir(directory, "p")
  for _, suffix in ipairs({ "result.txt", "error.txt", "differences.txt" }) do
    vim.fn.delete(directory .. "/" .. mode .. "-" .. suffix)
  end
  local differences = {}
  local function snapshot(label)
    vim.cmd.redraw()
    local state = capture()
    local path = directory .. "/" .. mode .. "-" .. label .. ".json"
    vim.fn.writefile({ vim.json.encode(state) }, path)
    if mode == "after" then
      local before = vim.json.decode(table.concat(vim.fn.readfile(directory .. "/before-" .. label .. ".json"), "\n"))
      -- The public name is the only intended change.
      if before.colors_name == "catppuccin-macchiato" then
        before.colors_name = "material-darker"
      end
      local function compare(a, b, key)
        if vim.deep_equal(a, b) then
          return
        end
        if type(a) == "table" and type(b) == "table" then
          local keys = vim.tbl_extend("force", {}, a, b)
          for k in pairs(keys) do
            compare(a[k], b[k], key .. "." .. k)
          end
        else
          differences[#differences + 1] = (key .. ": " .. vim.inspect(a) .. " -> " .. vim.inspect(b)):gsub("\n", " ")
        end
      end
      compare(comparable(before), comparable(state), label)
    end
  end
  local steps = {
    { "startup", function() end },
    {
      "loaded",
      function()
        require("lazy").load({
          plugins = {
            "neo-tree.nvim",
            "which-key.nvim",
            "blink.cmp",
            "render-markdown.nvim",
            "codediff.nvim",
            "overseer.nvim",
            "gitsigns.nvim",
            "trouble.nvim",
          },
        })
      end,
    },
    {
      "tsx",
      function()
        vim.cmd.enew()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
          'import type { Thing } from "./types";',
          'import { Component, SOME_CONST } from "./component";',
          "interface Props { label: string }",
          "export const App = ({ label }: Props) => <div title={label}><Component /></div>;",
          "const pattern = /\\w+[a-z]$/g;",
        })
        vim.bo.filetype = "typescriptreact"
        vim.treesitter.start(0, "tsx")
      end,
    },
    {
      "mocha",
      function()
        vim.cmd.colorscheme("catppuccin-mocha")
      end,
    },
    {
      "return",
      function()
        vim.cmd.colorscheme(material)
      end,
    },
    {
      "repeat",
      function()
        vim.cmd.colorscheme(material)
      end,
    },
    {
      "tokyonight",
      function()
        vim.cmd.colorscheme("tokyonight-moon")
      end,
    },
    {
      "return-noncat",
      function()
        vim.cmd.colorscheme(material)
      end,
    },
    {
      "markdown",
      function()
        vim.cmd("enew!")
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
          "# Heading",
          "## Second heading",
          "### Third heading",
          "#### Fourth heading",
          "##### Fifth heading",
          "###### Sixth heading",
          "",
          "**bold** *italic* `code`",
          "- [ ] Task",
          "> Quote",
          "[link](https://example.com)",
        })
        vim.bo.filetype = "markdown"
        vim.treesitter.start(0, "markdown")
      end,
    },
    {
      "yaml",
      function()
        vim.cmd("enew!")
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "plain: value", 'quoted: "value"', "number: 3.9", "- item" })
        vim.bo.filetype = "yaml"
        vim.treesitter.start(0, "yaml")
      end,
    },
    {
      "terminal",
      function()
        vim.cmd("enew!")
        vim.fn.jobstart(
          { "sh", "-c", "printf '\\033[31mred \\033[1;34mbright blue\\033[0m\\n'; sleep 30" },
          { term = true }
        )
      end,
    },
  }
  local index = 0
  local function advance()
    index = index + 1
    local step = steps[index]
    if not step then
      table.sort(differences)
      vim.fn.writefile(differences, directory .. "/" .. mode .. "-differences.txt")
      vim.fn.writefile(
        { #differences == 0 and "PASS" or ("FAIL: " .. #differences .. " differences") },
        directory .. "/" .. mode .. "-result.txt"
      )
      return
    end
    local ok, err = pcall(step[2])
    if not ok then
      vim.fn.writefile({ tostring(err) }, directory .. "/" .. mode .. "-error.txt")
      return
    end
    vim.defer_fn(function()
      local captured, capture_err = pcall(snapshot, step[1])
      if not captured then
        vim.fn.writefile({ tostring(capture_err) }, directory .. "/" .. mode .. "-error.txt")
        return
      end
      advance()
    end, 1200)
  end
  vim.defer_fn(advance, 3000) -- allow VeryLazy and UI plugins to finish startup
end

-- Also run after starting with :colorscheme tokyonight-moon, once VeryLazy has
-- loaded bufferline/lualine. Exercises activation after their initial setup.
function M.check_switching(directory)
  assert(package.loaded.bufferline and package.loaded.lualine, "run after VeryLazy in a real UI")
  local expected = vim.json.decode(table.concat(vim.fn.readfile(directory .. "/before-startup.json"), "\n"))
  local events = {}
  local autocmd = vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function(ev)
      events[#events + 1] = ev.match
    end,
  })
  local ok, err = pcall(function()
    for _, theme in ipairs({
      "catppuccin-macchiato",
      "catppuccin-latte",
      "catppuccin-frappe",
      "catppuccin-mocha",
      "default",
    }) do
      vim.cmd.colorscheme("material-darker")
      assert(vim.g.colors_name == "material-darker")
      for group, value in pairs(expected.highlights.global.raw) do
        if group:match("^BufferLine") or group:match("^lualine_[abcxyz]_[a-z]+$") then
          assert(
            vim.deep_equal(value, vim.api.nvim_get_hl(0, { name = group })),
            group .. " changed on late activation"
          )
        end
      end
      for i = 0, 15 do
        assert(vim.g["terminal_color_" .. i] == expected.terminal[tostring(i)])
      end
      vim.cmd.colorscheme(theme)
      for i = 0, 15 do
        assert(vim.g["terminal_color_" .. i] == nil, "Material terminal colour leaked into " .. theme)
      end
      local flavour = theme:match("^catppuccin%-(.+)")
      if flavour then
        assert(
          vim.deep_equal(require("catppuccin.palettes").get_palette(), require("catppuccin.palettes." .. flavour)),
          "stock palette not restored"
        )
        assert(not vim.api.nvim_get_hl(0, { name = "Keyword", link = false }).italic, "Material keyword style leaked")
      end
    end
    vim.cmd.colorscheme("material-darker")
    vim.cmd.colorscheme("material-darker")
    assert(#events == 12, "nested or duplicate ColorScheme events")
  end)
  vim.api.nvim_del_autocmd(autocmd)
  vim.fn.writefile({ ok and "PASS" or tostring(err) }, directory .. "/switching-result.txt")
  assert(ok, err)
end

return M
