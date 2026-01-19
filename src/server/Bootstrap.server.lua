-- World bootstrapper: ensures basic workspace objects and remotes exist

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Content = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ContentPack"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local colors = {
	Navy = Color3.fromRGB(11, 16, 32),
	Teal = Color3.fromRGB(25, 211, 197),
	Yellow = Color3.fromRGB(255, 213, 74),
	Steel = Color3.fromRGB(43, 47, 58),
	Red = Color3.fromRGB(255, 59, 59),
}

local function ensureFolder(parent, name)
	local existing = parent:FindFirstChild(name)
	if existing then
		return existing, false
	end
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	print(('[Bootstrap] Created folder %s.%s'):format(parent.Name, name))
	return folder, true
end

local function ensureSpawn(folder, name, position)
	local existing = folder:FindFirstChild(name)
	if existing and existing:IsA("SpawnLocation") then
		return existing, false
	end
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = name
	spawn.Position = position
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Anchored = true
	spawn.CanCollide = true
	spawn.Transparency = 0.2
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.BottomSurface = Enum.SurfaceType.Smooth
	spawn.Neutral = true
	spawn.Parent = folder
	print(('[Bootstrap] Created spawn %s in %s'):format(name, folder.Name))
	return spawn, true
end

local function ensureLighting()
	Lighting.Technology = Enum.Technology.Future

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = 0.35
	atmosphere.Offset = 0.15
	atmosphere.Haze = 1.5
	atmosphere.Glare = 0.15
	atmosphere.Color = Color3.fromRGB(200, 220, 255)
	atmosphere.Decay = Color3.fromRGB(90, 110, 140)

	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if not bloom then
		bloom = Instance.new("BloomEffect")
		bloom.Parent = Lighting
	end
	bloom.Intensity = 0.25
	bloom.Size = 24
	bloom.Threshold = 1.0

	local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if not colorCorrection then
		colorCorrection = Instance.new("ColorCorrectionEffect")
		colorCorrection.Parent = Lighting
	end
	colorCorrection.Brightness = -0.03
	colorCorrection.Contrast = 0.15
	colorCorrection.Saturation = 0.08
	colorCorrection.TintColor = Color3.fromRGB(210, 235, 255)
end

local function ensureTsunami()
	local existing = workspace:FindFirstChild("TsunamiWater")
	if not existing then
		existing = Instance.new("Part")
		existing.Name = "TsunamiWater"
		existing.Anchored = true
		existing.CanCollide = false
		existing.Material = Enum.Material.Water
		existing.Transparency = 0.45
		existing.Size = Vector3.new(600, 40, 600)
		existing.Position = Vector3.new(0, Content.Presets.Casual.WaterStartY, 0)
		existing.Parent = workspace
		print('[Bootstrap] Created TsunamiWater part')
	else
		existing.Anchored = true
		existing.CanCollide = false
	end

	if not existing:FindFirstChildOfClass("ParticleEmitter") then
		local p = Instance.new("ParticleEmitter")
		p.Rate = 24
		p.Lifetime = NumberRange.new(1.2, 2.2)
		p.Speed = NumberRange.new(1, 3)
		p.SpreadAngle = Vector2.new(25, 25)
		p.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(0.5, 2.5),
			NumberSequenceKeypoint.new(1, 1),
		})
		p.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(1, 1),
		})
		p.Parent = existing
		print('[Bootstrap] Added water particles to TsunamiWater')
	end
end

