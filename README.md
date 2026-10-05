# Layfield

A modern, open script hub UI framework for Roblox (Luau). Rayfield-style layout, rebuilt better: tabs with live search, animated toggles with rebindable keybinds, sliders, dropdowns, text inputs, paragraphs, standalone keybinds and toast notifications.

**Docs & guides: https://kere0ne.github.io/Layfield/**

## Structure

```
Layfield/
├── main.lua           # loader: paste this into your executor
├── docs/index.html    # the docs site (GitHub Pages)
└── src/
    ├── init.lua       # library entry, fetches modules from this repo
    ├── theme.lua      # colors, re-skin everything here
    ├── util.lua       # tween / corner / stroke / label helpers
    ├── window.lua     # window, header, tab bar, search, drag, minimize
    ├── elements.lua   # Toggle, Button, Slider, Dropdown, Input, Paragraph, Keybind, Section, Label
    └── notify.lua     # toast notifications with countdown bar
```

## Quick start

Paste `main.lua` into your executor, or run it directly:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kere0ne/Layfield/main/main.lua"))()
```

Build your features under the FEATURES block in `main.lua` (templates for every element are in there):

```lua
local Window = Layfield:CreateWindow({
    Name = "Layfield",
    Subtitle = "example hub",
    Version = "v2.2",
    Icon = "E",
    AccentColor = Color3.fromRGB(45, 145, 255),
    ToggleKey = Enum.KeyCode.LeftControl,
    Width = 460,
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

Window:Notify({ Title = "Layfield", Text = "online", Icon = "E" })
```

## Highlights

- **Tabs**: `Window:Tab("Movement")` returns a tab object; skip tabs and a Main tab is auto-created so `Window:Toggle(...)` still works.
- **Live search**: the search box on the tab bar filters the current tab as you type.
- **Keybinds**: every toggle takes a keybind, rebindable by clicking the KEY chip. Keybinds pause while you're typing anywhere.
- **Object API**: every element returns an object with `:Set()`, `:Get()` (and more) so your scripts can drive the UI.
- **Config saving**: Rayfield-style flags. Add `Flag = "name"` to a toggle/slider/dropdown/input and values persist to a local config file, restored on next launch. `Window:SaveConfig(name)` / `Window:LoadConfig(name)` for manual control.
- **Mobile friendly**: touch drag and tap both work; the window clamps to your screen when dragged; draggable open/close bubble (disable with `ShowMobileButton = false`).
- **Repo-loaded modules**: edits pushed to src/ propagate to every user on their next execute.

## API

| Call | What it makes |
| --- | --- |
| `Window:Tab(name, icon)` | New page; elements added via `tab:Toggle(...)` etc. |
| `Window:Toggle(cfg)` | Card with icon, status pill, animated switch, rebindable keybind. `:Set(bool)`, `:Get()`, `:SetKeybind(kc)` |
| `Window:Button(cfg)` | Click card, `cfg.Callback()` |
| `Window:Slider(cfg)` | `{Name, Min, Max, Default, Suffix, Whole, Callback}`, `:Set(n)`, `:Get()` |
| `Window:Dropdown(cfg)` | `{Name, Options, Default, Callback}` popup, click-away close, `:Set(opt)`, `:Get()` |
| `Window:Input(cfg)` | Text box `{Name, Placeholder, Default, Callback(text, enter)}`, `:Set()`, `:Get()` |
| `Window:Paragraph(cfg)` | Auto-growing text block `{Title, Text}` |
| `Window:Keybind(cfg)` | Standalone keybind `{Name, Default, Callback}`, `:SetKeybind(kc)`, `:Get()` |
| `Window:Section(txt)` / `Window:Label(txt)` | Dividers and helper text |
| `Window:Notify(cfg)` | Toast `{Title, Text, Icon, Duration}` |
| `Window:SelectTab(tab)` | Switch pages from code |
| `Window:SaveConfig(name)` / `Window:LoadConfig(name)` | Config persistence via flags |
| `Layfield:Destroy()` | Unloads every Layfield window |
