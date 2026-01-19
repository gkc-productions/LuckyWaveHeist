-- src/client/TimerUI.client.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local Remotes = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("Remotes"))
local roundEvent = Remotes.RoundUpdate

print("[TimerUI] Starting...")

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "RoundHUD"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 300, 0, 50)
label.Position = UDim2.new(0.5, -150, 0, 20)
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.BackgroundTransparency = 0.3
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Parent = gui

local function fmt(seconds)
	local m = math.floor(seconds / 60)
	local s = seconds % 60
	return string.format("%d:%02d", m, s)
end

print("[TimerUI] Connected to RoundUpdate event")

roundEvent.OnClientEvent:Connect(function(payload)
	local state = payload.state or "?"
	local timeLeft = payload.timeLeft or 0
	local alive = payload.alive or 0

	if state == "Intermission" then
		label.Text = ("Intermission: %s | Players: %d"):format(fmt(timeLeft), alive)
		label.TextColor3 = Color3.fromRGB(100, 100, 255)
	elseif state == "Round" then
		label.Text = ("SURVIVE: %s | Alive: %d"):format(fmt(timeLeft), alive)
		label.TextColor3 = Color3.fromRGB(255, 100, 100)
	else
		label.Text = ("%s | %s"):format(state, fmt(timeLeft))
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	
	print("[TimerUI] Update: " .. label.Text)
end)

print("[TimerUI] Ready!")
