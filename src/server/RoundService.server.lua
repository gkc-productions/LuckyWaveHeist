local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local Content = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ContentPack"))
local WaterRise = require(script.Parent:WaitForChild("WaterRise"))
local TsunamiService = require(script.Parent:WaitForChild("TsunamiService"))
local LuckyBlocksService = require(script.Parent:WaitForChild("LuckyBlocksService"))
local CurrencyService = require(script.Parent:WaitForChild("CurrencyService"))

local preset = Content.Presets.Casual

local spawns = workspace:WaitForChild("Spawns")
local lobbyFolder = spawns:WaitForChild("Lobby")
local arenaFolder = spawns:WaitForChild("Arena")

local water = WaterRise.new()
local currency = CurrencyService.new(Remotes)
local tsunami = TsunamiService.new(Remotes, "Casual")
local luckyBlocks = LuckyBlocksService.new(Remotes, currency, tsunami)

local roundActive = false
local roundIndex = 1

local function pickSpawn(folder)
	local kids = folder:GetChildren()
	if #kids == 0 then return nil end
	local p = kids[math.random(1, #kids)]
	return p:IsA("BasePart") and p or nil
end

local function setSpawnShield(player)
	player:SetAttribute("SpawnShieldUntil", os.clock() + 3)
	local char = player.Character
	if char then
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(120, 200, 255)
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.Parent = char
		task.delay(3, function()
			if highlight and highlight.Parent then
				highlight:Destroy()
			end
		end)
	end
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
		if folder == arenaFolder then
			setSpawnShield(plr)
		end
	end
end

local function alivePlayers()
	local list = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		local c = plr.Character
		local hum = c and c:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			table.insert(list, plr)
		end
	end
	return list
end

local function aliveCount()
	return #alivePlayers()
end

local function broadcast(state, timeLeft, waveNumber)
	Remotes.RoundUpdate:FireAllClients({
		state = state,
		timeLeft = timeLeft,
		alive = aliveCount(),
		wave = waveNumber,
		totalWaves = #preset.WaveDurations,
	})
end

Players.PlayerAdded:Connect(function(plr)
	currency:onPlayerAdded(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.1)
		if roundActive then
			teleportPlayer(plr, arenaFolder)
			setSpawnShield(plr)
		else
			teleportPlayer(plr, lobbyFolder)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	currency:onPlayerRemoving(plr)
end)

Remotes.PurchaseUpgrade.OnServerEvent:Connect(function(player, payload)
	if typeof(payload) ~= "table" then return end
	local kind = payload.kind
	if kind then
		currency:purchase(player, kind)
	end
end)

local function intermission()
	roundActive = false
	local timeLeft = preset.IntermissionSeconds
	teleportAll(lobbyFolder)
	while timeLeft > 0 do
		broadcast("Intermission", timeLeft, 1)
		task.wait(1)
		timeLeft -= 1
	end
end

local function runWave(waveNumber)
	local duration = preset.WaveDurations[waveNumber]
	local baseSpeed = preset.WaveSpeeds[waveNumber]

	-- Warning phase
	local warning = preset.WarningSeconds
	tsunami:Warn()
	while warning > 0 do
		broadcast("Warning", warning, waveNumber)
		task.wait(1)
		warning -= 1
	end

	roundActive = true
	teleportAll(arenaFolder)
	luckyBlocks:SpawnBlocks(Content.LuckyBlock.SpawnCount, Content.Shop.BreakSpeed.baseHold)
	currency:startPerSecondLoop(function()
		return roundActive
	end)
	if waveNumber == 1 then
		currency:applyWalletBonus(Players:GetPlayers())
	end

	tsunami:Reset(roundIndex)
	water:Reset(CFrame.new(0, preset.WaterStartY, 0))
	tsunami:Start(baseSpeed)

	local waveMessage = Content.RoundText.Wave1
	if waveNumber == 2 then
		waveMessage = Content.RoundText.Wave2
	elseif waveNumber == 3 then
		waveMessage = Content.RoundText.Wave3
	end
	Remotes.Toast:FireAllClients({message = waveMessage})
	print(('[Round] start wave %d'):format(waveNumber))

	local timeLeft = duration
	local last = os.clock()
	while timeLeft > 0 and roundActive do
		local now = os.clock()
		local dt = now - last
		last = now

		if aliveCount() == 0 then
			roundActive = false
			break
		end

		tsunami:Step(dt)
		broadcast("Wave", timeLeft, waveNumber)
		task.wait(1)
		timeLeft -= 1
	end

	roundActive = false
	currency:stopPerSecondLoop()
	tsunami:Stop()
	luckyBlocks:Clear()

	if aliveCount() > 0 then
		local bonus = currency:awardSurvival(alivePlayers(), waveNumber)
		Remotes.Toast:FireAllClients({message = ("Wave %d complete! +%d coins"):format(waveNumber, bonus)})
		return true
	end

	Remotes.Toast:FireAllClients({message = Content.RoundText.AllEliminated})
	return false
end

math.randomseed(os.clock() * 1000000)

while true do
	intermission()
	local success = true
	for waveNumber = 1, #preset.WaveDurations do
		if not runWave(waveNumber) then
			success = false
			break
		end
		task.wait(2)
	end

	if success then
		Remotes.Toast:FireAllClients({message = Content.RoundText.Victory})
	end

	roundIndex += 1
end
