# Lucky Wave Heist — Codex & Development Guide

## Game Vision

**Lucky Wave Heist** is a fast, replayable "flood escape + lucky loot" Roblox survival game where 1–12 players drop into a neon harbor arena and climb, parkour, and outsmart rising water across three escalating waves. Every round is a heist run: the water is the security system, the arena is the vault, and Lucky Blocks are the loot crates.

### Core Loop
**Survive → Break Blocks → Get Stronger → Survive Longer → Earn More → Buy Upgrades → Repeat**

### Gameplay Promise
- **Accessible**: Easy-to-learn parkour + pick-up-and-play survival
- **Replayable**: Randomized loot, dynamic water patterns, escalating difficulty
- **Rewarding**: Every block broken yields loot; every upgrade feels meaningful
- **Tense**: Warning sirens, rising water, tight escape routes force improvisation
- **Social**: Team survival creates cooperation and shared moments

---

## Game Loop & Phases

### Phase 1: Lobby (20 seconds)
- Players spawn in a safe pre-game area
- See the arena map and water starting level
- Can visit the Shop to buy upgrades (persistent perks)
- Timer counts down to wave start
- Visual: calm harbor, idle water, neon accent lighting

### Phase 2: Wave 1 (60 seconds, slow rise)
- Water begins rising **slowly** (1 stud per ~2 seconds)
- Lucky Blocks spawn throughout arena (distributed clusters)
- Players break blocks to get random loot
- Early survival is easy; focus is on gathering blocks and exploring
- Visual: gentle water glow, particles, low tension

### Phase 3: Wave 2 (45 seconds, medium rise)
- Water rises **faster** (1 stud per ~1 second)
- Escape routes become tighter
- Blocks may be harder to reach; risk vs. reward intensifies
- Loot quality becomes critical for survival
- Visual: water glow brighter, foam particles, warning lights pulse

### Phase 4: Wave 3 (30 seconds, rapid rise)
- Water rises **aggressively** (1 stud per ~0.5 seconds)
- Pushes everyone toward tall landmarks (rooftops, cranes, towers)
- Few blocks left; those remaining are high-risk, high-reward
- Climax tension: last stand, final escapes, possible wipes
- Visual: intense water effects, bright warning lights, rumbling audio

### Phase 5: Victory / Defeat
- **Victory**: Team survives all waves → All alive players get base payout + performance bonuses (waves cleared, blocks broken, rare loot found)
- **Defeat**: Water wipes lobby → Round ends, show time survived + highest point reached
- Fast reset to Lobby (5 seconds) for next round

---

## Lucky Blocks System

### What Are Lucky Blocks?
- Breakable 2×2×2 studs cubes scattered around the arena
- Color-coded by rarity (visual tint + particle glow)
- Break with repeated clicks (3–8 hits depending on tier)
- Each block yields ONE random reward from the Loot Table

### Loot Table (25 Items, Weighted by Rarity)

#### **Common (40% drop rate)**
1. **+25 Coins** — Direct currency
2. **+50 Coins** — Larger haul
3. **+10 Coins** — Small gain
4. **Speed Burst** — +25% movement speed for 10 seconds
5. **Small Shield** — Absorb next water damage (1-hit barrier)
6. **Double Loot Ticket** — Next block drop is 2× value

#### **Uncommon (35% drop rate)**
7. **+100 Coins** — Major haul
8. **+75 Coins** — Solid mid-tier
9. **Speed Boost** — +50% movement speed for 15 seconds
10. **Jump Boost** — +40% jump height for 15 seconds
11. **Medium Shield** — Absorb 2 water hits
12. **Loot Magnet Charm** — Attract all blocks in 50-stud radius for 5 seconds
13. **Reroll Token** — Skip this reward, roll next time
14. **Time Slow** — Water rise slows by 50% for 8 seconds

#### **Rare (20% drop rate)**
15. **+200 Coins** — Jackpot
16. **+150 Coins** — Solid rare reward
17. **Double Earnings** — All coin rewards ×2 for rest of wave
18. **Invulnerable Potion** — Immune to water for 8 seconds
19. **Heavy Shield** — Absorb 5 water hits (rare survival save)
20. **Grapple Hook** — Enhanced climbing speed + air mobility for 12 seconds
21. **Team Speedup** — All nearby players +30% speed for 10 seconds
22. **Velocity Surge** — +100% jump height + air speed for 10 seconds

