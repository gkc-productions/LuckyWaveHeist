local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local mapAlias = workspace:FindFirstChild("Map")
if not mapAlias then
	mapAlias = Instance.new("ObjectValue")
	mapAlias.Name = "Map"
	mapAlias.Parent = workspace
	mapAlias.Value = workspace:FindFirstChild("LuckyWaveHeist_Map")
	warn("[RoundService] Missing Map alias; created placeholder.")
end

local Map = workspace:WaitForChild("Map").Value

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
if not sharedFolder then
	sharedFolder = Instance.new("Folder")
	sharedFolder.Name = "Shared"
	sharedFolder.Parent = ReplicatedStorage
end

local remotesModule = sharedFolder:FindFirstChild("Remotes")
if not remotesModule then
	error("Remotes module missing in ReplicatedStorage.Shared")
end

local Remotes = require(remotesModule)
local Economy = require(script.Parent:WaitForChild("Economy"))

local warned = {}
local function warnOnce(key, message)
	if warned[key] then
		return
	end
	warned[key] = true
	warn(message)
end

local function ensureFolder(parent, name, warnKey)
	local folder = parent:FindFirstChild(name)
	if folder and not folder:IsA("Folder") then
		folder:Destroy()
		folder = nil
	end
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
		warnOnce(warnKey or name, "[RoundService] Missing " .. name .. "; created placeholder.")
	end
	return folder
end

local spawnsFolder = ensureFolder(workspace, "Spawns", "Spawns")
local lobbySpawns = ensureFolder(spawnsFolder, "Lobby", "Spawns.Lobby")
local arenaSpawns = ensureFolder(spawnsFolder, "Arena", "Spawns.Arena")

local waterBounds = ensureFolder(workspace, "WaterBounds", "WaterBounds")
local waterStartPlane = waterBounds:FindFirstChild("WaterStartPlane")
if waterStartPlane and not waterStartPlane:IsA("BasePart") then
	waterStartPlane:Destroy()
	waterStartPlane = nil
end
if not waterStartPlane then
	waterStartPlane = Instance.new("Part")
	waterStartPlane.Name = "WaterStartPlane"
	waterStartPlane.Anchored = true
	waterStartPlane.Size = Vector3.new(300, 1, 300)
	waterStartPlane.Position = Vector3.new(0, 0, 0)
	waterStartPlane.Parent = waterBounds
	warnOnce("WaterStartPlane", "[RoundService] Missing WaterStartPlane; created placeholder.")
end

local function getArenaLowestY()
	local lowest = nil
	for _, child in ipairs(arenaSpawns:GetChildren()) do
		if child:IsA("BasePart") then
			if not lowest or child.Position.Y < lowest then
				lowest = child.Position.Y
			end
		end
	end
	return lowest
end

local function getTsunamiWaterPart()
	local existing = workspace:FindFirstChild("TsunamiWater")
	if existing then
		if existing:IsA("BasePart") then
			return existing
		elseif existing:IsA("Model") then
			local basePart = existing.PrimaryPart or existing:FindFirstChildWhichIsA("BasePart")
			if basePart then
				return basePart
			end
			local created = Instance.new("Part")
			created.Name = "Water"
			created.Anchored = true
			created.CanCollide = false
			created.Parent = existing
			return created
		end
	end

	local water = Instance.new("Part")
	water.Name = "TsunamiWater"
	water.Anchored = true
	water.CanCollide = false
	water.Parent = workspace
	return water
end

local waterPart = getTsunamiWaterPart()
local waterSize = Vector3.new(waterStartPlane.Size.X, 40, waterStartPlane.Size.Z)
waterPart.Size = waterSize
waterPart.Material = Enum.Material.Water
waterPart.Transparency = 0.45
waterPart.Color = Color3.fromRGB(50, 150, 170)

local arenaLowestY = getArenaLowestY()
local startSurfaceY = waterStartPlane.Position.Y - 50
if arenaLowestY then
	startSurfaceY = math.min(startSurfaceY, arenaLowestY - 80)
end

local waterSurfaceY = startSurfaceY
waterPart.Position = Vector3.new(
	waterStartPlane.Position.X,
	waterSurfaceY - (waterSize.Y / 2),
	waterStartPlane.Position.Z
)

local waveRates = { 1, 2, 3 }

