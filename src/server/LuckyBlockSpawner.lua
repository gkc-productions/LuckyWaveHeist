local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LuckyBlockSpawner = {}
LuckyBlockSpawner.__index = LuckyBlockSpawner

local BLOCK_COLOR = Color3.fromRGB(255, 230, 50)
local BLOCK_SIZE = Vector3.new(5, 5, 5)
local BLOCK_HEALTH = 3

local RARITY_COINS = {
	Common = 50,
	Rare = 100,
	Epic = 150,
	Legendary = 200,
}

local LOOT_TABLE = {
	{name = "Grapple Hook", rarity = "Rare", weight = 60, duration = 45},
	{name = "Rocket Boots", rarity = "Epic", weight = 35, duration = 30},
	{name = "Glider Wings", rarity = "Common", weight = 100, duration = 60},
	{name = "Dash Boots", rarity = "Rare", weight = 70, duration = 35},
	{name = "Wall Climb Gloves", rarity = "Rare", weight = 65, duration = 40},
	{name = "Hover Pack", rarity = "Epic", weight = 40, duration = 25},
	{name = "Feather Fall", rarity = "Common", weight = 90, duration = 50},
	{name = "Aegis Shield", rarity = "Epic", weight = 38, duration = 20},
	{name = "Immunity Frame", rarity = "Legendary", weight = 12, duration = 15},
	{name = "Revive Token", rarity = "Epic", weight = 32, duration = 0},
	{name = "Magnet Loot", rarity = "Rare", weight = 75, duration = 30},
	{name = "Radar Goggles", rarity = "Common", weight = 95, duration = 40},
	{name = "Platform Spawner", rarity = "Rare", weight = 70, duration = 45},
	{name = "Time Dilation", rarity = "Legendary", weight = 10, duration = 8},
	{name = "Golden Coin Doubler", rarity = "Rare", weight = 68, duration = 40},
	{name = "Party Popper", rarity = "Common", weight = 110, duration = 10},
	{name = "Rubber Ducky", rarity = "Common", weight = 105, duration = 60},
	{name = "Neon Aura", rarity = "Common", weight = 100, duration = 60},
	{name = "Risky Overdrive", rarity = "Rare", weight = 50, duration = 25},
	{name = "Curse of Chaos", rarity = "Rare", weight = 48, duration = 30},
	{name = "Grapple Booster v2", rarity = "Epic", weight = 36, duration = 35},
	{name = "Ramp Slide", rarity = "Rare", weight = 72, duration = 40},
	{name = "Blink Teleport", rarity = "Epic", weight = 34, duration = 20},
	{name = "Health Overshield", rarity = "Common", weight = 92, duration = 50},
	{name = "Double Jump Extender", rarity = "Common", weight = 98, duration = 45},
}

local function adjustedWeights(waveNumber)
	local multiplier = 1 + (0.1 * (waveNumber - 1))
	local items = {}
	for _, entry in ipairs(LOOT_TABLE) do
		local weight = entry.weight
		if entry.rarity ~= "Common" then
			weight = math.floor(weight * multiplier)
		end
		table.insert(items, {entry = entry, weight = weight})
	end
	return items
end

local function chooseLoot(waveNumber)
	local items = adjustedWeights(waveNumber)
	local total = 0
	for _, item in ipairs(items) do
		total += item.weight
	end
	local roll = math.random() * total
	local accum = 0
	for _, item in ipairs(items) do
		accum += item.weight
		if roll <= accum then
			return item.entry
		end
	end
	return LOOT_TABLE[1]
end

local function addHighlight(character, color, duration)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = color
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.Parent = character
	if duration > 0 then
		Debris:AddItem(highlight, duration)
	end
end

function LuckyBlockSpawner.new(remotes, currencyService, slowWaterCallback)
	local self = setmetatable({}, LuckyBlockSpawner)
	self.remotes = remotes
	self.currencyService = currencyService
	self.slowWaterCallback = slowWaterCallback
	self.blocks = {}
	self.magnetLoopRunning = false
	return self
