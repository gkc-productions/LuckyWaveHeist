local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Content = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ContentPack"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local roundEvt = Remotes.RoundUpdate
local currencyEvt = Remotes.CurrencyUpdate
local toastEvt = Remotes.Toast
local tutorialEvt = Remotes.Tutorial
local purchaseEvt = Remotes.PurchaseUpgrade
local fxEvt = Remotes.LuckyBlockFX

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local duplicateFound = false
for _, child in ipairs(guiParent:GetChildren()) do
	if child:IsA("ScreenGui") and (child.Name == "RoundHUD" or child.Name == "MainHUD" or child.Name == "HUD") then
		child:Destroy()
		duplicateFound = true
	end
end
if duplicateFound then
	print("[HUD] duplicate prevented")
end

local gui = Instance.new("ScreenGui")
gui.Name = "HUD"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = guiParent

local safeArea = Instance.new("Frame")
safeArea.Name = "SafeArea"
safeArea.AnchorPoint = Vector2.new(0, 0)
safeArea.Position = UDim2.new(0, 12, 0, 12)
safeArea.Size = UDim2.new(1, -24, 1, -24)
safeArea.BackgroundTransparency = 1
safeArea.Parent = gui

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 48)
padding.PaddingLeft = UDim.new(0, 0)
padding.PaddingRight = UDim.new(0, 0)
padding.PaddingBottom = UDim.new(0, 0)
padding.Parent = safeArea

local theme = {
	Navy = Color3.fromRGB(11, 16, 32),
	Teal = Color3.fromRGB(25, 211, 197),
	Yellow = Color3.fromRGB(255, 213, 74),
	Steel = Color3.fromRGB(43, 47, 58),
	Red = Color3.fromRGB(255, 59, 59),
	White = Color3.fromRGB(245, 248, 255),
	Soft = Color3.fromRGB(170, 190, 210),
}

local font = Enum.Font.Gotham

local coinsCard = Instance.new("Frame")
coinsCard.Name = "CoinsCard"
coinsCard.Size = UDim2.new(0, 240, 0, 60)
coinsCard.Position = UDim2.new(0, 0, 0, 0)
coinsCard.BackgroundColor3 = theme.Navy
coinsCard.BackgroundTransparency = 0.25
coinsCard.Parent = safeArea

local coinsCorner = Instance.new("UICorner")
coinsCorner.CornerRadius = UDim.new(0, 12)
coinsCorner.Parent = coinsCard

local coinsStroke = Instance.new("UIStroke")
coinsStroke.Color = theme.Teal
coinsStroke.Thickness = 1.2
coinsStroke.Transparency = 0.65
coinsStroke.Parent = coinsCard

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Size = UDim2.new(0.45, 0, 1, 0)
coinsLabel.Position = UDim2.new(0, 14, 0, 0)
coinsLabel.BackgroundTransparency = 1
coinsLabel.Text = "COINS"
coinsLabel.TextColor3 = theme.Soft
coinsLabel.Font = Enum.Font.GothamMedium
coinsLabel.TextSize = 14
coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
coinsLabel.Parent = coinsCard

local coinsValue = Instance.new("TextLabel")
coinsValue.Size = UDim2.new(0.55, -14, 1, 0)
coinsValue.Position = UDim2.new(0.45, 0, 0, 0)
coinsValue.BackgroundTransparency = 1
coinsValue.Text = "0"
coinsValue.TextColor3 = theme.Yellow
coinsValue.Font = Enum.Font.GothamBold
coinsValue.TextSize = 24
coinsValue.TextXAlignment = Enum.TextXAlignment.Right
coinsValue.Parent = coinsCard

local roundBanner = Instance.new("Frame")
roundBanner.Name = "RoundBanner"
roundBanner.AnchorPoint = Vector2.new(0.5, 0)
roundBanner.Position = UDim2.new(0.5, 0, 0, 0)
roundBanner.Size = UDim2.new(0, 520, 0, 72)
roundBanner.BackgroundColor3 = theme.Navy
roundBanner.BackgroundTransparency = 0.25
roundBanner.Parent = safeArea

local roundCorner = Instance.new("UICorner")
roundCorner.CornerRadius = UDim.new(0, 12)
roundCorner.Parent = roundBanner

