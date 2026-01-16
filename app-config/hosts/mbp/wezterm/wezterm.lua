local wezterm = require 'wezterm'

local config = wezterm.config_builder()
local act = wezterm.action

config.color_scheme = 'Dracula'
config.font = wezterm.font('BlexMono Nerd Font Mono')
config.font_size = 17.0
config.line_height = 1.2
config.default_cursor_style = 'BlinkingBar'
config.window_close_confirmation = 'NeverPrompt'
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.hide_mouse_cursor_when_typing = false
config.default_cwd = '~'
config.max_fps = 120

config.keys = {
    {
        key = 'LeftArrow',
        mods = 'OPT',
        action = act.SendKey {
            key = 'b',
            mods = 'ALT'
        }
    },
    {
        key = 'RightArrow',
        mods = 'OPT',
        action = act.SendKey {
            key = 'f',
            mods = 'ALT'
        }
    },
    {
        key = 'LeftArrow',
        mods = 'SUPER',
        action = act.SendKey {
            key = 'a',
            mods = 'CTRL'
        }
    },
    {
        key = 'RightArrow',
        mods = 'SUPER',
        action = act.SendKey {
            key = 'e',
            mods = 'CTRL'
        }
    },
    {
        key = 'LeftArrow',
        mods = 'CMD|OPT',
        action = act.ActivateTabRelative(-1)
    },
    {
        key = 'RightArrow',
        mods = "CMD|OPT",
        action = act.ActivateTabRelative(1)
    },
    {
        key = 'Backspace',
        mods = 'SUPER',
        action = act.SendKey {
            key = 'u',
            mods = 'CTRL'
        }
    },
    {
        key = 'LeftArrow',
        mods = 'CMD|SHIFT',
        action = act.MoveTabRelative(-1)
    },
    {
        key = 'RightArrow',
        mods = 'CMD|SHIFT',
        action = act.MoveTabRelative(1)
    },
    {
        key = 't',
        mods = 'CMD|SHIFT',
        action = act.ShowTabNavigator
    },
    {
        key = 'Enter',
        mods = 'ALT',
        action = wezterm.action.DisableDefaultAssignment
    },
    {
        key = 't',
        mods = 'CMD',
        action = act({ SpawnCommandInNewTab = { cwd = wezterm.home_dir } })
    },
}

return config
