local Remotes = require(game.ReplicatedStorage.shared.Remotes)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TimerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Timer Label
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(0, 200, 0, 60)
timerLabel.Position = UDim2.new(0.5, -100, 0, 20)
timerLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
timerLabel.BackgroundTransparency = 0.3
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Text = "Waiting..."
timerLabel.Parent = screenGui

-- Wave Label
local waveLabel = Instance.new("TextLabel")
waveLabel.Name = "WaveLabel"
waveLabel.Size = UDim2.new(0, 200, 0, 60)
waveLabel.Position = UDim2.new(0.5, -100, 0, 100)
waveLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
waveLabel.BackgroundTransparency = 0.3
waveLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
waveLabel.TextScaled = true
waveLabel.Font = Enum.Font.Gotham
waveLabel.Text = "Wave: --"
waveLabel.Parent = screenGui

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0, 300, 0, 40)
statusLabel.Position = UDim2.new(0.5, -150, 0, 180)
statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.BackgroundTransparency = 0.3
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Status: Lobby"
statusLabel.Parent = screenGui

-- Listen for events
Remotes.WaveStarted:Connect(function(data)
    waveLabel.Text = "Wave: " .. data.wave .. " / 3"
    statusLabel.Text = "Status: Active"
    print("[TimerUI] Wave " .. data.wave .. " started!")
end)

Remotes.TimerTick:Connect(function(data)
    local time = math.floor(data.time)
    timerLabel.Text = time .. "s"
end)

Remotes.WaveEnded:Connect(function(data)
    statusLabel.Text = "Status: Wave Ended"
    timerLabel.Text = "Next..."
    print("[TimerUI] Wave " .. data.wave .. " ended!")
end)

Remotes.WaveDefeat:Connect(function(data)
    statusLabel.Text = "Status: DEFEAT - " .. data.reason
    timerLabel.Text = "Lost"
    print("[TimerUI] Wave defeat: " .. data.reason)
end)

Remotes.WaveVictory:Connect(function()
    statusLabel.Text = "Status: VICTORY!"
    timerLabel.Text = "Won"
    print("[TimerUI] Victory!")
end)

Remotes.PlayerDied:Connect(function(data)
    print("[TimerUI] " .. data.player .. " " .. data.reason)
end)

print("[TimerUI] Initialized")
