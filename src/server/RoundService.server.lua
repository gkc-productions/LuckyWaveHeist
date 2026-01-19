local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))
local WaterRise = require(script.Parent:WaitForChild("WaterRise"))

-- CONFIG
local INTERMISSION_SECONDS = 10
local ROUND_SECONDS = 120
local WATER_RISE_SPEED = 1.5 -- studs/sec

-- REQUIRED objects in Workspace:
-- Workspace.Spawns.Lobby (folder of SpawnLocation/parts)
-- Workspace.Spawns.Arena (folder of SpawnLocation/parts)
local spawns = workspace:WaitForChild("Spawns")
local lobbyFolder = spawns:WaitForChild("Lobby")
local arenaFolder = spawns:WaitForChild("Arena")

local water = WaterRise.new()
water:Reset()

local state = "Intermission"
local timeLeft = INTERMISSION_SECONDS

local function pickSpawn(folder)
	local kids = folder:GetChildren()
	if #kids == 0 then return nil end
	local p = kids[math.random(1, #kids)]
	return p:IsA("BasePart") and p or nil
end

local function teleportPlayer(plr, folder)
	local char = plr.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local spawnPart = pickSpawn(folder)
	if not spawnPart then return end
	hrp.CFrame = spawnPart.CFrame + Vector3.new(0, 5, 0)
end

local function teleportAll(folder)
	for _, plr in ipairs(Players:GetPlayers()) do
		teleportPlayer(plr, folder)
	end
end

local function aliveCount()
	local count = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		local c = plr.Character
		local hum = c and c:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			count += 1
		end
	end
	return count
end

local function broadcast()
	Remotes.RoundUpdate:FireAllClients({
		state = state,
		timeLeft = timeLeft,
		alive = aliveCount(),
	})
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.1)
		if state == "Round" then
			teleportPlayer(plr, arenaFolder)
		else
			teleportPlayer(plr, lobbyFolder)
		end
	end)
end)

task.spawn(function()
	math.randomseed(os.clock() * 1000000)

	while true do
		-- Intermission
		state = "Intermission"
		timeLeft = INTERMISSION_SECONDS
		water:Reset()
		teleportAll(lobbyFolder)

		while timeLeft > 0 do
			broadcast()
			task.wait(1)
			timeLeft -= 1
		end

		-- Round
		state = "Round"
		timeLeft = ROUND_SECONDS
		water:Reset()
		teleportAll(arenaFolder)
		water:Start(WATER_RISE_SPEED)

		local last = os.clock()
		while timeLeft > 0 do
			local now = os.clock()
			local dt = now - last
			last = now

			water:Step(dt)

			if aliveCount() == 0 then
				timeLeft = 0
				break
			end

			broadcast()
			task.wait(1)
			timeLeft -= 1
		end

		water:Stop()
		broadcast()
		task.wait(3)
	end
end)
