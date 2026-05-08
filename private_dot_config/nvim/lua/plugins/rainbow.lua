local delimiter_hl = {
  "RainbowDelimiterRed",
  "RainbowDelimiterYellow",
  "RainbowDelimiterBlue",
  "RainbowDelimiterOrange",
  "RainbowDelimiterGreen",
  "RainbowDelimiterViolet",
  "RainbowDelimiterCyan",
}

local delimiter_fallback = {
  "#cc241d",
  "#d79921",
  "#458588",
  "#d65d0e",
  "#689d6a",
  "#b16286",
  "#a89984",
}

local indent_hl = {
  "RainbowIndentRed",
  "RainbowIndentYellow",
  "RainbowIndentBlue",
  "RainbowIndentOrange",
  "RainbowIndentGreen",
  "RainbowIndentViolet",
  "RainbowIndentCyan",
}

-- Lower = dimmer, higher = closer to delimiter colors.
local indent_alpha = 0.25
local indent_blend_target = "NonText"

local function get_hl_color(group, fallback)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  return ok and hl.fg and ("#%06x"):format(hl.fg) or fallback
end

local function blend_channel(fg, bg, alpha)
  return math.floor(fg * alpha + bg * (1 - alpha) + 0.5)
end

local function blend(fg, bg, alpha)
  local fr, fg_, fb = tonumber(fg:sub(2, 3), 16), tonumber(fg:sub(4, 5), 16), tonumber(fg:sub(6, 7), 16)
  local br, bg_, bb = tonumber(bg:sub(2, 3), 16), tonumber(bg:sub(4, 5), 16), tonumber(bg:sub(6, 7), 16)

  return ("#%02x%02x%02x"):format(
    blend_channel(fr, br, alpha),
    blend_channel(fg_, bg_, alpha),
    blend_channel(fb, bb, alpha)
  )
end

local function set_indent_highlights()
  local base = get_hl_color(indent_blend_target, "#45475a")

  for index, group in ipairs(indent_hl) do
    vim.api.nvim_set_hl(0, group, {
      fg = blend(get_hl_color(delimiter_hl[index], delimiter_fallback[index]), base, indent_alpha),
    })
  end
end

return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
  },
  {
    "folke/snacks.nvim",
    init = function()
      set_indent_highlights()

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("rainbow_indent_highlights", { clear = true }),
        callback = set_indent_highlights,
      })
    end,
    opts = {
      indent = {
        indent = {
          only_scope = true,
          only_current = true,
          hl = indent_hl,
        },
      },
    },
  },
}