local roundStroke = Instance.new("UIStroke")
roundStroke.Color = theme.Teal
roundStroke.Thickness = 1.2
roundStroke.Transparency = 0.65
roundStroke.Parent = roundBanner

local roundWave = Instance.new("TextLabel")
roundWave.Size = UDim2.new(1, -24, 0, 24)
roundWave.Position = UDim2.new(0, 12, 0, 6)
roundWave.BackgroundTransparency = 1
roundWave.Text = "WAVE 1/3"
roundWave.TextColor3 = theme.Yellow
roundWave.Font = Enum.Font.GothamBold
roundWave.TextSize = 20
roundWave.TextXAlignment = Enum.TextXAlignment.Left
roundWave.Parent = roundBanner

local roundStatus = Instance.new("TextLabel")
roundStatus.Size = UDim2.new(1, -24, 0, 20)
roundStatus.Position = UDim2.new(0, 12, 0, 30)
roundStatus.BackgroundTransparency = 1
roundStatus.Text = "Waiting for players..."
roundStatus.TextColor3 = theme.White
roundStatus.Font = Enum.Font.GothamMedium
roundStatus.TextSize = 16
roundStatus.TextXAlignment = Enum.TextXAlignment.Left
roundStatus.Parent = roundBanner

local roundMeta = Instance.new("TextLabel")
roundMeta.Size = UDim2.new(1, -24, 0, 18)
roundMeta.Position = UDim2.new(0, 12, 0, 50)
roundMeta.BackgroundTransparency = 1
roundMeta.Text = "0:00 | Alive: 0"
roundMeta.TextColor3 = theme.Soft
roundMeta.Font = Enum.Font.GothamMedium
roundMeta.TextSize = 14
roundMeta.TextXAlignment = Enum.TextXAlignment.Left
roundMeta.Parent = roundBanner

local shopButton = Instance.new("TextButton")
shopButton.Name = "ShopButton"
shopButton.Size = UDim2.new(0, 120, 0, 44)
shopButton.Position = UDim2.new(0, 0, 1, -120)
shopButton.BackgroundColor3 = theme.Teal
shopButton.BackgroundTransparency = 0.1
shopButton.Text = "Shop"
shopButton.TextColor3 = theme.Navy
shopButton.Font = Enum.Font.GothamBold
shopButton.TextSize = 16
shopButton.Parent = safeArea

local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 12)
shopCorner.Parent = shopButton

local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopPanel"
shopFrame.Size = UDim2.new(0, 320, 0, 280)
shopFrame.Position = UDim2.new(0, 0, 1, -420)
shopFrame.BackgroundColor3 = theme.Steel
shopFrame.BackgroundTransparency = 0.2
shopFrame.Visible = false
shopFrame.Parent = safeArea

local shopFrameCorner = Instance.new("UICorner")
shopFrameCorner.CornerRadius = UDim.new(0, 12)
shopFrameCorner.Parent = shopFrame

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, 0, 0, 30)
shopTitle.BackgroundTransparency = 1
shopTitle.Text = "Upgrades"
shopTitle.TextColor3 = theme.White
shopTitle.Font = Enum.Font.GothamBold
shopTitle.TextSize = 18
shopTitle.Parent = shopFrame

local function makeButton(y)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 32)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.BackgroundColor3 = theme.Navy
	btn.BackgroundTransparency = 0.15
	btn.TextColor3 = theme.White
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 14
	btn.Parent = shopFrame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = btn
	return btn
end

local buttons = {
	LootMagnet = makeButton(40),
	WalletExpansion = makeButton(76),
	WalkSpeed = makeButton(112),
	JumpPower = makeButton(148),
	BreakSpeed = makeButton(184),
	DailyReroll = makeButton(220),
}

local waterBar = Instance.new("Frame")
waterBar.Name = "WaterProgress"
waterBar.AnchorPoint = Vector2.new(0.5, 1)
waterBar.Position = UDim2.new(0.5, 0, 1, -28)
waterBar.Size = UDim2.new(0, 520, 0, 18)
waterBar.BackgroundColor3 = theme.Steel
waterBar.BackgroundTransparency = 0.2
waterBar.Parent = safeArea

