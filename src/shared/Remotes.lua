local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create or get the Remotes folder
local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
end

-- Create RemoteEvents
local function getOrCreateRemote(name: string)
	local r = remotesFolder:FindFirstChild(name)
	if not r then
		r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = remotesFolder
	end
	return r
end

return {
	RoundUpdate = getOrCreateRemote("RoundUpdate"),
}