local function ensureArenaKit()
	local kitFolder, created = ensureFolder(workspace, "ArenaKit")
	if created then
		kitFolder.Parent = workspace
	end

	local function ensurePart(name, size, cframe, material, color, partClass)
		local existing = kitFolder:FindFirstChild(name)
		if existing then
			return existing
		end
		local part = Instance.new(partClass or "Part")
		part.Name = name
		part.Size = size
		part.CFrame = cframe
		part.Anchored = true
		part.Material = material
		part.Color = color
		part.Parent = kitFolder
		print(('[Bootstrap] Created arena kit part %s'):format(name))
		return part
	end

	ensurePart("MainPlatform", Vector3.new(220, 8, 220), CFrame.new(0, 0, 0), Enum.Material.Metal, colors.Steel)
	ensurePart("TowerA", Vector3.new(26, 140, 26), CFrame.new(-70, 70, -70), Enum.Material.Metal, colors.Steel)
	ensurePart("TowerB", Vector3.new(26, 110, 26), CFrame.new(70, 55, 70), Enum.Material.Metal, colors.Steel)

	ensurePart("Ramp1", Vector3.new(34, 6, 24), CFrame.new(-40, 8, 40) * CFrame.Angles(0, math.rad(20), math.rad(-10)), Enum.Material.Concrete, colors.Steel, "WedgePart")
	ensurePart("Ramp2", Vector3.new(34, 6, 24), CFrame.new(0, 20, 0) * CFrame.Angles(0, math.rad(-25), math.rad(10)), Enum.Material.Concrete, colors.Steel, "WedgePart")
	ensurePart("Ramp3", Vector3.new(34, 6, 24), CFrame.new(40, 32, -40) * CFrame.Angles(0, math.rad(30), math.rad(-12)), Enum.Material.Concrete, colors.Steel, "WedgePart")

	for i = 1, 10 do
		local x = -60 + (i - 1) * 12
		local y = 20 + (i % 3) * 6
		local z = 60 - (i - 1) * 6
		ensurePart("Pad" .. i, Vector3.new(10, 2, 10), CFrame.new(x, y, z), Enum.Material.Metal, colors.Teal)
	end

	ensurePart("Bridge", Vector3.new(160, 6, 20), CFrame.new(0, 18, -90), Enum.Material.Metal, colors.Steel)

	local sign = ensurePart("NeonSign", Vector3.new(40, 12, 1), CFrame.new(0, 80, -120), Enum.Material.Neon, colors.Teal)
	if not sign:FindFirstChildOfClass("SurfaceGui") then
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Front
		gui.AlwaysOnTop = true
		gui.Parent = sign

		local text = Instance.new("TextLabel")
		text.Size = UDim2.new(1, 0, 1, 0)
		text.BackgroundTransparency = 1
		text.Text = "HARBOR HEIST"
		text.Font = Enum.Font.GothamBlack
		text.TextScaled = true
		text.TextColor3 = colors.Yellow
		text.TextStrokeTransparency = 0.3
		text.Parent = gui
	end

	if not sign:FindFirstChildOfClass("PointLight") then
		local light = Instance.new("PointLight")
		light.Color = colors.Teal
		light.Brightness = 2
		light.Range = 30
		light.Parent = sign
	end
end

local function run()
	ensureLighting()

	local spawnsFolder = ensureFolder(workspace, "Spawns")
	local lobbyFolder = ensureFolder(spawnsFolder, "Lobby")
	local arenaFolder = ensureFolder(spawnsFolder, "Arena")

	ensureSpawn(lobbyFolder, "LobbySpawn1", Vector3.new(-12, 5, -12))
	ensureSpawn(lobbyFolder, "LobbySpawn2", Vector3.new(12, 5, -12))

	ensureSpawn(arenaFolder, "ArenaSpawn1", Vector3.new(-25, 5, 0))
	ensureSpawn(arenaFolder, "ArenaSpawn2", Vector3.new(25, 5, 0))
	ensureSpawn(arenaFolder, "ArenaSpawn3", Vector3.new(-15, 25, 20))
	ensureSpawn(arenaFolder, "ArenaSpawn4", Vector3.new(15, 25, -20))
	ensureSpawn(arenaFolder, "ArenaSpawn5", Vector3.new(0, 45, 10))
	ensureSpawn(arenaFolder, "ArenaSpawn6", Vector3.new(0, 60, -10))

	ensureTsunami()
	ensureArenaKit()

	print("[Bootstrap] ready")
end

run()
