local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Content = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ContentPack"))

local TsunamiService = {}
TsunamiService.__index = TsunamiService

function TsunamiService.new(remotes)
	local self = setmetatable({}, TsunamiService)
	self.remotes = remotes
	self.water = workspace:FindFirstChild("TsunamiWater")
	self.activeTween = nil
	self.slowMultiplier = 1
	self.riseRate = 0
	self.waveTargetY = nil
	return self
end

function TsunamiService:Reset()
	if not self.water then
		self.water = workspace:FindFirstChild("TsunamiWater")
	end
	if not self.water then
		return
	end
	if self.activeTween then
		self.activeTween:Cancel()
		self.activeTween = nil
	end
	self.water.Anchored = true
	self.water.CanCollide = false
	self.water.Position = Vector3.new(self.water.Position.X, Content.Tuning.WaterStartY, self.water.Position.Z)
	self.slowMultiplier = 1
	self.riseRate = 0
	self.waveTargetY = nil
end

function TsunamiService:_ensureSiren()
	local siren = workspace:FindFirstChild("WarningSiren")
	if not siren then
		siren = Instance.new("Sound")
		siren.Name = "WarningSiren"
		siren.SoundId = "rbxassetid://5410086218"
		siren.Volume = 0.6
		siren.Parent = workspace
	end
	return siren
end

function TsunamiService:Warn()
	self.remotes.Toast:FireAllClients({message = Content.RoundText.Warning})
	self.remotes.Tutorial:FireAllClients({type = "warning"})
	local siren = self:_ensureSiren()
	siren:Play()
end

function TsunamiService:_tweenToTarget(targetY, duration)
	if not self.water then return end
	if self.activeTween then
		self.activeTween:Cancel()
	end
	local target = Vector3.new(self.water.Position.X, targetY, self.water.Position.Z)
	local info = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	self.activeTween = TweenService:Create(self.water, info, {Position = target})
	self.activeTween:Play()
end

function TsunamiService:SetSlow(multiplier, duration)
	self.slowMultiplier = multiplier
	if self.waveTargetY and self.water then
		local remaining = math.max(0, self.waveTargetY - self.water.Position.Y)
		local speed = math.max(0.01, self.riseRate * self.slowMultiplier)
		local remainingTime = remaining / speed
		self:_tweenToTarget(self.waveTargetY, remainingTime)
	end
	if duration and duration > 0 then
		task.delay(duration, function()
			self.slowMultiplier = 1
			if self.waveTargetY and self.water then
				local remaining = math.max(0, self.waveTargetY - self.water.Position.Y)
				local speed = math.max(0.01, self.riseRate)
				local remainingTime = remaining / speed
				self:_tweenToTarget(self.waveTargetY, remainingTime)
			end
		end)
	end
end

function TsunamiService:StartWave(duration, riseRate)
	if not self.water then
		self.water = workspace:FindFirstChild("TsunamiWater")
	end
	if not self.water then
		return
	end
	self.water.Anchored = true
	self.riseRate = riseRate
	self.waveTargetY = self.water.Position.Y + (riseRate * duration)
	self:_tweenToTarget(self.waveTargetY, duration)
	print("[Tsunami] start")
end

function TsunamiService:Stop()
	if self.activeTween then
		self.activeTween:Cancel()
		self.activeTween = nil
	end
	self.slowMultiplier = 1
	self.riseRate = 0
	self.waveTargetY = nil
end

return TsunamiService
