# Hearthrise: Build Stages

Source: `souls-task-tracker-design.md`. Section numbers (§) refer to that document.
Each stage ships something testable and ends with a gate. Do not start the next stage until the gate passes.

---

## Stage 0: Foundations (pre-code)

**Goal:** remove blockers that take calendar time.

- Choose the original app name and finalize vocabulary (§4).
- Choose fonts and sounds with commercial-use licenses (§8, open question 10).
- Low-fidelity sketches of five screens: home, boss, fallen, bonfire, victory (§6.1).
- Open the Google Play developer account and check current closed-testing rules (§10.4).
- Start recruiting Souls-playing testers.

**Gate:** name chosen, sketches done, developer account live, tester list started.

---

## Stage 1: Core loop, local only

**Goal:** fight a boss, fail, learn, try again. Fully offline.

- Flutter project: Riverpod, Drift, go_router, freezed (§10.1). Feature-based structure (§10.3).
- Bosses: unlimited, active / waiting / defeated, focus pin (§5.1).
- Phases with order and reordering (§5.2).
- Tasks: Light / Heavy / Boss-tier, one-time or recurring, Strike or Tried (§5.3).
- Attempts and attempt counter (§5.4).
- Fallen flow with "What did this teach you?" lesson note (§5.5).
- "Attempt N. Last time: …" line on the boss screen.
- Rule of three prompt (§5.10).
- Home list of boss cards and grouped Today view (§6.1).

**Gate:** create a boss, fail an attempt, write a lesson, and see it at the start of the next attempt, with no network.

---

## Stage 2: Feel prototype

**Goal:** prove the Souls feel before building more on it.

- Hold-to-strike scaled by weight: 0.3 s / 0.6 s / 1.2 s (§7.1, §7.4).
- Hold feedback: glow or fill line, building haptics, completion pulse (§7.2).
- Visible consequence: task dims, boss health bar loses a segment (§7.3).
- Tap fallback setting (§7.5).
- Segmented boss health bar with slow drain; palette, typography, slow fades (§8.1).
- Fallen screen dim and quiet line (§5.5).

**Gate:** 3 to 5 testers try the hold and the fallen screen. Tune or cut based on feedback (§12).

---

## Stage 3: Daily ritual

**Goal:** the "do, rest, bank, plan" loop.

- Bonfire screen: day summary, lesson field, tomorrow's top three (§5.6).
- Daily local notification at a user-chosen time, inexact scheduling, Android 13+ permission (§10.1).
- Embers: earn, carry, bank at the bonfire. Gentle mode only (§5.8).
- Flasks and light days (§5.7).
- Settings: reminder time, haptics, sound, hold-to-tap.

**Gate:** the loop runs for several real days without bugs or missed reminders.

---

## Stage 4: Commitments and health (gentle mode)

**Goal:** turn the task list into a commitment system.

- Commitments with deadlines; open tasks without deadlines (§5.12).
- Free first extension; second extension costs a flask.
- Player health derived from health events; loss by weight 1 / 2 / 3; Tried costs half.
- Death at zero health: freeze remaining commitments, fallen screen with "N promised, M kept".
- Deadline resolution from stored timestamps on app open and on a schedule; "While you were away" summary; late strike.
- Opt-in per-task deadline reminders.
- Daily summaries and planning accuracy (daily and weekly).
- Newcomer grace week.
- Unit tests for the deadline and health resolver.

**Gate:** the beginner's first-day example in §5.12 plays out exactly as written, and resolver tests pass.

---

## Stage 5: Victory, relics, onboarding (MVP complete)

**Goal:** finish the MVP list in §11.1.

- Victory screen: attempts, days, effort, lesson notes (§5.11).
- Relic creation with its own snapshot of the boss story, emblem weathering levels, final inscription (§5.14).
- Hall of relics on the profile screen.
- Profile: banked embers, single level, flasks, planning accuracy (§5.9).
- Onboarding under two minutes (§6.2).

**Gate:** every item in §11.1 works end to end on a small and a large Android screen.

---

## Stage 6: Closed test on Google Play

**Goal:** validate tone and retention with real users.

- Publish to the closed testing track for the required duration and tester count.
- Track the signals in §12: next-day return after a fall, Tried vs Strike, lesson notes written, hold turned into tap, first-week falls.
- Ask testers directly whether the app ever made them feel worse.

**Gate:** testers return after falling, and no recurring reports of guilt or discouragement.

---

## Stage 7: Backend and sync

**Goal:** cloud backup and multi-device support.

- Node.js API (Fastify or Express) with PostgreSQL mirroring §9 (§10.2).
- OpenAPI spec, generated Dart client.
- Google sign-in with server-side ID token verification.
- Batch sync endpoints; offline-first local writes (§9.3).
- Conflict rules: last-write-wins by updated time; embers and health derived from events; one active bloodstain per boss.

**Gate:** offline edits on two devices merge without losing embers, health events, or relics.

---

## Stage 8: Hardcore mode and Android launch

**Goal:** add the opt-in loss mechanic, then ship.

- Bloodstain drop on fall, recovery by doing a small version of the task (§5.8).
- Softening rules: partial loss, cap, flask protection, lesson refund.
- Store listing free of game trademarks (§4).
- Production launch on Google Play.

**Gate:** production release live.

---

## Stage 9: Subscriptions and consistency rewards

**Goal:** paid features and earned discounts. Not in the MVP (§11.2).

- Store policy review first (§10.6).
- Decide the free/paid split (§5.13).
- Server-side steadfast days, tiers, lock-in window, one redemption per billing period.
- Google Play developer-determined offers per tier; purchase verification; store notifications.
- Abuse checks: plausibility, daily cap, no stacking.

**Gate:** a test user earns a tier and redeems a verified discount exactly once.

---

## Stage 10: Expansion

- Home screen widget.
- iOS release: Sign in with Apple, promotional offers and offer codes (§10.5, §10.6).
- Future ideas in order: shortcuts, persistence achievements, weekly reckoning (§16.1), then §16.2.

---

## Differences from the design document's build order (§11.3)

- "Feel" is a separate stage (Stage 2), so the hold and fallen screen are tested before more features depend on them.
- Victory and relics are in the MVP (Stage 5), matching §11.1.
- Monetization comes after launch, matching §11.2.
