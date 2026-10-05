--[[
	CypherUI example.lua
	A full working demo: toggles (with working Inf Jump and Anti Ragdoll),
	slider, dropdown, buttons, notifications.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function loadLibrary()
	local src = game:HttpGet("https://raw.githubusercontent.com/kere0ne/CypherUI/main/src/init.lua")
	return loadstring(src)()
end

local CypherUI = loadLibrary()

local Window = CypherUI:CreateWindow({
	Name = "Kawatan Hub",
	Subtitle = "anti-bat system",
	Version = "v3.0",
	Icon = "K",
	AccentColor = Color3.fromRGB(45, 145, 255),
	ToggleKey = Enum.KeyCode.LeftControl,
	Width = 440,
})

Window:Section("Movement")

-- Anti Bat (wire this to your game's logic)
Window:Toggle({
	Name = "Anti Bat",
	Icon = "<>",
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
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
	Window:Toggle({
		Name = "Inf Jump",
		Icon = "^",
		Default = false,
		Keybind = Enum.KeyCode.I,
		Callback = function(state)
			on = state
		end,
	})
end

-- Anti Ragdoll (working, survives respawn)
do
	local enabled = true
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
	Window:Toggle({
		Name = "Anti Ragdoll",
		Icon = "o",
		Default = true,
		Keybind = Enum.KeyCode.R,
		Callback = function(state)
			enabled = state
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not state)
				hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not state)
			end
		end,
	})
end

Window:Section("Player")

Window:Slider({
	Name = "Walk Speed",
	Min = 16,
	Max = 100,
	Default = 16,
	Callback = function(v)
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = v
		end
	end,
})

Window:Dropdown({
	Name = "Accent",
	Options = {"Blue", "Purple", "Green", "Orange", "Red"},
	Default = "Blue",
	Callback = function(opt)
		print("accent picked:", opt)
	end,
})

Window:Section("Utilities")

Window:Button({
	Name = "Rejoin Server",
	Icon = ">",
	Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
	end,
})

Window:Button({
	Name = "Unload GUI",
	Icon = "x",
	Callback = function()
		CypherUI:Destroy()
	end,
})

Window:Notify({
	Title = "Kawatan Hub",
	Text = "Anti Bat system online",
	Icon = "K",
	Duration = 3,
})
