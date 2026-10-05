--[[
	Layfield elements.lua (v2.1, compact Rayfield-style rows)
	Registers the element factories on a tab:
	Section, Label, Toggle, Button, Slider, Dropdown, Input, Paragraph, Keybind.
	deps: { tab, frame, screenGui, Theme, Util, accent, search }
]]

return function(deps)
	local Theme, Util = deps.Theme, deps.Util
	local frame, screenGui = deps.frame, deps.screenGui
	local accent, search, tab = deps.accent, deps.search, deps.tab
	local UserInputService = game:GetService("UserInputService")

	local order = 0
	local function nextOrder()
		order = order + 1
		return order
	end

	local function register(f, name)
		f.LayoutOrder = nextOrder()
		f.Parent = frame
		if name then
			table.insert(search, {frame = f, name = name})
		end
	end

	local function typingInBox()
		return UserInputService:GetFocusedTextBox() ~= nil
	end

	-- ===== Section =====
	function tab:Section(txt)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, 0, 0, 18)
		f.BackgroundTransparency = 1
		register(f)
		Util.label(f, {
			Position = UDim2.fromOffset(2, 2), Size = UDim2.new(1, -4, 1, 0),
			Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left, Text = string.upper(txt or ""),
		})
	end

	-- ===== Label =====
	function tab:Label(txt)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, 0, 0, 14)
		f.BackgroundTransparency = 1
		register(f)
		Util.label(f, {
			Position = UDim2.fromOffset(2, 0), Size = UDim2.new(1, -4, 1, 0),
			Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left, Text = txt or "",
		})
	end

	-- ===== Toggle =====
	function tab:Toggle(cfg)
		local state = cfg.Default == true
		local key = cfg.Keybind or nil
		local rebinding = false

		local card = Instance.new("TextButton")
		card.Name = cfg.Name or "Toggle"
		card.BackgroundColor3 = Theme.Card
		card.BorderSizePixel = 0
		card.Size = UDim2.new(1, 0, 0, 34)
		card.AutoButtonColor = false
		card.Text = ""
		register(card, cfg.Name)
		Util.corner(card, 7)

		Util.label(card, {
			Position = UDim2.fromOffset(11, 0), Size = UDim2.new(1, -130, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.Name or "Toggle",
		})

		-- keybind chip
		local chip = Instance.new("TextButton")
		chip.AnchorPoint = Vector2.new(1, 0.5)
		chip.Position = UDim2.new(1, -58, 0.5, 0)
		chip.Size = UDim2.fromOffset(42, 18)
		chip.BackgroundColor3 = Theme.Chip
		chip.BorderSizePixel = 0
		chip.Font = Enum.Font.GothamBold
		chip.TextSize = 9
		chip.TextColor3 = Theme.SubText
		chip.Text = key and key.Name or "--"
		chip.AutoButtonColor = false
		chip.Parent = card
		Util.corner(chip, 5)

		-- switch
		local switch = Instance.new("Frame")
		switch.AnchorPoint = Vector2.new(1, 0.5)
		switch.Position = UDim2.new(1, -10, 0.5, 0)
		switch.Size = UDim2.fromOffset(34, 18)
		switch.BackgroundColor3 = Theme.Off
		switch.BorderSizePixel = 0
		switch.Parent = card
		Util.corner(switch, 9)
		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(14, 14)
		knob.Position = UDim2.fromOffset(2, 2)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.Parent = switch
		Util.corner(knob, 7)

		local obj = {}
		local function render()
			if state then
				Util.tween(switch, {BackgroundColor3 = accent}, 0.18)
				Util.tween(knob, {Position = UDim2.fromOffset(18, 2)}, 0.18)
				chip.TextColor3 = accent
			else
				Util.tween(switch, {BackgroundColor3 = Theme.Off}, 0.18)
				Util.tween(knob, {Position = UDim2.fromOffset(2, 2)}, 0.18)
				chip.TextColor3 = Theme.SubText
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
			Util.tween(card, {BackgroundColor3 = Theme.CardHover}, 0.12)
		end)
		card.MouseLeave:Connect(function()
			Util.tween(card, {BackgroundColor3 = Theme.Card}, 0.12)
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
			if gp or rebinding or typingInBox() then return end
			if key and input.KeyCode == key then
				obj:Set(not state)
			end
		end)

		if cfg.Flag and deps.registry then
			deps.registry[cfg.Flag] = obj
			local rawSet = obj.Set
			function obj:Set(v)
				rawSet(v)
				if deps.onFlagChange then
					deps.onFlagChange()
				end
			end
		end

		render()
		return obj
	end

	-- ===== Button =====
	function tab:Button(cfg)
		local card = Instance.new("TextButton")
		card.Name = cfg.Name or "Button"
		card.BackgroundColor3 = Theme.Card
		card.BorderSizePixel = 0
		card.Size = UDim2.new(1, 0, 0, 30)
		card.AutoButtonColor = false
		card.Font = Enum.Font.GothamMedium
		card.TextSize = 13
		card.TextColor3 = Theme.Text
		card.Text = (cfg.Icon and (cfg.Icon .. "  ") or "") .. (cfg.Name or "Button")
		register(card, cfg.Name)
		Util.corner(card, 7)

		card.MouseEnter:Connect(function()
			Util.tween(card, {BackgroundColor3 = Theme.CardHover}, 0.12)
		end)
		card.MouseLeave:Connect(function()
			Util.tween(card, {BackgroundColor3 = Theme.Card}, 0.12)
		end)
		card.MouseButton1Click:Connect(function()
			Util.tween(card, {BackgroundColor3 = accent}, 0.07)
			task.delay(0.07, function()
				Util.tween(card, {BackgroundColor3 = Theme.CardHover}, 0.12)
			end)
			if cfg.Callback then cfg.Callback() end
		end)
	end

	-- ===== Slider =====
	function tab:Slider(cfg)
		local min = cfg.Min or 0
		local max = cfg.Max or 100
		local value = cfg.Default or min
		local suffix = cfg.Suffix or ""

		local card = Instance.new("Frame")
		card.Name = cfg.Name or "Slider"
		card.BackgroundColor3 = Theme.Card
		card.BorderSizePixel = 0
		card.Size = UDim2.new(1, 0, 0, 42)
		register(card, cfg.Name)
		Util.corner(card, 7)

		Util.label(card, {
			Position = UDim2.fromOffset(11, 5), Size = UDim2.new(1, -80, 0, 14),
			Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Name or "Slider",
		})
		local valueText = Util.label(card, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -11, 0, 5), Size = UDim2.fromOffset(70, 14),
			Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = accent,
			TextXAlignment = Enum.TextXAlignment.Right, Text = tostring(value) .. suffix,
		})

		local trackBtn = Instance.new("TextButton")
		trackBtn.BackgroundColor3 = Theme.Off
		trackBtn.BorderSizePixel = 0
		trackBtn.Size = UDim2.new(1, -22, 0, 4)
		trackBtn.Position = UDim2.new(0, 11, 1, -13)
		trackBtn.Text = ""
		trackBtn.AutoButtonColor = false
		trackBtn.Parent = card
		Util.corner(trackBtn, 2)

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = accent
		fill.BorderSizePixel = 0
		fill.Size = UDim2.fromScale(0, 1)
		fill.Parent = trackBtn
		Util.corner(fill, 2)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(10, 10)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.Parent = trackBtn
		Util.corner(knob, 5)

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
			knob.Position = UDim2.new(p, -5, 0.5, -5)
			if fire and cfg.Callback then cfg.Callback(v) end
			if cfg.Flag and deps.onFlagChange then
				deps.onFlagChange()
			end
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
	function tab:Dropdown(cfg)
		local options = cfg.Options or {}
		local current = cfg.Default or (options[1] or "")
		local open = false
		local popup = nil
		local awayConn = nil

		local card = Instance.new("TextButton")
		card.Name = cfg.Name or "Dropdown"
		card.BackgroundColor3 = Theme.Card
		card.BorderSizePixel = 0
		card.Size = UDim2.new(1, 0, 0, 32)
		card.AutoButtonColor = false
		card.Text = ""
		register(card, cfg.Name)
		Util.corner(card, 7)

		Util.label(card, {
			Position = UDim2.fromOffset(11, 0), Size = UDim2.new(1, -120, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.Name or "Dropdown",
		})
		local valueText = Util.label(card, {
			Position = UDim2.new(1, -108, 0, 0), Size = UDim2.fromOffset(84, 32),
			Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = accent,
			TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd,
			Text = tostring(current),
		})
		local chevron = Util.label(card, {
			Position = UDim2.new(1, -20, 0, 0), Size = UDim2.fromOffset(10, 32),
			Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Right, Text = "v",
		})

		local obj = {}
		local function close()
			if popup then
				popup:Destroy()
				popup = nil
				open = false
				chevron.Text = "v"
				if awayConn then
					awayConn:Disconnect()
					awayConn = nil
				end
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
			popup.Position = UDim2.fromOffset(card.AbsolutePosition.X, card.AbsolutePosition.Y + card.AbsoluteSize.Y + 3)
			popup.Size = UDim2.fromOffset(card.AbsoluteSize.X, math.min(#options, 8) * 28 + 10)
			popup.BackgroundColor3 = Theme.Header
			popup.BorderSizePixel = 0
			Util.corner(popup, 8)
			Util.stroke(popup, Theme.Stroke, 1, 0.35)
			popup.Parent = screenGui

			local pl = Instance.new("UIListLayout")
			pl.Padding = UDim.new(0, 2)
			pl.SortOrder = Enum.SortOrder.LayoutOrder
			pl.Parent = popup

			local pp = Instance.new("UIPadding")
			pp.PaddingTop = UDim.new(0, 5)
			pp.PaddingLeft = UDim.new(0, 5)
			pp.PaddingRight = UDim.new(0, 5)
			pp.Parent = popup

			for i, opt in ipairs(options) do
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 0, 26)
				btn.BackgroundColor3 = (opt == current) and Theme.Chip or Theme.Card
				btn.BorderSizePixel = 0
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 12
				btn.TextColor3 = (opt == current) and accent or Theme.Text
				btn.Text = tostring(opt)
				btn.AutoButtonColor = false
				btn.LayoutOrder = i
				btn.ZIndex = 11
				Util.corner(btn, 6)
				btn.Parent = popup
				btn.MouseButton1Click:Connect(function()
					obj:Set(opt)
					close()
				end)
				btn.MouseEnter:Connect(function()
					Util.tween(btn, {BackgroundColor3 = Theme.CardHover}, 0.1)
				end)
				btn.MouseLeave:Connect(function()
					Util.tween(btn, {BackgroundColor3 = (opt == current) and Theme.Chip or Theme.Card}, 0.1)
				end)
			end

			awayConn = UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					local p = input.Position
					local ap, as = popup.AbsolutePosition, popup.AbsoluteSize
					if p.X < ap.X or p.X > ap.X + as.X or p.Y < ap.Y or p.Y > ap.Y + as.Y then
						close()
					end
				end
			end)
		end)

		if cfg.Flag and deps.registry then
			deps.registry[cfg.Flag] = obj
			local rawSet = obj.Set
			function obj:Set(v)
				rawSet(v)
				if deps.onFlagChange then
					deps.onFlagChange()
				end
			end
		end

		return obj
	end

	-- ===== Input =====
	function tab:Input(cfg)
		local card = Instance.new("Frame")
		card.Name = cfg.Name or "Input"
		card.BackgroundColor3 = Theme.Card
		card.BorderSizePixel = 0
		card.Size = UDim2.new(1, 0, 0, 34)
		register(card, cfg.Name)
		Util.corner(card, 7)

		Util.label(card, {
			Position = UDim2.fromOffset(11, 0), Size = UDim2.new(1, -170, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.Name or "Input",
		})

		local box = Instance.new("TextBox")
		box.AnchorPoint = Vector2.new(1, 0.5)
		box.Position = UDim2.new(1, -10, 0.5, 0)
		box.Size = UDim2.fromOffset(150, 22)
		box.BackgroundColor3 = Theme.Chip
		box.BorderSizePixel = 0
		box.Font = Enum.Font.Gotham
		box.TextSize = 11
		box.TextColor3 = Theme.Text
		box.PlaceholderText = cfg.Placeholder or "type here..."
		box.PlaceholderColor3 = Theme.SubText
		box.Text = cfg.Default or ""
		box.ClearTextOnFocus = false
		box.Parent = card
		Util.corner(box, 5)
		local bpad = Instance.new("UIPadding")
		bpad.PaddingLeft = UDim.new(0, 7)
		bpad.PaddingRight = UDim.new(0, 7)
		bpad.Parent = box

		box.FocusLost:Connect(function(enter)
			if cfg.Callback then
				cfg.Callback(box.Text, enter)
			end
		end)

		local obj = {}
		function obj:Set(text)
			box.Text = tostring(text)
		end
		function obj:Get()
			return box.Text
		end

		if cfg.Flag and deps.registry then
			deps.registry[cfg.Flag] = obj
			local rawSet = obj.Set
			function obj:Set(v)
				rawSet(v)
				if deps.onFlagChange then
					deps.onFlagChange()
				end
			end
		end

		return obj
	end

	-- ===== Paragraph =====
	function tab:Paragraph(cfg)
		local card = Instance.new("Frame")
		card.Name = cfg.Title or "Paragraph"
		card.BackgroundColor3 = Theme.Card
		card.BorderSizePixel = 0
		card.AutomaticSize = Enum.AutomaticSize.Y
		card.Size = UDim2.new(1, 0, 0, 0)
		register(card, cfg.Title)
		Util.corner(card, 7)

		local cardPad = Instance.new("UIPadding")
		cardPad.PaddingBottom = UDim.new(0, 8)
		cardPad.Parent = card

		if cfg.Title then
			Util.label(card, {
				Position = UDim2.fromOffset(11, 8), Size = UDim2.new(1, -22, 0, 14),
				Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Title,
			})
		end
		Util.label(card, {
			Position = UDim2.fromOffset(11, cfg.Title and 24 or 8),
			Size = UDim2.new(1, -22, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
			Text = cfg.Text or "",
		})
	end

	-- ===== Keybind =====
	function tab:Keybind(cfg)
		local key = cfg.Default or nil
		local rebinding = false

		local card = Instance.new("Frame")
		card.Name = cfg.Name or "Keybind"
		card.BackgroundColor3 = Theme.Card
		card.BorderSizePixel = 0
		card.Size = UDim2.new(1, 0, 0, 32)
		register(card, cfg.Name)
		Util.corner(card, 7)

		Util.label(card, {
			Position = UDim2.fromOffset(11, 0), Size = UDim2.new(1, -100, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.Name or "Keybind",
		})

		local chip = Instance.new("TextButton")
		chip.AnchorPoint = Vector2.new(1, 0.5)
		chip.Position = UDim2.new(1, -10, 0.5, 0)
		chip.Size = UDim2.fromOffset(56, 20)
		chip.BackgroundColor3 = Theme.Chip
		chip.BorderSizePixel = 0
		chip.Font = Enum.Font.GothamBold
		chip.TextSize = 10
		chip.TextColor3 = Theme.Text
		chip.Text = key and key.Name or "--"
		chip.AutoButtonColor = false
		chip.Parent = card
		Util.corner(chip, 5)

		local obj = {}
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
			if gp or rebinding or typingInBox() then return end
			if key and input.KeyCode == key then
				if cfg.Callback then cfg.Callback() end
			end
		end)

		function obj:SetKeybind(kc)
			key = kc
			chip.Text = key and key.Name or "--"
		end
		function obj:Get()
			return key
		end
		return obj
	end
end
