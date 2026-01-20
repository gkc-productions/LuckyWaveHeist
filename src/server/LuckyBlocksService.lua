local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ContentPack"))

local LuckyBlocksService = {}
LuckyBlocksService.__index = LuckyBlocksService

local LootConfig = Content.Loot

local function rollRarity()
	local total = 0
	for _, weight in pairs(LootConfig.RarityWeights) do
		total += weight
	end
	local roll = math.random() * total
	local accum = 0
	for rarity, weight in pairs(LootConfig.RarityWeights) do
		accum += weight
		if roll <= accum then
			return rarity
		end
	end
	return "Common"
end

local function randomItem(rarity)
	local list = LootConfig.Items[rarity] or LootConfig.Items.Common
	return list[math.random(1, #list)]
end

function LuckyBlocksService.new(remotes, currencyService, tsunamiService)
	local self = setmetatable({}, LuckyBlocksService)
	self.remotes = remotes
	self.currency = currencyService
	self.tsunami = tsunamiService
	self.blocks = {}
	self.magnetActive = false
	return self
end

function LuckyBlocksService:_getMagnetRadius(player)
	local radius = 0
	if self.currency and self.currency.hasUpgrade and self.currency:hasUpgrade(player, "LootMagnet") then
		radius = Content.Shop.LootMagnet.radius
	end
	local untilTime = player:GetAttribute("MagnetUntil")
	if untilTime and os.clock() < untilTime then
		local magnetRadius = player:GetAttribute("MagnetRadius") or 50
		radius = math.max(radius, magnetRadius)
	end
	return radius
end

function LuckyBlocksService:_startMagnetLoop()
	if self.magnetActive then return end
	self.magnetActive = true
	task.spawn(function()
		while self.magnetActive do
			task.wait(0.25)
			if next(self.blocks) == nil then
				continue
			end
			for _, player in ipairs(Players:GetPlayers()) do
				local char = player.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local radius = self:_getMagnetRadius(player)
					if radius > 0 then
						for block in pairs(self.blocks) do
							if block and block.Parent then
								local offset = hrp.Position - block.Position
								local dist = offset.Magnitude
								if dist > 0 and dist <= radius then
									local step = math.min(4, dist * 0.2)
									local target = block.Position + offset.Unit * step
									block.Position = Vector3.new(target.X, block.Position.Y, target.Z)
								end
							end
						end
					end
				end
			end
		end
	end)
end

function LuckyBlocksService:_makeBlock(position, rarity, holdDuration)
	local part = Instance.new("Part")
	part.Name = "LuckyBlock"
	part.Size = Vector3.new(2, 2, 2)
	part.Position = position
	part.Anchored = true
	part.CanCollide = true
	part.Color = LootConfig.RarityColors[rarity] or Color3.fromRGB(255, 200, 80)
	part.Material = Enum.Material.Neon
	part:SetAttribute("Health", LootConfig.BlockHits[rarity] or 3)
	part:SetAttribute("Rarity", rarity)

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 120, 0, 32)
	billboard.MaxDistance = 30
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = part.Color
	label.TextStrokeTransparency = 0.3
	label.TextScaled = true
	label.Text = "Lucky Block"
	label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
	label.Parent = billboard

	local glow = Instance.new("ParticleEmitter")
	glow.Rate = 6
	glow.Lifetime = NumberRange.new(0.6, 1)
	glow.Speed = NumberRange.new(0.4, 0.8)
	glow.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(1, 0),
	})
	glow.Color = ColorSequence.new(part.Color)
	glow.Parent = part

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Break"
	prompt.ObjectText = "Lucky Block"
	prompt.HoldDuration = holdDuration
	prompt.MaxActivationDistance = 14
	prompt.Parent = part

	prompt.Triggered:Connect(function(player)
		self:_onPrompt(player, part)
	end)

	part.Parent = workspace
	return part
end

function LuckyBlocksService:_applySpeed(player, multiplier, duration)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local original = hum.WalkSpeed
	hum.WalkSpeed = original * multiplier
	task.delay(duration, function()
		if hum and hum.Parent then
			hum.WalkSpeed = original
		end
	end)
end

function LuckyBlocksService:_applyJump(player, multiplier, duration)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local original = hum.JumpPower
	hum.JumpPower = original * multiplier
	task.delay(duration, function()
		if hum and hum.Parent then
			hum.JumpPower = original
		end
	end)
end

function LuckyBlocksService:_applyMobility(player, speedMult, jumpMult, duration)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local originalSpeed = hum.WalkSpeed
	local originalJump = hum.JumpPower
	hum.WalkSpeed = originalSpeed * speedMult
	hum.JumpPower = originalJump * jumpMult
	task.delay(duration, function()
		if hum and hum.Parent then
			hum.WalkSpeed = originalSpeed
			hum.JumpPower = originalJump
		end
	end)
