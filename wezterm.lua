-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
--[[
--本人常用快捷键:
创建新Wezterm: ctrl+shift+n
创建新Tab: ctrl+shift+t
切换Tab: alt+1/2/.../8
屏幕左右分割: ctrl+shift+s
屏幕上下分割: ctrl+shift+d
分割的屏幕之间移动: ctrl+shift+hjkl（与本人的neovim配置一致）
全屏显示: ctrl+f11
--]]

local act = wezterm.action
local config_keys = {
    {
        key = 'w',
        mods = 'SUPER',
        action = act.CloseCurrentPane { confirm = true },

    },
    {
        key = 'F11',
        mods = 'CTRL',
        action = act.ToggleFullScreen,
    },

    {
        key = 'C',
        mods = 'SUPER',
        action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
    },
    -- paste from the clipboard
    {
        key = 'V',
        mods = 'SUPER',
        action = act.PasteFrom 'Clipboard'
    },

        -- paste from the primary selection
        -- { key = 'V', mods = 'CTRL', action = act.PasteFrom 'PrimarySelection' },

    -- 重新定义上下分割
    -- 描述：通过ctrl+shift+d
    {
        key = 'd',
        mods = 'SUPER|SHIFT',
        action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },

    -- 重新定义左右分割
    -- 描述：通过ctrl+shift+s
    {
        key = 'd',
        mods = 'SUPER',
        action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },

    -- 重新定义分屏窗口切换快捷键
    -- 描述：通过ctrl+shift+hjkl
    {
        key = 'h', --左侧的分屏窗口
        mods = 'CTRL|SHIFT',
        action = act.ActivatePaneDirection 'Left',
    },
    {
        key = 'l', -- 右侧的分屏窗口
        mods = 'CTRL|SHIFT',
        action = act.ActivatePaneDirection 'Right',
    },
    {
        key = 'k', -- 上侧的分屏窗口
        mods = 'CTRL|SHIFT',
        action = act.ActivatePaneDirection 'Up',
    },
    {
        key = 'j', -- 下侧的分屏窗口
        mods = 'CTRL|SHIFT',
        action = act.ActivatePaneDirection 'Down',
    }
}

-- 重新定义Tab切换快捷键
-- 描述：通过alt+1/2/3/../8进行切换Tab标签
for i = 1, 8 do
  table.insert(config_keys, {
    key = tostring(i),
    mods = 'ALT',
    action = act.ActivateTab(i - 1),
  })
end


-- For example, changing the color scheme:
config.color_scheme = 'GruvboxDark'

config.font = wezterm.font 'Maple Mono'
config.font_size = 12

config.keys = config_keys

-- and finally, return the configuration to wezterm
return config