#### **Epic (4% drop rate)**
23. **+500 Coins** — Epic jackpot
24. **Legendary Shield** — Absorb 10 water hits (late-game survival)
25. **Time Freeze** — Water paused for 10 seconds (rare clutch save)

### Lucky Block Visuals
- **Common**: Bright yellow-orange, subtle pulse
- **Uncommon**: Electric blue, medium pulse
- **Rare**: Violet-pink, pronounced pulse + extra particles
- **Epic**: Gold-white, intense glow + particle spiral
- All tiers have **spark particles on break** + **satisfying pop sound**
- Reward toast appears above player: `[+100 Coins]` with rarity color

---

## Economy & Progression

### Currency: Coins
- Earned by: Breaking blocks (random), surviving waves (performance bonus), completing daily quests
- Spent on: Permanent shop upgrades, cosmetics (future)
- Persistent: Stored in DataStore (per-player, per-session)

### Shop: 6 Permanent Upgrades
Each upgrade is one-time purchase, applies forever:

1. **Loot Magnet** (100 coins)
   - Increase pickup radius by 30 studs (easier block collection)
   
2. **Wallet Expansion** (150 coins)
   - Start each round with +50 bonus coins (quality-of-life)
   
3. **Nimble Feet** (200 coins)
   - +15% movement speed (always active, felt progression)
   
4. **High Jumper** (200 coins)
   - +20% jump height (enables new parkour routes)
   
5. **Break Efficiency** (250 coins)
   - Reduce block hits needed by 1 (blocks break 25% faster)
   
6. **Daily Reroll** (300 coins)
   - Get 1 free "bad loot reroll" token per round (strategic choice)

### Performance Bonus (End of Wave)
```
Base Payout = 150 coins (if survive)
+ (Blocks Broken × 10)
+ (Waves Cleared × 100)
+ (Rare Items Found × 50)
```

### Daily Quests (Future Milestone 2)
- "Survive 1 Round" → +50 coins
- "Break 5 Blocks" → +50 coins
- "Find a Rare Item" → +100 coins
- "Win 3 Waves Without Dying" → +200 coins
- Quests reset daily, stackable bonus coins

---

## Arena Design Principles

### Map Layout
- **Base Area**: Harbor platforms, containers, cranes (low-rise, safe start)
- **Mid-Tier**: Rooftop pathways, scaffolding, suspended bridges (50–80 studs high)
- **High Ground**: Crane tops, tower peaks, isolated platforms (100–150 studs high)
- **Water Entry**: Multiple angles (from harbor level, spreads outward and upward)

### Lucky Block Distribution
- **Lobby**: 0 blocks (safe zone)
- **Wave 1**: 15–20 blocks, spread evenly across lower-to-mid areas
- **Wave 2**: 10–15 blocks, clustered at higher elevations (risk/reward)
- **Wave 3**: 5–8 blocks, only at peak heights (desperate last runs)

### Aesthetic: Neon Harbor Heist
- **Platforms**: Dark steel with weathered industrial look
- **Accents**: Teal neon strips (navigation guides), warning-red emergency lights (pulsing with water rise)
- **Water**: Glowing cyan, foam particles, rising audibly with low rumble
- **Lighting**: Moody, nighttime, accent lights reflect off wet surfaces
- **Audio**: Distant sirens, water splashes, drip sounds, warning tones

---

## Technical Architecture

### Service-Oriented Design
Each system is a ModuleScript service, required by ServerScripts:

#### **RoundService** (Main Game Loop)
- Manages round state: `Lobby` → `Wave1` → `Wave2` → `Wave3` → `Victory`/`Defeat`
- Handles wave transitions, timers, water rise progression
- Broadcasts state changes via RemoteEvents
- Coordinates all other services

#### **CurrencyService** (Economy)
- Tracks player coins (in-game + persistent DataStore)
- Handles shop purchases (validation, deduction, upgrades)
- Calculates and awards performance bonuses
- Studio mode support (mock data when testing)

#### **LuckyBlockSpawner** (Loot System)
- Spawns blocks at round start per wave
- Handles block break detection (Raycast on click)
- Rolls random rewards from Loot Table (weighted rarity)
- Manages pickup radius and delivery to players
- Particle + audio effects on break

#### **TsunamiService** (Water Simulation)
- Manages water part (position, size, tween speed)
- Calculates damage to players (health loss, wipe detection)
- Provides wave presets (Wave 1/2/3 rise speeds)
- Optional: wave pattern randomization (future)

