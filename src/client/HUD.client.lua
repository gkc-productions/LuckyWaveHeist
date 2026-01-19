-- HUD.client.lua
-- Displays coins, round state, shop, toasts, and handles UI interactions

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Content = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ContentPack")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local toastQueue = {}
local toastActive = false
local guiBuilt = false

-- ============================================================================
-- BUILD HUD
-- ============================================================================

local function buildHUD()
	if guiBuilt then return end
	guiBuilt = true
	
	-- Main ScreenGui
	local mainGui = Instance.new("ScreenGui")
	mainGui.Name = "MainHUD"
	mainGui.ResetOnSpawn = false
	mainGui.Parent = playerGui
	
	-- TOP-LEFT: COINS CARD
	local coinsCard = Instance.new("Frame")
	coinsCard.Name = "CoinsCard"
	coinsCard.Size = UDim2.new(0, 150, 0, 60)
	coinsCard.Position = UDim2.new(0, 15, 0, 15)
	coinsCard.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	coinsCard.BorderSizePixel = 0
	coinsCard.Parent = mainGui
	
	-- Coins corner radius (aesthetic)
	local cornerRadius = Instance.new("UICorner")
	cornerRadius.CornerRadius = UDim.new(0, 8)
	cornerRadius.Parent = coinsCard
	
	local coinsLabel = Instance.new("TextLabel")
	coinsLabel.Name = "CoinsLabel"
	coinsLabel.Size = UDim2.new(1, 0, 1, 0)
	coinsLabel.BackgroundTransparency = 1
	coinsLabel.TextColor3 = Color3.fromRGB(255, 220, 60)
	coinsLabel.TextSize = 20
	coinsLabel.Font = Enum.Font.GothamBold
	coinsLabel.Text = "💰 0"
	coinsLabel.Parent = coinsCard
	
	-- TOP-CENTER: ROUND STATE
	local roundBanner = Instance.new("TextLabel")
	roundBanner.Name = "RoundBanner"
	roundBanner.Size = UDim2.new(0, 400, 0, 100)
	roundBanner.Position = UDim2.new(0.5, -200, 0, 20)
	roundBanner.BackgroundTransparency = 0.1
	roundBanner.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	roundBanner.TextColor3 = Color3.fromRGB(255, 255, 255)
	roundBanner.TextSize = 16
	roundBanner.Font = Enum.Font.Gotham
	roundBanner.Text = "Waiting for players..."
	roundBanner.Parent = mainGui
	
	-- TOP-RIGHT: SHOP BUTTON
	local shopBtn = Instance.new("TextButton")
	shopBtn.Name = "ShopButton"
	shopBtn.Size = UDim2.new(0, 100, 0, 40)
	shopBtn.Position = UDim2.new(1, -125, 0, 20)
	shopBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
	shopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	shopBtn.TextSize = 14
	shopBtn.Font = Enum.Font.GothamBold
	shopBtn.Text = "🛍️ Shop"
	shopBtn.BorderSizePixel = 0
	shopBtn.Parent = mainGui
	
	local shopCorner = Instance.new("UICorner")
	shopCorner.CornerRadius = UDim.new(0, 6)
	shopCorner.Parent = shopBtn
	
	-- TOAST CONTAINER (top-right stacked)
	local toastContainer = Instance.new("Frame")
	toastContainer.Name = "ToastContainer"
	toastContainer.Size = UDim2.new(0, 200, 1, 0)
	toastContainer.Position = UDim2.new(1, -220, 0, 0)
	toastContainer.BackgroundTransparency = 1
	toastContainer.Parent = mainGui
	
	-- SHOP PANEL (initially hidden)
	local shopPanel = Instance.new("Frame")
	shopPanel.Name = "ShopPanel"
	shopPanel.Size = UDim2.new(0, 400, 0, 500)
	shopPanel.Position = UDim2.new(0.5, -200, 0.5, -250)
	shopPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	shopPanel.BorderSizePixel = 0
	shopPanel.Visible = false
	shopPanel.Parent = mainGui
	
	local shopCornerBig = Instance.new("UICorner")
	shopCornerBig.CornerRadius = UDim.new(0, 10)
	shopCornerBig.Parent = shopPanel
	
	local shopTitle = Instance.new("TextLabel")
	shopTitle.Name = "Title"
	shopTitle.Size = UDim2.new(1, 0, 0, 40)
	shopTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	shopTitle.TextColor3 = Color3.fromRGB(255, 220, 60)
	shopTitle.TextSize = 18
	shopTitle.Font = Enum.Font.GothamBold
	shopTitle.Text = "🛍️ Shop"
	shopTitle.BorderSizePixel = 0
	shopTitle.Parent = shopPanel
	
	local shopScroll = Instance.new("ScrollingFrame")
	shopScroll.Name = "Scroll"
	shopScroll.Size = UDim2.new(1, 0, 1, -50)
	shopScroll.Position = UDim2.new(0, 0, 0, 40)
	shopScroll.BackgroundTransparency = 1
	shopScroll.ScrollBarThickness = 8
	shopScroll.Parent = shopPanel
	
	local shopLayout = Instance.new("UIListLayout")
	shopLayout.Padding = UDim.new(0, 10)
	shopLayout.Parent = shopScroll
	
	-- Store references
	mainGui:SetAttribute("coinsLabel", coinsLabel)
	mainGui:SetAttribute("roundBanner", roundBanner)
	mainGui:SetAttribute("toastContainer", toastContainer)
	mainGui:SetAttribute("shopPanel", shopPanel)
	mainGui:SetAttribute("shopScroll", shopScroll)
	mainGui:SetAttribute("shopBtn", shopBtn)
	
	return mainGui
