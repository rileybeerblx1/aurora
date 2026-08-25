local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local req = (syn and syn.request) or (http and http.request) or http_request or request
local setclipboard = setclipboard or toclipboard or function() end
local isfile = isfile or function() return false end
local readfile = readfile or function() return "" end
local writefile = writefile or function() end
local delfile = delfile or function() end
local targetContainer = (typeof(gethui) == "function" and gethui()) or playerGui

local BaseURL = "https://api.pandauth.com/api/v1"
local Client_ServiceID = "aurora"
local KeyFileName = "aurora_key.txt"

local function getHardwareId()
	local success, hwid = pcall(gethwid)
	if success and hwid then return hwid end
	local clientId = tostring(RbxAnalyticsService:GetClientId())
	return clientId:gsub("-", "")
end

local function makeRequest(endpoint, body)
	if not req then return nil end
	local success, response = pcall(req, {
		Url = BaseURL .. endpoint,
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = HttpService:JSONEncode(body)
	})
	if success and response and response.Body then
		local ok, decoded = pcall(function() return HttpService:JSONDecode(response.Body) end)
		if ok then return decoded end
	end
	return nil
end

local function GetKeyURL()
	return "https://ads.pandauth.com/getkey/" .. Client_ServiceID .. "?hwid=" .. getHardwareId()
end

local function Validate(key, Premium_Verification)
	local result = makeRequest("/keys/validate", {
		ServiceID = Client_ServiceID,
		HWID = getHardwareId(),
		Key = key
	})
	if not result then
		return { success = false, message = "Connection failed" }
	end
	local isAuthenticated = result.Authenticated_Status == "Success"
	local isPremium = result.Key_Premium or false
	local isValid = isAuthenticated
	local message = result.Note or (isAuthenticated and "Key validated!" or "Invalid key")
	if Premium_Verification and isAuthenticated and not isPremium then
		isValid = false
		message = "Premium key required"
	end
	return {
		success = isValid,
		message = message,
		isPremium = isPremium,
		expireDate = result.Expire_Date
	}
end

local Assets = {
	Key = "rbxassetid://96510194465420",
	Proceed = "rbxassetid://93898873302694",
	GetKey = "rbxassetid://131607023382430",
	Clipboard = "rbxassetid://89601995828423",
}

local Theme = {
	Card   = Color3.fromRGB(16, 20, 44),
	Ink    = Color3.fromRGB(238, 242, 255),
	InkDim = Color3.fromRGB(150, 160, 201),
	Teal   = Color3.fromRGB(45, 216, 167),
	Blue   = Color3.fromRGB(79, 168, 255),
	Violet = Color3.fromRGB(124, 92, 255),
	Pink   = Color3.fromRGB(255, 95, 184),
	Gold   = Color3.fromRGB(255, 215, 111),
	Dark   = Color3.fromRGB(8, 14, 22),
}

local AuroraSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0.0, Theme.Teal),
	ColorSequenceKeypoint.new(0.35, Theme.Blue),
	ColorSequenceKeypoint.new(0.7, Theme.Violet),
	ColorSequenceKeypoint.new(1.0, Theme.Pink),
})

local function safeFont(name, fallback)
	local ok, font = pcall(function() return Enum.Font[name] end)
	return ok and font or fallback
end

local DisplayFont = safeFont("Michroma", Enum.Font.GothamBlack)
local BodyFont = Enum.Font.Gotham
local BodyFontMedium = Enum.Font.GothamMedium

local function new(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = inst end
	return inst
end

local function corner(radius)
	return new("UICorner", { CornerRadius = radius or UDim.new(0, 12) })
end

local function gradient(rotation, seq, transparency)
	return new("UIGradient", {
		Color = seq or AuroraSequence,
		Rotation = rotation or 0,
		Transparency = transparency,
	})
end

local function stroke(color, thickness, transparency)
	return new("UIStroke", {
		Color = color or Theme.Blue,
		Thickness = thickness or 1.5,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function buildImageAsset(id, size, color)
	return new("ImageLabel", {
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		Image = id,
		ImageColor3 = color or Theme.Ink,
		ScaleType = Enum.ScaleType.Fit,
	})
end

local function buildXIcon(size, color)
	local holder = new("Frame", { Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1 })
	for _, rot in ipairs({ 45, -45 }) do
		new("Frame", {
			Size = UDim2.fromOffset(size, size * 0.14),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Rotation = rot,
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}, { corner(UDim.new(1, 0)) }).Parent = holder
	end
	return holder
end

local function addPressFeedback(btn)
	local scale = new("UIScale", { Scale = 1 })
	scale.Parent = btn
	btn.MouseButton1Down:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 0.95 }):Play()
	end)
	local function release()
		TweenService:Create(scale, TweenInfo.new(0.12), { Scale = 1 }):Play()
	end
	btn.MouseButton1Up:Connect(release)
	btn.MouseLeave:Connect(release)
