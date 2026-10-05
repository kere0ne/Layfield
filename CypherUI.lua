--[[
	CypherUI v1.0
	A modern, single-file script hub framework. Rayfield-style, rebuilt better.

	- Glass-dark window, draggable, minimize/expand (LeftControl default)
	- Toggle cards: icon, status pill, animated switch, rebindable keybind
	- Buttons, sliders, dropdowns, section labels
	- Toast notifications with progress bar
	- Mobile friendly (touch drag + tap)
	- CypherUI:Destroy() unloads everything

	Edit the EXAMPLE SETUP section at the bottom.
]]

local CypherUI = {}
CypherUI.__index = CypherUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ================= THEME (re-skin everything here) =================
local Theme = {
	Window    = Color3.fromRGB(15, 17, 25),
	Header    = Color3.fromRGB(26, 30, 44),
	Card      = Color3.fromRGB(29, 33, 47),
	CardHover = Color3.fromRGB(38, 43, 61),
	Chip      = Color3.fromRGB(46, 52, 74),
	Stroke    = Color3.fromRGB(56, 62, 88),
	Text      = Color3.fromRGB(238, 241, 250),
	SubText   = Color3.fromRGB(146, 153, 178),
	Off       = Color3.fromRGB(58, 64, 92),
	Accent    = Color3.fromRGB(52, 142, 255),
}