end

-- ============================================================================
-- TOAST SYSTEM
-- ============================================================================

local function showToast(title, subtitle, rarity)
	local mainGui = playerGui:FindFirstChild("MainHUD")
	if not mainGui then return end
	local toastContainer = mainGui:FindFirstChild("ToastContainer")
	if not toastContainer then return end
	
	local toastFrame = Instance.new("Frame")
	toastFrame.Name = "Toast"
	toastFrame.Size = UDim2.new(1, -10, 0, 60)
	toastFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	toastFrame.BorderSizePixel = 0
	
	-- Rarity-based coloring
	local toastDef = Content and Content.Toast and Content.Toast[rarity] or nil
	if toastDef then
		toastFrame.BackgroundColor3 = toastDef.bgColor
	end
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = toastFrame
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 1, 0)
	label.Position = UDim2.new(0, 5, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = toastDef and toastDef.textColor or Color3.fromRGB(255, 255, 255)
	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.Text = title
	label.TextWrapped = true
	label.Parent = toastFrame
	
	toastFrame.LayoutOrder = #toastContainer:GetChildren()
	toastFrame.Parent = toastContainer
	
	-- Tween in
	local tweenService = game:GetService("TweenService")
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = tweenService:Create(toastFrame, tweenInfo, {Position = UDim2.new(0, 0, 0, 0)})
	tween:Play()
	
	-- Auto-dismiss after 3s
	task.delay(3, function()
		if toastFrame and toastFrame.Parent then
			local tweenOut = tweenService:Create(toastFrame, TweenInfo.new(0.3), {
				BackgroundTransparency = 1,
			})
			tweenOut:Play()
			tweenOut.Completed:Connect(function()
				toastFrame:Destroy()
			end)
		end
	end)
end

-- ============================================================================
-- UPDATE FUNCTIONS
-- ============================================================================

local function updateCoinLabel(coins)
	local mainGui = playerGui:FindFirstChild("MainHUD")
	if mainGui then
		local coinsLabel = mainGui:FindFirstChild("CoinsCard"):FindFirstChild("CoinsLabel")
		if coinsLabel then
			coinsLabel.Text = ("💰 %d"):format(coins or 0)
		end
	end
end

local function updateRoundBanner(state, timeLeft, alive)
	local mainGui = playerGui:FindFirstChild("MainHUD")
	if not mainGui then return end
	local banner = mainGui:FindFirstChild("RoundBanner")
	if not banner then return end
	
	local text = "..."
	if state == "Intermission" then
		text = ("Intermission | Round starting in %d..."):format(timeLeft)
	elseif state == "Active" then
		text = ("Wave Active | %d:%02d | Alive: %d"):format(
			math.floor(timeLeft / 60),
			timeLeft % 60,
			alive
		)
	else
		text = state or "..."
	end
	banner.Text = text
end

-- ============================================================================
-- REMOTES
-- ============================================================================

local CurrencyUpdate = Remotes:WaitForChild("CurrencyUpdate")
local Toast = Remotes:WaitForChild("Toast")
local RoundUpdate = Remotes:WaitForChild("RoundUpdate")

CurrencyUpdate.OnClientEvent:Connect(function(data)
	updateCoinLabel(data.coins)
end)

Toast.OnClientEvent:Connect(function(data)
	local item = data.message or "Item obtained"
	local rarity = data.rarity or "Common"
	showToast(item, "", rarity)
end)

RoundUpdate.OnClientEvent:Connect(function(data)
	updateRoundBanner(data.state, data.timeLeft, data.alive)
end)

-- ============================================================================
-- SHOP UI
-- ============================================================================

local function buildShopItems()
	local mainGui = playerGui:FindFirstChild("MainHUD")
	if not mainGui then return end
	local shopScroll = mainGui:FindFirstChild("ShopPanel"):FindFirstChild("Scroll")
	if not shopScroll then return end
	
	for name, def in pairs(Content.Shop) do
		local itemFrame = Instance.new("Frame")
		itemFrame.Name = name
		itemFrame.Size = UDim2.new(1, -20, 0, 80)
		itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		itemFrame.BorderSizePixel = 0
		itemFrame.Parent = shopScroll
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = itemFrame
		
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0, 150, 0, 30)
		nameLabel.Position = UDim2.new(0, 10, 0, 5)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.fromRGB(255, 220, 60)
		nameLabel.TextSize = 14
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.Text = def.name
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = itemFrame
		
		local levelLabel = Instance.new("TextLabel")
		levelLabel.Size = UDim2.new(0, 100, 0, 20)
		levelLabel.Position = UDim2.new(0, 10, 0, 35)
		levelLabel.BackgroundTransparency = 1
		levelLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		levelLabel.TextSize = 12
		levelLabel.Font = Enum.Font.Gotham
		levelLabel.Text = "Level: 0 / " .. def.max
		levelLabel.TextXAlignment = Enum.TextXAlignment.Left
		levelLabel.Parent = itemFrame
		
		local costLabel = Instance.new("TextLabel")
		costLabel.Size = UDim2.new(0, 150, 0, 30)
		costLabel.Position = UDim2.new(0, 10, 0, 55)
		costLabel.BackgroundTransparency = 1
		costLabel.TextColor3 = Color3.fromRGB(150, 200, 100)
		costLabel.TextSize = 12
		costLabel.Font = Enum.Font.Gotham
		costLabel.Text = "Cost: ..."
		costLabel.TextXAlignment = Enum.TextXAlignment.Left
		costLabel.Parent = itemFrame
		
		local buyBtn = Instance.new("TextButton")
		buyBtn.Name = "BuyBtn"
		buyBtn.Size = UDim2.new(0, 80, 0, 50)
		buyBtn.Position = UDim2.new(1, -95, 0, 15)
		buyBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
		buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyBtn.TextSize = 12
		buyBtn.Font = Enum.Font.GothamBold
		buyBtn.Text = "Buy"
		buyBtn.BorderSizePixel = 0
		buyBtn.Parent = itemFrame
		
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 4)
		btnCorner.Parent = buyBtn
		
		buyBtn.MouseButton1Click:Connect(function()
			Remotes:FindFirstChild("PurchaseUpgrade"):FireServer(name)
		end)
	end
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

local mainGui = buildHUD()
buildShopItems()

-- Shop toggle
local shopBtn = mainGui:FindFirstChild("ShopButton")
local shopPanel = mainGui:FindFirstChild("ShopPanel")

shopBtn.MouseButton1Click:Connect(function()
	shopPanel.Visible = not shopPanel.Visible
end)

-- Escape to close shop
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Escape and shopPanel.Visible then
		shopPanel.Visible = false
	end
end)

print("[HUD] Client-side HUD initialized")
