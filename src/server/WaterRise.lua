-- src/server/WaterRise.lua
local Players = game:GetService("Players")

local WaterRise = {}
WaterRise.__index = WaterRise

local WATER_PART_NAME = "TsunamiWater"
local KILL_ON_TOUCH = true

function WaterRise.new()
	local self = setmetatable({}, WaterRise)

	self.water = workspace:WaitForChild(WATER_PART_NAME)
	self.startCFrame = self.water.CFrame
	self.startSize = self.water.Size

	self._running = false
	self._speedStudsPerSec = 0
	self._conn = nil

	-- Kill on touch
	if KILL_ON_TOUCH then
		self._touchConn = self.water.Touched:Connect(function(hit)
			local character = hit:FindFirstAncestorOfClass("Model")
			if not character then return end
			local hum = character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				hum.Health = 0
			end
		end)
	end

	return self
end

function WaterRise:Reset()
	self._running = false
	self._speedStudsPerSec = 0
	self.water.CFrame = self.startCFrame
	self.water.Size = self.startSize
end

function WaterRise:Start(speedStudsPerSec: number)
	self._running = true
	self._speedStudsPerSec = speedStudsPerSec
end

function WaterRise:Stop()
	self._running = false
end

function WaterRise:Step(dt: number)
	if not self._running then return end
	local dy = self._speedStudsPerSec * dt
	self.water.CFrame = self.water.CFrame + Vector3.new(0, dy, 0)
end

return WaterRise.new()
