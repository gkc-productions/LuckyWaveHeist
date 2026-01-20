local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui")
if not playerGui then
	error("PlayerGui missing for LocalPlayer")
end

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
if not sharedFolder then
	sharedFolder = Instance.new("Folder")
	sharedFolder.Name = "Shared"
	sharedFolder.Parent = ReplicatedStorage
end

local remotesModule = sharedFolder:FindFirstChild("Remotes")
if not remotesModule then
	error("Remotes module missing in ReplicatedStorage.Shared")
end

local Remotes = require(remotesModule)

local existingGui = playerGui:FindFirstChild("HUD")
if existingGui and not existingGui:IsA("ScreenGui") then
	existingGui:Destroy()
	existingGui = nil
end

local hud = existingGui
if not hud then
	hud = Instance.new("ScreenGui")
	hud.Name = "HUD"
	hud.ResetOnSpawn = false
	hud.IgnoreGuiInset = false
	hud.Parent = playerGui
end

local fontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")

local safeArea = hud:FindFirstChild("SafeArea")
if safeArea and not safeArea:IsA("Frame") then
	safeArea:Destroy()
	safeArea = nil
end

if not safeArea then
	safeArea = Instance.new("Frame")
	safeArea.Name = "SafeArea"
	safeArea.BackgroundTransparency = 1
	safeArea.Size = UDim2.new(1, 0, 1, 0)
	safeArea.Parent = hud

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 16)
	padding.PaddingBottom = UDim.new(0, 16)
	padding.PaddingLeft = UDim.new(0, 16)
	padding.PaddingRight = UDim.new(0, 16)
	padding.Parent = safeArea
end

local coinsCard = safeArea:FindFirstChild("CoinsCard")
if coinsCard and not coinsCard:IsA("Frame") then
	coinsCard:Destroy()
	coinsCard = nil
end

if not coinsCard then
	coinsCard = Instance.new("Frame")
	coinsCard.Name = "CoinsCard"
	coinsCard.Size = UDim2.new(0, 180, 0, 50)
	coinsCard.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	coinsCard.BackgroundTransparency = 0.1
	coinsCard.Parent = safeArea

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = coinsCard

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 70)
	stroke.Thickness = 1
	stroke.Parent = coinsCard

	local title = Instance.new("TextLabel")
	title.Name = "CoinsTitle"
	title.BackgroundTransparency = 1
	title.FontFace = fontFace
	title.Text = "Coins"
	title.TextColor3 = Color3.fromRGB(200, 200, 210)
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Position = UDim2.new(0, 12, 0, 6)
	title.Size = UDim2.new(1, -24, 0, 16)
	title.Parent = coinsCard

	local value = Instance.new("TextLabel")
	value.Name = "CoinsValue"
	value.BackgroundTransparency = 1
	value.FontFace = fontFace
	value.Text = "0"
	value.TextColor3 = Color3.fromRGB(255, 215, 105)
	value.TextSize = 20
	value.TextXAlignment = Enum.TextXAlignment.Left
	value.Position = UDim2.new(0, 12, 0, 22)
	value.Size = UDim2.new(1, -24, 0, 22)
	value.Parent = coinsCard
end

local banner = safeArea:FindFirstChild("RoundBanner")
if banner and not banner:IsA("Frame") then
	banner:Destroy()
	banner = nil
end

if not banner then
	banner = Instance.new("Frame")
	banner.Name = "RoundBanner"
	banner.Size = UDim2.new(0, 320, 0, 100)
	banner.AnchorPoint = Vector2.new(0.5, 0)
	banner.Position = UDim2.new(0.5, 0, 0, 0)
	banner.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	banner.BackgroundTransparency = 0.1
	banner.Parent = safeArea

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = banner

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 70)
	stroke.Thickness = 1
	stroke.Parent = banner

	local line1 = Instance.new("TextLabel")
	line1.Name = "Line1"
	line1.BackgroundTransparency = 1
	line1.FontFace = fontFace
	line1.Text = "Lobby"
	line1.TextColor3 = Color3.fromRGB(235, 235, 240)
	line1.TextSize = 20
	line1.Position = UDim2.new(0, 12, 0, 8)
	line1.Size = UDim2.new(1, -24, 0, 24)
	line1.TextXAlignment = Enum.TextXAlignment.Center
	line1.Parent = banner

	local line2 = Instance.new("TextLabel")
	line2.Name = "Line2"
	line2.BackgroundTransparency = 1
	line2.FontFace = fontFace
	line2.Text = "Waiting"
	line2.TextColor3 = Color3.fromRGB(180, 180, 190)
	line2.TextSize = 16
	line2.Position = UDim2.new(0, 12, 0, 34)
	line2.Size = UDim2.new(1, -24, 0, 20)
	line2.TextXAlignment = Enum.TextXAlignment.Center
	line2.Parent = banner

	local line3 = Instance.new("TextLabel")
	line3.Name = "Line3"
	line3.BackgroundTransparency = 1
	line3.FontFace = fontFace
	line3.Text = "0s | Alive: 0"
	line3.TextColor3 = Color3.fromRGB(200, 200, 210)
	line3.TextSize = 16
	line3.Position = UDim2.new(0, 12, 0, 58)
	line3.Size = UDim2.new(1, -24, 0, 20)
	line3.TextXAlignment = Enum.TextXAlignment.Center
	line3.Parent = banner
end

local toast = safeArea:FindFirstChild("Toast")
if toast and not toast:IsA("TextLabel") then
	toast:Destroy()
	toast = nil
end

if not toast then
	toast = Instance.new("TextLabel")
	toast.Name = "Toast"
	toast.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
	toast.BackgroundTransparency = 0.2
	toast.TextColor3 = Color3.fromRGB(235, 235, 240)
	toast.TextSize = 16
	toast.FontFace = fontFace
	toast.AnchorPoint = Vector2.new(0.5, 1)
	toast.Position = UDim2.new(0.5, 0, 1, -20)
	toast.Size = UDim2.new(0, 260, 0, 36)
	toast.Visible = false
	toast.Parent = safeArea

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = toast

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 70)
	stroke.Thickness = 1
	stroke.Parent = toast
end

local coinsValue = coinsCard:FindFirstChild("CoinsValue")
local line1 = banner:FindFirstChild("Line1")
local line2 = banner:FindFirstChild("Line2")
local line3 = banner:FindFirstChild("Line3")

local waveCount = 3
local toastToken = 0

local function updateRound(state, waveIndex, timeLeft, alive)
	if line1 then
		if state == "Wave" then
			line1.Text = string.format("Wave %d/%d", waveIndex, waveCount)
		else
			line1.Text = tostring(state)
		end
	end

	if line2 then
		line2.Text = (state == "Wave") and "Active" or "Waiting"
	end

	if line3 then
		line3.Text = string.format("%ds | Alive: %d", timeLeft, alive)
	end
end

local function showToast(message, rarity)
	toastToken += 1
	local token = toastToken

	if toast then
		local prefix = rarity and ("[" .. tostring(rarity) .. "] ") or ""
		toast.Text = prefix .. tostring(message)
		toast.Visible = true
	end

	task.delay(2, function()
		if toast and token == toastToken then
			toast.Visible = false
		end
	end)
end

Remotes.RoundUpdate.OnClientEvent:Connect(updateRound)
Remotes.CoinsUpdate.OnClientEvent:Connect(function(coins)
	if coinsValue then
		coinsValue.Text = tostring(coins)
	end
end)

Remotes.Toast.OnClientEvent:Connect(showToast)

print("[HUD] init")
