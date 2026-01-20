-- Client-side visual effects for Lucky Block breaks
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))

local RARITY_COLORS = {
	Common = Color3.fromRGB(255, 213, 74),       -- Yellow
	Uncommon = Color3.fromRGB(25, 211, 197),    -- Teal
	Rare = Color3.fromRGB(200, 100, 255),       -- Violet
	Epic = Color3.fromRGB(255, 255, 0),         -- Gold
}

local function playBreakFX(position, rarity)
	-- Create particle emitter at block location
	local emitter = Instance.new("Part")
	emitter.Name = "BlockBreakFX"
	emitter.Shape = Enum.PartType.Ball
	emitter.Size = Vector3.new(0.6, 0.6, 0.6)
	emitter.Position = position
	emitter.Anchored = true
	emitter.CanCollide = false
	emitter.Material = Enum.Material.Neon
	emitter.Color = RARITY_COLORS[rarity] or RARITY_COLORS.Common
	emitter.Parent = workspace

	-- Add particle effect
	local particles = Instance.new("ParticleEmitter")
	particles.Parent = emitter
	particles.Rate = 50
	particles.Lifetime = NumberRange.new(0.5, 1.5)
	particles.Speed = NumberRange.new(15, 35)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(1, 0.2),
	})
	particles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.7, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	particles.Enabled = true

	-- Play sound (using CreakSound which is common in Roblox)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://204307103"  -- Pop sound
	sound.Volume = 0.5
	sound.Parent = emitter
	sound:Play()

	-- Fade out and destroy
	game:GetService("Debris"):AddItem(emitter, 2)
end

-- Listen for block break events
if Remotes:FindFirstChild("LuckyBlockFX") then
	Remotes.LuckyBlockFX.OnClientEvent:Connect(function(data)
		if data and data.position and data.rarity then
			playBreakFX(data.position, data.rarity)
		end
	end)
else
	print("[BlockBreakFX] LuckyBlockFX remote not found, waiting...")
	Remotes.ChildAdded:Connect(function(child)
		if child.Name == "LuckyBlockFX" then
			child.OnClientEvent:Connect(function(data)
				if data and data.position and data.rarity then
					playBreakFX(data.position, data.rarity)
				end
			end)
		end
	end)
end

print("[BlockBreakFX] Client loaded")
