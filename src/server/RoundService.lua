-- src/server/RoundService.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("Remotes"))
local Water = require(script.Parent:WaitForChild("WaterRise"))

print("[RoundService] Starting...")

-- CONFIG
local ROUND_SECONDS = 120
local INTERMISSION_SECONDS = 15
local WATER_RISE_SPEED = 1.5

local SPAWNS_FOLDER = workspace:WaitForChild("Spawns")
local LOBBY_FOLDER = SPAWNS_FOLDER:WaitForChild("Lobby")
local ARENA_FOLDER = SPAWNS_FOLDER:WaitForChild("Arena")

-- UTIL
local function getSpawn(folder)
	local spawns = folder:GetChildren()
	if #spawns == 0 then return nil end
	local pick = spawns[math.random(1, #spawns)]
	if pick:IsA("BasePart") then return pick end
	return nil
end

local function teleportPlayerToFolder(plr, folder)
	local character = plr.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local spawnPart = getSpawn(folder)
	if not spawnPart then return end
	hrp.CFrame = spawnPart.CFrame + Vector3.new(0, 5, 0)
end

local function teleportAll(folder)
	for _, plr in ipairs(Players:GetPlayers()) do
		teleportPlayerToFolder(plr, folder)
	end
end

local function aliveCount()
	local count = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		local c = plr.Character
		local hum = c and c:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			count = count + 1
		end
	end
	return count
end

-- STATE
local state = "Intermission"
local timeLeft = INTERMISSION_SECONDS

local function broadcast()
	Remotes.RoundUpdate:FireAllClients({
		state = state,
		timeLeft = timeLeft,
		alive = aliveCount(),
	})
	print("[RoundService] Broadcast: " .. state .. " - " .. timeLeft .. "s - Alive: " .. aliveCount())
end

-- Spawn logic
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.1)
		if state == "Round" then
			teleportPlayerToFolder(plr, ARENA_FOLDER)
		else
			teleportPlayerToFolder(plr, LOBBY_FOLDER)
		end
	end)
end)

-- MAIN LOOP
math.randomseed(os.clock() * 1000000)
Water:Reset()

while true do
	-- === INTERMISSION ===
	state = "Intermission"
	timeLeft = INTERMISSION_SECONDS
	Water:Reset()
	teleportAll(LOBBY_FOLDER)
	print("[RoundService] Intermission started")

	while timeLeft > 0 do
		broadcast()
		task.wait(1)
		timeLeft = timeLeft - 1
	end

	-- === ROUND START ===
	state = "Round"
	timeLeft = ROUND_SECONDS
	Water:Reset()
	teleportAll(ARENA_FOLDER)
	Water:Start(WATER_RISE_SPEED)
	print("[RoundService] Round started - " .. ROUND_SECONDS .. "s")

	local last = os.clock()
	while timeLeft > 0 do
		-- Water step
		local now = os.clock()
		local dt = now - last
		last = now
		Water:Step(dt)

		-- End early if everyone died
		if aliveCount() == 0 then
			print("[RoundService] All players dead!")
			timeLeft = 0
			break
		end

		-- UI update
		broadcast()
		task.wait(1)
		timeLeft = timeLeft - 1
	end

	Water:Stop()
	broadcast()
	print("[RoundService] Round ended")

	-- Pause
	task.wait(3)
end
