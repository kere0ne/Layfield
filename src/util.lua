--[[
	CypherUI util.lua
	Small shared helpers. Receives the Theme table, returns the Util table.
]]

return function(Theme)
	local TweenService = game:GetService("TweenService")

	local Util = {}

	function Util.tween(obj, props, dur, style)
		local t = TweenService:Create(obj, TweenInfo.new(dur or 0.22, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
		t:Play()
		return t
	end

	function Util.corner(parent, r)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, r or 10)
		c.Parent = parent
		return c
	end

	function Util.stroke(parent, color, thickness, transparency)
		local s = Instance.new("UIStroke")
		s.Color = color or Theme.Stroke
		s.Thickness = thickness or 1
		s.Transparency = transparency or 0.3
		s.Parent = parent
		return s
	end

	function Util.label(parent, props)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.BorderSizePixel = 0
		for k, v in pairs(props) do
			l[k] = v
		end
		l.Parent = parent
		return l
	end

	return Util
end
