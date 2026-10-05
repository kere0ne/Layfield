--[[
	Layfield loader (main.lua)
	Paste this whole file into your executor. It loads the library
	from this repo and opens the demo hub below.
	Edit CONFIG for your own branding, edit the FEATURES block
	to build your own hub. Full docs: https://kere0ne.github.io/Layfield/
]]

local CONFIG = {
	Name = "Example Hub",
	Subtitle = "demo",
	Version = "v2.1",
	Icon = "E",
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
--========================================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function getHumanoid()
	local char = LocalPlayer.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

-- Movement tab
local Movement = Window:Tab("Movement", ">")

Movement:Paragraph({
	Title = "Welcome",
	Text = "Press LeftControl to hide the GUI. Click a KEY chip to rebind a feature.",
})

-- Anti Bat (wire this to your game's logic)
Movement:Toggle({
	Name = "Anti Bat",
	Default = false,
	Keybind = Enum.KeyCode.O,
	Callback = function(state)
		-- put your anti-bat logic here
	end,
})

-- Inf Jump (working)
do
	local on = false
	UserInputService.JumpRequest:Connect(function()
		if not on then return end
		local hum = getHumanoid()
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
	Movement:Toggle({
		Name = "Inf Jump",
		Default = false,
		Keybind = Enum.KeyCode.I,
		Callback = function(state)
			on = state
		end,
	})
end

-- Anti Ragdoll (working, survives respawn)
do
	local enabled = false
	local function apply(char)
		local hum = char:WaitForChild("Humanoid", 5)
		if not hum then return end
		hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not enabled)
		hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not enabled)
		hum.StateChanged:Connect(function(_, new)
			if enabled and (new == Enum.HumanoidStateType.Ragdoll or new == Enum.HumanoidStateType.FallingDown) then
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
	end
	if LocalPlayer.Character then
		task.spawn(apply, LocalPlayer.Character)
	end
	LocalPlayer.CharacterAdded:Connect(function(char)
		task.spawn(apply, char)
	end)
	Movement:Toggle({
		Name = "Anti Ragdoll",
		Default = true,
		Keybind = Enum.KeyCode.R,
		Callback = function(state)
			enabled = state
			local hum = getHumanoid()
			if hum then
				hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not state)
				hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not state)
			end
		end,
	})
end

-- Player tab
local PlayerTab = Window:Tab("Player", "@")

PlayerTab:Slider({
	Name = "Walk Speed",
	Min = 16,
	Max = 100,
	Default = 16,
	Callback = function(v)
		local hum = getHumanoid()
		if hum then
			hum.WalkSpeed = v
		end
	end,
})

PlayerTab:Dropdown({
	Name = "Jump Style",
	Options = {"Normal", "Low", "Moon"},
	Default = "Normal",
	Callback = function(opt)
		local hum = getHumanoid()
		if hum then
			if opt == "Low" then
				hum.UseJumpPower = true
				hum.JumpPower = 30
			elseif opt == "Moon" then
				hum.UseJumpPower = true
				hum.JumpPower = 100
			else
				hum.UseJumpPower = true
				hum.JumpPower = 50
			end
		end
	end,
})

PlayerTab:Input({
	Name = "Custom Speed",
	Placeholder = "16-100",
	Callback = function(text, enter)
		local n = tonumber(text)
		if n and enter then
			local hum = getHumanoid()
			if hum then
				hum.WalkSpeed = math.clamp(n, 0, 500)
			end
		end
	end,
})

PlayerTab:Keybind({
	Name = "Reset Character",
	Default = Enum.KeyCode.P,
	Callback = function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Health = 0
		end
	end,
})

-- Utility tab
local Utility = Window:Tab("Utility")

Utility:Button({
	Name = "Rejoin Server",
	Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
	end,
})

Utility:Button({
	Name = "Unload GUI",
	Callback = function()
		Layfield:Destroy()
	end,
})

--========================================================================
--  STARTUP
--========================================================================
Window:Notify({
	Title = CONFIG.Name,
	Text = "loaded, " .. Layfield.Version,
	Icon = CONFIG.Icon,
	Duration = 4,
})
