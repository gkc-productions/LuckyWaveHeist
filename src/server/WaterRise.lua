local WaterRise = {}
WaterRise.__index = WaterRise

local WATER_PART_NAME = "TsunamiWater"

function WaterRise.new()
	local self = setmetatable({}, WaterRise)

	self.water = workspace:WaitForChild(WATER_PART_NAME)
	self.startCFrame = self.water.CFrame
	self.startSize = self.water.Size

	self.running = false
	self.speed = 0

	-- kill on touch
	self.water.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		if not character then return end
		local hum = character:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			hum.Health = 0
		end
	end)

	return self
end

function WaterRise:Reset()
	self.running = false
	self.speed = 0
	self.water.CFrame = self.startCFrame
	self.water.Size = self.startSize
end

function WaterRise:Start(speedStudsPerSec: number)
	self.running = true
	self.speed = speedStudsPerSec
end

function WaterRise:Stop()
	self.running = false
end

function WaterRise:Step(dt: number)
	if not self.running then return end
	self.water.CFrame = self.water.CFrame + Vector3.new(0, self.speed * dt, 0)
end

return WaterRise
