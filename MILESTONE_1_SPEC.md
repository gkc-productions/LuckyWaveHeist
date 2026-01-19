# LUCKY WAVE HEIST - MILESTONE 1 SPECIFICATION

## Project Overview
Lucky Wave Heist is a Roblox game where players work together in a heist scenario with round-based gameplay, wave progression, and team coordination.

## Milestone 1 Scope
Implement core round system, team setup, player joining, and basic wave progression with minimal files.

---

## DIRECTORY STRUCTURE

```
src/
├── server/
│   ├── RoundManager.server.lua
│   └── PlayerManager.server.lua
├── shared/
│   ├── RoundStates.lua
│   ├── Constants.lua
│   └── RemoteEvents.lua
└── client/
    └── RoundUI.client.lua
```

---

## ROUND STATES

The game progresses through these states:

| State | Description | Duration | Next State |
|-------|-------------|----------|-----------|
| **Lobby** | Waiting for players (min 1 player) | Infinite or 30s timeout | Wave Start |
| **Wave Start** | Players spawn, briefing shown | 5 seconds | Active |
| **Active** | Round in progress, players complete objectives | Variable (60-120s) | Wave End or Defeat |
| **Wave End** | Round completed successfully | 3 seconds | Wave Start (next wave) or Victory |
| **Defeat** | All players dead or time expired | 3 seconds | Lobby |
| **Victory** | All waves completed (Milestone 1: 3 waves) | 5 seconds | Lobby |

---

## SHARED MODULE: RoundStates.lua

```lua
-- Enum-like table for round states
return {
    LOBBY = "Lobby",
    WAVE_START = "WaveStart",
    ACTIVE = "Active",
    WAVE_END = "WaveEnd",
    DEFEAT = "Defeat",
    VICTORY = "Victory"
}
```

---

## SHARED MODULE: Constants.lua

```lua
return {
    -- Wave Configuration
    MAX_WAVES = 3,
    WAVES = {
        { number = 1, duration = 60, enemyCount = 5 },
        { number = 2, duration = 75, enemyCount = 8 },
        { number = 3, duration = 90, enemyCount = 12 },
    },
    
    -- Lobby Settings
    MIN_PLAYERS = 1,
    LOBBY_TIMEOUT = 30,
    
    -- State Durations (seconds)
    WAVE_START_DURATION = 5,
    WAVE_END_DURATION = 3,
    VICTORY_DURATION = 5,
    DEFEAT_DURATION = 3,
    
    -- Teams
    TEAMS = {
        { name = "Heist Team", color = BrickColor.new("Cyan") }
    },
    
    -- Spawn Points
    SPAWN_LOCATION_PREFIX = "Spawn"
}
```

---

## SHARED MODULE: RemoteEvents.lua

These are the networked communication channels:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create folder for RemoteEvents if needed
if not ReplicatedStorage:FindFirstChild("Events") then
    Instance.new("Folder", ReplicatedStorage).Name = "Events"
end

local Events = ReplicatedStorage:WaitForChild("Events")

-- Remote Events (server → all clients or bidirectional)
local remoteEvents = {
    -- Round State Changes
    RoundStateChanged = Instance.new("RemoteEvent", Events),
    
    -- Wave Progression
    WaveStarted = Instance.new("RemoteEvent", Events),
    WaveEnded = Instance.new("RemoteEvent", Events),
    
    -- Player Events
    PlayerJoined = Instance.new("RemoteEvent", Events),
    PlayerLeft = Instance.new("RemoteEvent", Events),
    
    -- Game Events
    GameVictory = Instance.new("RemoteEvent", Events),
    GameDefeat = Instance.new("RemoteEvent", Events),
}

-- Name them for debugging
for eventName, event in pairs(remoteEvents) do
    event.Name = eventName
end

return remoteEvents
```

---

## SERVER: RoundManager.server.lua

Core round/wave logic running on the server.

**Responsibilities:**
- Manage round state transitions
- Track current wave number
- Handle wave timer and completion
- Signal state changes to clients

**Pseudocode:**
```
1. Initialize: currentWave = 1, currentState = LOBBY
2. Monitor player count → when ≥ MIN_PLAYERS, start countdown
3. Countdown expires → transition to WAVE_START
4. WAVE_START (5s) → spawn players → transition to ACTIVE
5. ACTIVE: 
   - Run wave timer
   - If timer expires: transition to WAVE_END
   - If all players die: transition to DEFEAT
