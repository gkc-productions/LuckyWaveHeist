local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ContentPack"))

local CurrencyService = {}
CurrencyService.__index = CurrencyService

local STORE_NAME = "LWH_Currency_v4"
local AUTOSAVE_INTERVAL = 60

function CurrencyService.new(remotes)
	local self = setmetatable({}, CurrencyService)
	self.remotes = remotes
	self.store = DataStoreService:GetDataStore(STORE_NAME)
	self.coins = {}
	self.upgrades = {}
	self.blockStats = {}
	self.rareStats = {}
	self.multiplier = {}
	self.running = true
	self.perSecond = false
	self:_startAutosave()
	return self
end

local function emptyUpgrades()
	return {
		LootMagnet = false,
		WalletExpansion = false,
		NimbleFeet = false,
		HighJumper = false,
		BreakEfficiency = false,
		DailyReroll = false,
	}
end

function CurrencyService:_send(player)
	self.remotes.CurrencyUpdate:FireClient(player, {
		coins = self.coins[player] or 0,
		upgrades = self.upgrades[player] or emptyUpgrades(),
	})
end

function CurrencyService:_load(player)
	if RunService:IsStudio() then
		self.coins[player] = 0
		self.upgrades[player] = emptyUpgrades()
		self:_send(player)
		return
	end

	local ok, data = pcall(function()
		return self.store:GetAsync("p_" .. player.UserId)
	end)
	if ok and data then
		self.coins[player] = data.coins or 0
		self.upgrades[player] = data.upgrades or emptyUpgrades()
	else
		self.coins[player] = 0
		self.upgrades[player] = emptyUpgrades()
	end
	self:_send(player)
end

function CurrencyService:_save(player)
	if not player or not player.Parent then return end
	if RunService:IsStudio() then return end
	local data = {
		coins = self.coins[player] or 0,
		upgrades = self.upgrades[player] or emptyUpgrades(),
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
	self.blockStats[player] = nil
	self.rareStats[player] = nil
	self.multiplier[player] = nil
end

function CurrencyService:hasUpgrade(player, name)
	local data = self.upgrades[player]
	return data and data[name] or false
end

function CurrencyService:addCoins(player, amount)
	if not player then return end
	local mult = self.multiplier[player] or 1
	self.coins[player] = (self.coins[player] or 0) + math.floor(amount * mult)
	self:_send(player)
end

function CurrencyService:setCoinMultiplier(player, mult)
	self.multiplier[player] = mult
end

function CurrencyService:clearTempMultipliers()
	for player in pairs(self.multiplier) do
		self.multiplier[player] = 1
	end
end

function CurrencyService:resetRoundStats(playersList)
	for _, plr in ipairs(playersList) do
		self.blockStats[plr] = 0
		self.rareStats[plr] = 0
		self.multiplier[plr] = 1
		if self:hasUpgrade(plr, "DailyReroll") then
			plr:SetAttribute("RerollToken", true)
		end
	end
end

function CurrencyService:recordBlockBreak(player, rarity)
	self.blockStats[player] = (self.blockStats[player] or 0) + 1
	if rarity == "Rare" or rarity == "Epic" then
		self.rareStats[player] = (self.rareStats[player] or 0) + 1
	end
end

function CurrencyService:awardWaveBonus(playersList, waveNumber)
	local base = Content.Economy.BaseSurvivalBonus
	local waveBonus = Content.Economy.WaveClearBonus * waveNumber
	for _, plr in ipairs(playersList) do
		local blocks = self.blockStats[plr] or 0
		local rares = self.rareStats[plr] or 0
		local total = base + (blocks * Content.Economy.BlockBreakBonus) + waveBonus + (rares * Content.Economy.RareItemBonus)
		self:addCoins(plr, total)
		self.remotes.Toast:FireClient(plr, {message = ("Wave bonus +%d"):format(total)})
	end
end

function CurrencyService:applyWalletBonus(playersList)
	for _, plr in ipairs(playersList) do
		if self:hasUpgrade(plr, "WalletExpansion") then
			self:addCoins(plr, Content.Shop.WalletExpansion.bonus)
		end
	end
end

function CurrencyService:applyMovementUpgrades(player, character)
	local hum = character:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local speed = hum.WalkSpeed
	local jump = hum.JumpPower
	if self:hasUpgrade(player, "NimbleFeet") then
		speed = speed * (1 + Content.Shop.NimbleFeet.speedPct)
	end
	if self:hasUpgrade(player, "HighJumper") then
		jump = jump * (1 + Content.Shop.HighJumper.jumpPct)
	end
	hum.WalkSpeed = speed
	hum.JumpPower = jump
end

function CurrencyService:startPerSecondLoop(isRoundActive)
	if self.perSecond then return end
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
	if self:hasUpgrade(player, upgradeName) then
		self.remotes.Toast:FireClient(player, {message = "Already owned"})
		return
	end
	local cost = def.cost
	if (self.coins[player] or 0) < cost then
		self.remotes.Toast:FireClient(player, {message = "Not enough coins"})
		return
	end
	self.coins[player] -= cost
	self.upgrades[player][upgradeName] = true
	self:_send(player)
	self.remotes.Toast:FireClient(player, {message = "Purchase successful"})

	if upgradeName == "NimbleFeet" or upgradeName == "HighJumper" then
		local char = player.Character
		if char then
			self:applyMovementUpgrades(player, char)
		end
	end
end

return CurrencyService
