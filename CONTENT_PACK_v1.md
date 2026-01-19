# Lucky Wave Heist – Content Pack v1
## Implementable in 1 Day

---

## 1) Tsunami / Disaster Tuning (2 Presets)

### Preset A: CASUAL
For new players. Forgiving. ~3–4 rounds per session.

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Intermission** | 15 seconds | Chat/prep time |
| **Round Duration** | 120 seconds (2 min) | 3 waves of 40s each |
| **Wave 1 Duration** | 40s | Speed: 1.2 studs/sec |
| **Wave 2 Duration** | 40s | Speed: 1.4 studs/sec |
| **Wave 3 Duration** | 40s | Speed: 1.6 studs/sec |
| **Disaster Warning** | 5 seconds before wave | Red screen tint + alarm sound |
| **Water Rise Speed Baseline** | 1.2 studs/sec | Starts at Wave 1 |
| **Catch-Up Mechanic** | +0.2 studs/sec per wave (linear) | Accelerates smoothly |
| **Difficulty Scaling (5 rounds)** | Round 1 = base; Round 5 = +0.8 studs/sec | Reaches 2.0 studs/sec by round 5 |
| **Water Start Position** | Y = -5 studs | Below arena floor |
| **Player Death Zone** | Y = -50 studs | Failsafe depth (touching water = death at Y > -5) |

**Example progression**:
- Round 1: Wave speeds [1.2, 1.4, 1.6] studs/sec
- Round 2: Wave speeds [1.4, 1.6, 1.8] studs/sec
- Round 5: Wave speeds [2.0, 2.2, 2.4] studs/sec

---

### Preset B: SWEATY
For veterans. High pressure. ~5–6 rounds per session.

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Intermission** | 8 seconds | Quick restart |
| **Round Duration** | 90 seconds (1.5 min) | 3 waves of 30s each |
| **Wave 1 Duration** | 30s | Speed: 1.8 studs/sec |
| **Wave 2 Duration** | 30s | Speed: 2.1 studs/sec |
| **Wave 3 Duration** | 30s | Speed: 2.4 studs/sec |
| **Disaster Warning** | 3 seconds before wave | Same visual cue (more intense) |
| **Water Rise Speed Baseline** | 1.8 studs/sec | Aggressive from start |
| **Catch-Up Mechanic** | +0.3 studs/sec per wave (aggressive) | Steep acceleration |
| **Difficulty Scaling (5 rounds)** | Round 1 = base; Round 5 = +1.2 studs/sec | Reaches 3.0 studs/sec by round 5 |
| **Water Start Position** | Y = -5 studs | Same as Casual |
| **Player Death Zone** | Y = -50 studs | Same as Casual |

**Example progression**:
- Round 1: Wave speeds [1.8, 2.1, 2.4] studs/sec
- Round 2: Wave speeds [2.1, 2.4, 2.7] studs/sec
- Round 5: Wave speeds [3.0, 3.3, 3.6] studs/sec

**Tuning Values** (shared, adjustable per difficulty):
1. **Wave Speed Multiplier**: Adjust baseline speed globally (1.0 = current, 1.2 = harder)
2. **Catch-Up Rate**: Adjust acceleration per round (0.2 = gentle, 0.4 = aggressive)
3. **Intermission Buffer**: Add grace seconds when spawning (0 = hard spawn, 3 = soft spawn)

**Recommended Default**: CASUAL (ship with this; toggle in settings)

---

## 2) Lucky Block Loot Table v3 (25 Items)

