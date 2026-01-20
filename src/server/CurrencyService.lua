local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ContentPack"))

local CurrencyService = {}
CurrencyService.__index = CurrencyService

local STORE_NAME = "LWH_Currency_v3"
local AUTOSAVE_INTERVAL = 60
local STUDIO_MODE = RunService:IsStudio() -- Disable DataStore in Studio

function CurrencyService.new(remotes)
	local self = setmetatable({}, CurrencyService)
	self.remotes = remotes
	self.store = not STUDIO_MODE and DataStoreService:GetDataStore(STORE_NAME) or nil
	self.coins = {}
	self.upgrades = {}
	self.lastPrint = {}
	self.multiplier = {}
	self.running = true
	self:_startAutosave()
	return self
end

local function getCost(def, level)
	return def.costs[level] or math.huge
end

function CurrencyService:getUpgradeLevel(player, name)
	local data = self.upgrades[player]
	return data and data[name] or 0
end

function CurrencyService:getUpgradeCost(player, name)
	local def = Content.Shop[name]
	if not def then return math.huge end
	local level = self:getUpgradeLevel(player, name)
	if level >= def.max then
		return math.huge
	end
	return getCost(def, level + 1)
end

function CurrencyService:_send(player)
	self.remotes.CurrencyUpdate:FireClient(player, {
		coins = self.coins[player] or 0,
		upgrades = self.upgrades[player] or {},
	})

	local now = os.clock()
	local last = self.lastPrint[player] or 0
	if now - last > 12 then
		self.lastPrint[player] = now
		print(('[Currency] %s -> %d coins'):format(player.Name, self.coins[player] or 0))
	end
end

function CurrencyService:_load(player)
	if not self.store then
		-- Studio mode: start with fresh data
		self.coins[player] = 0
		self.upgrades[player] = {}
		self:_send(player)
		return
	end
	local ok, data = pcall(function()
		return self.store:GetAsync("p_" .. player.UserId)
	end)
	if ok and data then
		self.coins[player] = data.coins or 0
		self.upgrades[player] = data.upgrades or {}
	else
		self.coins[player] = 0
		self.upgrades[player] = {}
	end
	self:_send(player)
end

function CurrencyService:_save(player)
	if not player or not player.Parent or not self.store then return end
	local data = {
		coins = self.coins[player] or 0,
		upgrades = self.upgrades[player] or {},
	}
	pcall(function()
		self.store:SetAsync("p_" .. player.UserId, data)
	end)
end

function CurrencyService:_startAutosave()
	task.spawn(function()
		while self.running do
			task.wait(AUTOSAVE_INTERVAL)
			for player in pairs(self.coins) do
				self:_save(player)
			end
		end
	end)
end

function CurrencyService:onPlayerAdded(player)
	self:_load(player)
	player.CharacterAdded:Connect(function(char)
		self:applyMovementUpgrades(player, char)
	end)
end

function CurrencyService:onPlayerRemoving(player)
	self:_save(player)
	self.coins[player] = nil
	self.upgrades[player] = nil
	self.lastPrint[player] = nil
	self.multiplier[player] = nil
end

function CurrencyService:addCoins(player, amount)
	if not player then return end
	local mult = self.multiplier[player] or 1
	self.coins[player] = (self.coins[player] or 0) + math.floor(amount * mult)
	self:_send(player)
end

function CurrencyService:setCoinMultiplier(player, mult, duration)
	self.multiplier[player] = mult
	player:SetAttribute("CoinMultiplierUntil", os.clock() + duration)
	task.delay(duration, function()
		if player and player.Parent then
			self.multiplier[player] = 1
		end
	end)
end

function CurrencyService:awardSurvival(playersList, waveNumber)
	local bonus = Content.Economy.SurvivalBonusPerWave * waveNumber
	for _, plr in ipairs(playersList) do
		self:addCoins(plr, bonus)
	end
	return bonus
end

function CurrencyService:applyWalletBonus(playersList)
	local def = Content.Shop.WalletExpansion
	for _, plr in ipairs(playersList) do
		local level = self:getUpgradeLevel(plr, "WalletExpansion")
		if level > 0 then
			self:addCoins(plr, def.bonusPerLevel * level)
		end
	end
end

function CurrencyService:applyMovementUpgrades(player, character)
	local hum = character:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local speedDef = Content.Shop.WalkSpeed
	local jumpDef = Content.Shop.JumpPower
	local speedLevel = self:getUpgradeLevel(player, "WalkSpeed")
	local jumpLevel = self:getUpgradeLevel(player, "JumpPower")
	hum.WalkSpeed = speedDef.base + (speedLevel * speedDef.perLevel)
	hum.JumpPower = jumpDef.base + (jumpLevel * jumpDef.perLevel)
end

function CurrencyService:startPerSecondLoop(isRoundActive)
	self.perSecond = true
	task.spawn(function()
		while self.perSecond and isRoundActive() do
			task.wait(1)
			for _, player in ipairs(Players:GetPlayers()) do
				local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					self:addCoins(player, Content.Economy.CoinsPerSecond)
				end
			end
		end
	end)
end

function CurrencyService:stopPerSecondLoop()
	self.perSecond = false
end

function CurrencyService:purchase(player, upgradeName)
	local def = Content.Shop[upgradeName]
	if not def then
		self.remotes.Toast:FireClient(player, {message = "Unknown upgrade"})
		return
	end
	local level = self:getUpgradeLevel(player, upgradeName)
	if level >= def.max then
		self.remotes.Toast:FireClient(player, {message = "Max level reached"})
		return
	end
	local cost = self:getUpgradeCost(player, upgradeName)
	if (self.coins[player] or 0) < cost then
		self.remotes.Toast:FireClient(player, {message = "Not enough coins"})
		return
	end
	self.coins[player] -= cost
	self.upgrades[player][upgradeName] = level + 1
	self:_send(player)
	self.remotes.Toast:FireClient(player, {message = "Purchase successful"})

	if upgradeName == "WalkSpeed" or upgradeName == "JumpPower" then
		local char = player.Character
		if char then
			self:applyMovementUpgrades(player, char)
		end
	end
end

return CurrencyService
