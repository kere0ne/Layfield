--[[
	Example init.lua
	Entry module. Fetches the other modules from this repo and
	returns the Example library table.
]]

local Example = {}
Example.__index = Example
Example.Version = "2.0.0"

local BASE = "https://raw.githubusercontent.com/kere0ne/Example/main/src/"
local cache = {}

local function fetch(name)
	if cache[name] then
		return cache[name]
	end
	local src = game:HttpGet(BASE .. name .. ".lua")
	local fn, err = loadstring(src)
	if not fn then
		error("[Example] failed to load module '" .. name .. "': " .. tostring(err))
	end
	local mod = fn()
	cache[name] = mod
	return mod
end

Example.Theme = fetch("theme")
Example.Util = fetch("util")(Example.Theme)

function Example:CreateWindow(config)
	local windowFactory = fetch("window")
	return windowFactory({
		Library = Example,
		Theme = Example.Theme,
		Util = Example.Util,
		fetch = fetch,
		config = config,
	})
end

function Example:Destroy()
	local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	for _, gui in ipairs(PlayerGui:GetChildren()) do
		if gui:IsA("ScreenGui") and string.find(gui.Name, "Example_") == 1 then
			gui:Destroy()
		end
	end
end

return Example