| # | Item | Tier | Weight | Duration | Effect | Implementation Notes | Mobile Note |
|---|------|------|--------|----------|--------|----------------------|------------|
| 1 | Grapple Hook | Rare | 70 | 45s | Fire hook (E key), pull to point. Speed +15%. Cooldown: 0.5s. | Raycast from player, create attachment, tween player to target. Max range: 60 studs. | Tap icon, aim, tap target. |
| 2 | Rocket Boots | Epic | 40 | 30s | +80% jump height. Gain 3 mid-air dashes (reset on ground). | Modify JumpPower stat; track air jumps remaining. Deplete = fall. | Tap jump in air to dash. Shows "3/3" counter. |
| 3 | Glider Wings | Common | 110 | 60s | Hold SPACE mid-air = slow fall (60% slower). No forward momentum. | Reduce fall speed when `falling` and `space held`. Simple math: `velocity.Y = velocity.Y * 0.4`. | Hold jump to glide. Automatic. |
| 4 | Dash Boots | Rare | 75 | 35s | SHIFT = 15-stud instant dash. 6 charges, 8s recharge global. | MoveDirection raycast. Create charging system (charges: 6, regen: 1 per 8s). | Tap RMB (or LMB+drag) to dash directionally. |
| 5 | Wall Climb Gloves | Rare | 65 | 40s | Hold near wall + climb key = climb up. Wall-jump enabled. +30% climb speed. | Raycast side; if hit, enable vertical movement on wall. Slip chance on wet surfaces (M2). | Press against wall + hold climb button. |
| 6 | Hover Pack | Epic | 38 | 25s | Jetpack: +50% upward velocity for 25s. Drains "fuel" (1 sec fuel per 2s hover). | Track fuel (max 25, drain 0.5/sec when active). Recharge on ground (instant). Show fuel bar. | Tap & hold jump to hover. Fuel bar visible. |
| 7 | Feather Fall | Common | 105 | 50s | No fall damage. Cap fall speed at 50 studs/sec. | Detect `Humanoid.StateChanged == Landed`; bypass damage. | Passive. Always active. |
| 8 | Aegis Shield | Epic | 42 | 20s | Absorb 300 HP damage (shield pool). Breaks if depleted. Regen: 5s after last hit. | Track shield pool separately (not health). Reduce damage taken from shield first. Glow effect on shield. | Bubble icon shows shield pool. Visual only. |
| 9 | Immunity Window (5s) | Legendary | 15 | 15s | 5 seconds invulnerable (blinking glow). Then 2s cooldown. ONE use only. Activate on-hit or manual (E key). | Humanoid.TakeDamage intercept. Set `CanTakeDamage = false` for 5s. Blink animation loop. | Auto-trigger if downed. Or press E manually. |
| 10 | Revive Token | Epic | 35 | Instant | One-time auto-respawn if drowned (except water death). Respawn at nearest safe zone. | Detect water collision → death imminent → auto-teleport to Spawns/Arena[random]. Consumed on use. | Auto-triggers. No input needed. |
| 11 | Coin Magnet | Rare | 80 | 30s | Auto-vacuum coins + Lucky Blocks in 30-stud radius. Pull toward player. | Create invisible area; detect coins/blocks; `MoveTo` them toward player. Aura effect visual. | Passive. Aura shows range. |
| 12 | Radar Goggles | Common | 100 | 40s | Show all players (green dots) + water level (blue line) on minimap. | Create GUI minimap; update player positions every 0.1s. Draw line for water. | Minimap auto-shown. Tap to zoom. |
| 13 | Platform Spawner | Rare | 72 | 45s | Press E to spawn platform (3×1 studs). 8 charges, 2s recharge. Platforms vanish after 30s. | Create new part on-click; Parent to Workspace; schedule destroy after 30s. Prevent spam (2s cooldown). | E key = place below you. Shows "8/8" charges. |
| 14 | Time Slow (Global) | Legendary | 12 | 8s | Slow all time to 30% speed for 8s. Water STILL rises normally (exception). | Modify `RunService.Heartbeat` delta; scale all movement/animations by 0.3. Water unaffected. Single use. | Screen fades blue. Affects everyone. |
| 15 | Coin Doubler | Rare | 70 | 40s | All coins earned × 2 for 40s. Retroactive to round start if active at round end. | Add multiplier flag. On coin add, check flag and multiply. Show "x2" overlay on coin count. | Coin display shows "2×" icon. |
| 16 | Party Popper | Common | 120 | 10s | Confetti explosion + celebratory sound. No gameplay effect. Pure fun. | Spawn 20 ConfettiParts with random colors; tween downward; destroy after 2s. Audio: celebratory fanfare. | Auto-triggers. Fun only! |
| 17 | Rubber Ducky | Common | 115 | ∞ | Adorable pet NPC follows you (flies). No gameplay effect. Leaves if you take damage. | Spawn humanoid-sized part (ducky model or sphere). Weld to player HRP with offset. Destroy if player hurt. | Pet floats near head. Cute mascot. |
| 18 | Neon Aura | Common | 110 | 60s | You glow in random color. Cycles RGB. Pure cosmetic. | Add SurfaceGui to character; display neon color cycle. Cycles: Red → Green → Blue → repeat. | Rainbow glow effect. Show-off cosmetic. |
| 19 | Risky Overdrive | Rare | 55 | 25s | +100% coin earn rate BUT -15% max HP (min 50 HP). Amplifies damage taken. | Apply multiplier to coin gains. Reduce MaxHealth by 15%; cap at 50. Show red HP bar indicator. | HP bar turns red. High risk, high reward. |
| 20 | Chaos Potion | Rare | 50 | 30s | Every 5s: 50% gain random buff, 30% lose control 1s, 20% heal 50 HP. | Seed random every 5s in loop. Apply effect. Show toast "CHAOS!" on trigger. Can be bad. | "CHAOS!" message pops up. Unpredictable fun. |
| 21 | Grapple v2 (Enhanced) | Epic | 36 | 35s | Longer grapple range (80 studs, +25%), faster pull (1.5×), cooldown 0.25s. Stacks with Grapple Hook if both active. | Same as item 1, but with boosted parameters. Only useful if Grapple Hook already in inventory. | Enhanced grapple. Icon glows gold. |
| 22 | Speed Ramp Boost | Rare | 68 | 40s | On slopes/ramps: +150% downhill speed (auto-sprint). Gain speed sliding. | Detect slope angle; apply multiplier if going downhill. Uphill unaffected. | Player auto-slides. Visible on ramps. |
| 23 | Blink Teleport | Epic | 38 | 20s | E key = teleport up to 30 studs forward (instant). 5 charges, 3s recharge per charge. | Raycast forward 30 studs; teleport HRP. Check no-clip zones (prevent teleport into water). 5 max charges. | "Blink!" sound + vanish/reappear. |
| 24 | Health Overshield | Common | 108 | 50s | +50 max HP (cap: 200 total). Temporary pool. Lost on respawn or expiry. | Store original MaxHealth; add 50 for duration. Restore on expiry or death. Show yellow bar overlay. | Health bar extends yellow above normal. |
| 25 | Double Jump Extender | Common | 112 | 45s | +2 extra mid-air jumps (3 total). No momentum bonus—pure height. Jump counter shows "3/3" on HUD. | Track jump count in air. Reset on ground. Allow 3 total jumps before grounded. | Jump counter shows "3". Up to 3 hops. |

