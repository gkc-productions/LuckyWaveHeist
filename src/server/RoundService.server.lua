local Remotes = require(game.ReplicatedStorage.shared.Remotes)
local Players = game:GetService("Players")

local RoundService = {}

-- Configuration
local LOBBY_COUNTDOWN = 10
local WAVES = {
    { duration = 30, number = 1 },
    { duration = 30, number = 2 },
    { duration = 30, number = 3 },
}

-- State
local currentWave = 0
local waveActive = false
local waveTimeRemaining = 0
local lobbyTimeRemaining = 0
local inLobby = true

local function GetAlivePlayers()
    local alive = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                alive = alive + 1
            end
        end
    end
    return alive
end

local function SpawnPlayers(spawnFolder)
    local spawns = {}
    for _, part in pairs(spawnFolder:GetChildren()) do
        if part:IsA("SpawnLocation") then
            table.insert(spawns, part)
        end
    end
    
    local spawnIndex = 1
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local spawn = spawns[spawnIndex] or spawns[1]
            if spawn then
                player.Character:MoveTo(spawn.Position + Vector3.new(0, 3, 0))
            end
            spawnIndex = spawnIndex + 1
        end
    end
end

local function StartWave(waveNumber)
    if waveNumber > #WAVES then
        inLobby = true
        waveActive = false
        Remotes.WaveVictory:FireAllClients()
        print("[RoundService] All waves complete - Victory!")
        return
    end
    
    currentWave = waveNumber
    waveActive = true
    inLobby = false
    waveTimeRemaining = WAVES[waveNumber].duration
    
    print("[RoundService] Wave " .. waveNumber .. " started - Duration: " .. waveTimeRemaining .. "s")
    
    -- Spawn players in Arena
    local arena = game.Workspace.Spawns:FindFirstChild("Arena")
    if arena then
        SpawnPlayers(arena)
    end
    
    Remotes.WaveStarted:FireAllClients({ wave = waveNumber, duration = waveTimeRemaining })
end

local function EndWave()
    waveActive = false
    print("[RoundService] Wave " .. currentWave .. " ended")
    Remotes.WaveEnded:FireAllClients({ wave = currentWave })
    
    -- Start next wave after 3 seconds
    wait(3)
    StartWave(currentWave + 1)
end

local function GameLoop()
    while true do
        wait(0.1)
        
        if inLobby then
            -- Countdown in lobby
            if Players:FindFirstChild(Players:GetPlayers()[1].Name) then
                if #Players:GetPlayers() > 0 then
                    lobbyTimeRemaining = lobbyTimeRemaining - 0.1
                    
                    if lobbyTimeRemaining <= 0 then
                        lobbyTimeRemaining = LOBBY_COUNTDOWN
                        StartWave(1)
                    end
                else
                    lobbyTimeRemaining = LOBBY_COUNTDOWN
                end
            end
        elseif waveActive then
            -- Count down wave timer
            waveTimeRemaining = waveTimeRemaining - 0.1
            
            -- Send timer update to clients
            Remotes.TimerTick:FireAllClients({ time = math.max(0, waveTimeRemaining), wave = currentWave })
            
            -- Check if all players dead
            if GetAlivePlayers() <= 0 then
                waveActive = false
                Remotes.WaveDefeat:FireAllClients({ reason = "All players dead" })
                print("[RoundService] Wave defeated - all players dead")
                wait(3)
                inLobby = true
                lobbyTimeRemaining = LOBBY_COUNTDOWN
            -- Check if time expired
            elseif waveTimeRemaining <= 0 then
                EndWave()
            end
        end
    end
end

function RoundService.Init()
    print("[RoundService] Initialized")
    lobbyTimeRemaining = LOBBY_COUNTDOWN
    inLobby = true
    GameLoop()
end

return RoundService
