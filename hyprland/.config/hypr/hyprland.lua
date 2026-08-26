-- #######################################################################################
-- HYPRLAND CONFIG IM NEUEN LUA-FORMAT (Hyprland >= 0.55)
-- Migration von hyprland.conf (hyprlang, deprecated) -> dotfiles-tauglich.
--
-- Maschinenspezifische Overrides liegen NICHT hier, sondern in
--   ~/.config/hypr/hyprland-overrides.lua   (wird unten per require geladen,
--   entspricht dem alten "source = hyprland-overrides.conf")
--
-- Aktivieren: Datei nach ~/.config/hypr/hyprland.lua umbenennen und
--   hyprctl reload   ausfuehren.
-- Quelle: https://wiki.hypr.land/Configuring/Start/
-- #######################################################################################

-- ###################
-- ### ENVIRONMENT ###
-- ###################

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct") -- fuer Qt-Apps (qt6ct)

-- ###################
-- ### MY PROGRAMS ###
-- ###################

local terminal             = "wezterm"
local filePickerTerminal   = "wezterm start -e zsh -c 'cd $(tere) && zsh'"
local textEditor           = "wezterm start hx"
local filePickerTextEditor = "wezterm start -e zsh -c 'hx -w $(tere)'"
local browser              = "firefox"
local fileManager          = "nautilus"
local menu                 = "rofi -show drun"

-- ################
-- ### MONITORS ###
-- ################

-- Fallback-Regel (entspricht monitor=,preferred,auto,auto)
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- #################
-- ### AUTOSTART ###
-- #################

hl.on("hyprland.start", function ()
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst -conf $HOME/.config/dunst/dunstrc")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")  -- Stores only text data
    hl.exec_cmd("wl-paste --type image --watch cliphist store") -- Stores only image data
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("$HOME/.config/hypr/toggle_theme.sh --restore") -- Theme Management
end)

-- #####################
-- ### LOOK AND FEEL ###
-- #####################

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 20,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,   -- Standard; Override in hyprland-overrides.lua setzt 0
        disable_hyprland_logo  = false, -- Standard; Override in hyprland-overrides.lua setzt true
    },

    xwayland = {
        force_zero_scaling = true,
    },

    input = {
        kb_layout      = "de",
        kb_variant     = "",
        kb_model       = "",
        kb_options     = "",
        kb_rules       = "",
        follow_mouse   = 1,
        sensitivity    = 0.0, -- -1.0 - 1.0, 0 = keine Aenderung
        accel_profile  = "flat",
        touchpad = {
            natural_scroll = false,
        },
    },
})

-- #################
-- ### GESTURES ###
-- #################

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- #################
-- ### ANIMATIONEN #
-- #################

-- Kurven (entspricht bezier = NAME, x0, y0, x1, y1)
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

-- Animationen (entspricht animation = NAME, ONOFF, SPEED, CURVE, [STYLE])
hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

-- ###################
-- ### KEYBINDINGS ###
-- ###################

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())         -- dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))   -- dwindle

-- Fokus mit mainMod + Pfeiltasten
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Workspaces mit mainMod + [0-9] (0 = Workspace 10)
for i = 1, 10 do
    hl.bind(mainMod .. " + " .. (i % 10), hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. (i % 10), hl.dsp.window.move({ workspace = i }))
end

-- Spezial-Workspace (Scratchpad)
hl.bind(mainMod .. " + S",        hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Durch Workspaces scrollen mit mainMod + Mausrad
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Fenster verschieben/vergroessern mit mainMod + LMB/RMB
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia-Tasten fuer Lautstaerke und Display-Helligkeit
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                    { locked = true, repeating = true })

-- Benoetigt playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Custom Binds
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + H",        hl.dsp.exec_cmd(textEditor))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd(filePickerTextEditor))
hl.bind(mainMod .. " + B",        hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(filePickerTerminal))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("~/.cargo/bin/codep recent -a | rofi -dmenu | xargs -r -I {} code --new-window \"{}\""))
hl.bind(mainMod .. " + CTRL + SHIFT + C", hl.dsp.exec_cmd("~/.cargo/bin/codep -p workspaces -aD -M 365 | rofi -dmenu -markup-rows -display-columns 2 | awk -F '\\t' '{print $1}' | xargs -r -I {} code --folder-uri \"{}\""))

hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))

hl.bind(mainMod .. " + SHIFT + P",        hl.dsp.exec_cmd("hyprshot -o $HOME/Bilder/hyprshot -m region"))
hl.bind(mainMod .. " + CTRL + SHIFT + P", hl.dsp.exec_cmd("hyprshot -o $HOME/Bilder/hyprshot -m window"))

hl.bind(mainMod .. " + SHIFT + ALT + O", hl.dsp.exec_cmd("bash -c 'FEN=$(hyprshot --raw -m region | ~/.dotfiles/hyprland/.config/hypr/chess-cli.py) && [ -n \"$FEN\" ] && xdg-open \"https://lichess.org/editor/$FEN\"'"))
hl.bind(mainMod .. " + SHIFT + O",       hl.dsp.exec_cmd("hyprpicker -a"))

hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("$HOME/.dotfiles/hyprland/.config/hypr/switch_kvm.sh")) -- KVM auf Ziel in KVM_TARGET umschalten
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("$HOME/.config/hypr/toggle_theme.sh"))                   -- Dark/Light-Mode umschalten

-- Keybindings fuer Monitor-Rotation
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.exec_cmd("$HOME/.dotfiles/hyprland/.config/hypr/rotate_monitor.sh left"))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.exec_cmd("$HOME/.dotfiles/hyprland/.config/hypr/rotate_monitor.sh right"))

-- #############################################
-- ### MASCHINENSPEZIFISCHE OVERRIDES (lokal) #
-- #############################################
-- Entspricht dem alten source = ~/.config/hypr/hyprland-overrides.conf
-- (dort: Monitore, KVM_TARGET, zusaetzliche exec-onces, T/R-Binds)
-- Absoluter Pfad noetig: Hyprland kanonisiert Symlinks, ein relatives
-- require wuerde relativ zum Dotfiles-Verzeichnis aufgeloest werden.
local ok, err = pcall(require, os.getenv("HOME") .. "/.config/hypr/hyprland-overrides")
if not ok and not err:match("not found") then
    error("hyprland-overrides.lua konnte nicht geladen werden: " .. err)
end
