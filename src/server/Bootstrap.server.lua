local mapAlias = workspace:FindFirstChild("Map")
if not mapAlias then
	mapAlias = Instance.new("ObjectValue")
	mapAlias.Name = "Map"
	mapAlias.Parent = workspace
	mapAlias.Value = workspace:FindFirstChild("LuckyWaveHeist_Map")
	warn("[Bootstrap] Missing Map alias; created placeholder.")
end

print("[Bootstrap] ready")
