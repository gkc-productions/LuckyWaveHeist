local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create folder for RemoteEvents if needed
if not ReplicatedStorage:FindFirstChild("Events") then
    Instance.new("Folder", ReplicatedStorage).Name = "Events"
end

local Events = ReplicatedStorage:WaitForChild("Events")

-- Remote Events (server → all clients or bidirectional)
local remoteEvents = {
    -- Round State Changes
    RoundStateChanged = Instance.new("RemoteEvent", Events),
    
    -- Wave Progression
    WaveStarted = Instance.new("RemoteEvent", Events),
    WaveEnded = Instance.new("RemoteEvent", Events),
    
    -- Player Events
    PlayerJoined = Instance.new("RemoteEvent", Events),
    PlayerLeft = Instance.new("RemoteEvent", Events),
    
    -- Game Events
    GameVictory = Instance.new("RemoteEvent", Events),
    GameDefeat = Instance.new("RemoteEvent", Events),
}

-- Name them for debugging
for eventName, event in pairs(remoteEvents) do
    event.Name = eventName
end

return remoteEvents
