--[[
	LayField init.lua
	Entry module. Fetches the other modules from this repo and
	returns the LayField library table.
]]

local LayField = {}
LayField.__index = LayField
LayField.Version = "2.0.0"

local BASE = "https://raw.githubusercontent.com/kere0ne/LayField/main/src/"
local cache = {}

local function fetch(name)
	if cache[name] then
		return cache[name]
	end
	local src = game:HttpGet(BASE .. name .. ".lua")
	local fn, err = loadstring(src)
	if not fn then
		error("[LayField] failed to load module '" .. name .. "': " .. tostring(err))
	end
	local mod = fn()
	cache[name] = mod
	return mod
end

LayField.Theme = fetch("theme")
LayField.Util = fetch("util")(LayField.Theme)

function LayField:CreateWindow(config)
	local windowFactory = fetch("window")
	return windowFactory({
		Library = LayField,
		Theme = LayField.Theme,
		Util = LayField.Util,
		fetch = fetch,
		config = config,
	})
end

function LayField:Destroy()
	local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	for _, gui in ipairs(PlayerGui:GetChildren()) do
		if gui:IsA("ScreenGui") and string.find(gui.Name, "LayField_") == 1 then
			gui:Destroy()
		end
	end
end

return LayField