end

function LuckyBlockSpawner:_makeBillboard(part)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 110, 0, 40)
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.2
	label.TextScaled = true
	label.Text = "Lucky Block"
	label.Parent = billboard
end

function LuckyBlockSpawner:_makeBlock(position)
	local part = Instance.new("Part")
	part.Name = "LuckyBlock"
	part.Size = BLOCK_SIZE
	part.Position = position
	part.Anchored = true
	part.CanCollide = true
	part.Color = BLOCK_COLOR
	part.Material = Enum.Material.Neon
	part:SetAttribute("Health", BLOCK_HEALTH)
	part:SetAttribute("LastMagnet", 0)

	self:_makeBillboard(part)

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Break"
	prompt.ObjectText = "Lucky Block"
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 14
	prompt.Parent = part

	prompt.Triggered:Connect(function(player)
		self:_onPrompt(player, part)
	end)

	part.Parent = workspace
	return part
end

function LuckyBlockSpawner:_onPrompt(player, part)
	if not part or not part.Parent then return end
	local health = part:GetAttribute("Health") or BLOCK_HEALTH
	health -= 1
	part:SetAttribute("Health", health)
	if health > 0 then
		return
	end

	local loot = chooseLoot(self.waveNumber or 1)
	local rarityCoins = RARITY_COINS[loot.rarity] or 50

	self.currencyService:addCoins(player, rarityCoins)
	self:giveReward(player, loot)

	self.remotes.LuckyBlockFX:FireAllClients({position = part.Position, rarity = loot.rarity})
	self.remotes.Toast:FireClient(player, {message = ("You got: %s"):format(loot.name), rarity = loot.rarity})

	part:Destroy()
end

function LuckyBlockSpawner:_giveTool(player, name)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then return nil end
	local existing = backpack:FindFirstChild(name)
	if existing then existing:Destroy() end
	local tool = Instance.new("Tool")
	tool.RequiresHandle = false
	tool.Name = name
	tool:SetAttribute("RoundTemp", true)
	tool.Parent = backpack
	return tool
end

function LuckyBlockSpawner:_giveGrapple(player, boosted)
	local tool = self:_giveTool(player, "Grapple")
	if not tool then return end
	tool.Activated:Connect(function()
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local range = boosted and 80 or 50
		local direction = hrp.CFrame.LookVector
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {char}
		local result = workspace:Raycast(hrp.Position, direction * range, params)
		local pos = result and result.Position or (hrp.Position + direction * (range * 0.6))
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		local speed = boosted and 180 or 120
		bv.Velocity = (pos - hrp.Position).Unit * speed
		bv.Parent = hrp
		Debris:AddItem(bv, 0.25)
	end)
end

function LuckyBlockSpawner:_givePlatformSpawner(player)
	local tool = self:_giveTool(player, "PlatformSpawner")
	if not tool then return end
	tool.Activated:Connect(function()
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local pad = Instance.new("Part")
		pad.Size = Vector3.new(6, 1.5, 6)
		pad.Color = Color3.fromRGB(120, 120, 120)
		pad.Material = Enum.Material.Metal
		pad.Anchored = true
		pad.CanCollide = true
		pad.CFrame = hrp.CFrame * CFrame.new(0, -3, -8)
		pad:SetAttribute("RoundTemp", true)
		pad.Parent = workspace
		Debris:AddItem(pad, 30)
	end)
end

function LuckyBlockSpawner:_giveBlink(player)
	local tool = self:_giveTool(player, "BlinkTeleport")
	if not tool then return end
	local last = 0
	local charges = 5
	tool.Activated:Connect(function()
		if charges <= 0 then return end
		local now = os.clock()
		if now - last < 3 then return end
		last = now
		charges -= 1
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local target = hrp.CFrame + (hrp.CFrame.LookVector * 30)
		hrp.CFrame = target
	end)
end

