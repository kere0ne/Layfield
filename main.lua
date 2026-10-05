--[[
	Layfield loader (main.lua)
	Paste this whole file into your executor. It pulls the library
	from this repo and opens a window you can build on.

	Feature code goes under "YOUR FEATURES" below, or copy
	example.lua for a full working demo.
]]

local CONFIG = {
	Name = "Kawatan Hub",
	Subtitle = "anti-bat system",
	Version = "v3.0",
	Icon = "K",
	AccentColor = Color3.fromRGB(45, 145, 255),
	ToggleKey = Enum.KeyCode.LeftControl,
	Width = 440,
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
--  YOUR FEATURES
--========================================================================

Window:Notify({
	Title = CONFIG.Name,
	Text = "loaded, " .. Layfield.Version,
	Icon = CONFIG.Icon,
	Duration = 3,
})

-- Example toggle:
-- local myToggle = Window:Toggle({
--     Name = "My Feature",
--     Icon = "-",
--     Default = false,
--     Keybind = Enum.KeyCode.F,
--     Callback = function(state)
--         -- your logic here
--     end,
-- })
