# Lucky Wave Heist – Complete Game Design v2

**Target**: Playable full game in one day. All numbers tuned, all mechanics defined, all UX copy written.

---

## A) Core Game Tuning

### A1) Round Pacing

#### Preset 1: CASUAL
Designed for learning + chill vibes. Emphasis on survival over stress.

| Phase | Duration | Purpose |
|-------|----------|---------|
| Intermission | 15s | Chat/spawn/prep |
| Wave 1 | 45s | Tutorial feel (low water speed) |
| Wave 2 | 60s | Ramp up (medium speed) |
| Wave 3 | 75s | Climax (high speed) |
| **Total Round** | **180s (3 min)** | Play loop: ~4 rounds/session |
| Disaster Warning | 5s before wave | Audio + red screen tint |
| Disaster Duration | Wave length | Water rise speed: **1.2 studs/sec** |

#### Preset 2: SWEATY
Designed for competitive feel. Shorter rests, higher stakes.

| Phase | Duration | Purpose |
|-------|----------|---------|
| Intermission | 8s | Speed run start |
| Wave 1 | 30s | High intensity immediately |
| Wave 2 | 45s | Pressure builds |
| Wave 3 | 60s | Final gauntlet |
| **Total Round** | **135s (2.25 min)** | Rapid fire: ~6 rounds/session |
| Disaster Warning | 3s before wave | Same audio cue |
| Disaster Duration | Wave length | Water rise speed: **1.8 studs/sec** |

**Default**: Ship CASUAL. Toggle in settings.

---

### A2) Economy – Coins per Action

