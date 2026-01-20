local ReplicatedStorage = game:GetService("ReplicatedStorage")

local mapAlias = workspace:FindFirstChild("Map")
if not mapAlias then
	mapAlias = Instance.new("ObjectValue")
	mapAlias.Name = "Map"
	mapAlias.Parent = workspace
	mapAlias.Value = workspace:FindFirstChild("LuckyWaveHeist_Map")
	warn("[LuckyBlockSpawner] Missing Map alias; created placeholder.")
end

local Map = workspace:WaitForChild("Map").Value

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

local spawnsFolder = workspace:FindFirstChild("LuckyBlockSpawns")
if not spawnsFolder then
	spawnsFolder = Instance.new("Folder")
	spawnsFolder.Name = "LuckyBlockSpawns"
	spawnsFolder.Parent = workspace
	warn("[LuckyBlockSpawner] Missing LuckyBlockSpawns; created placeholder.")
end

local blocksFolder = Map and Map:FindFirstChild("LuckyBlocks")
if blocksFolder and not blocksFolder:IsA("Folder") then
	blocksFolder:Destroy()
	blocksFolder = nil
end

if not blocksFolder then
	blocksFolder = Instance.new("Folder")
	blocksFolder.Name = "LuckyBlocks"
	blocksFolder.Parent = Map or workspace
end

local activeByMarker = {}
local activeBlocks = {}

local function getActiveCount()
	local count = 0
	for _ in pairs(activeBlocks) do
		count += 1
	end
	return count
end

local function getSpawnMarkers()
	local markers = {}
	for _, child in ipairs(spawnsFolder:GetChildren()) do
		if child:IsA("BasePart") then
			table.insert(markers, child)
		end
	end
	return markers
end

local function createBillboard(part)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "LuckyLabel"
	billboard.Size = UDim2.new(0, 140, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "Lucky Block"
	label.TextColor3 = Color3.fromRGB(255, 240, 120)
	label.TextStrokeTransparency = 0.5
	label.TextScaled = true
	label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
	label.Parent = billboard
end

local function createBlock(marker)
	local part = Instance.new("Part")
	part.Name = "LuckyBlock"
	part.Size = Vector3.new(4, 4, 4)
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 235, 80)
	part.CFrame = marker.CFrame + Vector3.new(0, 3, 0)
	part.Parent = blocksFolder
	part:SetAttribute("MarkerName", marker.Name)

	createBillboard(part)

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Break"
	prompt.ObjectText = "Lucky Block"
	prompt.HoldDuration = 0.2
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 12
	prompt.Parent = part

	prompt.Triggered:Connect(function(player)
		if not part.Parent then
			return
		end
		if part:GetAttribute("Collected") then
			return
		end

		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end

		local magnetLevel = Economy.GetUpgradeLevel(player, "Magnet")
		local allowedDistance = 10 + (magnetLevel * 3)
		if (root.Position - part.Position).Magnitude > allowedDistance then
			return
		end

		part:SetAttribute("Collected", true)
		Economy.AddCoins(player, 50)
		Remotes.Toast:FireClient(player, "+50", "Common")

		activeByMarker[marker.Name] = nil
		activeBlocks[part] = nil
		part:Destroy()
	end)

	activeByMarker[marker.Name] = part
	activeBlocks[part] = marker
end

local function cleanupBlocks()
	for part, marker in pairs(activeBlocks) do
		if not part.Parent then
			activeBlocks[part] = nil
			if marker then
				activeByMarker[marker.Name] = nil
			end
		end
	end
end

local function spawnUntil(targetCount)
	local markers = getSpawnMarkers()
	if #markers == 0 then
		return
	end

	local available = {}
	for _, marker in ipairs(markers) do
		if not activeByMarker[marker.Name] then
			table.insert(available, marker)
		end
	end

	while getActiveCount() < targetCount and #available > 0 do
		local index = math.random(1, #available)
		local marker = table.remove(available, index)
		createBlock(marker)
	end
end

print("[LuckyBlockSpawner] ready")

while true do
	cleanupBlocks()
	spawnUntil(20)
	task.wait(2)
end
