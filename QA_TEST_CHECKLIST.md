# Lucky Wave Heist – QA Test Checklist

## Phase 1: World Bootstrap
**Goal**: Rojo syncs correctly. Players spawn. RemoteEvents exist. No Rojo duplication.

### What You Should See in Studio

- [ ] **ServerScriptService > Server > RoundService.server.lua** (running, no errors in Output)
- [ ] **ReplicatedStorage > Shared > Remotes** (folder with `RoundUpdate` event inside)
- [ ] **ReplicatedStorage > Shared > Constants** (module visible)
- [ ] **StarterPlayer > StarterCharacterScripts > (empty, M1 scope)**
- [ ] **StarterPlayer > StarterPlayerScripts > Client > TimerUI.client.lua** (running, listening for events)
- [ ] **Workspace > Spawns > Lobby** (folder, contains 2–4 SpawnLocations)
- [ ] **Workspace > Spawns > Arena** (folder, contains 2–4 SpawnLocations)
- [ ] **Workspace > TsunamiWater** (anchored part, positioned at Y = -10 initially)

### Tests to Run

| # | Test | Expected Result | Pass/Fail |
|---|------|-----------------|-----------|
| 1.1 | Reload Rojo (Ctrl+Shift+P → "Rojo Sync"). Check Output console. | **Zero errors**. "Rojo synced" or similar message appears. | ☐ |
| 1.2 | In-game: Play. Observe Output. | Players teleport to Lobby spawn. UI appears (empty label is OK). No "WaitForChild timeout" errors. | ☐ |
| 1.3 | Search ReplicatedStorage for "Remotes" folder. | **Exactly one** "Remotes" folder exists. No duplication (no "remotes" lowercase copy). | ☐ |
| 1.4 | Expand Remotes folder. Check contents. | Contains RemoteEvent named "RoundUpdate". No empty subfolders. | ☐ |
| 1.5 | In Output, search for "Waiting for". | **Zero matches**. If found, it means WaitForChild is hanging. | ☐ |
| 1.6 | Stop play. Check Output for red errors during load. | All errors related to expected M2 features (e.g., "ShopUI not found") are OK. No "module not found" errors. | ☐ |
| 1.7 | Manually add 2 SpawnLocations to Workspace/Spawns/Arena. Play. | Players spawn at these locations (not at origin). Teleport works. | ☐ |
| 1.8 | In Studio, check file paths in default.project.json. | No paths to non-existent folders (e.g., `src/server/modules`). Paths match disk structure exactly. | ☐ |

### Common Failure Symptoms & Root Causes

| Symptom | Most Likely Cause | Quick Fix |
|---------|-------------------|-----------|
| **"WaitForChild timeout"** in Output | Remotes.lua or Constants.lua not syncing / wrong path | Reload Rojo. Check ReplicatedStorage folder structure. Verify `src/shared/` has Remotes.lua and Constants.lua. |
| **"Remotes" folder appears twice** (Remotes + remotes) | Rojo synced folder + code dynamically created folder both exist | Delete `remotes` (lowercase) folder in ReplicatedStorage manually. Let Rojo create the correct one. |
| **TimerUI shows but label is blank/frozen** | RoundUpdate event not firing OR TimerUI not connecting | In RoundService, verify `evt:FireAllClients(...)` is called. In TimerUI, add debug print: `print("Event fired:", p.state)` and check Output. |
| **Players spawn at origin (0, 0, 0)** | Spawns/Lobby or Spawns/Arena folders don't exist OR are empty | Create both folders manually in Workspace. Add 2+ SpawnLocation parts to each. Verify paths in RoundService match. |
| **"cannot require Shared" error** | Path casing mismatch (Shared vs shared) OR Shared folder doesn't exist | In RoundService, verify line reads: `local Shared = ReplicatedStorage:WaitForChild("Shared")` (capital S). |
| **Rojo says "file could not be turned into Instance"** | Empty folder exists in src/ OR folder name has no files | Delete empty folders. Use `ls -la src/*/` in terminal to verify all folders have content. |

---

