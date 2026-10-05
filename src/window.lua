--[[
	CypherUI window.lua
	Builds the window: header, draggable frame, minimize/toggle key,
	scrolling body, toasts, then registers the element factories.
	deps: { Library, Theme, Util, fetch, config }
]]

return function(deps)
	local Theme, Util, fetch = deps.Theme, deps.Util, deps.fetch
	local config = deps.config or {}
	local UserInputService = game:GetService("UserInputService")
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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
	Util.corner(main, 16)
	Util.stroke(main, Theme.Stroke, 1, 0.4)
	main.Parent = screenGui

	local scale = Instance.new("UIScale")
	scale.Scale = 0.94
	scale.Parent = main
	Util.tween(scale, {Scale = 1}, 0.35, Enum.EasingStyle.Back)

	-- ---------- header ----------
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, headerH)
	header.BackgroundColor3 = Theme.Header
	header.BorderSizePixel = 0
	header.Parent = main
	Util.corner(header, 16)

	local badge = Instance.new("Frame")
	badge.Size = UDim2.fromOffset(38, 38)
	badge.Position = UDim2.fromOffset(12, 12)
	badge.BackgroundColor3 = accent
	badge.BorderSizePixel = 0
	badge.Parent = header
	Util.corner(badge, 12)
	Util.label(badge, {
		Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 18,
		TextColor3 = Color3.fromRGB(255, 255, 255), Text = config.Icon or "C",
	})

	Util.label(header, {
		Position = UDim2.fromOffset(62, 11), Size = UDim2.new(1, -130, 0, 20),
		Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, Text = config.Name or "Cypher Hub",
	})
	Util.label(header, {
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
	Util.corner(versionPill, 11)
	Util.label(versionPill, {
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
	Util.corner(minBtn, 10)

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
			Util.tween(main, {Size = UDim2.fromOffset(width, headerH)}, 0.3)
			task.delay(0.3, function()
				if minimized then body.Visible = false end
			end)
		else
			body.Visible = true
			Util.tween(main, {Size = UDim2.fromOffset(width, headerH + bodyH)}, 0.3)
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

	-- ---------- window api ----------
	local order = 0
	local function nextOrder()
		order = order + 1
		return order
	end

	local window = {}
	window._gui = screenGui
	window._main = main
	window._accent = accent

	local notifyModule = fetch("notify")
	local Notify = notifyModule({holder = toastHolder, Theme = Theme, Util = Util, accent = accent})
	window.Notify = function(_, cfg)
		Notify.make(cfg or {})
	end

	local elements = fetch("elements")
	elements({
		window = window,
		body = body,
		screenGui = screenGui,
		Theme = Theme,
		Util = Util,
		accent = accent,
		nextOrder = nextOrder,
	})

	window:Label("gui toggle: " .. toggleKey.Name .. "   |   drag the header to move")

	return window
end