end

local function makeDraggable(guiObject)
	guiObject.Active = true
	local dragging = false
	local dragInput, dragStart, startPos

	local function clampToScreen(pos, size)
		local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
		local minX, maxX = size.X / 2, viewport.X - size.X / 2
		local minY, maxY = size.Y / 2, viewport.Y - size.Y / 2
		return UDim2.fromOffset(
			math.clamp(pos.X.Offset, minX, math.max(minX, maxX)),
			math.clamp(pos.Y.Offset, minY, math.max(minY, maxY))
		)
	end

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			local raw = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
			guiObject.Position = clampToScreen(raw, guiObject.AbsoluteSize)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local screenGui = new("ScreenGui", {
	Name = "AuroraKeySystem",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset = false,
	DisplayOrder = 2147483647,
})
screenGui.Parent = targetContainer

local toastHolder = new("Frame", {
	Size = UDim2.new(1, 0, 0, 0),
	Position = UDim2.new(0.5, 0, 0, 16),
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	ZIndex = 30,
})
toastHolder.Parent = screenGui

local function showToast(message)
	local toast = new("TextLabel", {
		Size = UDim2.fromOffset(0, 28),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(0.5, 0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.05,
		Text = "   " .. message .. "   ",
		Font = BodyFontMedium,
		TextSize = 11,
		TextColor3 = Theme.Ink,
		TextTransparency = 1,
		ZIndex = 31,
	}, { corner(UDim.new(0, 8)), stroke(Color3.new(1, 1, 1), 1, 0.85) })
	toast.Parent = toastHolder

	TweenService:Create(toast, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
	task.delay(2, function()
		if toast.Parent then
			local fade = TweenService:Create(toast, TweenInfo.new(0.25), { TextTransparency = 1 })
			fade:Play()
			fade.Completed:Wait()
			toast:Destroy()
		end
	end)
end

local card = new("Frame", {
	Name = "Card",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(0, 320, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundColor3 = Theme.Card,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Active = true,
	ZIndex = 5,
}, { corner(UDim.new(0, 16)) })
card.Parent = screenGui

makeDraggable(card)

local cardStroke = stroke(Color3.new(1, 1, 1), 1.5, 0.1)
cardStroke.Parent = card
local cardStrokeGradient = gradient(0)
cardStrokeGradient.Parent = cardStroke

RunService.Heartbeat:Connect(function(dt)
	if card.Parent then
		cardStrokeGradient.Rotation = (cardStrokeGradient.Rotation + dt * 35) % 360
	end
end)

local cardLayout = new("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 10),
})
cardLayout.Parent = card

new("UIPadding", { PaddingBottom = UDim.new(0, 14) }).Parent = card

local header = new("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, 44),
	BackgroundTransparency = 1,
	LayoutOrder = 1,
	ZIndex = 6,
})
header.Parent = card

new("Frame", {
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 1, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.9,
	BorderSizePixel = 0,
	ZIndex = 6,
}).Parent = header

local titleIcon = buildImageAsset(Assets.Key, 16, Theme.Gold)
titleIcon.Position = UDim2.new(0, 14, 0.5, -8)
titleIcon.Parent = header

local title = new("TextLabel", {
	Size = UDim2.new(1, -60, 1, 0),
	Position = UDim2.new(0, 36, 0, 0),
	BackgroundTransparency = 1,
	Text = "KEY SYSTEM",
	Font = DisplayFont,
	TextSize = 12,
	TextColor3 = Theme.Ink,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 6,
})
title.Parent = header
gradient(0, AuroraSequence).Parent = title

local closeBtn = new("TextButton", {
	Size = UDim2.fromOffset(26, 26),
	Position = UDim2.new(1, -10, 0.5, 0),
	AnchorPoint = Vector2.new(1, 0.5),
	BackgroundColor3 = Theme.Pink,
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
	ZIndex = 6,
}, { corner(UDim.new(0, 8)) })
closeBtn.Parent = header

local closeIcon = buildXIcon(11, Theme.InkDim)
closeIcon.Position = UDim2.fromScale(0.5, 0.5)
closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
closeIcon.Parent = closeBtn

closeBtn.MouseEnter:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.85 }):Play()
end)
closeBtn.MouseLeave:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
end)
addPressFeedback(closeBtn)

