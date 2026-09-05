-- Layout switching: English outside Insert, content-aware inside.
-- macOS: our own async handlers (the CLI's TIS call costs ~40ms and the plugin blocks on it).
-- Elsewhere (or set USE_PLUGIN = true): the plugin's stock sync setup, which is cheap on Linux IMEs.
local USE_PLUGIN = vim.fn.has("mac") == 0

return {
  "drop-stones/im-switch.nvim",
  config = function()
    if USE_PLUGIN then
      require("im-switch").setup({
        macos = { default_im = "com.apple.keylayout.UnicodeHexInput" },
        linux = { default_im = "keyboard-us" }, -- fcitx5 name; for ibus use e.g. "xkb:us::eng"
      })
      vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = require("im-switch.im").set_default_im })
      return
    end

    local EN, RU = "com.apple.keylayout.UnicodeHexInput", "com.apple.keylayout.RussianWin"
    local cli = require("im-switch.utils.path").get_cli_path()
    local cur -- layout we believe is active (nil = unknown, forces a set)
    local saved = EN -- layout to restore on InsertEnter when the line gives no hint
    local function set(id)
      if cur ~= id then
        cur = id
        vim.system({ cli, "set", id })
      end
    end
    local function detect(s) -- Cyrillic UTF-8 lead bytes -> RU, Latin letters -> EN, else nil
      if s:find("[\208\209]") then return RU elseif s:find("%a") then return EN end
    end
    local au = vim.api.nvim_create_autocmd
    local g = vim.api.nvim_create_augroup("im_switch_async", { clear = true })
    au({ "VimEnter", "FocusGained" }, { group = g, callback = function() cur = nil; set(EN) end })
    au("CmdlineLeave", { group = g, callback = function() set(EN) end })
    au("InsertLeave", { group = g, callback = function() saved = cur; set(EN) end })
    au("InsertEnter", { group = g, callback = function() set(detect(vim.api.nvim_get_current_line()) or saved) end })
    -- Track manual layout switches during Insert from what actually gets typed; costs nothing.
    au("InsertCharPre", { group = g, callback = function() cur = detect(vim.v.char) or cur end })
  end,
}
