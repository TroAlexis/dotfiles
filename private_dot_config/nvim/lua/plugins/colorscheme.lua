-- CONSOLE_*_OUTPUT from the .icls. WebStorm has no 16-colour ANSI model, so it
-- exports no bright set; 9-14 are the normal hues blended 30% toward white.
-- Colour 0 is the editor background so "black" panels in TUIs blend rather than
-- showing a grey slab; colour 8 is CONSOLE_GRAY_OUTPUT for dim text.
local material_terminal = {
  [0] = "#212121",
  [1] = "#ff5370",
  [2] = "#c3e88d",
  [3] = "#ffcb6b",
  [4] = "#82aaff",
  [5] = "#c792ea",
  [6] = "#80cbc4", -- teal, not CONSOLE_CYAN_OUTPUT: that is a light blue too close
  -- to ANSI blue for TUIs that use both (sesh icons)
  [7] = "#b0bec5", -- dimmed: .icls normal/white differ by 2%, so bold text in TUIs
  -- (lazygit's selected tab) was indistinguishable from normal
  [8] = "#616161", -- CONSOLE_GRAY_OUTPUT
  [9] = "#ff879b",
  [10] = "#d5efaf",
  [11] = "#ffdb97",
  [12] = "#a8c4ff",
  [13] = "#d8b3f0",
  [14] = "#a5dbd6",
  [15] = "#eeffff", -- CONSOLE_NORMAL/WHITE_OUTPUT, the theme's brightest
}

local default_colorscheme = "catppuccin-macchiato"

-- Per-flavour overrides for options catppuccin only reads at setup time
-- (transparent_background, styles). Applied by the ColorScheme autocmd below.
local flavour_opts = {
  ["catppuccin-macchiato"] = {
    -- Ghostty's background is #212121 (Material Darker), so staying transparent
    -- gives the same colour while keeping background-opacity/blur.
    transparent_background = true,
    -- Material sets FONT_TYPE=2 (italic) on keywords and comments.
    styles = { keywords = { "italic" }, comments = { "italic" } },
  },
}

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = default_colorscheme,
    },
  },
  {
    "catppuccin/nvim",
    opts = {
      transparent_background = true,
      -- WebStorm "Material Darker" (exported from Material_Darker.icls) in the
      -- macchiato slot. Switch with :colorscheme catppuccin-macchiato or <leader>uC
      color_overrides = {
        macchiato = {
          base = "#212121", -- editor background
          mantle = "#1a1a1a",
          crust = "#141414",
          surface0 = "#2b2b2b", -- injected-language background
          surface1 = "#353535", -- selection
          surface2 = "#424242", -- line numbers, indent guides
          overlay0 = "#4a4a4a",
          overlay1 = "#565656",
          overlay2 = "#616161", -- comments
          subtext0 = "#90a4ae",
          subtext1 = "#b2ccd6",
          text = "#eeffff", -- variables, identifiers
          rosewater = "#ffccbc",
          flamingo = "#ffab91",
          pink = "#ff9cac", -- Material pink
          mauve = "#c792ea", -- keywords
          red = "#ff5370", -- this/super, errors
          maroon = "#f78c6c", -- parameters
          peach = "#f78c6c", -- numbers, constants, booleans
          yellow = "#ffcb6b", -- classes, types, attributes
          green = "#c3e88d", -- strings, module names
          teal = "#80cbc4",
          sky = "#89ddff", -- operators, punctuation
          sapphire = "#4fc3f7",
          blue = "#82aaff", -- functions
          lavender = "#b2ccd6", -- properties, object keys
        },
      },
      -- Roles catppuccin assigns differently than Material does. Treesitter
      -- covers syntax; the @lsp.* groups are what WebStorm's type-checker
      -- drives and catppuccin leaves almost entirely unmapped.
      -- Per-flavour overrides. Do NOT move these back to `custom_highlights` with a
      -- flavour guard: catppuccin hashes the config by *calling* the function
      -- (lib/hashing.lua:19), so a guarded early-return hashes identically on every
      -- edit and the compiled cache is never invalidated.
      highlight_overrides = {
        macchiato = function(c)
          local italic = { "italic" }
          local hl = {
            -- punctuation: Material uses cyan, catppuccin uses comment grey
            Delimiter = { fg = c.sky },
            ["@punctuation.bracket"] = { fg = c.sky },
            ["@punctuation.delimiter"] = { fg = c.sky },
            ["@punctuation.special"] = { fg = c.sky }, -- optional `?`, template `${}`
            ["@string.escape"] = { fg = c.sky }, -- DEFAULT_VALID_STRING_ESCAPE
            ["@string.regexp"] = { fg = c.green }, -- JS.REGEXP
            ["@character.special"] = { fg = c.peach }, -- DEFAULT_ENTITY (&nbsp;)
            ["@variable.member"] = { fg = c.text }, -- DEFAULT_INSTANCE_FIELD
            ["@variable.builtin"] = { fg = c.red }, -- JS.THIS_SUPER
            ["@constant.builtin"] = { fg = c.peach, style = italic }, -- JS.NULL_UNDEFINED
            ["@module"] = { fg = c.green, style = italic }, -- JS.MODULE_NAME
            ["@keyword.jsdoc"] = { fg = c.mauve, style = { "bold", "italic", "underline" } },
            ["@attribute.python"] = { fg = c.blue }, -- PY.DECORATOR
            ["@module.go"] = { fg = c.yellow }, -- GO_PACKAGE
            ["@variable.builtin.go"] = { fg = c.mauve }, -- GO_BUILTIN_VARIABLE
            ["@attribute.typescript"] = { fg = c.blue }, -- DEFAULT_METADATA (decorators)
            ["@attribute.tsx"] = { fg = c.blue },
            -- JSX. Needs the priority bump in after/queries/tsx/highlights.scm to fire.
            ["@tag.builtin"] = { fg = "#f07178" }, -- HTML_TAG_NAME (<div>)
            ["@tag"] = { fg = "#f071d0" }, -- HTML_CUSTOM_TAG_NAME (<MyComp>)
            ["@tag.css"] = { fg = "#f07178" }, -- CSS.TAG_NAME keeps the plain tag colour
            ["@tag.delimiter"] = { fg = c.sky },
            -- semantic tokens (vtsls): what treesitter alone cannot know
            ["@lsp.type.interface"] = { fg = c.green, style = italic },
            ["@lsp.type.type"] = { fg = c.green, style = italic }, -- type aliases
            -- catppuccin leaves this empty, so treesitter's (wrong) @type shows through
            ["@lsp.type.variable"] = { fg = c.text },
            ["@variable.import"] = { fg = c.yellow, style = italic }, -- see after/queries/
          ["@type.import"] = { fg = c.green, style = italic }, -- `import type { X }`
          ["@constant.import"] = { fg = c.peach }, -- DEFAULT_CONSTANT, ALL_CAPS imports
            -- .icls splits these: DEFAULT_CLASS_REFERENCE is green, DEFAULT_CLASS_NAME
          -- (the declaration) is yellow. Matches the bat/delta theme.
          ["@lsp.type.class"] = { fg = c.green },
          ["@lsp.typemod.class.declaration"] = { fg = c.yellow },
            ["@lsp.type.enum"] = { fg = c.yellow },
            ["@lsp.type.typeParameter"] = { fg = c.yellow }, -- TS.TYPE_PARAMETER
            ["@lsp.type.namespace"] = { fg = c.green, style = italic }, -- JS.MODULE_NAME
            ["@lsp.type.enumMember"] = { fg = c.peach },
            -- JS.GLOBAL_FUNCTION (module-level fns) vs JS.INSTANCE_MEMBER_FUNCTION
            -- DEFAULT_FUNCTION_DECLARATION is blue everywhere; yellow-italic is
            -- JS.GLOBAL_FUNCTION specifically. Without scoping, Go and Python
            -- functions came out yellow.
            ["@lsp.type.function"] = { fg = c.blue },
            ["@lsp.type.function.typescript"] = { fg = c.yellow, style = italic },
            ["@lsp.type.function.typescriptreact"] = { fg = c.yellow, style = italic },
            ["@lsp.type.function.javascript"] = { fg = c.yellow, style = italic },
            ["@lsp.type.function.javascriptreact"] = { fg = c.yellow, style = italic },
            ["@lsp.type.method"] = { fg = c.blue },
            ["@lsp.type.property"] = { fg = c.text }, -- JS.INSTANCE_MEMBER_VARIABLE
            ["@lsp.type.parameter"] = { fg = c.peach },
            ["@lsp.typemod.variable.defaultLibrary"] = { fg = c.blue, style = italic },
            -- PY.PREDEFINED_USAGE is blue italic; JS.CONSOLE is yellow
            ["@lsp.typemod.function.defaultLibrary"] = { fg = c.blue, style = italic },
            ["@lsp.typemod.function.defaultLibrary.typescript"] = { fg = c.yellow, style = italic },
            ["@lsp.typemod.function.defaultLibrary.typescriptreact"] = { fg = c.yellow, style = italic },
            -- DEFAULT_STATIC_FIELD / DEFAULT_STATIC_METHOD are italic in Material
            ["@lsp.typemod.property.static"] = { fg = c.text, style = italic },
            ["@lsp.typemod.method.static"] = { fg = c.blue, style = italic },
            ["@lsp.typemod.variable.static"] = { fg = c.text, style = italic },
            -- json
            ["@property.json"] = { fg = c.mauve }, -- JSON.PROPERTY_KEY
          ["@property.yaml"] = { fg = "#f07178" }, -- YAML_SCALAR_KEY
            ["@boolean.json"] = { fg = c.peach, style = italic }, -- JSON.KEYWORD
            -- css
            ["@property.css"] = { fg = c.lavender }, -- CSS.PROPERTY_NAME
            ["@property.scss"] = { fg = c.lavender },
            ["@type.css"] = { fg = c.yellow, style = italic }, -- CSS.CLASS_NAME
            ["@constant.css"] = { fg = c.mauve }, -- CSS.HASH
            ["@attribute.css"] = { fg = c.mauve, style = italic }, -- CSS.PSEUDO
            ["@keyword.modifier.css"] = { fg = c.peach, style = italic }, -- CSS.IMPORTANT
            -- markdown
            ["@markup.raw"] = { fg = c.mauve, style = italic },
            ["@markup.list"] = { fg = c.red, style = italic },
            ["@markup.strong"] = { fg = "#f07178", style = { "bold" } },
            ["@markup.italic"] = { fg = "#f07178", style = italic },
            ["@markup.link.label"] = { fg = "#f07178", style = { "underline" } },
            ["@markup.link.url"] = { fg = c.peach },
            ["@markup.quote"] = { fg = c.blue, style = italic },
            -- editor chrome
            Search = { fg = "#000000", bg = "#ffe153" }, -- TEXT_SEARCH_RESULT
            IncSearch = { fg = "#ffffff", bg = "#ff9800" }, -- SEARCH_RESULT
            CurSearch = { fg = "#ffffff", bg = "#ff9800" },
            Todo = { fg = "#ffeb95", bg = "NONE", style = italic },
            -- MATCHED_BRACE_ATTRIBUTES tints the bg only; the glyph keeps DEFAULT_BRACES
            MatchParen = { fg = c.sky, bg = "#3b514d", style = { "bold" } },
            CursorLine = { bg = "#181818" }, -- CARET_ROW_COLOR
              LineNr = { fg = c.surface2 }, -- LINE_NUMBERS_COLOR
            Visual = { bg = c.surface1 }, -- SELECTION_BACKGROUND
            Whitespace = { fg = c.overlay2 }, -- WHITESPACES
              WinSeparator = { fg = c.surface2 }, -- TEARLINE_COLOR
            GitSignsDelete = { fg = "#f07178" }, -- DELETED_LINES_COLOR
            -- IDENTIFIER_UNDER_CARET (read) vs WRITE_IDENTIFIER_UNDER_CARET
            LspReferenceText = { bg = "#033e5d" },
            LspReferenceRead = { bg = "#033e5d" },
            LspReferenceWrite = { bg = "#4a4d50" },
            IlluminatedWordText = { bg = "#033e5d" },
            IlluminatedWordRead = { bg = "#033e5d" },
            IlluminatedWordWrite = { bg = "#4a4d50" },
            Cursor = { fg = c.base, bg = "#94ff86" }, -- CARET_COLOR
            -- SELECTED_TEARLINE_COLOR: one "this is the active thing" accent, shared by
          -- the tmux active pane border, atuin's focused row, lazygit and lazydocker.
          UiAccent = { fg = "#ff9800" },
          WhichKeyDesc = { fg = c.text }, -- catppuccin uses pink; menus read as UI text
          }
          return hl
        end,
      },
    },
    config = function(_, opts)
      -- Set up with the startup flavour's overrides already applied, otherwise the
      -- autocmd below re-runs setup (and recompiles) on the very first ColorScheme.
      local startup = flavour_opts[default_colorscheme]
      require("catppuccin").setup(vim.tbl_deep_extend("force", opts, startup or {}))
      local applied = startup and default_colorscheme or "default"
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "catppuccin*",
        callback = function(ev)
          -- catppuccin ships term_colors = false, so nothing restores these on the
          -- way out; clear them explicitly for every other flavour.
          local term = ev.match == "catppuccin-macchiato" and material_terminal or {}
          for i = 0, 15 do
            vim.g["terminal_color_" .. i] = term[i]
          end
          local key = flavour_opts[ev.match] and ev.match or "default"
          if applied == key then
            return
          end
          applied = key
          require("catppuccin").setup(vim.tbl_deep_extend("force", opts, flavour_opts[ev.match] or {}))
          vim.schedule(function()
            vim.cmd.colorscheme(ev.match)
          end)
        end,
      })
    end,
  },
}