## Phase 2: Tsunami (Water Rising)
**Goal**: Water rises smoothly. Speeds escalate per round. Players die on water touch. No stuttering.

### What You Should See in Studio

- [ ] **Workspace > TsunamiWater** is a large anchored part (suggest 100×100×2 studs, positioned low)
- [ ] **Output shows**: "Round: Intermission" → "Round: Active" → "Water speed: 1.2 studs/sec" (per preset)
- [ ] **RoundService output logs** (add debug prints for water speed & position per second)
- [ ] **No lag spikes** when water moves (smooth tweening, not jumpy)

### Tests to Run

| # | Test | Expected Result | Pass/Fail |
|---|------|-----------------|-----------|
| 2.1 | Play. Watch Output. Note first log message. | Output shows "Round: Intermission" with countdown (15s for Casual). No freeze. | ☐ |
| 2.2 | Wait 15s. Observe screen transition. | UI text changes to "WAVE 1 OF 3". Water begins rising visibly. No lag spike. | ☐ |
| 2.3 | Place a part at Y = 20 studs high. Stand on it. Let water rise. | Water passes beneath you smoothly. You remain on part (no clipping). | ☐ |
| 2.4 | Let water reach your position (Y ≈ 20+). Wait 2s. | Player dies instantly. "💀 Drowned" message appears. Game respawns you to Lobby next intermission. | ☐ |
| 2.5 | Play Casual 2 full rounds. Measure water speed visually. | Wave 1: slow (≈1.2 s/s). Wave 3 of Round 2: slightly faster. Speed progression visible. | ☐ |
| 2.6 | In Output, search "Water speed" logs over 3 waves. | Logs show progression: [1.2, 1.4, 1.6] for Casual wave 1-3. Then [1.4, 1.6, 1.8] round 2. | ☐ |
| 2.7 | Use Sweaty preset (if toggle exists). Play 1 round. | Water moves much faster. Wave 1 clearly at 1.8 s/s (visibly harder). | ☐ |
| 2.8 | Stand on highest point of map. Let Round 5 water chase you. | Water corners you eventually. Tests difficulty scaling. | ☐ |

### Common Failure Symptoms & Root Causes

| Symptom | Most Likely Cause | Quick Fix |
|---------|-------------------|-----------|
| **Water doesn't move at all** | WaterRise.lua not loaded OR `:Step(dt)` not called in RoundService loop | In RoundService, verify `water:Step(dt)` is in main loop (inside while `timeLeft > 0`). Check RoundService console for water module errors. |
| **Water moves but very slowly/jerkily** | dt calculation wrong OR water tweened instead of incremental | Verify `local water = WaterRise.new()` is called once at startup. Check WaterRise.lua increments position: `self.part.Position = self.part.Position + Vector3.new(0, self.speed * dt, 0)`. |
| **Water passes through players (no death)** | Touched event not firing OR death logic broken | In WaterRise.lua, verify `.Touched:Connect(function(hit)...)` exists. Add print: `print("Water touched:", hit)` to confirm firing. Check Humanoid:TakeDamage() is called. |
| **Player respawns to wrong spawn** | Spawns/Lobby doesn't exist OR teleportAll() path wrong | Check RoundService: `local lobbySpawns = Spawns:WaitForChild("Lobby"):GetChildren()`. Verify both folders exist. |
| **Water reset between rounds doesn't work** | `water:Reset()` not called OR reset position hardcoded wrong | In RoundService, after round ends, verify `water:Reset()` is called before next intermission. Check WaterRise reset position = Y = -10 (or your start Y). |
| **Intermission countdown doesn't appear** | TimerUI not subscribing OR broadcast() not firing | In RoundService, add debug print in `broadcast()`: `print("Broadcasting:", state, timeLeft, alive)`. Check Output every second during intermission. |

---

## Phase 3: Lucky Blocks (Drops & Pickups)
**Goal**: Blocks spawn randomly. Clicking (or E) breaks them. Correct loot drops. Toasts appear.

### What You Should See in Studio