function LuckyBlockSpawner:_applyTimedStat(player, stat, multiplier, duration)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local original = hum[stat]
	hum[stat] = original * multiplier
	task.delay(duration, function()
		if hum and hum.Parent then
			hum[stat] = original
		end
	end)
end

function LuckyBlockSpawner:_applyHealthBonus(player, amount, duration)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local originalMax = hum.MaxHealth
	hum.MaxHealth = originalMax + amount
	hum.Health = math.min(hum.Health + amount, hum.MaxHealth)
	task.delay(duration, function()
		if hum and hum.Parent then
			hum.MaxHealth = originalMax
			hum.Health = math.min(hum.Health, hum.MaxHealth)
		end
	end)
end

function LuckyBlockSpawner:_chaosLoop(player, duration)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local endTime = os.clock() + duration
	while os.clock() < endTime do
		task.wait(5)
		local roll = math.random()
		if roll <= 0.5 then
			self:_applyTimedStat(player, "WalkSpeed", 1.3, 2)
		elseif roll <= 0.8 then
			local original = hum.WalkSpeed
			hum.WalkSpeed = 0
			task.delay(1, function()
				if hum and hum.Parent then
					hum.WalkSpeed = original
				end
			end)
		else
			hum.Health = math.min(hum.Health + 50, hum.MaxHealth)
		end
	end
end

function LuckyBlockSpawner:giveReward(player, loot)
	local duration = loot.duration

	if loot.name == "Grapple Hook" then
		self:_giveGrapple(player, false)
	elseif loot.name == "Rocket Boots" then
		self:_applyTimedStat(player, "JumpPower", 1.8, duration)
	elseif loot.name == "Glider Wings" then
		player:SetAttribute("GlideUntil", os.clock() + duration)
	elseif loot.name == "Dash Boots" then
		player:SetAttribute("DashBootsUntil", os.clock() + duration)
	elseif loot.name == "Wall Climb Gloves" then
		player:SetAttribute("WallClimbUntil", os.clock() + duration)
	elseif loot.name == "Hover Pack" then
		self:_applyTimedStat(player, "JumpPower", 1.5, duration)
	elseif loot.name == "Feather Fall" then
		player:SetAttribute("FeatherFallUntil", os.clock() + duration)
	elseif loot.name == "Aegis Shield" then
		player:SetAttribute("ShieldHP", 300)
	elseif loot.name == "Immunity Frame" then
		player:SetAttribute("InvulnUntil", os.clock() + 5)
	elseif loot.name == "Revive Token" then
		player:SetAttribute("ReviveToken", true)
	elseif loot.name == "Magnet Loot" then
		player:SetAttribute("MagnetUntil", os.clock() + duration)
	elseif loot.name == "Radar Goggles" then
		for _, other in ipairs(Players:GetPlayers()) do
			if other.Character then
				addHighlight(other.Character, Color3.fromRGB(80, 200, 120), duration)
			end
		end
	elseif loot.name == "Platform Spawner" then
		self:_givePlatformSpawner(player)
	elseif loot.name == "Time Dilation" then
		if self.slowWaterCallback then
			self.slowWaterCallback(duration)
		end
	elseif loot.name == "Golden Coin Doubler" then
		self.currencyService:setCoinMultiplier(player, 2, duration)
	elseif loot.name == "Party Popper" then
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local emitter = Instance.new("ParticleEmitter")
			emitter.Rate = 120
			emitter.Lifetime = NumberRange.new(1, 1.5)
			emitter.Speed = NumberRange.new(6, 10)
			emitter.Parent = hrp
			Debris:AddItem(emitter, 2)
		end
	elseif loot.name == "Rubber Ducky" then
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local duck = Instance.new("Part")
			duck.Size = Vector3.new(2, 2, 2)
			duck.Shape = Enum.PartType.Ball
			duck.Color = Color3.fromRGB(255, 220, 60)
			duck.Material = Enum.Material.Neon
			duck.CanCollide = false
			duck.CFrame = hrp.CFrame * CFrame.new(2, 2, 0)
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = duck
			weld.Part1 = hrp
			weld.Parent = duck
			duck.Parent = workspace
			Debris:AddItem(duck, duration)
		end
	elseif loot.name == "Neon Aura" then
		if player.Character then
			addHighlight(player.Character, Color3.fromRGB(math.random(80, 255), math.random(80, 255), math.random(80, 255)), duration)
		end
	elseif loot.name == "Risky Overdrive" then
		self.currencyService:setCoinMultiplier(player, 2, duration)
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			local original = hum.MaxHealth
			hum.MaxHealth = math.max(50, math.floor(original * 0.85))
			hum.Health = math.min(hum.Health, hum.MaxHealth)
			task.delay(duration, function()
				if hum and hum.Parent then
					hum.MaxHealth = original
					hum.Health = math.min(hum.Health, hum.MaxHealth)
				end
			end)
		end
	elseif loot.name == "Curse of Chaos" then
		task.spawn(function()
			self:_chaosLoop(player, duration)
		end)
	elseif loot.name == "Grapple Booster v2" then
		self:_giveGrapple(player, true)
	elseif loot.name == "Ramp Slide" then
		self:_applyTimedStat(player, "WalkSpeed", 1.2, duration)
	elseif loot.name == "Blink Teleport" then
		self:_giveBlink(player)
	elseif loot.name == "Health Overshield" then
		self:_applyHealthBonus(player, 50, duration)
	elseif loot.name == "Double Jump Extender" then
		player:SetAttribute("ExtraJumps", 2)
		task.delay(duration, function()
			player:SetAttribute("ExtraJumps", nil)
		end)
	end