local function getHumanoid(player)
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChildWhichIsA("Humanoid")
end

local function isAlive(player)
	local humanoid = getHumanoid(player)
	return humanoid ~= nil and humanoid.Health > 0
end

local function countAlive()
	local alive = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if isAlive(player) then
			alive += 1
		end
	end
	return alive
end

local function getSpawnLocation(folder)
	local candidates = {}
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("SpawnLocation") or child:IsA("BasePart") then
			table.insert(candidates, child)
		end
	end
	if #candidates == 0 then
		return nil
	end
	return candidates[math.random(1, #candidates)]
end

local function teleportPlayer(player, folder)
	local spawn = getSpawnLocation(folder)
	if not spawn then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	character:PivotTo(CFrame.new(spawn.Position + Vector3.new(0, 3, 0)))
end

local function applySpeed(player, isWave)
	local humanoid = getHumanoid(player)
	if not humanoid then
		return
	end

	local speedLevel = Economy.GetUpgradeLevel(player, "Speed")
	local baseSpeed = 16
	local bonus = isWave and (speedLevel * 2) or 0
	humanoid.WalkSpeed = baseSpeed + bonus
end

local function playWarningSiren()
	if not Map then
		return
	end
	local siren = Map:FindFirstChild("WarningSiren", true)
	if siren and siren:IsA("Sound") then
		siren:Play()
	end
end

local currentState = "Lobby"
local currentWaveIndex = 0
local currentTimeLeft = 0

local function broadcastRound()
	Remotes.RoundUpdate:FireAllClients(
		currentState,
		currentWaveIndex,
		currentTimeLeft,
		countAlive()
	)
end

Players.PlayerAdded:Connect(function(player)
	Remotes.RoundUpdate:FireClient(
		player,
		currentState,
		currentWaveIndex,
		currentTimeLeft,
		countAlive()
	)
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		applySpeed(player, currentState == "Wave")
	end)
end)

local phases = {
	{ state = "Lobby", duration = 10 },
	{ state = "Intermission", duration = 5 },
	{ state = "Wave", duration = 20, waveIndex = 1 },
	{ state = "Wave", duration = 20, waveIndex = 2 },
	{ state = "Wave", duration = 20, waveIndex = 3 },
	{ state = "Intermission", duration = 5 },
}

print("[RoundService] ready")

while true do
	for _, phase in ipairs(phases) do
		currentState = phase.state
		currentWaveIndex = phase.waveIndex or 0

		if currentState == "Wave" then
			waterSurfaceY = startSurfaceY
			waterPart.Position = Vector3.new(
				waterStartPlane.Position.X,
				waterSurfaceY - (waterSize.Y / 2),
				waterStartPlane.Position.Z
			)
			playWarningSiren()
			for _, player in ipairs(Players:GetPlayers()) do
				Economy.ApplyWalletBonus(player)
				applySpeed(player, true)
				teleportPlayer(player, arenaSpawns)
			end
		else
			for _, player in ipairs(Players:GetPlayers()) do
				applySpeed(player, false)
				teleportPlayer(player, lobbySpawns)
			end
		end

		local phaseEnd = os.clock() + phase.duration
		local nextBroadcast = 0
		local lastTick = os.clock()

		while true do
			local now = os.clock()
			local remaining = phaseEnd - now
			if remaining <= 0 then
				currentTimeLeft = 0
				broadcastRound()
				break
			end

			currentTimeLeft = math.max(0, math.ceil(remaining))

			if currentState == "Wave" then
				local dt = now - lastTick
				local rate = waveRates[currentWaveIndex] or waveRates[#waveRates]
				waterSurfaceY += rate * dt
				waterPart.Position = Vector3.new(
					waterStartPlane.Position.X,
					waterSurfaceY - (waterSize.Y / 2),
					waterStartPlane.Position.Z
				)

				for _, player in ipairs(Players:GetPlayers()) do
					local character = player.Character
					local root = character and character:FindFirstChild("HumanoidRootPart")
					local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
					if root and humanoid and humanoid.Health > 0 then
						if root.Position.Y < (waterSurfaceY - 2) then
							humanoid.Health = 0
						end
					end
				end
			end

			if now >= nextBroadcast then
				broadcastRound()
				nextBroadcast = now + 0.2
			end

			lastTick = now
			task.wait(0.05)
		end
	end
end