- [ ] **Workspace > LuckyBlocks** (folder, spawned dynamically or pre-placed for testing)
- [ ] **Each block** is a colorful Part (suggest bright pink/purple) or MeshPart
- [ ] **On block break**, brief animation (fade/shrink) then vanish
- [ ] **Output logs**: "Block broken: Grapple Hook (Rare)" per item
- [ ] **HUD label updates** to show coins earned immediately
- [ ] **Toast notification** pops center-screen (colored by rarity)

### Tests to Run

| # | Test | Expected Result | Pass/Fail |
|---|------|-----------------|-----------|
| 3.1 | Place 1 Lucky Block in arena manually. Play. Approach it. | Block shows as solid object. No collision issues. | ☐ |
| 3.2 | While near block, press E (or click it on mobile). | Block vanishes instantly or fades over 0.3s. Sound plays (optional). | ☐ |
| 3.3 | Immediately after breaking block, check chat or Output. | Log shows "Block broken: [ItemName] ([Rarity])". Toast appears center-screen (1–3 seconds). | ☐ |
| 3.4 | Break 10 blocks in one round. Check coin counter. | Each break adds coins (50 common, 100 rare, etc. per CONTENT_PACK). Counter updates visibly. | ☐ |
| 3.5 | Note item drops across 10 breaks. | Rarity distribution roughly matches weights (Common 60%, Rare 28%, Epic 9%, Legendary 3%). | ☐ |
| 3.6 | Break a Legendary block. Observe toast. | Toast says "🌟 LEGENDARY! GAME CHANGER! 🌟" in gold text. Heavenly sound plays. | ☐ |
| 3.7 | Test on mobile (gamepad). Approach block, press designated button. | Block breaks. Toast visible on small screen. No input lag. | ☐ |
| 3.8 | Break 1 block per wave, across 2 rounds. | Powers activate: grapple fires, speed boosts appear, health restores, etc. Each power works (basic test). | ☐ |

### Common Failure Symptoms & Root Causes

| Symptom | Most Likely Cause | Quick Fix |
|---------|-------------------|-----------|
| **Block doesn't disappear when clicked** | ClickDetector not added to block OR script not listening | Add ClickDetector to block part. In block-break script, verify `ClickDetector.MouseClick:Connect(...)`. |
| **"Block broken" log doesn't appear** | Loot table not loaded OR item name misspelled | Check LootTable module is required correctly. Verify CONTENT_PACK item names match exactly (case-sensitive). |
| **Toast doesn't appear** | Toast GUI not created OR rarity logic broken | In coin-add logic, verify toast call: `showToast(itemRarity, itemName)`. Check ReplicatedStorage for GUI template or dynamic creation. |
| **Wrong item dropped** | Rarity weight RNG broken OR table index wrong | Add debug print in loot roll: `print("Rolled rarity:", rarity, "Item:", items[rarity][math.random(#items[rarity])])`. Verify table structure. |
| **Coin counter doesn't update** | Stats module not updated OR GUI label not bound | Verify coin value written to PlayerData. In TimerUI or HUD script, check: `print("Coins:", player:GetAttribute("coins"))` every pickup. |
| **Power-up activated but doesn't work** | Module not found OR effect logic missing | Check each power (grapple, speed, etc.) module loads. Add test print: `print("Activating:", effectName)`. Verify effect applied to humanoid or stats. |

---

## Phase 4: Currency + Shop + Save
**Goal**: Coins persist between rounds. Shop purchases work. Datastore saves.

### What You Should See in Studio

- [ ] **Coins display** on HUD persists across deaths (tracked per player, not per character)
- [ ] **Shop GUI** visible with 6 upgrade buttons
- [ ] **Each upgrade** shows: name, current level, cost to next level, description
- [ ] **After purchase**, coins deduct, level increments, effect applies (e.g., speed +1.5)
- [ ] **Stop/restart Studio**: coins + levels reload (if datastore connected)

### Tests to Run