-- ================= HELPERS =================
local function tween(obj, props, dur, style)
	local t = TweenService:Create(obj, TweenInfo.new(dur or 0.22, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Stroke
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.3
	s.Parent = parent
	return s
end

local function makeLabel(parent, props)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.BorderSizePixel = 0
	for k, v in pairs(props) do
		l[k] = v
	end
	l.Parent = parent
	return l
end

-- ================= WINDOW =================
function CypherUI:CreateWindow(config)
	config = config or {}

	local accent = config.AccentColor or Theme.Accent
	local width = math.clamp(config.Width or 440, 320, 720)
	local headerH = 62
	local bodyH = 390

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CypherUI_" .. tostring(math.random(100000, 999999))
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui

	local main = Instance.new("Frame")
	main.Name = "Window"
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.new(0.5, 0, 0.5, -20)
	main.Size = UDim2.fromOffset(width, headerH + bodyH)
	main.BackgroundColor3 = Theme.Window
	main.BorderSizePixel = 0
	corner(main, 16)
	stroke(main, Theme.Stroke, 1, 0.4)
	main.Parent = screenGui

	local scale = Instance.new("UIScale")
	scale.Scale = 0.94
	scale.Parent = main
	tween(scale, {Scale = 1}, 0.35, Enum.EasingStyle.Back)

	-- ---------- header ----------
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, headerH)
	header.BackgroundColor3 = Theme.Header
	header.BorderSizePixel = 0
	header.Parent = main
	corner(header, 16)

	local badge = Instance.new("Frame")
	badge.Size = UDim2.fromOffset(38, 38)
	badge.Position = UDim2.fromOffset(12, 12)
	badge.BackgroundColor3 = accent
	badge.BorderSizePixel = 0
	badge.Parent = header
	corner(badge, 12)
	makeLabel(badge, {
		Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 18,
		TextColor3 = Color3.fromRGB(255, 255, 255), Text = config.Icon or "C",
	})

	makeLabel(header, {
		Position = UDim2.fromOffset(62, 11), Size = UDim2.new(1, -130, 0, 20),
		Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, Text = config.Name or "Cypher Hub",
	})
	makeLabel(header, {
		Position = UDim2.fromOffset(62, 33), Size = UDim2.new(1, -130, 0, 14),
		Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left, Text = config.Subtitle or "",
	})

	local versionPill = Instance.new("Frame")
	versionPill.Size = UDim2.fromOffset(54, 22)
	versionPill.Position = UDim2.new(1, -106, 0, 20)
	versionPill.BackgroundColor3 = Theme.Chip
	versionPill.BorderSizePixel = 0
	versionPill.Parent = header
	corner(versionPill, 11)
	makeLabel(versionPill, {
		Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 11,
		TextColor3 = Theme.SubText, Text = config.Version or "v1.0",
	})

	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.fromOffset(30, 30)
	minBtn.Position = UDim2.new(1, -42, 0, 16)
	minBtn.BackgroundColor3 = Theme.Chip
	minBtn.BorderSizePixel = 0
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 16
	minBtn.TextColor3 = Theme.Text
	minBtn.Text = "-"
	minBtn.AutoButtonColor = false
	minBtn.Parent = header
	corner(minBtn, 10)

	-- ---------- body ----------
	local body = Instance.new("ScrollingFrame")
	body.Name = "Body"
	body.Position = UDim2.fromOffset(0, headerH)
	body.Size = UDim2.new(1, 0, 0, bodyH)
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.ScrollBarThickness = 3
	body.ScrollBarImageColor3 = accent
	body.CanvasSize = UDim2.new(0, 0, 0, 0)
	body.AutomaticCanvasSize = Enum.AutomaticSize.Y
	body.Parent = main

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = body

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 10)
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.PaddingBottom = UDim.new(0, 10)
	pad.Parent = body

	-- ---------- minimize / toggle key ----------
	local minimized = false
	local function setMinimized(v)
		minimized = v
		minBtn.Text = v and "+" or "-"
		if v then
			tween(main, {Size = UDim2.fromOffset(width, headerH)}, 0.3)
			task.delay(0.3, function()
				if minimized then body.Visible = false end
			end)
		else
			body.Visible = true
			tween(main, {Size = UDim2.fromOffset(width, headerH + bodyH)}, 0.3)
		end
	end

	minBtn.MouseButton1Click:Connect(function()
		setMinimized(not minimized)
	end)

	local toggleKey = config.ToggleKey or Enum.KeyCode.LeftControl
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == toggleKey then
			setMinimized(not minimized)
		end
	end)

	-- ---------- dragging ----------
	local dragging = false
	local dragStart, startPos
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
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
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- ---------- toasts ----------
	local toastHolder = Instance.new("Frame")
	toastHolder.Name = "Toasts"
	toastHolder.AnchorPoint = Vector2.new(0.5, 0)
	toastHolder.Position = UDim2.new(0.5, 0, 0, 14)
	toastHolder.Size = UDim2.new(0, 340, 0, 0)
	toastHolder.AutomaticSize = Enum.AutomaticSize.Y
	toastHolder.BackgroundTransparency = 1
	toastHolder.Parent = screenGui

	local toastLayout = Instance.new("UIListLayout")
	toastLayout.Padding = UDim.new(0, 8)
	toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
	toastLayout.Parent = toastHolder

	-- ---------- element plumbing ----------
	local order = 0
	local function nextOrder()
		order = order + 1
		return order
	end

	local window = {}
	window._gui = screenGui

	-- ===== Section =====
	function window:Section(txt)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, 0, 0, 20)
		f.BackgroundTransparency = 1
		f.LayoutOrder = nextOrder()
		f.Parent = body
		makeLabel(f, {
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
		makeLabel(f, {
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
		corner(card, 12)
		stroke(card, Theme.Stroke, 1, 0.4)
		card.Parent = body

		local iconBox = Instance.new("Frame")
		iconBox.Size = UDim2.fromOffset(40, 40)
		iconBox.Position = UDim2.fromOffset(12, 14)
		iconBox.BackgroundColor3 = Theme.Chip
		iconBox.BorderSizePixel = 0
		iconBox.Parent = card
		corner(iconBox, 11)
		makeLabel(iconBox, {
			Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 16,
			TextColor3 = accent, Text = cfg.Icon or "-",
		})

		makeLabel(card, {
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
		corner(pill, 10)
		local pillDot = Instance.new("Frame")
		pillDot.Size = UDim2.fromOffset(6, 6)
		pillDot.Position = UDim2.fromOffset(9, 7)
		pillDot.BackgroundColor3 = Theme.SubText
		pillDot.BorderSizePixel = 0
		pillDot.Parent = pill
		corner(pillDot, 3)
		local pillText = makeLabel(pill, {
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
		corner(switch, 13)
		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(20, 20)
		knob.Position = UDim2.fromOffset(3, 3)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.Parent = switch
		corner(knob, 10)

		makeLabel(card, {
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
		corner(chip, 7)
		makeLabel(card, {
			Position = UDim2.new(1, -14, 0, 63), Size = UDim2.fromOffset(120, 14),
			Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Right, Text = "click to rebind",
		})

		local obj = {}
		local function render()
			if state then
				tween(switch, {BackgroundColor3 = accent})
				tween(knob, {Position = UDim2.fromOffset(23, 3)})
				pillText.Text = "ACTIVE"
				pillText.TextColor3 = accent
				pillDot.BackgroundColor3 = accent
			else
				tween(switch, {BackgroundColor3 = Theme.Off})
				tween(knob, {Position = UDim2.fromOffset(3, 3)})
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
			tween(card, {BackgroundColor3 = Theme.CardHover}, 0.15)
		end)
		card.MouseLeave:Connect(function()
			tween(card, {BackgroundColor3 = Theme.Card}, 0.15)
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
		corner(card, 11)
		stroke(card, Theme.Stroke, 1, 0.4)
		card.Parent = body

		card.MouseEnter:Connect(function()
			tween(card, {BackgroundColor3 = Theme.CardHover}, 0.15)
		end)
		card.MouseLeave:Connect(function()
			tween(card, {BackgroundColor3 = Theme.Card}, 0.15)
		end)
		card.MouseButton1Click:Connect(function()
			tween(card, {BackgroundColor3 = accent}, 0.08)
			task.delay(0.08, function()
				tween(card, {BackgroundColor3 = Theme.CardHover}, 0.15)
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
		corner(card, 11)
		stroke(card, Theme.Stroke, 1, 0.4)
		card.Parent = body

		makeLabel(card, {
			Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -100, 0, 16),
			Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Name or "Slider",
		})
		local valueText = makeLabel(card, {
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
		corner(trackBtn, 3)

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = accent
		fill.BorderSizePixel = 0
		fill.Size = UDim2.fromScale(0, 1)
		fill.Parent = trackBtn
		corner(fill, 3)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(14, 14)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.Parent = card
		corner(knob, 7)

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
		corner(card, 11)
		stroke(card, Theme.Stroke, 1, 0.4)
		card.Parent = body

		makeLabel(card, {
			Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -120, 1, 0),
			Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Name or "Dropdown",
		})
		local valueText = makeLabel(card, {
			Position = UDim2.new(1, -110, 0, 0), Size = UDim2.fromOffset(84, 46),
			Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = accent,
			TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd,
			Text = tostring(current),
		})
		local chevron = makeLabel(card, {
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
			corner(popup, 12)
			stroke(popup, Theme.Stroke, 1, 0.3)
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
				corner(btn, 8)
				btn.Parent = popup
				btn.MouseButton1Click:Connect(function()
					obj:Set(opt)
					close()
				end)
				btn.MouseEnter:Connect(function()
					tween(btn, {BackgroundColor3 = Theme.CardHover}, 0.12)
				end)
				btn.MouseLeave:Connect(function()
					tween(btn, {BackgroundColor3 = (opt == current) and Theme.Chip or Theme.Card}, 0.12)
				end)
			end
		end)

		return obj
	end

	-- ===== Notify =====
	function window:Notify(cfg)
		local dur = cfg.Duration or 3

		local toast = Instance.new("CanvasGroup")
		toast.Size = UDim2.new(1, 0, 0, 64)
		toast.BackgroundColor3 = Theme.Header
		toast.BorderSizePixel = 0
		toast.GroupTransparency = 1
		corner(toast, 14)
		stroke(toast, Theme.Stroke, 1, 0.4)
		toast.Parent = toastHolder

		local tBadge = Instance.new("Frame")
		tBadge.Size = UDim2.fromOffset(34, 34)
		tBadge.Position = UDim2.fromOffset(13, 13)
		tBadge.BackgroundColor3 = accent
		tBadge.BorderSizePixel = 0
		tBadge.Parent = toast
		corner(tBadge, 11)
		makeLabel(tBadge, {
			Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 14,
			TextColor3 = Color3.fromRGB(255, 255, 255), Text = cfg.Icon or "-",
		})

		makeLabel(toast, {
			Position = UDim2.fromOffset(58, 12), Size = UDim2.new(1, -72, 0, 17),
			Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.Title or "Notification",
		})
		makeLabel(toast, {
			Position = UDim2.fromOffset(58, 32), Size = UDim2.new(1, -72, 0, 15),
			Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.Text or "",
		})

		local bar = Instance.new("Frame")
		bar.AnchorPoint = Vector2.new(0, 1)
		bar.Position = UDim2.new(0, 0, 1, 0)
		bar.Size = UDim2.new(1, 0, 0, 3)
		bar.BackgroundColor3 = accent
		bar.BorderSizePixel = 0
		bar.Parent = toast
		corner(bar, 2)
		tween(bar, {Size = UDim2.new(0, 0, 0, 3)}, dur, Enum.EasingStyle.Linear)

		tween(toast, {GroupTransparency = 0}, 0.25)
		task.delay(dur, function()
			local t = tween(toast, {GroupTransparency = 1}, 0.25)
			t.Completed:Wait()
			toast:Destroy()
		end)
	end

	-- ===== footer hint =====
	window:Label("gui toggle: " .. toggleKey.Name .. "   |   drag the header to move   |   CypherUI:Destroy() unloads")

	return window
end

-- ===== unload everything =====
function CypherUI:Destroy()
	for _, gui in ipairs(PlayerGui:GetChildren()) do
		if gui:IsA("ScreenGui") and string.find(gui.Name, "CypherUI_") == 1 then
			gui:Destroy()
		end
	end
end

--========================================================================
--  EXAMPLE SETUP (edit this part)
--========================================================================
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

-- Inf Jump (working example)
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

-- Anti Ragdoll (working example, survives respawn)
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
	Suffix = "",
	Callback = function(v)
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = v
		end
	end,
})

Window:Dropdown({
	Name = "Theme Accent",
	Options = {"Blue", "Purple", "Green", "Orange", "Red"},
	Default = "Blue",
	Callback = function(opt)
		-- example: swap the accent color of new elements
	end,
})

Window:Section("Utilities")

Window:Button({
	Name = "Rejoin Server",
	Icon = ">",
	Callback = function()
		-- example: rejoin
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

-- startup toast, like the screenshot
Window:Notify({
	Title = "Kawatan Hub",
	Text = "Anti Bat system online",
	Icon = "K",
	Duration = 3,
})
