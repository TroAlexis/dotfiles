local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Everblush"
config.font_dirs = { "/Users/atroshin/Library/Fonts" }
config.font = wezterm.font("MesloLGS NF")
config.font_size = 16
config.freetype_load_target = "Light"

config.window_background_opacity = 0.96
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 10,
  right = 10,
  top = 8,
  bottom = 8,
}

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.audible_bell = "Disabled"
config.initial_cols = 120
config.initial_rows = 34

config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

return config