| # | Test | Expected Result | Pass/Fail |
|---|------|-----------------|-----------|
| 4.1 | Play 1 round, break 5 blocks (earn ~750 coins). Check coin label. | Coin counter shows ≈750 (or actual earned amount). Updates per block break. | ☐ |
| 4.2 | Die mid-round. Respawn to Lobby. Check coin counter. | Coins persist (still show ≈750). Not reset. | ☐ |
| 4.3 | Open Shop. Hover over "WalkSpeed L1" upgrade. | Cost displayed (e.g., 200 coins). Description shows "+1.5 studs/sec". Can click "Buy". | ☐ |
| 4.4 | With ≥200 coins, click "Buy" on WalkSpeed L1. | Coins deduct 200. WalkSpeed level shows "2". Player noticeably faster immediately. | ☐ |
| 4.5 | Buy same upgrade again (L2). | Cost increased (e.g., 300 coins). Deducts correctly. Level increments. Speed increases further. | ☐ |
| 4.6 | Hover over Loot Magnet. | Shows "Max Level: 5". If maxed, shows "MAXED" instead of cost. Can't buy. | ☐ |
| 4.7 | **Datastore Test (optional M1)**: Play, buy upgrade, close Studio. Reopen. Play same player. | If datastore connected: upgrade level persists. Coins persist. If not connected: new player (fresh coins/levels). | ☐ |
| 4.8 | Test insufficient coins. Try to buy expensive upgrade with <cost coins. | Button disabled or tooltip says "Insufficient coins". Purchase blocked. | ☐ |

### Common Failure Symptoms & Root Causes

| Symptom | Most Likely Cause | Quick Fix |
|---------|-------------------|-----------|
| **Coins reset to 0 after death** | Coins tracked on Character instead of Player | Move coin storage: from `char:SetAttribute("coins")` to `player:SetAttribute("coins")`. Verify UpdateHUD() reads from player, not character. |
| **Shop doesn't open / buttons unresponsive** | Shop GUI not created OR script not connected | Check Shop button exists. Verify ShopUI.client.lua is in StarterPlayer and listening for open event. Test on output: `print("Shop opened")`. |
| **Bought upgrade doesn't apply** | Effect not applied to player stats OR upgrade value wrong | After purchase, verify: `player.Character.Humanoid.WalkSpeed = newWalkSpeed`. Add print to confirm value. Check cost/level lookup table. |
| **Upgrade cost doesn't scale** | Cost formula wrong OR level not incremented | In shop script, verify cost calc: `cost = baseCost * (1.5 ^ level)`. Check level actually increments in PlayerData after purchase. |
| **Datastore fails silently** | API key wrong OR player ID malformed | Check DatastoreService is enabled in Studio (not disabled). Verify SavePlayer() is called after each action. Look for "DataStore request rejected" in Output. |
| **Shop shows old level after reload** | Datastore loaded but HUD not refreshed | After loading player data, call `updateShopDisplay()` and `updateCoinLabel()`. Verify player attributes match loaded data. |

---

## Red Flags Section

### 🚩 Rojo Duplication Signs

**What to look for**:
- ReplicatedStorage has **both** "Shared" and "shared" folders (uppercase + lowercase)
- ReplicatedStorage has **multiple** "Remotes" folders
- ServerScriptService has duplicate instances of RoundService.server.lua

**How to confirm**:
```bash
# In terminal:
ls -la ~/RobloxProjects/LuckyWaveHeist/src/shared/
# Should show: Remotes.lua, Constants.lua (files, not folders)

# In Studio, expand ReplicatedStorage:
# Should show: Shared (folder), NOT both Shared + shared
```

**Fix**:
1. Reload Rojo (Ctrl+Shift+P → Rojo Sync)
2. In Studio, manually delete lowercase/duplicate folders
3. Verify `default.project.json` has no duplicate mappings
4. Restart Studio if persists

---

### 🚩 WaitForChild Infinite Yield Signs

**What to look for**:
- Output shows: **"infinite yield possible on"** (yellow warning)
- Game freezes for >5 seconds on load
- Players stuck at "Waiting for players..." message
- RoundService doesn't output any "Round: Intermission" message

