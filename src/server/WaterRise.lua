local Players = game:GetService("Players")

local WaterRise = {}
WaterRise.__index = WaterRise

local WATER_PART_NAME = "TsunamiWater"

function WaterRise.new()
	local self = setmetatable({}, WaterRise)

	self.water = workspace:FindFirstChild(WATER_PART_NAME)
	if not self.water then
		self.water = Instance.new("Part")
		self.water.Name = WATER_PART_NAME
		self.water.Parent = workspace
	end

	self.water.Anchored = true
	self.water.CanCollide = false
	self.water.Material = Enum.Material.Water
	self.water.Transparency = 0.45

	self.startCFrame = self.water.CFrame
	self.startSize = self.water.Size
	self.running = false
	self.speed = 0
	self.slowMultiplier = 1

	self.water.Touched:Connect(function(hit)
		self:_onTouched(hit)
	end)

	return self
end

function WaterRise:_onTouched(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then return end
	local hum = character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end

	local player = Players:GetPlayerFromCharacter(character)
	if player then
		local spawnShield = player:GetAttribute("SpawnShieldUntil")
		if spawnShield and os.clock() < spawnShield then
			return
		end
		local invuln = player:GetAttribute("InvulnUntil")
		if invuln and os.clock() < invuln then
			return
		end
		local shieldHp = player:GetAttribute("ShieldHP")
		if shieldHp and shieldHp > 0 then
			player:SetAttribute("ShieldHP", shieldHp - 1)
			return
		end
		local revive = player:GetAttribute("ReviveToken")
		if revive then
			player:SetAttribute("ReviveToken", nil)
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = hrp.CFrame + Vector3.new(0, 20, 0)
			end
			return
		end
	end

	hum.Health = 0
end

function WaterRise:Reset(position)
	self.running = false
	self.speed = 0
	self.startCFrame = position or self.startCFrame
	self.water.CFrame = self.startCFrame
	self.water.Size = self.startSize
	self.water.Anchored = true
	self.slowMultiplier = 1
end

function WaterRise:SetSpeed(speedStudsPerSec)
	self.speed = speedStudsPerSec
end

function WaterRise:SetSlow(multiplier)
	self.slowMultiplier = multiplier
end

function WaterRise:Start(speedStudsPerSec)
	self.running = true
	self.speed = speedStudsPerSec
end

function WaterRise:Stop()
	self.running = false
end

function WaterRise:Step(dt)
	if not self.running then return end
	self.water.CFrame = self.water.CFrame + Vector3.new(0, (self.speed * self.slowMultiplier) * dt, 0)
end

return WaterRise
