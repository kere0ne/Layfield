--[[
	Layfield mobile.lua
	Mobile quick-action panel: a draggable grid of big rounded buttons
	floating over gameplay (like mobile game hubs).
	deps: { screenGui, Theme, Util, accent }

	Usage:
	local Panel = Window:MobilePanel({ Side = "Right" })
	Panel:Button({ Name = "TP Down", Callback = function() end })
	Panel:SetSide("Left")
]]

return function(deps)
	local Theme, Util, accent = deps.Theme, deps.Util, deps.accent
	local screenGui = deps.screenGui
	local UserInputService = game:GetService("UserInputService")

	return function(cfg)
		cfg = cfg or {}
		local side = (cfg.Side == "Left") and "Left" or "Right"
		local columns = math.clamp(cfg.Columns or 2, 1, 4)

		local panel = Instance.new("Frame")
		panel.Name = "MobilePanel"
		panel.Active = true
		panel.BackgroundTransparency = 1
		panel.BorderSizePixel = 0
		panel.Size = UDim2.fromOffset(110, 60)
		panel.AutomaticSize = Enum.AutomaticSize.XY
		panel.Parent = screenGui

		local grid = Instance.new("UIGridLayout")
		grid.CellSize = UDim2.fromOffset(52, 52)
		grid.CellPadding = UDim2.fromOffset(6, 6)
		grid.SortOrder = Enum.SortOrder.LayoutOrder
		grid.Parent = panel

		local obj = {}

		local function place()
			if side == "Right" then
				panel.AnchorPoint = Vector2.new(1, 0.5)
				panel.Position = UDim2.new(1, -14, 0.5, -40)
			else
				panel.AnchorPoint = Vector2.new(0, 0.5)
				panel.Position = UDim2.new(0, 14, 0.5, -40)
			end
		end
		place()

		function obj:Button(bcfg)
			local btn = Instance.new("TextButton")
			btn.Name = bcfg.Name or "Button"
			btn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
			btn.BackgroundTransparency = 0.04
			btn.BorderSizePixel = 0
			btn.Size = UDim2.fromOffset(52, 52)
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 9
			btn.TextColor3 = Color3.fromRGB(232, 232, 238)
			btn.TextWrapped = true
			btn.Text = string.upper(bcfg.Name or "?")
			btn.AutoButtonColor = false
			btn.LayoutOrder = #panel:GetChildren()
			Util.corner(btn, 12)
			btn.Parent = panel

			btn.MouseEnter:Connect(function()
				Util.tween(btn, {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}, 0.12)
			end)
			btn.MouseLeave:Connect(function()
				Util.tween(btn, {BackgroundColor3 = Color3.fromRGB(15, 15, 18)}, 0.12)
			end)
			btn.MouseButton1Click:Connect(function()
				Util.tween(btn, {BackgroundColor3 = accent}, 0.07)
				task.delay(0.07, function()
					Util.tween(btn, {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}, 0.12)
				end)
				if bcfg.Callback then bcfg.Callback() end
			end)
			return btn
		end

		function obj:SetSide(s)
			side = (s == "Left") and "Left" or "Right"
			place()
		end
		function obj:SetVisible(v)
			panel.Visible = v and true or false
		end
		function obj:Destroy()
			panel:Destroy()
		end

		-- drag by grabbing the empty space around the buttons
		local dragging = false
		local dragStart, startPos
		panel.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = panel.Position
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)

		return obj
	end
end
