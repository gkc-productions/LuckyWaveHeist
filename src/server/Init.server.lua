local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for shared modules to load
local shared = ReplicatedStorage:WaitForChild("shared")
shared:WaitForChild("RoundStates")
shared:WaitForChild("Constants")
shared:WaitForChild("RemoteEvents")

-- Require managers
local PlayerManager = require(script.Parent:WaitForChild("PlayerManager"))
local RoundManager = require(script.Parent:WaitForChild("RoundManager"))

-- Initialize systems
PlayerManager.Init()
RoundManager.Init(PlayerManager)

print("[Server] Lucky Wave Heist started - Milestone 1")
