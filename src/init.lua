--[[
	Layfield init.lua
	Entry module. Fetches the other modules from this repo and
	returns the Layfield library table.
]]

local Layfield = {}
Layfield.__index = Layfield
Layfield.Version = "2.0.0"

local BASE = "https://raw.githubusercontent.com/kere0ne/Layfield/main/src/"
local cache = {}

local function fetch(name)
	if cache[name] then
		return cache[name]
	end
	local src = game:HttpGet(BASE .. name .. ".lua")
	local fn, err = loadstring(src)
	if not fn then
		error("[Layfield] failed to load module '" .. name .. "': " .. tostring(err))
	end
	local mod = fn()
	cache[name] = mod
	return mod
end

Layfield.Theme = fetch("theme")
Layfield.Util = fetch("util")(Layfield.Theme)

function Layfield:CreateWindow(config)
	local windowFactory = fetch("window")
	return windowFactory({
		Library = Layfield,
		Theme = Layfield.Theme,
		Util = Layfield.Util,
		fetch = fetch,
		config = config,
	})
end

function Layfield:Destroy()
	local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	for _, gui in ipairs(PlayerGui:GetChildren()) do
		if gui:IsA("ScreenGui") and string.find(gui.Name, "Layfield_") == 1 then
			gui:Destroy()
		end
	end
end

return Layfield
