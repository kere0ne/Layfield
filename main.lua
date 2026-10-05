--[[
	Layfield loader (main.lua)
	Paste this whole file into your executor.
	Edit CONFIG for your branding, add your features in the FEATURES block.
	Full docs: https://kere0ne.github.io/Layfield/
]]

local CONFIG = {
	Name = "Layfield",
	Subtitle = "ui library",
	Version = "v2.3",
	Icon = "L",
	AccentColor = Color3.fromRGB(68, 140, 255),
	ToggleKey = Enum.KeyCode.LeftControl,
	Width = 520,
	Height = 340,
}

local function loadLibrary()
	local src = game:HttpGet("https://raw.githubusercontent.com/kere0ne/Layfield/main/src/init.lua")
	local fn, err = loadstring(src)
	if not fn then
		error("[Layfield] failed to compile init.lua: " .. tostring(err))
	end
	return fn()
end

local Layfield = loadLibrary()
local Window = Layfield:CreateWindow(CONFIG)

--========================================================================
--  FEATURES
--  Build your hub here. Templates for every element:
--========================================================================
--[[
local Movement = Window:Tab("Movement", ">")

Movement:Toggle({
	Name = "My Toggle",
	Flag = "MyToggle",            -- optional: value saves and restores automatically
	Default = false,
	Keybind = Enum.KeyCode.F,
	Callback = function(state)
		-- your logic
	end,
})

Movement:Slider({ Name = "My Slider", Min = 0, Max = 100, Default = 50, Callback = function(v) end })
Movement:Dropdown({ Name = "My Dropdown", Options = {"A", "B", "C"}, Callback = function(opt) end })
Movement:Input({ Name = "My Input", Placeholder = "...", Callback = function(text, enter) end })
Movement:Keybind({ Name = "My Keybind", Default = Enum.KeyCode.G, Callback = function() end })
Movement:Button({ Name = "My Button", Callback = function() end })
Movement:Paragraph({ Title = "Notes", Text = "multi-line text block" })

Window:Button({ Name = "Unload GUI", Callback = function() Layfield:Destroy() end })

-- Mobile quick-action panel (draggable button grid, Left or Right):
local Panel = Window:MobilePanel({ Side = "Right" })
Panel:Button({ Name = "TP Down", Callback = function() end })
Panel:Button({ Name = "Reset", Callback = function() end })
Panel:SetSide("Left")        -- move it from code, users can also drag it
Panel:SetVisible(true)       -- or false to hide it
]]

Window:Paragraph({
	Title = "Your features go here",
	Text = "Open main.lua and add features in the FEATURES block. Full docs: kere0ne.github.io/Layfield",
})

Window:Button({
	Name = "Unload GUI",
	Callback = function()
		Layfield:Destroy()
	end,
})

Window:Notify({
	Title = CONFIG.Name,
	Text = "loaded, " .. Layfield.Version,
	Icon = CONFIG.Icon,
	Duration = 4,
})
