local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local evt = Remotes.RoundUpdate

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "RoundHUD"
gui.ResetOnSpawn = false
gui.Parent = guiParent

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 360, 0, 50)
label.Position = UDim2.new(0.5, -180, 0, 20)
label.BackgroundTransparency = 0.3
label.TextScaled = true
label.Parent = gui

local function fmt(t)
	local m = math.floor(t/60)
	local s = t % 60
	return string.format("%d:%02d", m, s)
end

evt.OnClientEvent:Connect(function(p)
	local state = p.state or "?"
	local timeLeft = p.timeLeft or 0
	local alive = p.alive or 0
	label.Text = string.format("%s | %s | Alive: %d", state, fmt(timeLeft), alive)
end)
