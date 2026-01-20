local Players = game:GetService("Players")
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
local Economy = require(script.Parent:WaitForChild("Economy"))

local function onPlayerAdded(player)
	Economy.Load(player)
end

local function onPlayerRemoving(player)
	Economy.Save(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in ipairs(Players:GetPlayers()) do
	Economy.Load(player)
end

Remotes.PurchaseUpgrade.OnServerInvoke = function(player, upgradeName)
	if type(upgradeName) ~= "string" then
		return false, "InvalidUpgrade"
	end

	local normalized = string.upper(string.sub(upgradeName, 1, 1)) .. string.lower(string.sub(upgradeName, 2))
	local success, result1, result2, result3 = Economy.PurchaseUpgrade(player, normalized)
	if not success then
		return false, result1
	end

	Economy.Save(player)
	return true, normalized, result1, result2, result3
end

while true do
	task.wait(60)
	for _, player in ipairs(Players:GetPlayers()) do
		Economy.Save(player)
	end
end