#### **Remotes** (Communication)
- Factory for creating RemoteEvents
- Clean two-way messaging: Server ↔ Client
- Used for: loot toasts, state broadcasts, shop purchases, upgrades applied

### Content-Driven Design
**ContentPack.lua** (single source of truth):
- Loot Table definition (25 items, rarities, rewards)
- Shop upgrades list (prices, descriptions, IDs)
- Tuning: wave speeds, block HP, damage rates
- UI copy: button text, quest descriptions, toast messages
- All systems reference ContentPack for consistency

### File Structure
```
src/
├── server/
│   ├── Bootstrap.server.lua        # Arena initialization
│   ├── RoundService.lua             # Game loop orchestrator
│   ├── CurrencyService.lua          # Economy + shop
│   ├── LuckyBlockSpawner.lua        # Loot system
│   ├── TsunamiService.lua           # Water + damage
│   └── Remotes.lua                  # RemoteEvent factory
├── client/
│   ├── HUD.client.lua               # UI: coins, shop, toasts
│   ├── TimerUI.client.lua           # Wave timer + state display
│   └── UserInput.client.lua         # Player input handling
└── shared/
    ├── ContentPack.lua              # Game data + tuning
    └── [Utilities]                  # Shared helpers (future)
```

### Server-Authoritative Pattern
- **Server decides**: Block breaks, loot rolls, damage, purchases
- **Client is truthful**: Reports clicks to server; server validates
- **No exploits**: Money, upgrades, loot all server-verified
- **Clients notified**: RemoteEvents broadcast changes to all players

---

## UI/UX Design

### HUD Layout
- **Top-Left**: Coin Card (current coins, per-round earnings visual)
- **Top-Center**: Wave Banner (state: "Wave 1", timer, water progress bar)
- **Bottom-Center**: Water Progress Bar (visual % of wave survived)
- **Right-Side**: Toast Stack (loot notifications, system messages)
- **Center-Bottom** (Modal): Shop Panel (6 upgrades, buy buttons, descriptions)

### Toast Notifications
- Appear on right side, auto-dismiss after 3 seconds
- Loot drops: `[+100 Coins]` (color-coded by rarity)
- Boosts: `[Speed Boost Active!]`
- Purchases: `[Wallet Expansion Bought!]`
- Milestones: `[Wave 2 Cleared! +100 Bonus]`

### Lucky Block Feedback
- **Visual**: Break animation (shrink + scatter particles), rarity glow
- **Audio**: Crisp pop sound, pitch varies by rarity
- **Toast**: Reward appears above player's head, floats up and fades
- **Haptic** (mobile future): Rumble on break

### State Transitions
- **Lobby → Wave 1**: Fade in siren, water begins, "Wave 1 Start!" banner
- **Wave 1 → Wave 2**: "Wave 2 Incoming!" warning, water speed increases, lights pulse red
- **Wave 2 → Wave 3**: "Final Wave!" dramatic banner, intense music cue
- **Victory**: "Victory!" golden banner, all players celebrate, coin tally
- **Defeat**: "Wipe!" red banner, show time + height reached, restart prompt

---

## Design Philosophy & Pillars

### 1. **Accessibility**
- No complex mechanics to learn (click block → get loot)
- Visual clarity: rarity colors are instantly readable
- No pay-to-win: all upgrades are small QoL improvements
- Mobile-friendly controls: click to break, tap to shop

### 2. **Replayability**
- Randomized loot drops keep each round fresh
- Water patterns are consistent but arena changes (future waves variation)
- Performance-based scoring encourages multiple playstyles
- Daily quests give short-session rewards

### 3. **Tension & Pacing**
- Warning sirens and countdowns build dread
- Water rises visibly, forcing constant repositioning
- Escape routes close behind players (no backtracking)
- Climax in Wave 3 creates memorable moments

### 4. **Social Collaboration**
- Team-based survival encourages helping others
- Shared loot zone means cooperation over competition
- Performance bonus rewards group success
- Large player count (up to 12) enables chaotic fun

### 5. **Satisfying Feedback**
- Audible water rumble + visual effects on rise
- Block break has crisp pop + particle explosion
- Loot toasts are colorful and celebratory
- Upgrades have tangible, felt impact (you move noticeably faster)

---

## Roadmap: Future Milestones

### Milestone 2: Enemy AI & Obstacles
- Spawning obstacle robots that chase players
- Teleporting enemy NPCs at high elevations
- Destructible map sections (adds environmental hazards)

