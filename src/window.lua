--[[
	LayField window.lua (v2.1, compact Rayfield-style layout)
	Title bar on top, tab sidebar on the left with live search,
	compact content rows. Smaller, denser, smoother.
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
	local width = math.clamp(config.Width or 520, 380, 760)
	local height = math.clamp(config.Height or 340, 260, 600)
	local headerH = 40
	local sidebarW = 132

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LayField_" .. tostring(math.random(100000, 999999))
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui

	local main = Instance.new("Frame")
	main.Name = "Window"
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.new(0.5, 0, 0.5, -20)
	main.Size = UDim2.fromOffset(width, height)
	main.BackgroundColor3 = Theme.Window
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	Util.corner(main, 10)
	Util.stroke(main, Theme.Stroke, 1, 0.45)
	main.Parent = screenGui

	local scale = Instance.new("UIScale")
	scale.Scale = 0.96
	scale.Parent = main
	Util.tween(scale, {Scale = 1}, 0.3, Enum.EasingStyle.Quint)

	-- ---------- title bar ----------
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, headerH)
	header.BackgroundColor3 = Theme.Header
	header.BorderSizePixel = 0
	header.Parent = main

	local badge = Instance.new("Frame")
	badge.Size = UDim2.fromOffset(24, 24)
	badge.Position = UDim2.fromOffset(9, 8)
	badge.BackgroundColor3 = accent
	badge.BorderSizePixel = 0
	badge.Parent = header
	Util.corner(badge, 7)
	Util.label(badge, {
		Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 12,
		TextColor3 = Color3.fromRGB(255, 255, 255), Text = config.Icon or "L",
	})

	Util.label(header, {
		Position = UDim2.fromOffset(42, 0), Size = UDim2.new(1, -130, 1, 0),
		Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, Text = config.Name or "LayField",
	})

	local versionPill = Instance.new("Frame")
	versionPill.AnchorPoint = Vector2.new(1, 0.5)
	versionPill.Position = UDim2.new(1, -40, 0.5, 0)
	versionPill.Size = UDim2.fromOffset(42, 17)
	versionPill.BackgroundColor3 = Theme.Chip
	versionPill.BorderSizePixel = 0
	versionPill.Parent = header
	Util.corner(versionPill, 5)
	Util.label(versionPill, {
		Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 9,
		TextColor3 = Theme.SubText, Text = config.Version or "v2.3",
	})

	local minBtn = Instance.new("TextButton")
	minBtn.AnchorPoint = Vector2.new(1, 0)
	minBtn.Position = UDim2.new(1, -8, 0, 8)
	minBtn.Size = UDim2.fromOffset(24, 24)
	minBtn.BackgroundColor3 = Theme.Chip
	minBtn.BorderSizePixel = 0
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 13
	minBtn.TextColor3 = Theme.Text
	minBtn.Text = "-"
	minBtn.AutoButtonColor = false
	minBtn.Parent = header
	Util.corner(minBtn, 6)

	-- ---------- sidebar ----------
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Position = UDim2.fromOffset(0, headerH)
	sidebar.Size = UDim2.new(0, sidebarW, 0, height - headerH)
	sidebar.BackgroundColor3 = Theme.Sidebar
	sidebar.BorderSizePixel = 0
	sidebar.Parent = main

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "Search"
	searchBox.Position = UDim2.fromOffset(8, 8)
	searchBox.Size = UDim2.new(1, -16, 0, 24)
	searchBox.BackgroundColor3 = Theme.Card
	searchBox.BorderSizePixel = 0
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 11
	searchBox.TextColor3 = Theme.Text
	searchBox.PlaceholderText = "search..."
	searchBox.PlaceholderColor3 = Theme.SubText
	searchBox.Text = ""
	searchBox.ClearTextOnFocus = false
	searchBox.Parent = sidebar
	Util.corner(searchBox, 6)
	local searchPad = Instance.new("UIPadding")
	searchPad.PaddingLeft = UDim.new(0, 7)
	searchPad.PaddingRight = UDim.new(0, 7)
	searchPad.Parent = searchBox

	local tabList = Instance.new("Frame")
	tabList.Name = "TabList"
	tabList.Position = UDim2.fromOffset(0, 40)
	tabList.Size = UDim2.new(1, 0, 1, -40)
	tabList.BackgroundTransparency = 1
	tabList.Parent = sidebar

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 3)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabList

	local tabPad = Instance.new("UIPadding")
	tabPad.PaddingLeft = UDim.new(0, 8)
	tabPad.PaddingRight = UDim.new(0, 8)
	tabPad.PaddingTop = UDim.new(0, 4)
	tabPad.Parent = tabList

	-- ---------- tabs ----------
	local tabs = {}
	local activeTab = nil

	local window = {}
	window._gui = screenGui
	window._accent = accent

	window._flags = {}

	-- config saving (Rayfield-style flags, stored via writefile when available)
	local HttpService = game:GetService("HttpService")
	local hasFS = (type(writefile) == "function") and (type(isfolder) == "function")
		and (type(makefolder) == "function") and (type(readfile) == "function")
	local saveScheduled = false
	local function ensureFolders()
		pcall(function()
			if not isfolder("LayField") then makefolder("LayField") end
			if not isfolder("LayField/Configs") then makefolder("LayField/Configs") end
		end)
	end
	local function saveConfig(cfgName)
		if not hasFS then return end
		ensureFolders()
		local data = {}
		for flag, obj in pairs(window._flags) do
			local ok, v = pcall(obj.Get)
			if ok then
				data[flag] = v
			end
		end
		pcall(function()
			writefile("LayField/Configs/" .. tostring(cfgName) .. ".json", HttpService:JSONEncode(data))
		end)
	end
	local function loadConfig(cfgName)
		if not hasFS then return end
		local ok, contents = pcall(readfile, "LayField/Configs/" .. tostring(cfgName) .. ".json")
		if not ok or type(contents) ~= "string" then return end
		local ok2, data = pcall(function()
			return HttpService:JSONDecode(contents)
		end)
		if not ok2 or type(data) ~= "table" then return end
		for flag, v in pairs(data) do
			local obj = window._flags[flag]
			if obj then
				pcall(function()
					obj:Set(v)
				end)
			end
		end
	end
	local function queueSave()
		if not hasFS then return end
		if saveScheduled then return end
		saveScheduled = true
		task.delay(0.5, function()
			saveScheduled = false
			saveConfig(config.ConfigName or "default")
		end)
	end
	window.SaveConfig = function(_, name)
		saveConfig(name or config.ConfigName or "default")
	end
	window.LoadConfig = function(_, name)
		loadConfig(name or config.ConfigName or "default")
	end

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
				t.selBar.Visible = true
				Util.tween(t.btn, {BackgroundColor3 = Theme.Card, TextColor3 = Theme.Text})
			else
				t.selBar.Visible = false
				Util.tween(t.btn, {BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.SubText})
			end
		end
		applySearch()
	end

	function window:Tab(name, icon)
		local frame = Instance.new("ScrollingFrame")
		frame.Name = name or "Tab"
		frame.Position = UDim2.fromOffset(sidebarW, headerH)
		frame.Size = UDim2.new(1, -sidebarW, 0, height - headerH)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.ScrollBarThickness = 2
		frame.ScrollBarImageColor3 = accent
		frame.CanvasSize = UDim2.new(0, 0, 0, 0)
		frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		frame.Visible = false
		frame.Parent = main

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 5)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = frame

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 8)
		pad.PaddingLeft = UDim.new(0, 10)
		pad.PaddingRight = UDim.new(0, 10)
		pad.PaddingBottom = UDim.new(0, 10)
		pad.Parent = frame

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 28)
		btn.BackgroundColor3 = Theme.Sidebar
		btn.BorderSizePixel = 0
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.TextColor3 = Theme.SubText
		btn.Text = (icon and (icon .. "  ") or "") .. (name or "Tab")
		btn.AutoButtonColor = false
		btn.LayoutOrder = #tabs + 1
		btn.Parent = tabList
		Util.corner(btn, 6)

		local selBar = Instance.new("Frame")
		selBar.Size = UDim2.fromOffset(3, 14)
		selBar.Position = UDim2.fromOffset(0, 7)
		selBar.BackgroundColor3 = accent
		selBar.BorderSizePixel = 0
		selBar.Visible = false
		selBar.Parent = btn
		Util.corner(selBar, 2)
		local btnPad = Instance.new("UIPadding")
		btnPad.PaddingLeft = UDim.new(0, 10)
		btnPad.Parent = btn

		local tab = {_frame = frame, frame = frame, btn = btn, selBar = selBar, _search = {}}
		local order = 0
		function tab._nextOrder()
			order = order + 1
			return order
		end

		btn.MouseEnter:Connect(function()
			if activeTab ~= tab then
				Util.tween(btn, {BackgroundColor3 = Theme.Card}, 0.12)
			end
		end)
		btn.MouseLeave:Connect(function()
			if activeTab ~= tab then
				Util.tween(btn, {BackgroundColor3 = Theme.Sidebar}, 0.12)
			end
		end)
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
			registry = window._flags,
			onFlagChange = queueSave,
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
			Util.tween(main, {Size = UDim2.fromOffset(width, headerH)}, 0.28, Enum.EasingStyle.Quint)
			task.delay(0.28, function()
				if minimized then
					sidebar.Visible = false
					for _, t in ipairs(tabs) do
						t.frame.Visible = false
					end
				end
			end)
		else
			sidebar.Visible = true
			for _, t in ipairs(tabs) do
				t.frame.Visible = (t == activeTab)
			end
			Util.tween(main, {Size = UDim2.fromOffset(width, height)}, 0.28, Enum.EasingStyle.Quint)
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

	-- ---------- dragging (header or sidebar, clamped to screen) ----------
	local dragging = false
	local dragStart, startPos
	local function beginDrag(input)
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			beginDrag(input)
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
			local x = math.clamp(startPos.X.Offset + delta.X, -vp.X / 2 + width * 0.4, vp.X / 2 - width * 0.4)
			local y = math.clamp(startPos.Y.Offset + delta.Y, -vp.Y / 2 + 30, vp.Y / 2 - 30)
			main.Position = UDim2.new(startPos.X.Scale, x, startPos.Y.Scale, y)
		end
	end)


	-- ---------- floating open/close bubble (mobile friendly) ----------
	if config.ShowMobileButton ~= false then
		local bubble = Instance.new("TextButton")
		bubble.Name = "OpenButton"
		bubble.AnchorPoint = Vector2.new(0.5, 0.5)
		bubble.Position = UDim2.new(1, -30, 1, -30)
		bubble.Size = UDim2.fromOffset(34, 34)
		bubble.BackgroundColor3 = accent
		bubble.BorderSizePixel = 0
		bubble.Font = Enum.Font.GothamBold
		bubble.TextSize = 14
		bubble.TextColor3 = Color3.fromRGB(255, 255, 255)
		bubble.Text = "-"
		bubble.AutoButtonColor = false
		bubble.Parent = screenGui
		Util.corner(bubble, 17)

		local bDrag = false
		local bStart, bPos
		bubble.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				bDrag = true
				bStart = input.Position
				bPos = bubble.Position
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				bDrag = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if bDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - bStart
				bubble.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset + delta.X, bPos.Y.Scale, bPos.Y.Offset + delta.Y)
			end
		end)
		bubble.MouseButton1Click:Connect(function()
			setMinimized(not minimized)
		end)
		window._bubble = bubble
	end

	-- ---------- toasts (top right) ----------
	local toastHolder = Instance.new("Frame")
	toastHolder.Name = "Toasts"
	toastHolder.AnchorPoint = Vector2.new(1, 0)
	toastHolder.Position = UDim2.new(1, -12, 0, 12)
	toastHolder.Size = UDim2.new(0, 250, 0, 0)
	toastHolder.AutomaticSize = Enum.AutomaticSize.Y
	toastHolder.BackgroundTransparency = 1
	toastHolder.Parent = screenGui

	local toastLayout = Instance.new("UIListLayout")
	toastLayout.Padding = UDim.new(0, 6)
	toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
	toastLayout.Parent = toastHolder

	local notifyModule = fetch("notify")
	local Notify = notifyModule({holder = toastHolder, Theme = Theme, Util = Util, accent = accent})
	window.Notify = function(_, cfg)
		Notify.make(cfg or {})
	end


	local mobileModule = fetch("mobile")
	window.MobilePanel = function(_, cfg)
		return mobileModule({
			screenGui = screenGui,
			Theme = Theme,
			Util = Util,
			accent = accent,
		})(cfg or {})
	end

	-- restore saved config shortly after startup, once features exist
	if config.SaveConfigs ~= false then
		task.delay(1, function()
			loadConfig(config.ConfigName or "default")
		end)
	end

	return window
end
