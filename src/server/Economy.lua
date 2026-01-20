local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local store = DataStoreService:GetDataStore("LuckyWaveHeist_v1")

local MAX_LEVEL = 5

local DEFAULT_UPGRADES = {
	Magnet = 0,
	Wallet = 0,
	Speed = 0,
}

local BASE_COSTS = {
	Magnet = 500,
	Wallet = 1000,
	Speed = 1500,
}

local WALLET_BONUS_PER_LEVEL = 25

local dataByUserId = {}

local function deepCopyUpgrades()
	return {
		Magnet = DEFAULT_UPGRADES.Magnet,
		Wallet = DEFAULT_UPGRADES.Wallet,
		Speed = DEFAULT_UPGRADES.Speed,
	}
end

local function normalizeData(data)
	local normalized = {
		Coins = 0,
		Upgrades = deepCopyUpgrades(),
	}

	if type(data) == "table" then
		if type(data.Coins) == "number" then
			normalized.Coins = math.max(0, math.floor(data.Coins))
		end
		if type(data.Upgrades) == "table" then
			for name, _ in pairs(DEFAULT_UPGRADES) do
				local level = data.Upgrades[name]
				if type(level) == "number" then
					normalized.Upgrades[name] = math.clamp(math.floor(level), 0, MAX_LEVEL)
				end
			end
		end
	end

	return normalized
end

local Economy = {}

function Economy.Load(player)
	local key = tostring(player.UserId)
	local success, data = pcall(function()
		return store:GetAsync(key)
	end)

	if not success then
		data = nil
	end

	dataByUserId[player.UserId] = normalizeData(data)
	Remotes.CoinsUpdate:FireClient(player, dataByUserId[player.UserId].Coins)
end

function Economy.Save(player)
	local data = dataByUserId[player.UserId]
	if not data then
		return
	end

	local key = tostring(player.UserId)
	pcall(function()
		store:SetAsync(key, data)
	end)
end

function Economy.GetData(player)
	return dataByUserId[player.UserId]
end

function Economy.GetCoins(player)
	local data = dataByUserId[player.UserId]
	return data and data.Coins or 0
end

function Economy.AddCoins(player, amount)
	local data = dataByUserId[player.UserId]
	if not data then
		return 0
	end

	data.Coins = math.max(0, data.Coins + math.floor(amount))
	Remotes.CoinsUpdate:FireClient(player, data.Coins)
	return data.Coins
end

function Economy.GetUpgradeLevel(player, upgradeName)
	local data = dataByUserId[player.UserId]
	if not data then
		return 0
	end
	return data.Upgrades[upgradeName] or 0
end

function Economy.GetUpgradeCost(upgradeName, level)
	local base = BASE_COSTS[upgradeName]
	if not base then
		return nil
	end
	if level >= MAX_LEVEL then
		return nil
	end
	return base * (2 ^ level)
end

function Economy.PurchaseUpgrade(player, upgradeName)
	local data = dataByUserId[player.UserId]
	if not data then
		return false, "NoData"
	end

	if BASE_COSTS[upgradeName] == nil then
		return false, "UnknownUpgrade"
	end

	local currentLevel = data.Upgrades[upgradeName] or 0
	if currentLevel >= MAX_LEVEL then
		return false, "MaxLevel"
	end

	local cost = Economy.GetUpgradeCost(upgradeName, currentLevel)
	if not cost then
		return false, "InvalidCost"
	end

	if data.Coins < cost then
		return false, "NotEnoughCoins"
	end

	data.Coins -= cost
	data.Upgrades[upgradeName] = currentLevel + 1
	Remotes.CoinsUpdate:FireClient(player, data.Coins)

	return true, data.Upgrades[upgradeName], data.Coins, cost
end

function Economy.ApplyWalletBonus(player)
	local level = Economy.GetUpgradeLevel(player, "Wallet")
	if level <= 0 then
		return
	end
	Economy.AddCoins(player, level * WALLET_BONUS_PER_LEVEL)
end

return Economy