local heroBadge = new("Frame", {
	Size = UDim2.fromOffset(48, 48),
	BackgroundColor3 = Theme.Violet,
	BackgroundTransparency = 0.75,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 6,
}, { corner(UDim.new(0, 14)), stroke(Color3.new(1, 1, 1), 1, 0.85) })
heroBadge.Parent = card

local heroIcon = buildImageAsset(Assets.Key, 24, Theme.Gold)
heroIcon.Position = UDim2.fromScale(0.5, 0.5)
heroIcon.AnchorPoint = Vector2.new(0.5, 0.5)
heroIcon.Parent = heroBadge

local subtitle = new("TextLabel", {
	Size = UDim2.new(1, -32, 0, 28),
	BackgroundTransparency = 1,
	Text = "Get a key below, then paste it here to continue.",
	Font = BodyFont,
	TextSize = 11,
	TextColor3 = Theme.InkDim,
	TextWrapped = true,
	LayoutOrder = 3,
	ZIndex = 6,
})
subtitle.Parent = card

local inputRow = new("Frame", {
	Size = UDim2.new(1, -32, 0, 38),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.95,
	BorderSizePixel = 0,
	LayoutOrder = 4,
	ZIndex = 6,
}, { corner(UDim.new(0, 10)), stroke(Color3.new(1, 1, 1), 1, 0.85) })
inputRow.Parent = card

local keyInput = new("TextBox", {
	Name = "KeyInput",
	Size = UDim2.new(1, -44, 1, 0),
	Position = UDim2.new(0, 10, 0, 0),
	BackgroundTransparency = 1,
	Text = "",
	PlaceholderText = "Paste your key here",
	PlaceholderColor3 = Theme.InkDim,
	Font = BodyFont,
	TextSize = 12,
	TextColor3 = Theme.Ink,
	TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false,
	ZIndex = 7,
})
keyInput.Parent = inputRow

local pasteBtn = new("TextButton", {
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.new(1, -5, 0.5, 0),
	AnchorPoint = Vector2.new(1, 0.5),
	BackgroundColor3 = Theme.Teal,
	BackgroundTransparency = 0.85,
	Text = "",
	AutoButtonColor = false,
	ZIndex = 7,
}, { corner(UDim.new(0, 7)) })
pasteBtn.Parent = inputRow

local pasteIcon = buildImageAsset(Assets.Clipboard, 16, Theme.Teal)
pasteIcon.Position = UDim2.fromScale(0.5, 0.5)
pasteIcon.AnchorPoint = Vector2.new(0.5, 0.5)
pasteIcon.Parent = pasteBtn
addPressFeedback(pasteBtn)

local function makeIconButton(props)
	local btn = new("TextButton", {
		Size = props.size,
		BackgroundColor3 = props.bgColor,
		BackgroundTransparency = props.bgTransparency or 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = props.order,
		ZIndex = 6,
	}, { corner(UDim.new(0, 10)) })
	btn.Parent = card

	if props.gradientSeq then
		gradient(100, props.gradientSeq).Parent = btn
	end
	if props.outline then
		stroke(Color3.new(1, 1, 1), 1, 0.85).Parent = btn
	end

	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
	}).Parent = btn

	local icon = buildImageAsset(props.assetId, 16, props.textColor)
	icon.LayoutOrder = 1
	icon.Parent = btn

	new("TextLabel", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text = props.text,
		Font = DisplayFont,
		TextSize = 11,
		TextColor3 = props.textColor,
		LayoutOrder = 2,
	}).Parent = btn

	addPressFeedback(btn)
	return btn
end