6. WAVE_END (3s) → check if currentWave < MAX_WAVES
   - Yes: increment wave, loop to WAVE_START
   - No: transition to VICTORY
7. VICTORY (5s) → reset, transition to LOBBY
8. DEFEAT (3s) → reset, transition to LOBBY
```

**Key Functions:**
- `ChangeState(newState)` - Broadcast state change to clients
- `StartWave(waveNumber)` - Initialize wave with enemy count
- `EndWave()` - Check win/loss conditions
- `SpawnPlayers()` - Place players at spawn points
- `ResetRound()` - Clear state for next cycle

---

## SERVER: PlayerManager.server.lua

Handle player joining, leaving, and team assignment.

**Responsibilities:**
- Detect players joining the game
- Assign players to team
- Track alive/dead players
- Remove disconnected players from tracking

**Pseudocode:**
```
1. On game start: Listen for Players.PlayerAdded
2. PlayerAdded event:
   - Create character humanoid listener
   - On death: increment dead count, check if all dead
   - If all dead: trigger wave defeat
3. On player leaving: Clean up character, decrease player count
4. Broadcast PlayerJoined/PlayerLeft events
```

**Key Functions:**
- `PlayerJoined(player)` - Set up new player
- `PlayerLeft(player)` - Clean up
- `IsAllPlayersDead()` - Return true if all are dead

---

## CLIENT: RoundUI.client.lua

Display round state and wave info to players.

**Responsibilities:**
- Listen for RoundStateChanged events
- Display current state (Lobby, Wave 1, Active, etc.)
- Show wave number and timer
- Show player count

**Pseudocode:**
```
1. Connect to RoundStateChanged remote event
2. Create ScreenGui with TextLabels
3. On state change:
   - Update UI with new state name
   - Show wave number
   - Update player count display
4. Listen to WaveStarted and update timer UI
5. Show "Wave X / 3" and time remaining
```

**UI Elements:**
- TextLabel: "Round State: [Current State]"
- TextLabel: "Wave: X / 3"
- TextLabel: "Players: X"

---

## REMOTE EVENTS COMMUNICATION

**Server → Clients:**
- `RoundStateChanged` - Sends: `{newState, timestamp}`
- `WaveStarted` - Sends: `{waveNumber, duration}`
- `WaveEnded` - Sends: `{waveNumber, success}`
- `GameVictory` - No data (fires when all waves complete)
- `GameDefeat` - Sends: `{reason}` ("AllPlayersDead" or "TimeExpired")

**Clients → Server:**
- (None in Milestone 1 - purely responsive)

---

## MILESTONE 1 RULES

1. **Joining**: Players spawn into Lobby state
2. **Starting**: With ≥ 1 player, game starts 30s countdown
3. **Waves**: 3 sequential waves (durations: 60s, 75s, 90s)
4. **Winning**: Survive all 3 waves → Victory state → return to Lobby
5. **Losing**: All players die OR wave timer expires → Defeat state → return to Lobby
6. **Respawn**: (Milestone 2) - Not implemented in M1; players stay dead
7. **Enemies**: (Milestone 2) - Not spawned; logic only exists

---

## FILES TO CREATE (Milestone 1)

1. ✅ `src/server/RoundManager.server.lua` - Round state machine
2. ✅ `src/server/PlayerManager.server.lua` - Player tracking
3. ✅ `src/shared/RoundStates.lua` - State enum
4. ✅ `src/shared/Constants.lua` - Game constants
5. ✅ `src/shared/RemoteEvents.lua` - Event definitions
6. ✅ `src/client/RoundUI.client.lua` - UI display

**Total: 6 files**

---

## TESTING CHECKLIST

- [ ] Game starts in Lobby
- [ ] Countdown begins when 1+ player joins
- [ ] Wave 1 starts after countdown
- [ ] Wave 1 transitions to Wave End after timer
- [ ] Wave 2 starts
- [ ] Wave 2 completes
- [ ] Wave 3 starts and completes
- [ ] Victory state triggers after Wave 3
- [ ] Game returns to Lobby
- [ ] UI displays correct wave number and state
