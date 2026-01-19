# VALIDATION SCRIPT (Run in Studio Output Console)

## Copy-paste these checks in Studio's Command Bar to validate build:

```lua
-- ============================================================================
-- VALIDATION 1: Check Remotes Folder Structure
-- ============================================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
print("[VAL-1] Remotes folder:", Remotes and "✅ FOUND" or "❌ MISSING")
if Remotes then
	print("  - RoundUpdate:", Remotes:FindFirstChild("RoundUpdate") and "✅" or "❌")
	print("  - Toast:", Remotes:FindFirstChild("Toast") and "✅" or "❌")
	print("  - CurrencyUpdate:", Remotes:FindFirstChild("CurrencyUpdate") and "✅" or "❌")
	print("  - PurchaseUpgrade:", Remotes:FindFirstChild("PurchaseUpgrade") and "✅" or "❌")
	print("  - LuckyBlockFX:", Remotes:FindFirstChild("LuckyBlockFX") and "✅" or "❌")
end
```

```lua
-- ============================================================================
-- VALIDATION 2: Check Shared Modules
-- ============================================================================
local Shared = ReplicatedStorage:FindFirstChild("Shared")
print("[VAL-2] Shared folder:", Shared and "✅ FOUND" or "❌ MISSING")
if Shared then
	print("  - ContentPack:", Shared:FindFirstChild("ContentPack") and "✅" or "❌")
	print("  - Remotes:", Shared:FindFirstChild("Remotes") and "✅" or "❌")
end
```

```lua
-- ============================================================================
-- VALIDATION 3: Check Workspace Objects
-- ============================================================================
print("[VAL-3] Workspace objects:")
print("  - TsunamiWater:", workspace:FindFirstChild("TsunamiWater") and "✅" or "❌")
print("  - Spawns > Lobby:", workspace:FindFirstChild("Spawns") and workspace.Spawns:FindFirstChild("Lobby") and "✅" or "❌")
print("  - Spawns > Arena:", workspace:FindFirstChild("Spawns") and workspace.Spawns:FindFirstChild("Arena") and "✅" or "❌")
```

```lua
-- ============================================================================
-- VALIDATION 4: Check Server Scripts Running
-- ============================================================================
local ServerScriptService = game:GetService("ServerScriptService")
local Server = ServerScriptService:FindFirstChild("Server")
print("[VAL-4] Server scripts:")
if Server then
	print("  - RoundService:", Server:FindFirstChild("RoundService") and "✅" or "❌")
	print("  - Bootstrap:", Server:FindFirstChild("Bootstrap") and "✅" or "❌")
	print("  - CurrencyService:", Server:FindFirstChild("CurrencyService") and "✅" or "❌")
	print("  - LuckyBlockSpawner:", Server:FindFirstChild("LuckyBlockSpawner") and "✅" or "❌")
end
```

```lua
-- ============================================================================
-- VALIDATION 5: Check Client Scripts Running
-- ============================================================================
local StarterPlayer = game:GetService("StarterPlayer")
local playerScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
local Client = playerScripts and playerScripts:FindFirstChild("Client")
print("[VAL-5] Client scripts:")
if Client then
	print("  - HUD:", Client:FindFirstChild("HUD") and "✅" or "❌")
	print("  - TimerUI:", Client:FindFirstChild("TimerUI") and "✅" or "❌")
else
	print("  ❌ Client folder not found")
end
```

```lua
-- ============================================================================
-- VALIDATION 6: Simulate First Player Load
-- ============================================================================
-- This will trigger Bootstrap and load Currency data for first player
local Players = game:GetService("Players")
local player = Players:FindFirstPlayer()
if player then
	print("[VAL-6] First player:", player.Name)
	print("  - Coins:", player:GetAttribute("coins") or "loading...")
	print("  - Upgrades:", player:GetAttribute("upgrades") and "stored" or "pending")
else
	print("[VAL-6] No players yet (waiting for join)")
end
```

```lua
-- ============================================================================
-- VALIDATION 7: Check for Syntax/Script Errors
-- ============================================================================
-- Look in Output tab for RED ERROR messages
print("[VAL-7] Check Output tab above for RED errors:")
print("  ❌ Any 'Syntax Error', 'WaitForChild timeout', or 'module not found' = FIX REQUIRED")
print("  ❌ Any 'DeprecatedApi' = update API calls")
print("  ✅ No errors = ready for gameplay test")
```

---

## MANUAL TESTS IN STUDIO (After Validation Passes)

### Test A: Coins & Round State
1. Play
2. Wait 15 seconds (Intermission)
3. Observe: "Intermission | Round starting in X..." text appears
4. After 15s: "Wave Active" appears, water starts rising
5. Watch coins label update every second (+10 per sec)

### Test B: Lucky Blocks
1. During wave, approach a Lucky Block
2. Click ProximityPrompt ("Break" label appears)
3. Hold 0.4 seconds
4. Block disappears, toast appears (e.g., "✅ Common power activated!")
5. Coins add (50–200 depending on rarity)

### Test C: Shop Purchase
1. Stop play, delete player character (or wait until next round)
2. Play again
3. Click "Shop" button (top-right)
4. Find "WalkSpeed" upgrade
5. Click "Buy"
6. Coins deduct 200
7. Level shows "1 / 8"
8. Respawn: character noticeably faster

### Test D: DataStore Persistence
1. Complete Test C
2. Exit to lobby (or leave game)
3. Re-join same game
4. Check coins & upgrades are restored

### Test E: Tsunami Scaling
1. Play 5 consecutive rounds
2. Observe water speed increases each round
3. Round 5 water should be faster than Round 1
4. Verify difficulty is harder

---

## COMMON ISSUES & FIXES

| Issue | Symptom | Fix |
|-------|---------|-----|
| **Remotes not created** | "RoundUpdate not found" error | Bootstrap creates them auto; if missing, check ReplicatedStorage/Shared/Remotes.lua loaded |
| **Coins don't update** | Label blank or frozen at 0 | Check CurrencyUpdate remote fires from RoundService; verify HUD script listens |
| **Shop doesn't appear** | Button visible but panel doesn't open | Check HUD.client.lua loaded; verify shopBtn.MouseButton1Click connected |
| **Water doesn't rise** | Water part exists but never moves | Check TsunamiService.Start() called in RoundService; verify water.Anchored = true |
| **Blocks don't break** | ProximityPrompt fires but block persists | Check _onPrompt() in LuckyBlockSpawner; verify part:Destroy() executes |
| **Toasts don't appear** | No visual feedback on pickup | Check Toast remote fires; verify HUD container exists and is visible |

---

## IF ALL VALIDATIONS PASS ✅

Congratulations! Your Lucky Wave Heist game is ready for playtesting.

Next steps:
1. Invite testers to play
2. Collect feedback on difficulty balance, UI clarity, loot drops
3. Tune economy costs/earnings based on playtest data
4. Add cosmetic/polish (sounds, particles, animations)
5. Implement Milestone 2 features (enemy AI, respawns, leaderboards)

