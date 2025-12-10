-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- enable tab bar...
config.enable_tab_bar = true
-- ...but only if multiple tabs exist
config.hide_tab_bar_if_only_one_tab = true

config.colors = {
  background = "#0a0c10"
}

config.default_prog = { '/bin/zsh' } 

local function recompute_padding(window)
  local window_dims = window:get_dimensions()
  local overrides = window:get_config_overrides() or {}

  if window_dims.is_full_screen then
    local fullscreen_padding = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    }
    if overrides.window_padding
        and overrides.window_padding.left == fullscreen_padding.left
    then
      return
    end
    overrides.window_padding = fullscreen_padding
  else
    if overrides.window_padding == nil then
      return
    end
    -- zurück zum Standard aus config
    overrides.window_padding = nil
  end

  window:set_config_overrides(overrides)
end

wezterm.on('window-resized', function(window, pane)
  recompute_padding(window)
end)

wezterm.on('window-config-reloaded', function(window)
  recompute_padding(window)
end)

return config
