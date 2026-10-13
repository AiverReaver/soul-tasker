# Hearthrise: Checklist

Details for each stage are in `STAGES.md`.

## Stage 0: Foundations
- [x] Choose app name (Hearthrise)
- [ ] Finalize vocabulary (§4)
- [x] Choose licensed fonts (Cormorant Garamond + Inter, OFL)
- [ ] Choose licensed sounds
- [x] Sketch home screen
- [x] Sketch boss screen
- [x] Sketch fallen screen
- [x] Sketch bonfire screen
- [x] Sketch victory screen
- [ ] Open Google Play developer account
- [ ] Check current closed-testing rules
- [ ] Start tester recruitment list
- [ ] **Gate passed**

## Stage 1: Core loop, local only
- [ ] Flutter project with Riverpod, Drift, go_router, freezed
- [ ] Feature-based folder structure
- [ ] Move feel prototype into feature structure; replace in-memory models with Drift
- [ ] Boss: create, edit, status (active / waiting / defeated)
- [ ] Boss focus pin
- [ ] Phases: create, order, reorder
- [ ] Tasks: weight, one-time / recurring
- [ ] Strike and Tried outcomes
- [ ] Attempt counter (declared failure)
- [ ] Per-boss reset setting: nothing / current phase / whole boss
- [ ] Fallen flow with lesson note
- [ ] "Attempt N. Last time: …" line
- [ ] Rule of three prompt
- [ ] Home boss cards
- [ ] Today view grouped by boss, with filter
- [ ] **Gate passed:** fail, write lesson, see it next attempt, offline

## Stage 2: Feel prototype
- [x] Hold-to-strike with weight durations (0.3 / 0.6 / 1.2 s)
- [x] Release early rolls back
- [x] Glow / fill line during hold
- [x] Building haptics and completion pulse (in code; not yet felt on a real phone)
- [x] Task dims after strike
- [x] Segmented boss health bar with slow drain
- [x] Tap fallback setting
- [x] Palette, typography, slow fades
- [x] Fallen screen dim and quiet line
- [ ] Test with 3 to 5 testers
- [ ] Apply tuning from feedback
- [ ] **Gate passed**

## Stage 3: Daily ritual
- [ ] Bonfire screen: summary
- [ ] Bonfire screen: lesson field
- [ ] Bonfire screen: tomorrow's top three
- [ ] Daily local notification at chosen time
- [ ] Android 13+ notification permission prompt
- [ ] Day rollover time (default 4 AM)
- [ ] Missed day fails attempt on every active boss, one shared lesson
- [ ] Embers: earn on Strike and Tried
- [ ] Embers: carried total
- [ ] Embers: bank at bonfire
- [ ] Flask charges and restore rule
- [ ] Light day
- [ ] Settings screen
- [ ] **Gate passed:** loop runs several real days

## Stage 4: Commitments and health
- [ ] Commit task with deadline
- [ ] Open tasks without deadline
- [ ] Calm note for heavy commitment load
- [ ] Free first extension
- [ ] Second extension costs flask
- [ ] Health events table; health derived from events
- [ ] Loss by weight (1 / 2 / 3), Tried costs half
- [ ] Death at zero health (failed attempt on final-blow boss)
- [ ] Rest after a fall: rise same day at bonfire
- [ ] Freeze remaining commitments after death
- [ ] Fallen screen with "N promised, M kept"
- [ ] Resolve deadlines on app open
- [ ] Resolve deadlines on schedule while running
- [ ] "While you were away" summary
- [ ] Late strike
- [ ] Opt-in per-task deadline reminders
- [ ] Waiting bosses exempt
- [ ] Recurring tasks create a daily commitment
- [ ] Health restore at bonfire
- [ ] Daily summaries
- [ ] Planning accuracy (daily and weekly)
- [ ] Newcomer grace week
- [ ] Unit tests for deadline and health resolver
- [ ] **Gate passed:** §5.12 beginner example matches

## Stage 5: Victory, relics, onboarding
- [ ] Victory screen with numbers and lesson list
- [ ] Relic created on defeat, with its own snapshot
- [ ] Emblem weathering levels
- [ ] Final inscription (editable)
- [ ] Hall of relics, with empty state
- [ ] Relic detail timeline
- [ ] Profile: embers, level, flasks, accuracy
- [ ] Onboarding flow (under two minutes)
- [ ] Test on small and large Android screens
- [ ] **Gate passed:** §11.1 complete

## Stage 6: Closed test
- [ ] Upload to closed testing track
- [ ] Meet required tester count and duration
- [ ] Track next-day return after a fall
- [ ] Track Tried vs Strike ratio
- [ ] Track lesson notes written
- [ ] Track hold-to-tap toggles
- [ ] Track first-week falls and returns
- [ ] Ask testers whether the app made them feel worse
- [ ] **Gate passed**

## Stage 7: Backend and sync
- [ ] Node.js API with PostgreSQL
- [ ] Schema mirroring §9
- [ ] OpenAPI spec
- [ ] Generated Dart client
- [ ] Google sign-in with token verification
- [ ] Batch push endpoint
- [ ] Changes-since pull endpoint
- [ ] Last-updated time and synced marker on records
- [ ] Event-derived embers and health on server
- [ ] One active bloodstain per boss enforced
- [ ] **Gate passed:** two-device offline merge without loss

## Stage 8: Hardcore mode and launch
- [ ] Mode setting (gentle / hardcore)
- [ ] Bloodstain on fall
- [ ] Recovery by small version of task
- [ ] Partial loss and cap
- [ ] Flask protection
- [ ] Lesson refund
- [ ] Older bloodstain on same boss marked lost
- [ ] Trademark check of store listing
- [ ] Production launch
- [ ] **Gate passed**

## Stage 9: Subscriptions and rewards
- [ ] Google Play subscription policy review
- [ ] Apple in-app purchase guideline review
- [ ] Decide free / paid split
- [ ] Server steadfast-day calculation
- [ ] Tiers and lock-in window
- [ ] Play subscription, base plans, offer per tier
- [ ] Server verifies tier before offer
- [ ] Purchase verification
- [ ] Store notification handling
- [ ] One redemption per billing period
- [ ] Abuse checks: plausibility, daily cap, no stacking
- [ ] **Gate passed:** verified single redemption

## Stage 10: Expansion
- [ ] Home screen widget
- [ ] iOS build
- [ ] Sign in with Apple
- [ ] iOS promotional offers and offer codes
- [ ] Shortcuts
- [ ] Persistence achievements
- [ ] Weekly reckoning
