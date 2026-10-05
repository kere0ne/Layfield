# CypherUI

A modern, single-hub UI framework for Roblox script hubs. Rayfield-style layout, rebuilt cleaner and smoother.

## Structure

```
CypherUI/
├── main.lua           # loader: paste this into your executor
├── example.lua        # full working demo (toggles, slider, dropdown, buttons)
├── CypherUI.lua       # optional single-file bundle
└── src/
    ├── init.lua       # library entry, fetches modules from this repo
    ├── theme.lua      # colors, re-skin everything here
    ├── util.lua       # tween / corner / stroke / label helpers
    ├── window.lua     # window, header, drag, minimize, toggle key
    ├── elements.lua   # Section, Label, Toggle, Button, Slider, Dropdown
    └── notify.lua     # toast notifications with countdown bar
```

## Quick start

Paste `main.lua` into your executor. It loads the library from this repo and opens a window. Build your features under the YOUR FEATURES block:

```lua
local Window = CypherUI:CreateWindow({
    Name = "Kawatan Hub",
    Subtitle = "anti-bat system",
    Version = "v3.0",
    Icon = "K",
    AccentColor = Color3.fromRGB(45, 145, 255),
    ToggleKey = Enum.KeyCode.LeftControl,
    Width = 440,
})

local myToggle = Window:Toggle({
    Name = "My Feature",
    Icon = "-",
    Default = false,
    Keybind = Enum.KeyCode.F,
    Callback = function(state)
        -- your logic here
    end,
})

Window:Notify({ Title = "Kawatan Hub", Text = "online", Icon = "K" })
```

## API

| Call | What it makes |
| --- | --- |
| `Window:Toggle(cfg)` | Card with icon, status pill, animated switch, rebindable keybind. Returns object with `:Set(bool)`, `:Get()`, `:SetKeybind(keycode)` |
| `Window:Button(cfg)` | Click card, `cfg.Callback()` |
| `Window:Slider(cfg)` | `{Name, Min, Max, Default, Suffix, Whole, Callback}` |
| `Window:Dropdown(cfg)` | `{Name, Options, Default, Callback}` popup list |
| `Window:Section(txt)` / `Window:Label(txt)` | Dividers and helper text |
| `Window:Notify(cfg)` | Toast `{Title, Text, Icon, Duration}` |
| `CypherUI:Destroy()` | Unloads every CypherUI window |

Toggle keybinds rebind by clicking the KEY chip, then pressing any key. LeftControl minimizes by default (set `ToggleKey` in the window config).

## Notes

- Mobile friendly: touch drag and tap both work.
- Modules load over `game:HttpGet` from this repo, so repo updates propagate without re-pasting the loader.
- Prefer fully offline? Run `CypherUI.lua`, the bundled single-file version with the same API.