**Rarity Weight Distribution** (total = 1,000):
- **Common** (600/1000): Easy early-game power. No dominance.
- **Rare** (280/1000): Meaningful upgrades. 1–2 per round typical.
- **Epic** (90/1000): Strong combos. Rare excitement.
- **Legendary** (30/1000): Game-changing. 1 per 3–4 sessions typically.

**Drop Logic**: On Lucky Block break, roll rarity by weight → select random item of that rarity.

---

## 3) Shop Upgrades (6 Items)

| Upgrade | Max Level | Cost per Level | What It Changes | Cap | Why It's Fair |
|---------|-----------|-----------------|-----------------|-----|---------------|
| **Loot Magnet** | 5 | L1: 300 / L2: 450 / L3: 675 / L4: 1,012 / L5: 1,518 | Increase coin vacuum radius. Base: 20 studs → L5: 40 studs. Also pulls blocks 10% closer to player. | 40 studs radius | QoL only. Doesn't give *more* coins; just easier pickup. |
| **Wallet Expansion** | 5 | L1: 250 / L2: 375 / L3: 562 / L4: 843 / L5: 1,264 | Starting coins next round +100. L1: +100 → L5: +500. | +500 coins/round | Small advantage, but grinding = better. Avoids pay-to-win because same earnings available free. |
| **WalkSpeed** | 8 | L1: 200 / L2: 300 / L3: 450 / L4: 675 / L5: 1,012 / L6: 1,518 / L7: 2,277 / L8: 3,415 | Base: 16 studs/sec → L8: 28 studs/sec (+75%). | 28 studs/sec | Small increments (≈1.5 studs/sec per level). Doesn't trivialize map. Quality-of-life (less backtracking). |
| **JumpPower** | 6 | L1: 220 / L2: 330 / L3: 495 / L4: 742 / L5: 1,113 / L6: 1,670 | Base jump height increases. Humanoid.JumpPower: 50 → L6: 95 (+90%). | 95 HP equivalent | Vertical escape = skill expression. Small, consistent advantage. Fair because available to all players. |
| **Break Speed** | 5 | L1: 150 / L2: 225 / L3: 337 / L4: 506 / L5: 759 | Lucky Block collection speed. Base: 0.3s → L5: 0.15s (-50% faster). | 0.15s pickup | Greed upgrade. QoL (faster feel). No gameplay advantage (collect same blocks, same total coin). |
| **Daily Reroll** | 3 | L1: 400 / L2: 600 / L3: 900 | Free quest rerolls per day. Base: 0 → L3: 3 rerolls/day. | 3/day | Convenience. Doesn't give bonus coins; just flexibility to avoid hard quests. Grind-friendly, not pay-gated. |

