--[[
	CypherUI init.lua
	Entry module. Fetches the other modules from this repo and
	returns the CypherUI library table.
]]

local CypherUI = {}
CypherUI.__index = CypherUI
CypherUI.Version = "1.1.0"

local BASE = "https://raw.githubusercontent.com/kere0ne/CypherUI/main/src/"
local cache = {}

local function fetch(name)
	if cache[name] then
		return cache[name]
	end
	local src = game:HttpGet(BASE .. name .. ".lua")
	local fn, err = loadstring(src)
	if not fn then
		error("[CypherUI] failed to load module '" .. name .. "': " .. tostring(err))
	end
	local mod = fn()
	cache[name] = mod
	return mod
end

CypherUI.Theme = fetch("theme")
CypherUI.Util = fetch("util")(CypherUI.Theme)

function CypherUI:CreateWindow(config)
	local windowFactory = fetch("window")
	return windowFactory({
		Library = CypherUI,
		Theme = CypherUI.Theme,
		Util = CypherUI.Util,
		fetch = fetch,
		config = config,
	})
end

function CypherUI:Destroy()
	local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	for _, gui in ipairs(PlayerGui:GetChildren()) do
		if gui:IsA("ScreenGui") and string.find(gui.Name, "CypherUI_") == 1 then
			gui:Destroy()
		end
	end
end

return CypherUI
