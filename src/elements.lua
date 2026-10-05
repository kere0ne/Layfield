--[[
	CypherUI elements.lua
	Registers all element factories on a window:
	Section, Label, Toggle, Button, Slider, Dropdown.
	deps: { window, body, screenGui, Theme, Util, accent, nextOrder }
]]

return function(deps)
	local Theme, Util = deps.Theme, deps.Util
	local window, body, screenGui = deps.window, deps.body, deps.screenGui
	local accent, nextOrder = deps.accent, deps.nextOrder
	local UserInputService = game:GetService("UserInputService")

	-- ===== Section =====
	function window:Section(txt)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, 0, 0, 20)
		f.BackgroundTransparency = 1
		f.LayoutOrder = nextOrder()
		f.Parent = body
		Util.label(f, {
			Position = UDim2.fromOffset(2, 2), Size = UDim2.new(1, -4, 1, 0),
			Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left, Text = string.upper(txt or ""),
		})
	end

	-- ===== Label =====
	function window:Label(txt)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, 0, 0, 18)
		f.BackgroundTransparency = 1
		f.LayoutOrder = nextOrder()
		f.Parent = body
		Util.label(f, {
			Position = UDim2.fromOffset(2, 0), Size = UDim2.new(1, -4, 1, 0),
			Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left, Text = txt or "",
		})
	end

	-- ===== Toggle =====
	function window:Toggle(cfg)
		local state = cfg.Default == true
		local key = cfg.Keybind or nil
		local rebinding = false

		local card = Instance.new("TextButton")
		card.Name = cfg.Name or "Toggle"
		card.BackgroundColor3 = Theme.Card
		card.BorderSizePixel = 0
		card.Size = UDim2.new(1, 0, 0, 92)
		card.AutoButtonColor = false
		card.Text = ""
		card.LayoutOrder = nextOrder()
		Util.corner(card, 12)
		Util.stroke(card, Theme.Stroke, 1, 0.4)
		card.Parent = body

		local iconBox = Instance.new("Frame")
		iconBox.Size = UDim2.fromOffset(40, 40)
		iconBox.Position = UDim2.fromOffset(12, 14)
		iconBox.BackgroundColor3 = Theme.Chip
		iconBox.BorderSizePixel = 0
		iconBox.Parent = card
		Util.corner(iconBox, 11)
		Util.label(iconBox, {
			Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 16,
			TextColor3 = accent, Text = cfg.Icon or "-",
		})

		Util.label(card, {
			Position = UDim2.fromOffset(62, 13), Size = UDim2.new(1, -140, 0, 18),
			Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Name or "Toggle",
		})

		local pill = Instance.new("Frame")
		pill.Size = UDim2.fromOffset(92, 20)
		pill.Position = UDim2.fromOffset(62, 36)
		pill.BackgroundColor3 = Theme.Chip
		pill.BorderSizePixel = 0
		pill.Parent = card
		Util.corner(pill, 10)
		local pillDot = Instance.new("Frame")
		pillDot.Size = UDim2.fromOffset(6, 6)
		pillDot.Position = UDim2.fromOffset(9, 7)
		pillDot.BackgroundColor3 = Theme.SubText
		pillDot.BorderSizePixel = 0
		pillDot.Parent = pill
		Util.corner(pillDot, 3)
		local pillText = Util.label(pill, {
			Position = UDim2.fromOffset(20, 0), Size = UDim2.new(1, -24, 1, 0),
			Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left, Text = "INACTIVE",
		})

		local switch = Instance.new("Frame")
		switch.Size = UDim2.fromOffset(46, 26)
		switch.Position = UDim2.new(1, -58, 0, 14)
		switch.BackgroundColor3 = Theme.Off
		switch.BorderSizePixel = 0
		switch.Parent = card
		Util.corner(switch, 13)
		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(20, 20)
		knob.Position = UDim2.fromOffset(3, 3)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.Parent = switch
		Util.corner(knob, 10)

		Util.label(card, {
			Position = UDim2.fromOffset(62, 62), Size = UDim2.fromOffset(30, 14),
			Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left, Text = "KEY",
		})
		local chip = Instance.new("TextButton")
		chip.Size = UDim2.fromOffset(54, 22)
		chip.Position = UDim2.fromOffset(92, 59)
		chip.BackgroundColor3 = Theme.Chip
		chip.BorderSizePixel = 0
		chip.Font = Enum.Font.GothamBold
		chip.TextSize = 11
		chip.TextColor3 = Theme.Text
		chip.Text = key and key.Name or "--"
		chip.AutoButtonColor = false
		chip.Parent = card
		Util.corner(chip, 7)
		Util.label(card, {
			Position = UDim2.new(1, -14, 0, 63), Size = UDim2.fromOffset(120, 14),
			Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Right, Text = "click to rebind",
		})

		local obj = {}
		local function render()
			if state then
				Util.tween(switch, {BackgroundColor3 = accent})
				Util.tween(knob, {Position = UDim2.fromOffset(23, 3)})
				pillText.Text = "ACTIVE"
				pillText.TextColor3 = accent
				pillDot.BackgroundColor3 = accent
			else
				Util.tween(switch, {BackgroundColor3 = Theme.Off})
				Util.tween(knob, {Position = UDim2.fromOffset(3, 3)})
				pillText.Text = "INACTIVE"
				pillText.TextColor3 = Theme.SubText
				pillDot.BackgroundColor3 = Theme.SubText
			end
		end

		function obj:Set(v)
			state = v and true or false
			render()
			if cfg.Callback then cfg.Callback(state) end
		end
		function obj:Get()
			return state
		end
		function obj:SetKeybind(kc)
			key = kc
			chip.Text = key and key.Name or "--"
		end

		card.MouseButton1Click:Connect(function()
			obj:Set(not state)
		end)
		card.MouseEnter:Connect(function()
			Util.tween(card, {BackgroundColor3 = Theme.CardHover}, 0.15)
		end)
		card.MouseLeave:Connect(function()
			Util.tween(card, {BackgroundColor3 = Theme.Card}, 0.15)
		end)

		chip.MouseButton1Click:Connect(function()
			if rebinding then return end
			rebinding = true
			chip.Text = "..."
			local conn
			conn = UserInputService.InputBegan:Connect(function(input, gp)
				if gp then return end
				if input.UserInputType == Enum.UserInputType.Keyboard then
					conn:Disconnect()
					key = input.KeyCode
					chip.Text = key.Name
					rebinding = false
				end
			end)
		end)

		UserInputService.InputBegan:Connect(function(input, gp)
			if gp or rebinding then return end
			if key and input.KeyCode == key then
				obj:Set(not state)
			end
		end)

		render()
		return obj
	end

	-- ===== Button =====
	function window:Button(cfg)
		local card = Instance.new("TextButton")
		card.Name = cfg.Name or "Button"
		card.BackgroundColor3 = Theme.Card
		card.BorderSizePixel = 0
		card.Size = UDim2.new(1, 0, 0, 44)
		card.AutoButtonColor = false
		card.Font = Enum.Font.GothamBold
		card.TextSize = 14
		card.TextColor3 = Theme.Text
		card.Text = (cfg.Icon and (cfg.Icon .. "  ") or "") .. (cfg.Name or "Button")
		card.LayoutOrder = nextOrder()
		Util.corner(card, 11)
		Util.stroke(card, Theme.Stroke, 1, 0.4)
		card.Parent = body

		card.MouseEnter:Connect(function()
			Util.tween(card, {BackgroundColor3 = Theme.CardHover}, 0.15)
		end)
		card.MouseLeave:Connect(function()
			Util.tween(card, {BackgroundColor3 = Theme.Card}, 0.15)
		end)
		card.MouseButton1Click:Connect(function()
			Util.tween(card, {BackgroundColor3 = accent}, 0.08)
			task.delay(0.08, function()
				Util.tween(card, {BackgroundColor3 = Theme.CardHover}, 0.15)
			end)
			if cfg.Callback then cfg.Callback() end
		end)
	end

	-- ===== Slider =====
	function window:Slider(cfg)
		local min = cfg.Min or 0
		local max = cfg.Max or 100
		local value = cfg.Default or min
		local suffix = cfg.Suffix or ""

		local card = Instance.new("Frame")
		card.Name = cfg.Name or "Slider"
		card.BackgroundColor3 = Theme.Card
		card.BorderSizePixel = 0
		card.Size = UDim2.new(1, 0, 0, 64)
		card.LayoutOrder = nextOrder()
		Util.corner(card, 11)
		Util.stroke(card, Theme.Stroke, 1, 0.4)
		card.Parent = body

		Util.label(card, {
			Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -100, 0, 16),
			Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Name or "Slider",
		})
		local valueText = Util.label(card, {
			Position = UDim2.new(1, -90, 0, 8), Size = UDim2.fromOffset(76, 16),
			Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = accent,
			TextXAlignment = Enum.TextXAlignment.Right, Text = tostring(value) .. suffix,
		})

		local trackBtn = Instance.new("TextButton")
		trackBtn.BackgroundColor3 = Theme.Chip
		trackBtn.BorderSizePixel = 0
		trackBtn.Size = UDim2.new(1, -28, 0, 6)
		trackBtn.Position = UDim2.new(0, 14, 1, -18)
		trackBtn.Text = ""
		trackBtn.AutoButtonColor = false
		trackBtn.Parent = card
		Util.corner(trackBtn, 3)

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = accent
		fill.BorderSizePixel = 0
		fill.Size = UDim2.fromScale(0, 1)
		fill.Parent = trackBtn
		Util.corner(fill, 3)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(14, 14)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.Parent = card
		Util.corner(knob, 7)

		local obj = {}
		local function setP(p, fire)
			p = math.clamp(p, 0, 1)
			local v = min + (max - min) * p
			if cfg.Whole ~= false then
				v = math.floor(v + 0.5)
			else
				v = math.floor(v * 10 + 0.5) / 10
			end
			value = v
			valueText.Text = tostring(v) .. suffix
			fill.Size = UDim2.new(p, 0, 1, 0)
			knob.Position = UDim2.new(p, -8, 0.5, -8)
			if fire and cfg.Callback then cfg.Callback(v) end
		end

		local sliding = false
		trackBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = true
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local p = (input.Position.X - trackBtn.AbsolutePosition.X) / math.max(trackBtn.AbsoluteSize.X, 1)
				setP(p, true)
			end
		end)

		function obj:Set(v)
			setP((v - min) / math.max(max - min, 1), false)
		end
		function obj:Get()
			return value
		end

		task.defer(function()
			setP((value - min) / math.max(max - min, 1), false)
		end)
		return obj
	end

	-- ===== Dropdown =====
	function window:Dropdown(cfg)
		local options = cfg.Options or {}
		local current = cfg.Default or (options[1] or "")
		local open = false
		local popup = nil

		local card = Instance.new("TextButton")
		card.Name = cfg.Name or "Dropdown"
		card.BackgroundColor3 = Theme.Card
		card.BorderSizePixel = 0
		card.Size = UDim2.new(1, 0, 0, 46)
		card.AutoButtonColor = false
		card.Text = ""
		card.LayoutOrder = nextOrder()
		Util.corner(card, 11)
		Util.stroke(card, Theme.Stroke, 1, 0.4)
		card.Parent = body

		Util.label(card, {
			Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -120, 1, 0),
			Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Name or "Dropdown",
		})
		local valueText = Util.label(card, {
			Position = UDim2.new(1, -110, 0, 0), Size = UDim2.fromOffset(84, 46),
			Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = accent,
			TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd,
			Text = tostring(current),
		})
		local chevron = Util.label(card, {
			Position = UDim2.new(1, -24, 0, 0), Size = UDim2.fromOffset(14, 46),
			Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Right, Text = "v",
		})

		local obj = {}
		local function close()
			if popup then
				popup:Destroy()
				popup = nil
				open = false
				chevron.Text = "v"
			end
		end

		function obj:Set(opt)
			current = opt
			valueText.Text = tostring(opt)
			if cfg.Callback then cfg.Callback(opt) end
		end
		function obj:Get()
			return current
		end

		card.MouseButton1Click:Connect(function()
			if open then
				close()
				return
			end
			open = true
			chevron.Text = "^"
			popup = Instance.new("Frame")
			popup.ZIndex = 10
			popup.Position = UDim2.fromOffset(card.AbsolutePosition.X, card.AbsolutePosition.Y + card.AbsoluteSize.Y + 4)
			popup.Size = UDim2.fromOffset(card.AbsoluteSize.X, math.min(#options, 8) * 34 + 12)
			popup.BackgroundColor3 = Theme.Header
			popup.BorderSizePixel = 0
			Util.corner(popup, 12)
			Util.stroke(popup, Theme.Stroke, 1, 0.3)
			popup.Parent = screenGui

			local pl = Instance.new("UIListLayout")
			pl.Padding = UDim.new(0, 2)
			pl.SortOrder = Enum.SortOrder.LayoutOrder
			pl.Parent = popup

			local pp = Instance.new("UIPadding")
			pp.PaddingTop = UDim.new(0, 6)
			pp.PaddingLeft = UDim.new(0, 6)
			pp.PaddingRight = UDim.new(0, 6)
			pp.Parent = popup

			for i, opt in ipairs(options) do
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 0, 32)
				btn.BackgroundColor3 = (opt == current) and Theme.Chip or Theme.Card
				btn.BorderSizePixel = 0
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 13
				btn.TextColor3 = (opt == current) and accent or Theme.Text
				btn.Text = tostring(opt)
				btn.AutoButtonColor = false
				btn.LayoutOrder = i
				btn.ZIndex = 11
				Util.corner(btn, 8)
				btn.Parent = popup
				btn.MouseButton1Click:Connect(function()
					obj:Set(opt)
					close()
				end)
				btn.MouseEnter:Connect(function()
					Util.tween(btn, {BackgroundColor3 = Theme.CardHover}, 0.12)
				end)
				btn.MouseLeave:Connect(function()
					Util.tween(btn, {BackgroundColor3 = (opt == current) and Theme.Chip or Theme.Card}, 0.12)
				end)
			end
		end)

		return obj
	end
end
