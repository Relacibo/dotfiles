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

local act = wezterm.action

config.keys = config.keys or {}

-- Shift + Alt + V: Vertical Split
table.insert(config.keys, { key = 's', mods = 'SHIFT|ALT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } })

-- Shift + Alt + S: Horizontal Split
table.insert(config.keys, { key = 'v', mods = 'SHIFT|ALT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } })

-- Shift + Alt + H: Activate Pane Left
table.insert(config.keys, { key = 'h', mods = 'SHIFT|ALT', action = act.ActivatePaneDirection('Left') })

-- Shift + Alt + J: Activate Pane Down
table.insert(config.keys, { key = 'j', mods = 'SHIFT|ALT', action = act.ActivatePaneDirection('Down') })

-- Shift + Alt + K: Activate Pane Up
table.insert(config.keys, { key = 'k', mods = 'SHIFT|ALT', action = act.ActivatePaneDirection('Up') })

-- Shift + Alt + L: Activate Pane Right
table.insert(config.keys, { key = 'l', mods = 'SHIFT|ALT', action = act.ActivatePaneDirection('Right') })

-- Shift + Alt + Z: Toggle Pane Maximize/Zoom
table.insert(config.keys, { key = 'z', mods = 'SHIFT|ALT', action = act.TogglePaneZoomState })

-- Shift + Alt + W: Close Current Pane
table.insert(config.keys, { key = 'w', mods = 'SHIFT|ALT', action = act.CloseCurrentPane { confirm = true } })

-- Ctrl + Shift + Alt + H: Adjust boundary Left (Shrink right pane / Grow current pane if on the right)
table.insert(config.keys, { key = 'h', mods = 'CTRL|SHIFT|ALT', action = act.AdjustPaneSize { 'Left', 1 } })

-- Ctrl + Shift + Alt + J: Adjust boundary Down (Grow current pane vertically)
table.insert(config.keys, { key = 'j', mods = 'CTRL|SHIFT|ALT', action = act.AdjustPaneSize { 'Down', 1 } })

-- Ctrl + Shift + Alt + K: Adjust boundary Up (Shrink current pane vertically)
table.insert(config.keys, { key = 'k', mods = 'CTRL|SHIFT|ALT', action = act.AdjustPaneSize { 'Up', 1 } })

-- Ctrl + Shift + Alt + L: Adjust boundary Right (Grow current pane horizontally)
table.insert(config.keys, { key = 'l', mods = 'CTRL|SHIFT|ALT', action = act.AdjustPaneSize { 'Right', 1 } })

local quickselect_plugin = require 'quickselect/plugin'

quickselect_plugin.apply_to_config(config, {
  key = 'y',
  mods = 'ALT|SHIFT'
})

return config
