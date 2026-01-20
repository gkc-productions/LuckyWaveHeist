local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if remotesFolder and not remotesFolder:IsA("Folder") then
	remotesFolder:Destroy()
	remotesFolder = nil
end

if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
end

local function getRemoteEvent(name)
	local remote = remotesFolder:FindFirstChild(name)
	if remote and not remote:IsA("RemoteEvent") then
		remote:Destroy()
		remote = nil
	end
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = remotesFolder
	end
	return remote
end

return {
	RoundUpdate = getRemoteEvent("RoundUpdate"),
	CoinsUpdate = getRemoteEvent("CoinsUpdate"),
	Toast = getRemoteEvent("Toast"),
	PurchaseUpgrade = getRemoteEvent("PurchaseUpgrade"),
}