local waterCorner = Instance.new("UICorner")
waterCorner.CornerRadius = UDim.new(0, 9)
waterCorner.Parent = waterBar

local waterStroke = Instance.new("UIStroke")
waterStroke.Color = theme.Teal
waterStroke.Thickness = 1
waterStroke.Transparency = 0.65
waterStroke.Parent = waterBar

local waterFill = Instance.new("Frame")
waterFill.Size = UDim2.new(0, 0, 1, 0)
waterFill.BackgroundColor3 = theme.Teal
waterFill.BackgroundTransparency = 0.05
waterFill.Parent = waterBar

local waterFillCorner = Instance.new("UICorner")
waterFillCorner.CornerRadius = UDim.new(0, 9)
waterFillCorner.Parent = waterFill

local toastContainer = Instance.new("Frame")
toastContainer.Name = "ToastContainer"
toastContainer.Size = UDim2.new(0, 280, 0, 240)
toastContainer.Position = UDim2.new(1, -280, 0, 0)
toastContainer.BackgroundTransparency = 1
toastContainer.Parent = safeArea

local tutorialFrame = Instance.new("TextLabel")
tutorialFrame.Name = "Tutorial"
tutorialFrame.Size = UDim2.new(0.8, 0, 0, 40)
tutorialFrame.Position = UDim2.new(0.1, 0, 0.82, 0)
tutorialFrame.BackgroundColor3 = theme.Navy
tutorialFrame.TextColor3 = theme.White
tutorialFrame.Font = Enum.Font.GothamMedium
tutorialFrame.TextSize = 16
tutorialFrame.BackgroundTransparency = 0.1
tutorialFrame.Visible = false
tutorialFrame.Parent = safeArea

local tutorialCorner = Instance.new("UICorner")
tutorialCorner.CornerRadius = UDim.new(0, 10)
tutorialCorner.Parent = tutorialFrame

local warningFlash = Instance.new("Frame")
warningFlash.Name = "WarningFlash"
warningFlash.Size = UDim2.new(1, 0, 1, 0)
warningFlash.BackgroundColor3 = theme.Red
warningFlash.BackgroundTransparency = 1
warningFlash.ZIndex = 5
warningFlash.Parent = gui

print("[HUD] initialized")

local currentCoins = 0
local upgradeLevels = {}
local inIntermission = true
local firstRoundUpdate = true
local tutorialSeen = false

local function fmt(t)
	local m = math.floor(t / 60)
	local s = t % 60
	return string.format("%d:%02d", m, s)
end

local function refreshShop()
	local shop = Content.Shop
	for key, btn in pairs(buttons) do
		local def = shop[key]
		if def then
			local level = upgradeLevels[key] or 0
			local cost = def.costs[level + 1]
			if cost then
				btn.Text = string.format("%s L%d (Cost %d)", key, level, cost)
				btn.AutoButtonColor = currentCoins >= cost
			else
				btn.Text = string.format("%s L%d (MAX)", key, level)
				btn.AutoButtonColor = false
			end
		end
	end
end

local function toastColor(rarity)
	if rarity == "Rare" then
		return theme.Teal
	elseif rarity == "Epic" then
		return Color3.fromRGB(180, 110, 255)
	elseif rarity == "Legendary" then
		return theme.Yellow
	end
	return theme.White
end

local toasts = {}

local function layoutToasts()
	for i, toast in ipairs(toasts) do
		local target = UDim2.new(0, 0, 0, (i - 1) * 60)
		TweenService:Create(toast, TweenInfo.new(0.2), {Position = target}):Play()
	end
end

local function pushToast(message, rarity)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 56)
	card.Position = UDim2.new(0, 24, 0, 0)
	card.BackgroundColor3 = theme.Navy
	card.BackgroundTransparency = 0.2
	card.Parent = toastContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = toastColor(rarity)
	stroke.Thickness = 1.2
	stroke.Transparency = 0.6
	stroke.Parent = card

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = message
	label.TextColor3 = toastColor(rarity)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = card

	table.insert(toasts, 1, card)
	layoutToasts()

	TweenService:Create(card, TweenInfo.new(0.25), {Position = UDim2.new(0, 0, 0, 0)}):Play()

	task.delay(3, function()
		TweenService:Create(card, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
		TweenService:Create(label, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.25), {Transparency = 1}):Play()
		task.delay(0.3, function()
			for i, item in ipairs(toasts) do
				if item == card then
					table.remove(toasts, i)
					break
				end
			end
			card:Destroy()
			layoutToasts()
		end)
	end)
