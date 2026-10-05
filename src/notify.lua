--[[
	Example notify.lua
	Compact toast notifications, top right, with countdown bar.
	deps: { holder, Theme, Util, accent }
]]

return function(deps)
	local Theme, Util, holder, accent = deps.Theme, deps.Util, deps.holder, deps.accent

	local Notify = {}

	function Notify.make(cfg)
		local dur = cfg.Duration or 4

		local toast = Instance.new("CanvasGroup")
		toast.Size = UDim2.new(1, 0, 0, 56)
		toast.BackgroundColor3 = Theme.Header
		toast.BorderSizePixel = 0
		toast.GroupTransparency = 1
		Util.corner(toast, 10)
		Util.stroke(toast, Theme.Stroke, 1, 0.4)
		toast.Parent = holder

		local tBadge = Instance.new("Frame")
		tBadge.Size = UDim2.fromOffset(28, 28)
		tBadge.Position = UDim2.fromOffset(11, 11)
		tBadge.BackgroundColor3 = accent
		tBadge.BorderSizePixel = 0
		tBadge.Parent = toast
		Util.corner(tBadge, 8)
		Util.label(tBadge, {
			Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 12,
			TextColor3 = Color3.fromRGB(255, 255, 255), Text = cfg.Icon or "-",
		})

		Util.label(toast, {
			Position = UDim2.fromOffset(48, 9), Size = UDim2.new(1, -58, 0, 15),
			Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.Title or "Notification",
		})
		Util.label(toast, {
			Position = UDim2.fromOffset(48, 27), Size = UDim2.new(1, -58, 0, 14),
			Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			Text = cfg.Text or "",
		})

		local bar = Instance.new("Frame")
		bar.AnchorPoint = Vector2.new(0, 1)
		bar.Position = UDim2.new(0, 0, 1, 0)
		bar.Size = UDim2.new(1, 0, 0, 2)
		bar.BackgroundColor3 = accent
		bar.BorderSizePixel = 0
		bar.Parent = toast
		Util.corner(bar, 2)
		Util.tween(bar, {Size = UDim2.new(0, 0, 0, 2)}, dur, Enum.EasingStyle.Linear)

		Util.tween(toast, {GroupTransparency = 0}, 0.2)
		task.delay(dur, function()
			local t = Util.tween(toast, {GroupTransparency = 1}, 0.2)
			t.Completed:Wait()
			toast:Destroy()
		end)
	end

	return Notify
end