**Cost Scaling Formula** (example for levels 1–8):
- L1: base × 1.0
- L2: base × 1.5
- L3: base × 2.25
- L4: base × 3.375
- L5+: base × (1.5 ^ level)

**Total Cost to Max (all 6 upgrades to max levels)**:
- All 6 to max ≈ 35,000 coins total
- Session earning (casual): ≈2,500 coins/round × 4 rounds = 10,000 coins/session
- Time to fully max: ~4 sessions (≈40 minutes gameplay)

**Design Philosophy**: All upgrades are incremental quality-of-life improvements. No single upgrade breaks the game. Stacking small bonuses creates "character progression" feel without pay-to-win mechanics.

---

## 4) Daily Quests (12 Lines)

| # | Quest Text | Requirement | Reward | Difficulty |
|---|-----------|-------------|--------|-----------|
| 1 | "Earn 2,000 coins in one session" | Survive 4 complete rounds | 300 coins + 1 badge | Easy |
| 2 | "Survive 3 full rounds without dying" | Complete 3 consecutive rounds alive | 400 coins | Easy |
| 3 | "Break 25 Lucky Blocks" | Open 25 blocks total (any rarity) | 250 coins | Medium |
| 4 | "Activate 5 Rare+ power-ups" | Pickup Rare/Epic/Legendary (cumulative) | 350 coins | Medium |
| 5 | "Reach the Peak POI" | Visit highest safe zone once | 150 coins + skin unlock | Medium |
| 6 | "Use Grapple 15 times" | Fire grapple hook 15 times in one round (requires pickup) | 300 coins | Hard |
| 7 | "Survive Wave 3 without damage" | Complete final wave with 100 HP (no hits) | 500 coins | Hard |
| 8 | "Purchase 2 Shop upgrades" | Buy any 2 upgrades (any level) | 200 coins | Meta |
| 9 | "Play 5 rounds" | Complete 5 round cycles (pass or fail) | 250 coins | Time sink |
| 10 | "Equip 3 cosmetics simultaneously" | Activate Party Popper + Neon Aura + Ducky | 100 coins + cosmetic unlock | Collect |
| 11 | "Land a Legendary power-up and use it" | Pickup Legendary tier item + active for 5s+ | 600 coins + prestige badge | Very Hard |
| 12 | "Complete 4 other quests today" | Finish quests 1–11 (any 4) | 400 coins bonus | Grind |

**Quest Reset**: Daily quests refresh at UTC midnight. Players can reroll 1 free per day (or more with Reroll upgrade).

**Difficulty Tags**:
- **Easy**: New players (2 rounds to clear)
- **Medium**: Standard players (1 session to clear)
- **Hard**: Requires skill or luck (2–3 sessions)
- **Meta**: Grind-y / progression-based
- **Very Hard**: Rare RNG + skill

**Design Note**: Quest #12 cascades completion (incentivizes doing other quests). Quest #7 (Wave 3 no-hit) is a skill checkpoint.