end

local function playTutorial()
	local steps = Content.Tutorial
	for i, text in ipairs(steps) do
		tutorialFrame.Text = text
		tutorialFrame.Visible = true
		task.wait(2)
	end
	tutorialFrame.Visible = false
end

local function waveCopy(wave)
	if wave == 1 then
		return Content.RoundText.Wave1
	elseif wave == 2 then
		return Content.RoundText.Wave2
	elseif wave == 3 then
		return Content.RoundText.Wave3
	end
	return "Wave in progress"
end

roundEvt.OnClientEvent:Connect(function(p)
	if firstRoundUpdate then
		print("[HUD] first RoundUpdate")
		firstRoundUpdate = false
	end
	local state = p.state or "?"
	local timeLeft = p.timeLeft or 0
	local alive = p.alive or 0
	local wave = p.wave or 1
	local total = p.totalWaves or 3
	inIntermission = (state == "Intermission")
	shopButton.Visible = inIntermission
	if not inIntermission then
		shopFrame.Visible = false
	end

	if state == "Warning" then
		warningFlash.BackgroundTransparency = 0.7
		TweenService:Create(warningFlash, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
	end

	local header = state
	if state == "Intermission" then
		header = Content.RoundText.Waiting
	elseif state == "Warning" then
		header = Content.RoundText.Warning
	elseif state == "Wave" then
		header = waveCopy(wave)
	end

	roundWave.Text = string.format("WAVE %d/%d", wave, total)
	roundStatus.Text = header
	roundMeta.Text = string.format("%s | Alive: %d", fmt(timeLeft), alive)

	local durations = Content.Presets.Casual.WaveDurations
	local waveDuration = durations[wave] or 1
	local progress = 0
	if state == "Wave" then
		progress = math.clamp(1 - (timeLeft / waveDuration), 0, 1)
	end
	TweenService:Create(waterFill, TweenInfo.new(0.2), {Size = UDim2.new(progress, 0, 1, 0)}):Play()
end)

currencyEvt.OnClientEvent:Connect(function(payload)
	currentCoins = payload.coins or 0
	upgradeLevels = payload.upgrades or upgradeLevels
	coinsValue.Text = tostring(currentCoins)
	refreshShop()
end)

toastEvt.OnClientEvent:Connect(function(data)
	local msg = data and data.message or ""
	if msg == "" then return end
	pushToast(msg, data and data.rarity or "Common")
end)

tutorialEvt.OnClientEvent:Connect(function(data)
	if data and data.type == "warning" then
		warningFlash.BackgroundTransparency = 0.7
		TweenService:Create(warningFlash, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
	end
end)

fxEvt.OnClientEvent:Connect(function(data)
	local pos = data and data.position
	if not pos then return end
	local burstPart = Instance.new("Part")
	burstPart.Size = Vector3.new(1, 1, 1)
	burstPart.Anchored = true
	burstPart.CanCollide = false
	burstPart.Transparency = 1
	burstPart.Position = pos
	burstPart.Parent = workspace

	local emitter = Instance.new("ParticleEmitter")
	emitter.Rate = 0
	emitter.Speed = NumberRange.new(6, 10)
	emitter.Lifetime = NumberRange.new(0.6, 1)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-180, 180)
	emitter.Parent = burstPart
	emitter:Emit(25)

	Debris:AddItem(burstPart, 1)
end)

shopButton.MouseButton1Click:Connect(function()
	shopFrame.Visible = not shopFrame.Visible
end)

for key, btn in pairs(buttons) do
	btn.MouseButton1Click:Connect(function()
		purchaseEvt:FireServer({kind = key})
	end)
end

task.delay(1, function()
	if not tutorialSeen then
		tutorialSeen = true
		playTutorial()
	end
end)