### Milestone 3: Advanced Power-Ups
- Crafting system: combine rare items for mega-rewards
- Seasonal cosmetics: unique skins, emotes, pet companions
- Leader boards: global high scores, weekly challenges

### Milestone 4: Sound & Polish
- Immersive audio: ambient harbor sounds, wave ambience
- Musical themes: tension track for Wave 3, victory fanfare
- SFX: footsteps, slide sounds, splash impacts

### Milestone 5: Daily Quests & Retention
- Full quest system with daily reset
- Quest rewards are substantial (10% of a session's earnings)
- Quest completion tracked, encouraging return plays

---

## Code Quality Standards

### Naming Conventions
- **Services**: `CurrencyService`, `LuckyBlockSpawner` (PascalCase, descriptive verbs)
- **Functions**: `_load()`, `_save()`, `breakBlock()` (camelCase, action-oriented)
- **Variables**: `playerCoins`, `blockHP`, `waveNumber` (camelCase, contextual)
- **Constants**: `STUDIO_MODE`, `MAX_PLAYERS`, `WAVE_SPEEDS` (UPPER_SNAKE_CASE)

### Error Handling
- Graceful fallback for Studio mode (no DataStore errors on local testing)
- Nil checks before accessing nested tables
- Try-catch on RemoteEvent invocations
- Meaningful error logging to Output

### Modular Design
- Each service handles one responsibility
- Services communicate via RemoteEvents or direct calls
- ContentPack is single source of truth for all game data
- No circular dependencies between services

### Performance Optimization
- Raycast for block detection (not FindPartOnRay, deprecated)
- Debounced input (clicks registered only once per 0.1 seconds)
- Efficient spawning: blocks created once per wave, not per player
- Tweens for smooth water rise (not frame-by-frame loops)

### Testing & Validation
- VALIDATION_CHECKLIST.md: confirm all systems work in Studio
- QA_TEST_CHECKLIST.md: 4-phase test plan (Bootstrap, Tsunami, Lucky Blocks, Shop)
- Git history: meaningful commits per feature, easy rollback
- Code comments: only where logic is non-obvious

---

## Prompt Template for Future Feature Implementation

When building new features or fixing issues, use this template:

```
CONTEXT:
- Feature: [Name of feature]
- Milestone: [Which milestone does this belong to?]
- Related systems: [Services it depends on]

REQUIREMENTS:
- [Specific requirement 1]
- [Specific requirement 2]
- [Performance/quality constraint]

ACCEPTANCE CRITERIA:
- [Testable success condition 1]
- [Testable success condition 2]

REFERENCE CONTENT:
- Codex section: [Link to relevant section]
- Related code: [File paths of similar implementations]

BUILD INSTRUCTIONS:
- [Specific file to create or modify]
- [Integration points with existing services]
- [Testing step to validate]
```

---

## Quick Reference: Common Tasks

### Adding a New Shop Upgrade
1. Add entry to `ContentPack.SHOP_UPGRADES` table
2. Add logic to `CurrencyService:buyUpgrade()` 
3. Add UI button to `HUD.client.lua` shop panel
4. Broadcast via `Remotes.shopUpdated` event
5. Test in Studio: purchase upgrade, verify it applies

### Adding a New Loot Item
1. Add entry to `ContentPack.LOOT_TABLE` with rarity weight
2. Add reward logic to `LuckyBlockSpawner:_awardLoot()`
3. Add toast message to `HUD.client.lua` for visibility
4. Test: break 20 blocks in Studio, verify distribution matches weights

### Adjusting Water Rise Speed
1. Edit `ContentPack.WAVE_SPEEDS` for each wave
2. `TsunamiService:tweenWater()` uses these presets
3. Test in Studio: start round, visually confirm speed feels right
4. QA: run VALIDATION_CHECKLIST.md "Tsunami Wave Speeds" test

### Debugging Server-Client Sync Issues
1. Add logging to RemoteEvent fires in both server and client
2. Use Output console to trace message sequence
3. Check for nil values or race conditions in event handlers
4. Use `Studio mode support` to test without DataStore complexities

---

## End of Codex

This document is the source of truth for Lucky Wave Heist development. Refer to it when:
- Building new features
- Making architectural decisions
- Onboarding new team members
- Validating code quality
- Planning future roadmap iterations

Last Updated: January 19, 2026
