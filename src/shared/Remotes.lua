local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folder to hold RemoteEvents
local folder = ReplicatedStorage:FindFirstChild("Remotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "Remotes"
	folder.Parent = ReplicatedStorage
end

local function getOrCreateRemote(name: string)
	local r = folder:FindFirstChild(name)
	if not r then
		r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = folder
	end
	return r
end

return {
	RoundUpdate = getOrCreateRemote("RoundUpdate"),
}