end

function LuckyBlocksService:_onPrompt(player, part)
	if not part or not part.Parent then return end
	local damage = 1
	if self.currency and self.currency.hasUpgrade and self.currency:hasUpgrade(player, "BreakEfficiency") then
		damage += Content.Shop.BreakEfficiency.reduceHits
	end
	local health = part:GetAttribute("Health") or 3
	health -= damage
	part:SetAttribute("Health", health)
	if health > 0 then
		return
	end

	local rarity = part:GetAttribute("Rarity") or rollRarity()
	local loot = randomItem(rarity)

	local hasReroll = player:GetAttribute("RerollToken")
	if hasReroll then
		player:SetAttribute("RerollToken", nil)
		loot = randomItem(rarity)
	end

	local doubleLoot = player:GetAttribute("DoubleLootTicket")
	if doubleLoot then
		player:SetAttribute("DoubleLootTicket", nil)
	end

	self.currency:recordBlockBreak(player, rarity)
	self.currency:addCoins(player, Content.Economy.BlockBreakBonus)

	self:_applyReward(player, loot, rarity, doubleLoot)

	self.remotes.LuckyBlockFX:FireAllClients({position = part.Position, rarity = rarity})
	self.remotes.Toast:FireClient(player, {message = ("You got: %s"):format(loot.name), rarity = rarity})

	local pop = Instance.new("Sound")
	pop.SoundId = "rbxassetid://138087017"
	pop.Volume = 0.6
	pop.Parent = part
	pop:Play()
	Debris:AddItem(pop, 2)

	part:Destroy()
end

function LuckyBlocksService:_applyReward(player, loot, rarity, doubleLoot)
	local kind = loot.type

	if kind == "Coins" then
		local amount = loot.amount
		if doubleLoot then
			amount *= 2
		end
		self.currency:addCoins(player, amount)
		return
	end

	if kind == "DoubleLoot" then
		player:SetAttribute("DoubleLootTicket", true)
		return
	end

	if kind == "Speed" then
		self:_applySpeed(player, loot.multiplier, loot.duration)
		return
	end

	if kind == "Jump" then
		self:_applyJump(player, loot.multiplier, loot.duration)
		return
	end

	if kind == "Shield" then
		player:SetAttribute("ShieldHP", loot.hits)
		return
	end

	if kind == "Magnet" then
		player:SetAttribute("MagnetUntil", os.clock() + loot.duration)
		player:SetAttribute("MagnetRadius", loot.radius)
		return
	end

	if kind == "Reroll" then
		player:SetAttribute("RerollToken", true)
		return
	end

	if kind == "TimeSlow" then
		if self.tsunami then
			self.tsunami:SetSlow(loot.slow, loot.duration)
		end
		return
	end

	if kind == "CoinMultiplier" then
		self.currency:setCoinMultiplier(player, loot.multiplier)
		return
	end

	if kind == "Invuln" then
		player:SetAttribute("InvulnUntil", os.clock() + loot.duration)
		return
	end

	if kind == "Mobility" then
		self:_applyMobility(player, loot.speed, loot.jump, loot.duration)
		return
	end

	if kind == "TeamSpeed" then
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		for _, other in ipairs(Players:GetPlayers()) do
			local otherChar = other.Character
			local otherHrp = otherChar and otherChar:FindFirstChild("HumanoidRootPart")
			if otherHrp and (otherHrp.Position - hrp.Position).Magnitude <= loot.radius then
				self:_applySpeed(other, loot.multiplier, loot.duration)
			end
		end
		return
	end
end

function LuckyBlocksService:SpawnBlocks(count)
	self:Clear()
	local attempts = 0
	local spawned = 0
	while spawned < count and attempts < count * 6 do
		attempts += 1
		local x = (math.random() - 0.5) * 200
		local z = (math.random() - 0.5) * 200
		local origin = Vector3.new(x, 200, z)
		local result = workspace:Raycast(origin, Vector3.new(0, -300, 0))
		local y = 10
		if result then
			y = result.Position.Y + 4
		end
		local pos = Vector3.new(x, y, z)
		local rarity = rollRarity()
		local block = self:_makeBlock(pos, rarity, 0.3)
		self.blocks[block] = true
		spawned += 1
	end
	print(('[LuckyBlocks] Spawned %d blocks'):format(spawned))
	self:_startMagnetLoop()
end

function LuckyBlocksService:Clear()
	for block in pairs(self.blocks) do
		if block and block.Parent then
			block:Destroy()
		end
	end
	self.blocks = {}
	self.magnetActive = false
end

return LuckyBlocksService
