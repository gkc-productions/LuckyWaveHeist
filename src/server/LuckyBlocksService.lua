local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ContentPack"))

local LuckyBlocksService = {}
LuckyBlocksService.__index = LuckyBlocksService

local LootConfig = Content.LuckyBlock
local Toasts = Content.Toasts

local function chooseItem()
	local total = 0
	for _, entry in ipairs(LootConfig.LootTable) do
		total += entry.weight
	end
	local roll = math.random() * total
	local accum = 0
	for _, entry in ipairs(LootConfig.LootTable) do
		accum += entry.weight
		if roll <= accum then
			return entry
		end
	end
	return LootConfig.LootTable[1]
end

local function rarityToast(tier)
	return Toasts[tier] or Toasts.Common
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
	local def = Content.Shop.LootMagnet
	local level = 0
	if self.currency and self.currency.getUpgradeLevel then
		level = self.currency:getUpgradeLevel(player, "LootMagnet")
	end
	local radius = 0
	if level > 0 then
		local t = math.min(1, level / def.max)
		radius = def.baseRadius + (def.maxRadius - def.baseRadius) * t
	end
	local untilTime = player:GetAttribute("MagnetUntil")
	if untilTime and os.clock() < untilTime then
		radius = math.max(radius, def.maxRadius)
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

function LuckyBlocksService:_makeBlock(position, holdDuration)
	local part = Instance.new("Part")
	part.Name = "LuckyBlock"
	part.Size = Vector3.new(5, 5, 5)
	part.Position = position
	part.Anchored = true
	part.CanCollide = true
	part.Color = Color3.fromRGB(255, 230, 50)
	part.Material = Enum.Material.Neon
	part:SetAttribute("Health", LootConfig.BlockHealth)

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 110, 0, 40)
	billboard.MaxDistance = 30
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

function LuckyBlocksService:_onPrompt(player, part)
	if not part or not part.Parent then return end
	local health = part:GetAttribute("Health") or LootConfig.BlockHealth
	health -= 1
	part:SetAttribute("Health", health)
	if health > 0 then
		return
	end

	local loot = chooseItem()
	local coins = LootConfig.RarityCoins[loot.tier] or 50
	self.currency:addCoins(player, coins)
	self:_applyReward(player, loot)

	self.remotes.LuckyBlockFX:FireAllClients({position = part.Position, rarity = loot.tier})
	self.remotes.Toast:FireClient(player, {message = rarityToast(loot.tier), rarity = loot.tier})
	self.remotes.Toast:FireClient(player, {message = ("You got: %s"):format(loot.item), rarity = loot.tier})

	part:Destroy()
end

function LuckyBlocksService:_applyReward(player, loot)
	local item = loot.item
	local duration = loot.duration or 0

	if item == "Coin Doubler" then
		self.currency:setCoinMultiplier(player, 2, duration)
		return
	end

	if item == "Risky Overdrive" then
		self.currency:setCoinMultiplier(player, 2, duration)
		return
	end

	if item == "Time Slow" then
		if self.tsunami then
			self.tsunami:SetSlow(0.3, duration)
		end
		return
	end

	if item == "Aegis Shield" then
		player:SetAttribute("ShieldHP", 300)
		return
	end

	if item == "Immunity Window" then
		player:SetAttribute("InvulnUntil", os.clock() + 5)
		return
	end

	if item == "Revive Token" then
		player:SetAttribute("ReviveToken", true)
		return
	end

	if item == "Coin Magnet" then
		local untilTime = os.clock() + duration
		player:SetAttribute("MagnetUntil", untilTime)
		task.delay(duration, function()
			if player and player.Parent then
				local current = player:GetAttribute("MagnetUntil")
				if current and current <= os.clock() then
					player:SetAttribute("MagnetUntil", nil)
				end
			end
		end)
		return
	end

	if item == "Radar Goggles" then
		for _, other in ipairs(Players:GetPlayers()) do
			if other.Character then
				local highlight = Instance.new("Highlight")
				highlight.FillColor = Color3.fromRGB(80, 200, 120)
				highlight.OutlineColor = Color3.new(1, 1, 1)
				highlight.Parent = other.Character
				Debris:AddItem(highlight, duration)
			end
		end
		return
	end

	if item == "Party Popper" then
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
		return
	end

	if item == "Rubber Ducky" then
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
		return
	end

	if item == "Neon Aura" then
		if player.Character then
			local highlight = Instance.new("Highlight")
			highlight.FillColor = Color3.fromRGB(math.random(80, 255), math.random(80, 255), math.random(80, 255))
			highlight.OutlineColor = Color3.new(1, 1, 1)
			highlight.Parent = player.Character
			Debris:AddItem(highlight, duration)
		end
		return
	end

	-- Movement buffs MVP
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if item == "Rocket Boots" then
		local original = hum.JumpPower
		hum.JumpPower = original * 1.8
		task.delay(duration, function()
			if hum and hum.Parent then
				hum.JumpPower = original
			end
		end)
		return
	end

	if item == "Dash Boots" or item == "Speed Ramp Boost" then
		local original = hum.WalkSpeed
		hum.WalkSpeed = original * 1.2
		task.delay(duration, function()
			if hum and hum.Parent then
				hum.WalkSpeed = original
			end
		end)
		return
	end

	if item == "Health Overshield" then
		local originalMax = hum.MaxHealth
		hum.MaxHealth = math.min(200, originalMax + 50)
		hum.Health = math.min(hum.Health + 50, hum.MaxHealth)
		task.delay(duration, function()
			if hum and hum.Parent then
				hum.MaxHealth = originalMax
				hum.Health = math.min(hum.Health, hum.MaxHealth)
			end
		end)
		return
	end

	if item == "Double Jump Extender" then
		player:SetAttribute("ExtraJumps", 2)
		task.delay(duration, function()
			player:SetAttribute("ExtraJumps", nil)
		end)
		return
	end
end

function LuckyBlocksService:SpawnBlocks(count, holdDuration)
	self:Clear()
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
		local block = self:_makeBlock(pos, holdDuration)
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