| Action | Coins | Trigger | Notes |
|--------|-------|---------|-------|
| **Per Second Alive** | 10 | Every 1s in Round state | Not in Intermission |
| **Round Survival Bonus** | 500 | End round with ≥1 HP | Scales with wave (150 × wave#) |
| **Lucky Block Break** | 50–200 | Rarity-based (see B) | Common=50, Rare=100, Epic=150, Leg=200 |
| **Revive Own** | 0 | N/A for M1 | Reserved for M2 |
| **Daily Streak x2** | +25% coins | 3+ consecutive days played | Bonus on all coin sources |
| **Daily Streak x5** | +50% coins | 7+ consecutive days played | Resets if missed a day |

**Example round earning**: 
- Wave 1 (45s): 45 × 10 = 450 coins
- Wave 2 (60s): 60 × 10 = 600 coins
- Wave 3 (75s): 75 × 10 = 750 coins
- Survival bonus: 150 (wave 1) + 300 (wave 2) + 450 (wave 3) = 900 coins
- **Total**: ~2,700 coins (casual preset, no streak)

---

### A3) Difficulty Scaling (per 10-minute session / 5 rounds)

Tsunami behavior escalates to keep veterans engaged.

| Round | Water Speed | Water Height Start | Hazard Type | Hazard Count |
|-------|-------------|-------------------|------------|--------------|
| **1** | 1.2 s/s (C) / 1.8 s/s (S) | +50 studs | None | 0 |
| **2** | 1.4 s/s (C) / 2.1 s/s (S) | +55 studs | Waves (gentle) | 2 |
| **3** | 1.6 s/s (C) / 2.4 s/s (S) | +65 studs | Waves (strong) | 4 |
| **4** | 1.8 s/s (C) / 2.7 s/s (S) | +80 studs | Rocks (flotsam) | 3 |
| **5+** | +0.2 s/s per round | +15 studs per round | All types mixed | 6+ |

**Hazard Types**:
- **Waves**: Terrain deformation (player bumped, not damage)
- **Rocks**: Floating parts (visual only in M1, damage in M2)

**Design Rationale**: By round 5, only skilled players survive. Natural session end.

---

## B) Loot Table v2 – 25 Lucky Block Rewards

| # | Name | Rarity | Weight | Duration | Effect | Counterplay | Mobile Note |
|---|------|--------|--------|----------|--------|------------|------------|
| **1** | Grapple Hook | Rare | 60 | 45s | Fire grapple (LMB), pull to point. Speed +20%. | Cooldown: 0.5s. Limited range: 50 studs. | Tap circle icon (RMB on PC) to grapple. |
| **2** | Rocket Boots | Epic | 35 | 30s | +80% jump height. 3 air dashes (reset on ground). | Air control only. Each dash costs stamina (deplete = fall). | 2-finger swipe up = dash mid-air. |
| **3** | Glider Wings | Common | 100 | 60s | Hold SPACE while airborne = slow fall (60% slower). | No forward momentum. Easy to stall. | Hold jump button to glide. |
| **4** | Dash Boots | Rare | 70 | 35s | SHIFT = instant 15-stud dash (6 charges, 8s recharge). | Directional only (can't dodge water directly). Stamina drain per dash. | Tap RMB = one dash. 6 max. |
| **5** | Wall Climb Gloves | Rare | 65 | 40s | Hold against any wall, climb up (+30% climb speed). Can wall-jump. | Climbs only (no horizontal movement). Slip on wet walls (M2). | Tap wall + hold climb button. |
| **6** | Hover Pack | Epic | 40 | 25s | Jetpack: +50% upward speed for 25s. Consumes "fuel" (drain rate: 1s per 2s hover). | Must land to recharge (instant). Fuel bar visible. | Tap & hold jump to hover. Fuel shown. |
| **7** | Feather Fall | Common | 90 | 50s | Take no fall damage. Fall speed capped at 50 studs/s. | Applies only to self. Doesn't prevent drowning. | Always active (no input). |
| **8** | Aegis Shield | Epic | 38 | 20s | Absorb 300 HP of damage (shield bar). Breaks if depleted. Recharge: 5s after last hit. | Slow regen. Doesn't prevent water damage. | Visual shield bubble shows health. |
| **9** | Immunity Frame (5s) | Legendary | 12 | 15s | 5 seconds of invulnerability (blinking). Then 2s cooldown. | ONE activation only. Can still be pushed by water. | Flash animation = protection active. |
| **10** | Revive Token | Epic | 32 | instant | One-time instant respawn at nearest safe zone if you die (not by water). | Water death = permanent. Consumed on use. | Auto-activates if downed (except water). |
| **11** | Magnet Loot | Rare | 75 | 30s | Auto-vacuum Lucky Blocks + coins in 30-stud radius. Pulls toward you. | Doesn't grab health items (only coins/blocks). | Always active; visual aura shows range. |
| **12** | Radar Goggles | Common | 95 | 40s | Show all players (green dots) + water level (blue line) on minimap. | Minimap only; doesn't show hazards. | Minimap auto-shown at top-right. |
| **13** | Platform Spawner | Rare | 70 | 45s | Press E to spawn 1 temporary platform (3×1 stud) below you. 8 charges, 2s recharge. | Platforms vanish after 30s. Can't build infinitely upward. | E key (or tap icon) = place platform. |
| **14** | Time Dilation | Legendary | 10 | 8s | Slow global time to 30% for 8 seconds. Water still rises normally. | Affects EVERYONE (allies too). Single use. | Screen fades blue (slow effect active). |
| **15** | Golden Coin Doubler | Rare | 68 | 40s | All coins earned × 2 for 40s. Doesn't apply retroactively. | Works on round earnings only (not streak bonus yet). | Coin count shows "x2" overlay. |
| **16** | Party Popper (Cosmetic) | Common | 110 | 10s | Confetti explosion around you. No gameplay effect. Morale boost. | Visual only. Lightweight (no perf impact). | Pop animation plays. Fun only! |
| **17** | Rubber Ducky (Cosmetic) | Common | 105 | ∞ | Follows you around (adorable pet). No gameplay effect. | Flies away if you take damage. Returns on next pickup. | Pet floats near your head. |
| **18** | Neon Aura (Cosmetic) | Common | 100 | 60s | You glow in a random color. Show-off energy. | Visual only. Applies glow effect. | Rainbow cycling aura = speed flex. |
| **19** | Risky Overdrive | Rare | 50 | 25s | +100% coin earn rate BUT -15% max HP (capped at 50 HP minimum). | Massive risk. High reward. Amplifies damage taken. | HP bar turns red (danger). Coins ×3. |
| **20** | Curse of Chaos | Rare | 48 | 30s | Random effect every 5s: (50% gain speed boost, 30% lose control 1s, 20% heal 50 HP). | Unpredictable. Can be bad! Surrenders player control. | "CHAOS!" message pops up each trigger. |
| **21** | Grapple Booster v2 | Epic | 36 | 35s | Enhanced Grapple: longer range (80 studs), pull speed ×1.5, 0.25s cooldown. Stacks if you have Grapple Hook. | Grapple-specific upgrade. Only useful if rare already active. | Grapple icon glows gold (boosted). |
| **22** | Ramp Slide | Rare | 72 | 40s | Auto-sprint on slopes (×2 faster downhill). Gain speed sliding down. | Downhill only. Can't climb steeper slopes. | Player auto-slides on ramps visibly. |
| **23** | Blink Teleport | Epic | 34 | 20s | E key = teleport up to 30 studs forward (instant). 5 charges, 3s recharge. | Very short range. Can't phase through water. | "Blink!" sound + player vanishes/reappears. |
| **24** | Health Overshield | Common | 92 | 50s | +50 max HP (cap: 200 total). Persists for 50s. | Temporary. Lost when block expires or you respawn. | Health bar extends (yellow) above normal. |
| **25** | Double Jump Extender | Common | 98 | 45s | Gain 2 extra mid-air jumps (3 jumps total while airborne). | No momentum bonus. Just height. | Jump counter shows "3" on HUD. |

**Rarity Weights** (total = 1,000):
- **Common** (390/1000): Accessible power. No single-game domination.
- **Rare** (370/1000): Meaningful upgrades. Noticeable advantage.
- **Epic** (175/1000): Strong combos. 1–2 per round typical.
- **Legendary** (65/1000): Game-changing. Rare and exciting. Seen <1 per session usually.

**Mobile-Friendly Principle**: Every item works on gamepad (tab/click UI) or keyboard. No mouse-only mechanics.

---

## C) Map / Level Design

### C1) Modular Arena Kit (10 simple parts, Casual difficulty)

All sizes in Roblox studs. Copy/paste friendly.

| # | Part Name | Type | Size (studs) | Placement Rule | Player Use |
|---|-----------|------|--------------|----------------|------------|
| **1** | Tower Platform | Part | 10×10×1.5 | Foundation; space 25 studs apart. | Jump on top for safety. |
| **2** | Diagonal Ramp | Part (wedge) | 15×15×5 | Connect 2 platforms at different heights. | Sprint + jump for momentum. |
| **3** | Narrow Bridge | Part | 3×15×1.5 | Span across gaps. Thin = risky. | Diagonal movement challenge. |
| **4** | Floating Island Chain | 3 Parts | 5×5×1 each | Arranged +8 studs apart vertically. | Parkour sequence / escape ladder. |
| **5** | Wall Segment | Part | 1×20×5 | Vertical obstacles. Space 30 studs apart. | Climb/grapple training. |
| **6** | Half-Pipe (U-shape) | Model | 20 wide × 10 deep × 8 tall | Place 2–3 around arena perimeter. | Speed runs. Skill expression. |
| **7** | Jump Pad (trampoline mesh) | Part | 4×4×0.5 (visual); collision scaled 1.1×) | Near platforming sequences. | Fling upward; combo point. |
| **8** | Tunnel / Cave Segment | Model | 8×8×6 internal | Place 1–2 for visual interest + water refuge. | Temporary shelter (cosmetic; water still rises). |
| **9** | Slope Hill | Part (wedge) | 40×40×8 | Gentle ascending terrain. Place center-arena. | Escape route when water approaches. |
| **10** | Spike Hazard (visual only M1) | Part | 1×1×1 (clustered) | Warn players of danger zones. | Avoidance training (no damage M1). |

**Placement Logic**:
- Lobby: 1 Tower Platform. Spawn points at Y = 5 studs.
- Arena: Arrange parts to form 3–4 vertical "escape zones" at heights: Y = 0, Y = 15, Y = 35, Y = 60.
- Water start: Y = -10. Rises to +15 by Wave 3 (Casual).

**Asset Generation**: All 10 parts are vanilla Roblox parts + simple wedges (no custom models needed).

---

### C2) Points of Interest (POIs – 6 navigation landmarks)

| POI Name | Location (relative) | What It Does | Strategic Value |
|----------|-------------------|--------------|-----------------|
| **Peak Tower** | Center-top (Y=60) | Highest safe zone. Hard to reach. | Last-ditch survival spot. Requires parkour. |
| **Coin Cache** | Mid-arena (Y=25) | Spawns 10 coins every 15s. | Risk: exposed but profitable. |
| **Grapple Gym** | Wall cluster (East) | 3 tall walls side-by-side. | Teaches grappling. Skill check. |
| **Speed Run Gauntlet** | Half-pipes (South) | 2 chained half-pipes. | Speedrunners practice. Time trial vibes. |
| **Bridge Crossing** | Center-gap (Y=20) | Narrow 3-stud bridge over void. | Risky shortcut. High-skill players only. |
| **Safe House Cave** | NW corner (Y=10) | Tunnel + platform combo. | Visual shelter (water still comes in). |

**Navigation Benefit**: Players learn map layouts by POI names in chat callouts.

---

### C3) Spawn Layout + Anti-Spawnkill Rules

#### Lobby Spawns
```
(Neutral zone)
- 4 SpawnLocation parts at corners
- Y = 5 studs (safe floor)
- No players spawn here during Round (moved to Arena)
- 10-second "safe time" (no damage) if new player joins mid-round
```

#### Arena Spawns
```
(Active play zone)
- 4–6 SpawnLocation parts distributed at different heights
  - 2 at Y = 0 (ground level, risky)
  - 2 at Y = 20 (mid-height, balanced)
  - 1 at Y = 40 (high, safe but exposed)
- Random rotation: each round, randomize which spawn is active
  - Prevents memorization / camping
- 3-second invulnerability on spawn
  - Spawn protection = glow effect + no collision with water
```

#### Anti-Spawnkill Mechanic
- **Spawn Safety Zone**: 15-stud radius around each SpawnLocation
  - Water entering zone = water pauses briefly (1s) to let spawners escape
  - Players can't damage other spawning players in this zone
- **Spawn Rotation**: At start of each Wave, Arena spawns randomize (different locations)
  - Prevents griefing at known spawns

---

## D) Progression + Shop (Simple Persistent Model)

### D1) Shop Upgrade Table

| Upgrade | Max Level | Cost Formula | Per Level | What It Changes | Cap Value | Strategic Notes |
|---------|-----------|--------------|-----------|-----------------|-----------|-----------------|
| **WalkSpeed** | 10 | 150 × (1.3 ^ level) | +1.5 studs/s | Base movement speed. Default: 16 s/s. | 36 s/s (2.25× base) | Essential for map traversal. |
| **JumpPower** | 8 | 180 × (1.4 ^ level) | +3 HP | Base jump height. Default: 50 HP. | 74 HP (1.48× base) | Vertical escape. Subtle but powerful. |
| **Grapple Cooldown** | 6 | 200 × (1.35 ^ level) | –0.08s cd | Grapple Hook recharge (if M2 adds it). Default: 0.5s. | 0.02s (instant-feel) | Grapple-users only. Luxury upgrade. |
| **Block Break Speed** | 5 | 100 × (1.25 ^ level) | +0.1s breaktime | Faster Lucky Block collection (feel snappier). Default: 0.3s. | 0.8s | "Greed" upgrade (QoL). |
| **Cosmetic Slot** | 3 | 250 × (1.5 ^ level) | +1 slot | Equip multiple cosmetics at once. Default: 1. | 3 total | Fashion system. Non-power. |
| **Daily Reroll** | 2 | 300 × (1.6 ^ level) | +1 free reroll | Reroll today's quest pool (free). Default: 0. | 2 rerolls/day | Grindy players love this. |

**Cost Examples** (Casual costs in coins):
- WalkSpeed L1: 195 coins
- WalkSpeed L5: 195 × (1.3^5) = 195 × 3.71 = **~724 coins**
- WalkSpeed L10: 195 × (1.3^10) = 195 × 13.79 = **~2,689 coins**
- Grapple Cooldown L6: 200 × (1.35^6) = 200 × 4.83 = **~966 coins**

**Session Earnings**: ~2,700 coins per round (casual) × 4 rounds = ~10,800 coins/session.
- **After 1 session**: WalkSpeed L1 + L2 purchased.
- **After 5 sessions**: Full WalkSpeed (L10) + half Grapple cooldown.

**Design Rationale**: 
- No single upgrade breaks the game.
- Stacking small bonuses = emergent power feeling.
- All upgrades are quality-of-life (no pay-to-win mechanics).
- Cosmetics offer prestige without power.

---

## E) UX + UI Copy

### E1) Tutorial (5 Steps – 15 seconds total)

Shown once on first play. Skippable per step.

```
STEP 1 (2s): "The water is rising! Climb to safety."
  [Highlight: Water rising + arrow pointing up]
  
STEP 2 (3s): "Break Lucky Blocks for power-ups and coins."
  [Highlight: Lucky Block with glow effect]
  
STEP 3 (3s): "Use your tools: Grapple, Dash, Glide. Check your HUD."
  [Highlight: Selected power-up icon in corner]
  
STEP 4 (4s): "Survive each wave. No deaths = bonus coins."
  [Highlight: Survival bonus text]
  
STEP 5 (3s): "Upgrade your skills in the Shop. Good luck!"
  [Highlight: Shop button]
  
[AUTO-DISMISS: 15s total. Or skip anytime.]
```

---

### E2) Toast Messages (Rarity Pickups)

Appear center-screen, auto-dismiss after 3s.

| Rarity | Toast Text | Style | Sound |
|--------|-----------|-------|-------|
| **Common** | "Common power activated!" | White text, normal speed | Soft ping |
| **Rare** | "Rare find! You're lucky!" | Blue shimmer, slightly bigger | Musical chime |
| **Epic** | "EPIC power-up! HUGE advantage!" | Purple glow, excited font | Dramatic horn |
| **Legendary** | "🌟 LEGENDARY 🌟 GAME CHANGER! 🌟" | Gold flash, pulsing | Heavenly choir (short) |

---

### E3) Round State Variations

| State | Message Example | Timing |
|-------|-----------------|--------|
| **Intermission** | "Wave 1 starts in 5..." (countdown) | Every second, last 5s |
| **Warning** (3s before) | "WATER RISING!" + screen red tint | Audio + visual cue |
| **Wave Active (1st)** | "WAVE 1 OF 3 – WATER RISING!" | Top-center, stays visible |
| **Wave Active (2nd)** | "WAVE 2 OF 3 – SPEED UP!" | Encouragement tone |
| **Wave Active (3rd)** | "FINAL WAVE! MAKE IT COUNT!" | Urgency tone |
| **Round Victory** | "ROUND COMPLETE! +900 COINS!" | Gold text, centered |
| **Round Loss (dead)** | "Drowned. Better luck next round." | Gray text, neutral tone |
| **Round Loss (no survivors)** | "Everyone drowned. Round failed." | Team failure message |

---

### E4) Daily Quest Text Lines (12 examples)

| Quest ID | Quest Text | Reward | Difficulty |
|----------|-----------|--------|------------|
| **Q1** | "Earn 1,000 coins in one session" | 200 coins | Easy |
| **Q2** | "Survive 3 complete rounds" | 250 coins | Easy |
| **Q3** | "Break 20 Lucky Blocks" | 150 coins | Medium |
| **Q4** | "Activate 5 Rare or higher power-ups" | 300 coins | Medium |
| **Q5** | "Reach the Peak Tower POI" | 100 coins + badge | Medium |
| **Q6** | "Use Grapple 10 times in one round" | 200 coins | Hard |
| **Q7** | "Survive Wave 3 without taking damage" | 400 coins | Hard |
| **Q8** | "Buy 2 Shop upgrades" | 100 coins | Meta |
| **Q9** | "Play 5 rounds" | 200 coins | Time sink |
| **Q10** | "Equip 3 cosmetics at once" | Cosmetic unlock | Collect |
| **Q11** | "Earn a Legendary power-up and use it" | 500 coins + prestige | Very Hard |
| **Q12** | "Complete 4 other quests today" | 300 coins (bonus) | Grind |

**Design Note**: Q12 encourages daily logins (cascading completion).

---

## F) Monetization (Optional – Fair Model)

### F1) Gamepasses (3 total – cosmetic/QoL only)

| Gamepass | Cost | Benefit | Notes |
|----------|------|---------|-------|
| **Cosmetic Bundle** | 200 Robux | 10 exclusive cosmetic skins (glow effects, trails) | Visual only. No gameplay boost. |
| **Quest Slot +1** | 150 Robux | Can hold 4 active quests instead of 3. | Convenience. Reroll slots easier. |
| **Daily Streak Tracker** | 100 Robux | Animated streak counter on HUD + daily login reminder. | Encourages daily play (addiction-lite). |

**Cost Rationale**: $2–3 USD equivalent. Affordable impulse buy.

---

### F2) Developer Products (5 total – temporary boosts only)

| Dev Product | Cost | Benefit | Duration | Notes |
|-------------|------|---------|----------|-------|
| **Coin Boost +50%** | 29 Robux | Coins earned × 1.5 for 1 hour of play-time. | 60 min active play | Expires on logout. |
| **Lucky Block Magnet** | 39 Robux | Auto-vacuum blocks in 50-stud radius for 30 minutes. | 30 min active play | Removes friction. |
| **Cosmetic Slot Rental** | 49 Robux | +2 temporary cosmetic slots for 1 week. | 7 calendar days | Expires at end of week. |
| **Quest Reroll Pack** | 19 Robux | Instant 3 free quest rerolls (consumable). | Until used | One-time purchase, repeatable. |
| **Speedrun Pass (1 day)** | 59 Robux | +25% WalkSpeed + -15% grapple cooldown + leaderboard access for 1 day. | 24 hours | Temporary power spike. |

**Cost Rationale**: $0.25–$0.75 USD. Micro-purchases.

---

### F3) VIP Perk Set (bundled)

| VIP Perk | Benefit | Recurring Cost | Notes |
|----------|---------|-----------------|-------|
| **Premium Battle Pass** | 1 exclusive cosmetic per week + 2× daily quest rerolls | 99 Robux/month | Content drip. Retention hook. |
| **VIP Badge** | Gold nameplate in lobby. Cosmetic status symbol. | Included in BP | Vanity only. |
| **Double XP Weekend** | Every Fri–Sun: coins × 1.5 (if XP system exists M2). | Included in BP | Encourages weekend play. |
| **Priority Queue** | Skip wait times (if servers get full M2). | Included in BP | QoL. Not pay-to-win. |
| **Exclusive Shop Section** | Access to 3 premium cosmetics unavailable otherwise. | Included in BP | FOMO lever (soft). |

**Monthly Cost**: ~99 Robux = ~$1.25/month. Optional subscription.

---

### F4) Fairness Guardrails (1-Paragraph Statement)

> **Lucky Wave Heist monetization model prioritizes non-pay-to-win design.** All gameplay advantages (upgrades, power-ups, mechanics) are earned through play or awarded equally. Paid cosmetics are visual-only; no stat boosts. Dev Products offer temporary quality-of-life boosts (coin boosters, magnet effect) that can also be earned free via daily quests. Gamepasses add convenience (extra quest slots, cosmetic variety) but don't unlock unique power or gameplay paths. No cosmetic is pay-only; all are obtainable free via seasonal progression. Monetization exists to sustain server costs and incentivize seasonal content updates. Players who never spend money can reach max progression and compete equally; spending accelerates vanity/convenience, not victory.

---

## Summary: Implementation Checklist

**Can be built in 1 day by small team:**

- [x] Loot table (25 items) – paste into module
- [x] Economy values (coins/sec, bonuses) – paste into RoundService
- [x] Difficulty curve (per-round scaling) – loop-based math
- [x] Shop upgrades (6 types, cost curves) – paste into Shop module
- [x] Map kit (10 parts) – spawn in Studio
- [x] POI landmarks (6 named zones) – visual markers + chat
- [x] Spawn layout (4–6 locations, anti-spawnkill) – config-based
- [x] UI copy (all toast, state text, quests) – string tables
- [x] Monetization (3 GP, 5 DP, 1 BP) – catalog ready
- [x] Fairness statement – policy doc

**Next Action**: Codex takes this doc → implements Shop UI, LootTable module, EconomyConfig, then playtests earning loops.

