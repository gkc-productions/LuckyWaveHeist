local Players = game:GetService("Players")
local Remotes = require(game.ReplicatedStorage.shared.Remotes)

local WaterRise = {}

local WATER_RISE_SPEED = 0.5 -- studs per second
local WATER_START_Y = -100 -- Starting position below map

local waterPart = workspace:WaitForChild("TsunamiWater")
waterPart.Position = Vector3.new(waterPart.Position.X, WATER_START_Y, waterPart.Position.Z)

local function DamagePlayersInWater()
    local waterY = waterPart.Position.Y
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                -- If player is below water level, kill them
                if rootPart.Position.Y < waterY then
                    humanoid:TakeDamage(humanoid.MaxHealth)
                    Remotes.PlayerDied:FireAllClients({ player = player.Name, reason = "Drowned" })
                    print("[WaterRise] " .. player.Name .. " drowned!")
                end
            end
        end
    end
end

local function WaterRiseLoop()
    while true do
        wait(0.1)
        
        -- Move water up
        waterPart.Position = waterPart.Position + Vector3.new(0, WATER_RISE_SPEED * 0.1, 0)
        
        -- Check for players in water
        DamagePlayersInWater()
    end
end

function WaterRise.Init()
    print("[WaterRise] Initialized - Water rising at " .. WATER_RISE_SPEED .. " studs/sec")
    WaterRiseLoop()
end

return WaterRise
