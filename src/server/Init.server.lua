local RoundService = require(script.Parent:WaitForChild("RoundService"))
local WaterRise = require(script.Parent:WaitForChild("WaterRise"))

-- Wait for shared modules
game.ReplicatedStorage:WaitForChild("shared"):WaitForChild("Remotes")

print("[Init] Starting Lucky Wave Heist...")

-- Initialize both services
RoundService.Init()
WaterRise.Init()

print("[Init] All services started!")
