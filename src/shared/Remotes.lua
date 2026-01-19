local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create Events folder if it doesn't exist
if not ReplicatedStorage:FindFirstChild("Events") then
    Instance.new("Folder", ReplicatedStorage).Name = "Events"
end

local Events = ReplicatedStorage:WaitForChild("Events")

-- Define all remote events
local Remotes = {}

Remotes.WaveStarted = Instance.new("RemoteEvent")
Remotes.WaveStarted.Name = "WaveStarted"
Remotes.WaveStarted.Parent = Events

Remotes.WaveEnded = Instance.new("RemoteEvent")
Remotes.WaveEnded.Name = "WaveEnded"
Remotes.WaveEnded.Parent = Events

Remotes.TimerTick = Instance.new("RemoteEvent")
Remotes.TimerTick.Name = "TimerTick"
Remotes.TimerTick.Parent = Events

Remotes.WaveDefeat = Instance.new("RemoteEvent")
Remotes.WaveDefeat.Name = "WaveDefeat"
Remotes.WaveDefeat.Parent = Events

Remotes.WaveVictory = Instance.new("RemoteEvent")
Remotes.WaveVictory.Name = "WaveVictory"
Remotes.WaveVictory.Parent = Events

Remotes.PlayerDied = Instance.new("RemoteEvent")
Remotes.PlayerDied.Name = "PlayerDied"
Remotes.PlayerDied.Parent = Events

return Remotes
