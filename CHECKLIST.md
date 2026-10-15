# Hearthrise: Checklist

Details for each stage are in `STAGES.md`.

Method for every item below: test first (red, green, refactor). A box is ticked only when its tests pass and `flutter analyze` is clean.

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
- [x] Flutter project with Riverpod, Drift, go_router (freezed deferred, see STAGE1_PLAN.md D4)
- [x] Feature-based folder structure
- [x] Move feel prototype into feature structure; replace in-memory models with Drift
- [x] Boss: create, edit, status (active / waiting / defeated)
- [x] Boss focus pin
- [x] Phases: create, order, reorder
- [x] Tasks: weight, one-time / recurring
- [x] Strike and Tried outcomes
- [x] Attempt counter (declared failure)
- [x] Per-boss reset setting: nothing / current phase / whole boss
- [x] Fallen flow with lesson note
- [x] "Attempt N. Last time: …" line
- [x] Rule of three prompt
- [x] Home boss cards
- [x] Today view grouped by boss, with filter
- [x] Reduced motion and 48 dp targets (in code)
- [ ] 200% text scale check on a device
- [ ] Run the gate on an Android device or emulator (no Android SDK on the dev Mac yet)
- [x] **Gate passed:** fail, write lesson, see it next attempt, offline (gate_test.dart and iOS simulator)

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
- [ ] Haptics off switch (settings, schema v2)
- [ ] Haptic profile by weight (Light / Heavy / Boss-tier)
- [ ] Scroll-safe hold (moving finger cancels)
- [ ] Strike landing sweep (longer for Boss-tier)
- [ ] Tests for dim, health bar drain, fallen dim and haptic
- [ ] Feel report (counts only, copy to clipboard)
- [ ] Tester build (Android release APK)
- [ ] Developer pass on a real phone
- [ ] Test with 3 to 5 testers
- [ ] Apply tuning from feedback
- [ ] **Gate passed**

## Stage 3: Daily ritual
- [x] Bonfire screen: summary
- [x] Bonfire screen: lesson field
- [x] Bonfire screen: tomorrow's top three
- [x] Daily local notification at chosen time
- [x] Android 13+ notification permission prompt
- [x] Day rollover time (default 4 AM)
- [x] Missed day fails attempt on every active boss, one shared lesson
- [x] Embers: earn on Strike and Tried
- [x] Embers: carried total
- [x] Embers: bank at bonfire
- [x] Flask charges and restore rule
- [x] Light day
- [x] Settings screen (reminder time, rollover hour, haptics, hold-to-tap; sound deferred to Stage 5)
- [ ] **Gate passed:** loop runs several real days

## Stage 4: Commitments and health
- [x] Commit task with deadline
- [x] Open tasks without deadline
- [x] Calm note for heavy commitment load
- [x] Free first extension
- [x] Second extension costs flask
- [x] Health events table; health derived from events
- [x] Loss by weight (1 / 2 / 3), Tried costs half
- [x] Death at zero health (failed attempt on final-blow boss)
- [x] Rest after a fall: rise same day at bonfire
- [x] Freeze remaining commitments after death
- [x] Fallen screen with "N promised, M kept"
- [x] Resolve deadlines on app open
- [x] Resolve deadlines on schedule while running
- [x] "While you were away" summary
- [x] Late strike
- [x] Opt-in per-task deadline reminders
- [x] Waiting bosses exempt
- [x] Recurring tasks create a daily commitment
- [x] Health restore at bonfire
- [x] Daily summaries
- [x] Planning accuracy (daily and weekly)
- [x] Newcomer grace week (calm line only; reduced losses in Stage 8)
- [x] Unit tests for deadline and health resolver
- [x] **Gate passed:** §5.12 beginner example matches

## Stage 5: Victory, relics, onboarding
- [ ] Victory screen with numbers and lesson list
- [ ] Relic created on defeat, with its own snapshot
- [ ] Emblem weathering levels
- [ ] Final inscription (editable)
- [ ] Hall of relics, with empty state
- [ ] Relic detail timeline
- [ ] Profile: embers, level, flasks, accuracy
- [ ] Onboarding flow (under two minutes)
- [ ] Sound setting and tones (deferred from Stage 3)
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
- [ ] Newcomer grace week reduces health losses (from Stage 4 D13)
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

## Stage 11: AI planning assistant
- [ ] Decide where the API key lives (standalone proxy or Stage 7 backend)
- [ ] `AiPlanner` interface, fake planner, JSON validation
- [ ] **Headline:** guided learning plan, adaptive interview (one question at a time, tap options + free text)
- [ ] Question cap and "build my plan" step
- [ ] Research step returns a `BossDraft` with sources shown
- [ ] Plan frames itself as an editable starting point, first phase small
- [ ] Image to boss draft
- [ ] Title to suggested tasks (quick version)
- [ ] Phase suggestion for a task
- [ ] Lesson coach after a failed attempt (opt-in)
- [ ] Task splitter for repeatedly missed tasks
- [ ] Daily plan helper (after Stages 3 and 4)
- [ ] Estimate check on task weights
- [ ] Boss definition helper (quick version)
- [ ] Fallen screen message (template first, AI opt-in)
- [ ] Weekly reckoning summary
- [ ] Voice capture to boss draft
- [ ] Recurrence detection
- [ ] Output opens in the boss editor, nothing saved until Save
- [ ] Offline, error, and rate-limited states
- [ ] Security: structured output only, no open chat endpoint
- [ ] Proxy owns system prompt, model, and token limits
- [ ] Schema validation rejects non-plan output, length caps on text
- [ ] Untrusted input handling: injection in text, images, research results
- [ ] Scope guard for off-topic requests
- [ ] Input limits (answer length, image size, question and turn caps)
- [ ] Per-user budgets, global spend cap, remote kill switch
- [ ] App attestation (Play Integrity, App Attest)
- [ ] Usage logging and abuse alerts
- [ ] Malicious-input test suite
- [ ] Privacy notice before first use
- [ ] Decide free / paid split
- [ ] **Gate passed:** photo of a handwritten list becomes a saved boss
