local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Canonical remotes folder at ReplicatedStorage.Remotes (capital R)
local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
	print("[Remotes] Created ReplicatedStorage.Remotes")
end

local function getOrCreateRemote(name: string)
	local remote = remotesFolder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = remotesFolder
		print(('[Remotes] Created RemoteEvent %s'):format(name))
	end
	return remote
end

return {
	RemotesFolder = remotesFolder,
	RoundUpdate = getOrCreateRemote("RoundUpdate"),
	Toast = getOrCreateRemote("Toast"),
	CurrencyUpdate = getOrCreateRemote("CurrencyUpdate"),
	Tutorial = getOrCreateRemote("Tutorial"),
	PurchaseUpgrade = getOrCreateRemote("PurchaseUpgrade"),
	LuckyBlockFX = getOrCreateRemote("LuckyBlockFX"),
}