---

## 5) UI Copy Pack

### Toast Messages (Rarity-Based)

**When player picks up a Lucky Block, show for 3 seconds (auto-dismiss):**

| Rarity | Toast Text | Visual Style | Sound Effect |
|--------|-----------|--------------|--------------|
| Common | "⭐ Common power activated!" | White text, normal speed | Soft "ping" |
| Rare | "✨ Rare find! You're lucky!" | Blue shimmer, medium speed | Musical chime (2-note) |
| Epic | "💥 EPIC power-up! BIG advantage!" | Purple glow, larger font, pulsing | Dramatic brass horn (short) |
| Legendary | "🌟 LEGENDARY! GAME CHANGER! 🌟" | Gold + rainbow flash, excited font | Heavenly choir (2-second) |

---

### Round State Text (Center Screen, Large Font)

| State | Message | Timing | Notes |
|-------|---------|--------|-------|
| **Waiting** | "Waiting for players..." | On load | Gray text, loading spinner |
| **Intermission** | "Round starting in 5..." (counts down) | Every 1s, last 5s before round | Yellow text, countdown timer |
| **Warning (3s before)** | "⚠️ WATER RISING ⚠️" + red screen tint | 3 seconds | Red text, screen flashes red, alarm beep |
| **Wave 1 Active** | "🌊 WAVE 1 OF 3 – WATER RISING!" | Start of wave | Blue text, stays visible until wave end |
| **Wave 2 Active** | "🌊 WAVE 2 OF 3 – PICK UP SPEED!" | Start of wave | Blue text, encouragement |
| **Wave 3 Active** | "🌊 FINAL WAVE! MAKE IT COUNT!" | Start of wave | Red text, urgency, exciting font |
| **Victory (Survived)** | "✅ ROUND COMPLETE! +1,200 COINS!" | Round end (alive) | Gold text, celebratory sound |
| **Defeat (Drowned)** | "💀 Drowned. Better luck next round." | On death | Gray text, neutral tone |
| **All Eliminated** | "💀 Everyone drowned. Round failed." | On all players dead | Team message, sad sound |

---

### 5-Step Micro Tutorial

**Shown once on first join. Skippable, 1 line each, auto-dismiss:**

```
STEP 1 (2s):  "The water is rising! Climb to escape."
STEP 2 (2s):  "Break Lucky Blocks for power-ups and coins."
STEP 3 (2s):  "Use tools smartly: grapple, dash, glide, climb."
STEP 4 (2s):  "Survive each wave. Last player wins!"
STEP 5 (2s):  "Upgrade your skills in the Shop. Good luck! →"
[AUTO-SKIP: 10s total | SKIP button available]
```

Each step has a highlight arrow pointing to relevant UI element:
- Step 1: Arrow pointing upward (sky)
- Step 2: Arrow pointing at a Lucky Block
- Step 3: Arrow pointing at HUD power-up slot
- Step 4: Arrow pointing at alive counter
- Step 5: Arrow pointing at Shop button

---

## Implementation Priority (by Codex)

**Tier 1 (Today)**:
- [ ] Integrate Loot Table v3 into LootTable module (copy-paste 25 items)
- [ ] Set economy values in RoundService (coins per second, bonuses)
- [ ] Create ShopUpgrades module (6 upgrades × 5–8 levels each)
- [ ] Create DailyQuests module (12 quest lines)
- [ ] Create UI copy strings (toasts, state text, tutorial)

**Tier 2 (Polish)**:
- [ ] Playtesting and numeric tuning (adjust weights/costs if needed)
- [ ] Connect Shop UI to upgrades module
- [ ] Connect quests UI to tracking system
- [ ] Difficulty mode toggle (Casual ↔ Sweaty)

---

## Notes

- **All values are tunable**: Change `CASUAL_WATER_SPEED = 1.2` to `1.0` or `1.4` globally.
- **No custom animations required**: All effects use existing Roblox properties + simple tweens.
- **Mobile-friendly**: All interactions work on gamepad (tap buttons, hold keys).
- **Balanced economy**: Max-out shop ≈ 4–5 hours gameplay. No paywall needed.