end

function LuckyBlockSpawner:_magnetRadius(player)
	local upgradeLevel = self.currencyService:getUpgradeLevel(player, "LootMagnet")
	local base = 12
	local mult = 1 + (0.2 * upgradeLevel)
	local lootMagnetUntil = player:GetAttribute("MagnetUntil")
	if lootMagnetUntil and os.clock() < lootMagnetUntil then
		mult += 0.5
	end
	return base * mult
end

function LuckyBlockSpawner:_startMagnetLoop()
	if self.magnetLoopRunning then return end
	self.magnetLoopRunning = true

	task.spawn(function()
		while self.magnetLoopRunning do
			task.wait(0.5)
			for _, player in ipairs(Players:GetPlayers()) do
				local radius = self:_magnetRadius(player)
				if radius > 12 then
					local char = player.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					if hrp then
						for block in pairs(self.blocks) do
							if block and block.Parent then
								local dist = (block.Position - hrp.Position).Magnitude
								if dist <= radius then
									local last = block:GetAttribute("LastMagnet") or 0
									if os.clock() - last >= 0.5 then
										block:SetAttribute("LastMagnet", os.clock())
										self:_onPrompt(player, block)
									end
								end
							end
						end
					end
				end
			end
		end
	end)
end

function LuckyBlockSpawner:spawnBlocks(waveNumber, count)
	self:clear()
	self.waveNumber = waveNumber

	local attempts = 0
	local spawned = 0
	while spawned < count and attempts < count * 5 do
		attempts += 1
		local x = (math.random() - 0.5) * 200
		local z = (math.random() - 0.5) * 200
		local origin = Vector3.new(x, 200, z)
		local result = workspace:Raycast(origin, Vector3.new(0, -300, 0))
		local y = 10
		if result then
			y = result.Position.Y + 6
		end
		local pos = Vector3.new(x, y, z)
		local block = self:_makeBlock(pos)
		self.blocks[block] = true
		spawned += 1
	end

	self:_startMagnetLoop()
	print(('[LuckyBlocks] Spawned %d blocks'):format(spawned))
end

function LuckyBlockSpawner:clear()
	for block in pairs(self.blocks) do
		if block and block.Parent then
			block:Destroy()
		end
	end
	self.blocks = {}
	self.magnetLoopRunning = false
end

return LuckyBlockSpawner
