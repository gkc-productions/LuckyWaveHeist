local RoundStates = require(game.ReplicatedStorage.shared.RoundStates)
local Constants = require(game.ReplicatedStorage.shared.Constants)
local RemoteEvents = require(game.ReplicatedStorage.shared.RemoteEvents)

local RoundManager = {}

-- State variables
local currentState = RoundStates.LOBBY
local currentWave = 1
local playerCount = 0
local activePlayers = {}
local lobbyCountdown = 0
local waveTimer = 0
local stateTimer = 0

-- Forward declaration for PlayerManager
local PlayerManager = nil

---Broadcast state change to all clients
local function ChangeState(newState)
    currentState = newState
    stateTimer = 0
    RemoteEvents.RoundStateChanged:FireAllClients({
        state = newState,
        wave = currentWave,
        timestamp = tick()
    })
    print("[RoundManager] State changed to: " .. newState)
end

---Spawn players at spawn locations
local function SpawnPlayers()
    local spawns = game.Workspace:FindFirstChild("Spawns") or game.Workspace
    local spawnCount = 0
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local spawnLocation = spawns:FindFirstChild(Constants.SPAWN_LOCATION_PREFIX .. spawnCount) or spawns:FindFirstChild("Spawn")
            if spawnLocation then
                player.Character:MoveTo(spawnLocation.Position + Vector3.new(0, 3, 0))
            end
            spawnCount = spawnCount + 1
        end
    end
end

---Initialize and start a wave
local function StartWave(waveNumber)
    if waveNumber > Constants.MAX_WAVES then
        ChangeState(RoundStates.VICTORY)
        return
    end
    
    currentWave = waveNumber
    ChangeState(RoundStates.WAVE_START)
    waveTimer = Constants.WAVE_START_DURATION
    
    RemoteEvents.WaveStarted:FireAllClients({
        waveNumber = waveNumber,
        duration = Constants.WAVES[waveNumber].duration
    })
    print("[RoundManager] Wave " .. waveNumber .. " started")
end

---End current wave and check for win/loss
local function EndWave()
    ChangeState(RoundStates.WAVE_END)
    stateTimer = Constants.WAVE_END_DURATION
    
    RemoteEvents.WaveEnded:FireAllClients({
        waveNumber = currentWave,
        success = true
    })
    print("[RoundManager] Wave " .. currentWave .. " ended")
end

---Handle wave defeat
local function WaveDefeat(reason)
    ChangeState(RoundStates.DEFEAT)
    stateTimer = Constants.DEFEAT_DURATION
    
    RemoteEvents.GameDefeat:FireAllClients({
        reason = reason
    })
    print("[RoundManager] Wave defeated: " .. reason)
end

---Reset round to lobby
local function ResetRound()
    currentWave = 1
    waveTimer = 0
    lobbyCountdown = 0
    activePlayers = {}
    ChangeState(RoundStates.LOBBY)
end

---Main game loop - updates round state
local function GameLoop()
    while true do
        wait(0.1)
        
        playerCount = #game.Players:GetPlayers()
        
        if currentState == RoundStates.LOBBY then
            -- Check if enough players to start countdown
            if playerCount >= Constants.MIN_PLAYERS then
                if lobbyCountdown == 0 then
                    lobbyCountdown = Constants.LOBBY_TIMEOUT
                    print("[RoundManager] Lobby countdown started: " .. lobbyCountdown .. "s")
                end
                
                lobbyCountdown = lobbyCountdown - 0.1
                
                if lobbyCountdown <= 0 then
                    StartWave(1)
                    lobbyCountdown = 0
                end
            else
                lobbyCountdown = 0
            end
            
        elseif currentState == RoundStates.WAVE_START then
            waveTimer = waveTimer - 0.1
            
            if waveTimer <= 0 then
                SpawnPlayers()
                ChangeState(RoundStates.ACTIVE)
                waveTimer = Constants.WAVES[currentWave].duration
            end
            
        elseif currentState == RoundStates.ACTIVE then
            waveTimer = waveTimer - 0.1
            
            -- Check if all players are dead
            if PlayerManager and PlayerManager.IsAllPlayersDead() then
                WaveDefeat("AllPlayersDead")
                return
            end
            
            -- Check if wave time expired
            if waveTimer <= 0 then
                EndWave()
            end
            
        elseif currentState == RoundStates.WAVE_END then
            stateTimer = stateTimer - 0.1
            
            if stateTimer <= 0 then
                if currentWave < Constants.MAX_WAVES then
                    StartWave(currentWave + 1)
                else
                    ChangeState(RoundStates.VICTORY)
                    stateTimer = Constants.VICTORY_DURATION
                end
            end
            
        elseif currentState == RoundStates.VICTORY then
            stateTimer = stateTimer - 0.1
            
            if stateTimer <= 0 then
                RemoteEvents.GameVictory:FireAllClients({})
                ResetRound()
            end
            
        elseif currentState == RoundStates.DEFEAT then
            stateTimer = stateTimer - 0.1
            
            if stateTimer <= 0 then
                ResetRound()
            end
        end
    end
end

---Initialize RoundManager
function RoundManager.Init(playerMgr)
    PlayerManager = playerMgr
    print("[RoundManager] Initialized")
    GameLoop()
end

return RoundManager
