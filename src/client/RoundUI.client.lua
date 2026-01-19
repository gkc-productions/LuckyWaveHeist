local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Wait for shared modules
local shared = ReplicatedStorage:WaitForChild("shared")
local RemoteEvents = require(shared:WaitForChild("RemoteEvents"))

-- UI State
local currentState = "Lobby"
local currentWave = 1
local totalWaves = 3
local waveTimeRemaining = 0
local playerCount = 0

-- Create UI
local function CreateUI()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RoundUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- State Label
    local stateLabel = Instance.new("TextLabel")
    stateLabel.Name = "StateLabel"
    stateLabel.Size = UDim2.new(0, 300, 0, 50)
    stateLabel.Position = UDim2.new(0.5, -150, 0, 20)
    stateLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    stateLabel.BackgroundTransparency = 0.5
    stateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    stateLabel.TextScaled = true
    stateLabel.Font = Enum.Font.GothamBold
    stateLabel.Text = "Lobby"
    stateLabel.Parent = screenGui
    
    -- Wave Label
    local waveLabel = Instance.new("TextLabel")
    waveLabel.Name = "WaveLabel"
    waveLabel.Size = UDim2.new(0, 300, 0, 50)
    waveLabel.Position = UDim2.new(0.5, -150, 0, 80)
    waveLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    waveLabel.BackgroundTransparency = 0.5
    waveLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    waveLabel.TextScaled = true
    waveLabel.Font = Enum.Font.Gotham
    waveLabel.Text = "Wave: 1 / 3"
    waveLabel.Parent = screenGui
    
    -- Timer Label
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "TimerLabel"
    timerLabel.Size = UDim2.new(0, 300, 0, 50)
    timerLabel.Position = UDim2.new(0.5, -150, 0, 140)
    timerLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    timerLabel.BackgroundTransparency = 0.5
    timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timerLabel.TextScaled = true
    timerLabel.Font = Enum.Font.Gotham
    timerLabel.Text = "Time: 0s"
    timerLabel.Parent = screenGui
    
    -- Player Count Label
    local playerCountLabel = Instance.new("TextLabel")
    playerCountLabel.Name = "PlayerCountLabel"
    playerCountLabel.Size = UDim2.new(0, 300, 0, 50)
    playerCountLabel.Position = UDim2.new(0.5, -150, 0, 200)
    playerCountLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    playerCountLabel.BackgroundTransparency = 0.5
    playerCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerCountLabel.TextScaled = true
    playerCountLabel.Font = Enum.Font.Gotham
    playerCountLabel.Text = "Players: 0"
    playerCountLabel.Parent = screenGui
    
    return {
        screenGui = screenGui,
        stateLabel = stateLabel,
        waveLabel = waveLabel,
        timerLabel = timerLabel,
        playerCountLabel = playerCountLabel
    }
end

-- Update UI display
local function UpdateUI(ui)
    ui.stateLabel.Text = currentState
    ui.waveLabel.Text = "Wave: " .. currentWave .. " / " .. totalWaves
    ui.playerCountLabel.Text = "Players: " .. playerCount
    
    local timeStr = math.floor(waveTimeRemaining)
    ui.timerLabel.Text = "Time: " .. timeStr .. "s"
end

-- Main UI loop
local function UILoop(ui)
    while true do
        wait(0.1)
        
        if currentState == "Active" then
            waveTimeRemaining = math.max(0, waveTimeRemaining - 0.1)
        end
        
        UpdateUI(ui)
    end
end

-- Listen for remote events
local function ConnectEvents()
    RemoteEvents.RoundStateChanged:Connect(function(data)
        currentState = data.state
        currentWave = data.wave or 1
        print("[RoundUI] State changed: " .. currentState)
    end)
    
    RemoteEvents.WaveStarted:Connect(function(data)
        currentWave = data.waveNumber
        waveTimeRemaining = data.duration
        print("[RoundUI] Wave " .. currentWave .. " started")
    end)
    
    RemoteEvents.WaveEnded:Connect(function(data)
        print("[RoundUI] Wave " .. data.waveNumber .. " ended")
    end)
    
    RemoteEvents.GameVictory:Connect(function()
        print("[RoundUI] Victory!")
        currentState = "Victory"
    end)
    
    RemoteEvents.GameDefeat:Connect(function(data)
        print("[RoundUI] Defeat: " .. data.reason)
        currentState = "Defeat"
    end)
    
    RemoteEvents.PlayerJoined:Connect(function(data)
        playerCount = data.totalPlayers
        print("[RoundUI] " .. data.playerName .. " joined (Total: " .. playerCount .. ")")
    end)
    
    RemoteEvents.PlayerLeft:Connect(function(data)
        playerCount = data.totalPlayers
        print("[RoundUI] " .. data.playerName .. " left (Total: " .. playerCount .. ")")
    end)
end

-- Initialize
local ui = CreateUI()
ConnectEvents()
UILoop(ui)
