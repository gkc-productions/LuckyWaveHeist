local RemoteEvents = require(game.ReplicatedStorage.shared.RemoteEvents)

local PlayerManager = {}

-- Track players and their state
local players = {}
local aliveCount = 0

---Handle player joining
local function OnPlayerAdded(player)
    print("[PlayerManager] Player joined: " .. player.Name)
    
    players[player.UserId] = {
        player = player,
        alive = false,
        character = nil
    }
    
    RemoteEvents.PlayerJoined:FireAllClients({
        playerName = player.Name,
        totalPlayers = #game.Players:GetPlayers()
    })
    
    -- Listen for character spawning
    if player.Character then
        players[player.UserId].character = player.Character
        players[player.UserId].alive = true
        aliveCount = aliveCount + 1
    end
    
    player.CharacterAdded:Connect(function(character)
        players[player.UserId].character = character
        players[player.UserId].alive = true
        aliveCount = aliveCount + 1
        print("[PlayerManager] " .. player.Name .. " spawned. Alive: " .. aliveCount)
    end)
    
    player.CharacterRemoving:Connect(function(character)
        if players[player.UserId] then
            players[player.UserId].alive = false
            aliveCount = math.max(0, aliveCount - 1)
            print("[PlayerManager] " .. player.Name .. " died. Alive: " .. aliveCount)
        end
    end)
end

---Handle player leaving
local function OnPlayerRemoving(player)
    print("[PlayerManager] Player left: " .. player.Name)
    
    if players[player.UserId] then
        if players[player.UserId].alive then
            aliveCount = math.max(0, aliveCount - 1)
        end
        players[player.UserId] = nil
    end
    
    RemoteEvents.PlayerLeft:FireAllClients({
        playerName = player.Name,
        totalPlayers = #game.Players:GetPlayers()
    })
end

---Check if all players are dead
function PlayerManager.IsAllPlayersDead()
    local totalPlayers = #game.Players:GetPlayers()
    
    if totalPlayers == 0 then
        return false
    end
    
    return aliveCount <= 0
end

---Get current alive player count
function PlayerManager.GetAliveCount()
    return aliveCount
end

---Get total player count
function PlayerManager.GetTotalCount()
    return #game.Players:GetPlayers()
end

---Initialize PlayerManager
function PlayerManager.Init()
    -- Listen for players joining
    game.Players.PlayerAdded:Connect(OnPlayerAdded)
    game.Players.PlayerRemoving:Connect(OnPlayerRemoving)
    
    -- Handle existing players
    for _, player in pairs(game.Players:GetPlayers()) do
        OnPlayerAdded(player)
    end
    
    print("[PlayerManager] Initialized")
end

return PlayerManager
