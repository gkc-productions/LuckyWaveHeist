local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local TsunamiController = {}
TsunamiController.__index = TsunamiController

local TSUNAMI_NAME = "TsunamiWater"
local WARNING_DURATION = 5

function TsunamiController.new(remotes)
	local self = setmetatable({}, TsunamiController)
	self.remotes = remotes
	self.part = workspace:WaitForChild(TSUNAMI_NAME)
	self.baseCFrame = self.part.CFrame
	self.startCFrame = self.baseCFrame + Vector3.new(-300, 0, 0)
	self.endCFrame = self.baseCFrame + Vector3.new(300, 0, 0)
	self.running = false
	self.elapsed = 0
	self.travelDuration = 60
	self.connections = {}

	self.connections.touch = self.part.Touched:Connect(function(hit)
		self:_handleTouch(hit)
	end)

	self.connections.step = RunService.Heartbeat:Connect(function(dt)
		self:_step(dt)
	end)

	return self
end

function TsunamiController:_handleTouch(hit)
	if not self.running then return end
	local char = hit:FindFirstAncestorOfClass("Model")
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end
	local player = Players:GetPlayerFromCharacter(char)
	local waveShieldUntil = player and player:GetAttribute("WaveShieldUntil")
	if waveShieldUntil and os.clock() < waveShieldUntil then
		return
	end
	local secondChance = player and player:GetAttribute("SecondChance")
	if secondChance then
		player:SetAttribute("SecondChance", nil)
		hum.Health = hum.MaxHealth
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local newCF = hrp.CFrame + Vector3.new(0, 10, 0)
			hrp.CFrame = newCF
		end
		player:SetAttribute("WaveShieldUntil", os.clock() + 2)
		return
	end
	hum.Health = 0
end

function TsunamiController:_step(dt)
	if not self.running then return end
	self.elapsed += dt
	local alpha = math.clamp(self.elapsed / self.travelDuration, 0, 1)
	self.part.CFrame = self.startCFrame:Lerp(self.endCFrame, alpha)
	if alpha >= 1 then
		self.running = false
	end
end

function TsunamiController:Prepare(roundDuration)
	self.running = false
	self.elapsed = 0
	self.travelDuration = math.max(10, roundDuration * 0.7)
	self.baseCFrame = self.part.CFrame
	self.startCFrame = self.baseCFrame + Vector3.new(-300, 0, 0)
	self.endCFrame = self.baseCFrame + Vector3.new(300, 0, 0)
	self.part.CFrame = self.startCFrame
end

function TsunamiController:Warn()
	self.remotes.Toast:FireAllClients({message = "Tsunami incoming! Brace!"})
end

function TsunamiController:Start(roundDuration)
	self:Prepare(roundDuration)
	self:Warn()
	print("[Tsunami] warning issued")
	task.wait(WARNING_DURATION)
	self.running = true
	self.elapsed = 0
	print("[Tsunami] wave moving")
end

function TsunamiController:Stop()
	self.running = false
	self.part.CFrame = self.startCFrame
end

function TsunamiController:Destroy()
	for _, conn in pairs(self.connections) do
		conn:Disconnect()
	end
end

return TsunamiController
