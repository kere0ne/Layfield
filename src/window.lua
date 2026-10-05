--[[
	Layfield window.lua
	Builds the window: header, tab bar with live search, draggable frame,
	minimize/toggle key, toasts, then wires tabs to the element factories.
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
	local width = math.clamp(config.Width or 460, 320, 760)
	local headerH = 62
	local tabbarH = 40
	local bodyH = 380
	local contentY = headerH + tabbarH

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Layfield_" .. tostring(math.random(100000, 999999))
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui

	local main = Instance.new("Frame")
	main.Name = "Window"
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.new(0.5, 0, 0.5, -20)
	main.Size = UDim2.fromOffset(width, contentY + bodyH)
	main.BackgroundColor3 = Theme.Window
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
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
		TextColor3 = Color3.fromRGB(255, 255, 255), Text = config.Icon or "L",
	})

	Util.label(header, {
		Position = UDim2.fromOffset(62, 11), Size = UDim2.new(1, -130, 0, 20),
		Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, Text = config.Name or "Layfield",
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
		TextColor3 = Theme.SubText, Text = config.Version or "v2.0",
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

	-- ---------- tab bar + search ----------
	local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Position = UDim2.fromOffset(0, headerH)
	tabBar.Size = UDim2.new(1, 0, 0, tabbarH)
	tabBar.BackgroundColor3 = Theme.Header
	tabBar.BackgroundTransparency = 0.35
	tabBar.BorderSizePixel = 0
	tabBar.Parent = main

	local tabList = Instance.new("Frame")
	tabList.BackgroundTransparency = 1
	tabList.Size = UDim2.new(1, -170, 1, 0)
	tabList.Parent = tabBar
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabList
	local tabPad = Instance.new("UIPadding")
	tabPad.PaddingLeft = UDim.new(0, 10)
	tabPad.Parent = tabList

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "Search"
	searchBox.AnchorPoint = Vector2.new(1, 0.5)
	searchBox.Position = UDim2.new(1, -12, 0.5, 0)
	searchBox.Size = UDim2.fromOffset(150, 26)
	searchBox.BackgroundColor3 = Theme.Card
	searchBox.BorderSizePixel = 0
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 12
	searchBox.TextColor3 = Theme.Text
	searchBox.PlaceholderText = "search elements..."
	searchBox.PlaceholderColor3 = Theme.SubText
	searchBox.Text = ""
	searchBox.ClearTextOnFocus = false
	searchBox.Parent = tabBar
	Util.corner(searchBox, 8)
	Util.stroke(searchBox, Theme.Stroke, 1, 0.5)
	local searchPad = Instance.new("UIPadding")
	searchPad.PaddingLeft = UDim.new(0, 8)
	searchPad.PaddingRight = UDim.new(0, 8)
	searchPad.Parent = searchBox

	-- ---------- tabs ----------
	local tabs = {}
	local activeTab = nil

	local window = {}
	window._gui = screenGui
	window._accent = accent

	local function applySearch()
		if not activeTab then return end
		local q = string.lower(searchBox.Text)
		for _, item in ipairs(activeTab._search) do
			item.frame.Visible = (q == "") or (string.find(string.lower(item.name), q, 1, true) ~= nil)
		end
	end
	searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

	local function selectTab(tab)
		activeTab = tab
		for _, t in ipairs(tabs) do
			t.frame.Visible = (t == tab)
			if t == tab then
				Util.tween(t.btn, {BackgroundColor3 = Theme.Chip, TextColor3 = accent})
			else
				Util.tween(t.btn, {BackgroundColor3 = Theme.Card, TextColor3 = Theme.SubText})
			end
		end
		applySearch()
	end

	function window:Tab(name, icon)
		local frame = Instance.new("ScrollingFrame")
		frame.Name = name or "Tab"
		frame.Position = UDim2.fromOffset(0, contentY)
		frame.Size = UDim2.new(1, 0, 0, bodyH)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.ScrollBarThickness = 3
		frame.ScrollBarImageColor3 = accent
		frame.CanvasSize = UDim2.new(0, 0, 0, 0)
		frame.AutomaticCanvasSize = Enum.AutomaticSize.Y

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = frame

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 10)
		pad.PaddingLeft = UDim.new(0, 10)
		pad.PaddingRight = UDim.new(0, 10)
		pad.PaddingBottom = UDim.new(0, 10)
		pad.Parent = frame

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromOffset(math.max(50, 18 + #(name or "") * 8), 26)
		btn.BackgroundColor3 = Theme.Card
		btn.BorderSizePixel = 0
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.TextColor3 = Theme.SubText
		btn.Text = (icon and (icon .. " ") or "") .. (name or "Tab")
		btn.LayoutOrder = #tabs + 1
		btn.AutoButtonColor = false
		btn.Parent = tabList
		Util.corner(btn, 8)

		local tab = {_frame = frame, frame = frame, btn = btn, _search = {}}
		local order = 0
		function tab._nextOrder()
			order = order + 1
			return order
		end

		btn.MouseButton1Click:Connect(function()
			selectTab(tab)
		end)

		local elements = fetch("elements")
		elements({
			tab = tab,
			frame = frame,
			screenGui = screenGui,
			Theme = Theme,
			Util = Util,
			accent = accent,
			search = tab._search,
		})

		table.insert(tabs, tab)
		if #tabs == 1 then
			selectTab(tab)
		end
		return tab
	end

	-- default tab, so window:Toggle(...) works without making one
	local mainTab = window:Tab(config.DefaultTab or "Main", "-")
	for _, fname in ipairs({"Section", "Label", "Toggle", "Button", "Slider", "Dropdown", "Input", "Paragraph", "Keybind"}) do
		window[fname] = function(self, cfg)
			return mainTab[fname](mainTab, cfg)
		end
	end
	function window:SelectTab(t)
		if typeof(t) == "table" and t.frame then
			selectTab(t)
		end
	end

	-- ---------- minimize / toggle key ----------
	local minimized = false
	local function setMinimized(v)
		minimized = v
		minBtn.Text = v and "+" or "-"
		if v then
			Util.tween(main, {Size = UDim2.fromOffset(width, contentY)}, 0.3)
			task.delay(0.3, function()
				if minimized then
					for _, t in ipairs(tabs) do
						t.frame.Visible = false
					end
				end
			end)
		else
			for _, t in ipairs(tabs) do
				t.frame.Visible = (t == activeTab)
			end
			Util.tween(main, {Size = UDim2.fromOffset(width, contentY + bodyH)}, 0.3)
		end
	end

	minBtn.MouseButton1Click:Connect(function()
		setMinimized(not minimized)
	end)

	local toggleKey = config.ToggleKey or Enum.KeyCode.LeftControl
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if UserInputService:GetFocusedTextBox() then return end
		if input.KeyCode == toggleKey then
			setMinimized(not minimized)
		end
	end)

	-- ---------- dragging (clamped to screen) ----------
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
			local cam = workspace.CurrentCamera
			local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
			local x = math.clamp(startPos.X.Offset + delta.X, -vp.X / 2 + width * 0.35, vp.X / 2 - width * 0.35)
			local y = math.clamp(startPos.Y.Offset + delta.Y, -vp.Y / 2 + 40, vp.Y / 2 - 40)
			main.Position = UDim2.new(startPos.X.Scale, x, startPos.Y.Scale, y)
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

	local notifyModule = fetch("notify")
	local Notify = notifyModule({holder = toastHolder, Theme = Theme, Util = Util, accent = accent})
	window.Notify = function(_, cfg)
		Notify.make(cfg or {})
	end

	return window
end