local getKeyBtn = makeIconButton({
	size = UDim2.new(1, -32, 0, 38),
	order = 5,
	bgColor = Theme.Blue,
	gradientSeq = ColorSequence.new(Theme.Teal, Theme.Violet),
	text = "GET KEY",
	textColor = Theme.Dark,
	assetId = Assets.GetKey,
})

local proceedBtn = makeIconButton({
	size = UDim2.new(1, -32, 0, 38),
	order = 6,
	bgColor = Color3.new(1, 1, 1),
	bgTransparency = 0.95,
	outline = true,
	text = "PROCEED",
	textColor = Theme.Ink,
	assetId = Assets.Proceed,
})
proceedBtn.Active = false

local footer = new("TextLabel", {
	Size = UDim2.new(1, -32, 0, 16),
	BackgroundTransparency = 1,
	Text = "Complete the key system to gain access to aurora!",
	Font = BodyFont,
	TextSize = 10,
	TextColor3 = Theme.InkDim,
	TextTransparency = 0.4,
	LayoutOrder = 7,
	ZIndex = 6,
})
footer.Parent = card

local reopenBtn = new("TextButton", {
	Size = UDim2.fromOffset(130, 36),
	Position = UDim2.new(0.5, 0, 0, 20),
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundColor3 = Theme.Card,
	BackgroundTransparency = 0.1,
	Text = "",
	Visible = false,
	AutoButtonColor = false,
	Active = true,
	ZIndex = 20,
}, { corner(UDim.new(1, 0)), stroke(Color3.new(1, 1, 1), 1, 0.85) })
reopenBtn.Parent = screenGui

makeDraggable(reopenBtn)

new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 6),
}).Parent = reopenBtn

local reopenIcon = buildImageAsset(Assets.Key, 14, Theme.Gold)
reopenIcon.LayoutOrder = 1
reopenIcon.Parent = reopenBtn

new("TextLabel", {
	Size = UDim2.new(0, 0, 1, 0),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundTransparency = 1,
	Text = "AURORA",
	Font = DisplayFont,
	TextSize = 10,
	TextColor3 = Theme.Ink,
	LayoutOrder = 2,
}).Parent = reopenBtn

addPressFeedback(reopenBtn)

closeBtn.MouseButton1Click:Connect(function()
	card.Visible = false
	reopenBtn.Visible = true
end)

reopenBtn.MouseButton1Click:Connect(function()
	card.Visible = true
	reopenBtn.Visible = false
end)

local function applyResponsiveSize()
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local width = math.clamp(viewport.X * 0.85, 280, 330)
	card.Size = UDim2.new(0, width, 0, 0)
end
applyResponsiveSize()
if camera then
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveSize)
end

local function updateProceedState()
	local hasText = keyInput.Text:gsub("%s+", "") ~= ""
	proceedBtn.Active = hasText
	proceedBtn.BackgroundTransparency = hasText and 0.85 or 0.95
end
keyInput:GetPropertyChangedSignal("Text"):Connect(updateProceedState)
updateProceedState()

local function onScriptPass()
	showToast("Access Granted!")
	task.wait(1)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/rileybeerblx1/aurora/refs/heads/main/uimobile.lua"))()
	screenGui:Destroy()
end

task.spawn(function()
	if isfile(KeyFileName) then
		local savedKey = readfile(KeyFileName):gsub("%s+", "")
		if #savedKey > 0 then
			showToast("Verifying saved key...")
			local res = Validate(savedKey)
			if res.success then
				onScriptPass()
				return
			else
				delfile(KeyFileName)
				showToast("Saved key expired/invalid")
			end
		end
	end
end)

pasteBtn.MouseButton1Click:Connect(function()
	keyInput:CaptureFocus()
	showToast("what")
end)

getKeyBtn.MouseButton1Click:Connect(function()
	local url = GetKeyURL()
	setclipboard(url)
	showToast("Key link copied to clipboard!")
end)

proceedBtn.MouseButton1Click:Connect(function()
	if not proceedBtn.Active then return end
	local inputKey = keyInput.Text:gsub("%s+", "")
	showToast("Validating key...")
	
	task.spawn(function()
		local res = Validate(inputKey)
		if res.success then
			writefile(KeyFileName, inputKey)
			showToast("Key valid! Saved.")
			onScriptPass()
		else
			showToast(res.message or "Invalid Key")
		end
	end)
end)