**How to confirm**:
```lua
-- Add this to RoundService top:
print("[BOOT] RoundService starting...")
print("[BOOT] Waiting for Workspace.Spawns...")
local Spawns = Workspace:WaitForChild("Spawns")
print("[BOOT] Spawns found!")
```
If you see first print but not second, WaitForChild is hanging.

**Common causes**:
- Path typo: `WaitForChild("Spawns")` but folder is "Spawn" (no 's')
- Folder doesn't exist in Workspace yet (create manually)
- Shared module path wrong: `ReplicatedStorage:WaitForChild("shared")` instead of "Shared"

**Fix**:
1. Check spelling: **exact case match** required
2. In Studio, manually create missing folder
3. In code, add `or error("XYZ not found")` to catch typos
4. In default.project.json, verify paths exist in src/

---

### 🚩 Casing Mismatch Signs

**What to look for**:
- Output says: **"module not found"** or **"WaitForChild timeout"**
- Code has `ReplicatedStorage:WaitForChild("shared")` but folder is "Shared"
- Remotes loaded but event fires to wrong place

**Common mismatches in code**:
| Code Line | Correct | Wrong | Issue |
|-----------|---------|-------|-------|
| `local Shared = ReplicatedStorage:WaitForChild("Shared")` | Shared (capital) | shared (lowercase) | Path not found; game hangs |
| `evt = Shared:WaitForChild("Remotes")` | Remotes (capital R) | remotes (lowercase) | Event never fires |
| `local Constants = Shared:WaitForChild("Constants")` | Constants (capital C) | constants (lowercase) | Module not found |

**How to find**:
- In Studio, open ReplicatedStorage and note exact folder/module names
- In code files (Terminal or VS Code), search for lowercase versions: `grep -i "waitforchmild.*shared" src/`

**Fix**:
1. Open each Lua file (RoundService, TimerUI, etc.)
2. Find all WaitForChild calls
3. Match case exactly to Studio folder names
4. Restart Rojo

---

### 🚩 Remotes Missing / Wrong Folder Signs

**What to look for**:
- Output says: **"Remotes is not a valid member of ReplicatedStorage"**
- Event fires but client never receives (no data flow)
- Toast notifications don't appear but blocks break (one-way communication only)

**How to confirm remotes exist**:
```lua
-- Add to RoundService (debug line):
print("[REMOTES] RemoteEvent:", ReplicatedStorage:FindFirstChild("Shared"):FindFirstChild("Remotes"):FindFirstChild("RoundUpdate"))
-- If this prints nil, event doesn't exist
```

**Common causes**:
- Remotes.lua not synced by Rojo (check src/shared/Remotes.lua exists)
- Remotes folder created by code but never called `broadcast()`
- Event fired to wrong folder: `ServerRemotes` instead of `Shared/Remotes`

**Fix**:
1. Verify `src/shared/Remotes.lua` exists on disk
2. In RoundService, check `broadcast()` fires: `evt:FireAllClients(...)`
3. In TimerUI, add debug print: `print("[CLIENT] Listening for RoundUpdate...")` then `local function onRoundUpdate(p) print("[CLIENT] Got event:", p) end; evt.OnClientEvent:Connect(onRoundUpdate)`
4. Check both server and client subscribe to same event name: "RoundUpdate"

---

## Quick Validation Checklist (Run Every Session)

Before deep testing, run these 5 checks:

| Check | Expected | Fails If | Fix |
|-------|----------|----------|-----|
| **Rojo reload** | No errors in Output | Red errors appear | Reload Rojo or fix casing in Lua files |
| **ReplicatedStorage structure** | Shared folder + Remotes inside | Remotes missing or duplicated | Restart Studio; manually create Shared/Remotes if needed |
| **Game starts** | UI appears, "Intermission" or "Waiting" message shown | Black screen or freeze | Check Spawns/Lobby exists; verify RoundService runs (add top print) |
| **WaitForChild warnings** | Zero yellow warnings in Output | "infinite yield possible" warnings | Find exact path in code; match case to Studio folders |
| **Coins appear** | HUD shows coin label after breaking 1 block | Label blank or unchanged | Check loot table loads; verify coin UI script runs (add print on spawn) |

---

