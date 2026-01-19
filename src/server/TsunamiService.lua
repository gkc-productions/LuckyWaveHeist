local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Content = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ContentPack"))

local TsunamiService = {}
TsunamiService.__index = TsunamiService

function TsunamiService.new(remotes, presetName)
	local self = setmetatable({}, TsunamiService)
	self.remotes = remotes
	self.preset = Content.Presets[presetName] or Content.Presets.Casual
	self.water = workspace:FindFirstChild("TsunamiWater")
	self.running = false
	self.speed = 0
	self.startY = self.preset.WaterStartY
	self.roundMultiplier = 0
	self.slowMultiplier = 1
	return self
end

function TsunamiService:Reset(roundIndex)
	if not self.water then
		return
	end
	self.roundMultiplier = (roundIndex - 1) * self.preset.CatchUpPerRound
	self.water.Anchored = true
	self.water.CanCollide = false
	self.water.Position = Vector3.new(self.water.Position.X, self.startY, self.water.Position.Z)
	self.running = false
	self.slowMultiplier = 1
end

function TsunamiService:Warn()
	self.remotes.Toast:FireAllClients({message = "⚠️ WATER RISING ⚠️"})
	self.remotes.Tutorial:FireAllClients({type = "warning"})
end

function TsunamiService:Start(speed)
	if not self.water then
		return
	end
	self.water.Anchored = true
	self.speed = speed + self.roundMultiplier
	self.running = true
	print("[Tsunami] start")
end

function TsunamiService:SetSlow(multiplier, duration)
	self.slowMultiplier = multiplier
	task.delay(duration, function()
		self.slowMultiplier = 1
	end)
end

function TsunamiService:Stop()
	self.running = false
	self.slowMultiplier = 1
end

function TsunamiService:Step(dt)
	if not self.running or not self.water then
		return
	end
	self.water.Position = self.water.Position + Vector3.new(0, (self.speed * self.slowMultiplier) * dt, 0)
end

return TsunamiService
