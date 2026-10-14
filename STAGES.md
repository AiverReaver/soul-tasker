# Hearthrise: Build Stages

Source: `souls-task-tracker-design.md`. Section numbers (§) refer to that document.
Each stage ships something testable and ends with a gate. Do not start the next stage until the gate passes. Build every stage test-first (see Development method below).

---

## Development method: test-driven development

Every stage, and every plan written for a stage, follows TDD. This is a standing rule, not a per-stage choice.

1. **Red:** write the test for the next behavior first, run it, and see it fail for the right reason.
2. **Green:** write the smallest code that makes it pass.
3. **Refactor:** clean up with the tests green.

Rules for every plan:

- Each build-order step lists its tests first, then the code. "Done when" names the tests that must pass, not just what the screen looks like.
- Logic goes in unit tests (in-memory Drift database, fixed clock). Each screen's main path gets a widget test. Each stage gate also gets an automated test where the gate can be scripted.
- A bug fix starts with a failing test that reproduces the bug.
- A step is done only when `flutter analyze` is clean and the full suite passes. One commit per step.
- Target 80% line coverage for `lib/core` and `lib/data`.
- Checks that cannot be automated (device feel, 200% text, real haptics) are listed as manual checks in the plan, not skipped.

---

## UI components: `lib/ui/`

Standing rule for every stage and every plan.

- All reusable visual widgets live in `app/lib/ui/`. Screens in `lib/features/` compose them; they do not build their own buttons, rows, cards, bars, sheets or text styles inline.
- Every `lib/ui/` widget is a `StatelessWidget`. It takes plain values and callbacks (title, weight, progress, `onPressed`), and never reads Riverpod providers, Drift, the router or `Haptics`. Theme tokens (`core/theme.dart`) are the only shared input.
- Behavior that needs state (hold timer, animation controller, providers) stays in a thin container in `lib/features/`, which passes the current values down to the stateless widget. Animation is passed in as a value (progress, `Animation<double>`), not owned.
- Before building a screen, check `lib/ui/` for a widget that fits. Use it. If none fits, create a new one in `lib/ui/` first (with its widget test), then use it. Extend an existing one with a parameter only when the new case is the same widget; otherwise add a new one.
- Swapping a look means editing one file in `lib/ui/`; no feature file should need to change.
- Each `lib/ui/` widget gets a widget test (renders from given values, fires callbacks) written first, per TDD. Plans list the `ui/` widgets each step uses or adds.

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
**Detailed plan:** `STAGE1_PLAN.md`.

- Flutter project: Riverpod, Drift, go_router (§10.1); freezed deferred until a type needs it (STAGE1_PLAN.md D4). Feature-based structure (§10.3).
- Move the Stage 2 feel prototype (`hold_to_strike`, `boss_health_bar`, `fallen_screen`, `theme`) into the feature structure, and replace the in-memory `models.dart` with Drift tables. Keep `feel_test.dart` passing.
- Bosses: unlimited, active / waiting / defeated, focus pin (§5.1).
- Phases with order and reordering (§5.2).
- Tasks: Light / Heavy / Boss-tier, one-time or recurring, Strike or Tried (§5.3).
- Attempts and attempt counter (§5.4): declared failure now; health-death and missed-day triggers arrive with Stages 3 and 4.
- Per-boss reset on a failed attempt: nothing (default), current phase, whole boss (§5.1).
- Fallen flow with "What did this teach you?" lesson note (§5.5).
- "Attempt N. Last time: …" line on the boss screen.
- Rule of three prompt (§5.10).
- Home list of boss cards and grouped Today view (§6.1).

**Gate:** create a boss, fail an attempt, write a lesson, and see it at the start of the next attempt, with no network.

---

## Stage 2: Feel prototype

**Goal:** prove the Souls feel before building more on it.
**Detailed plan:** `STAGE2_PLAN.md`.

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
**Detailed plan:** `STAGE3_PLAN.md`.

- Bonfire screen: day summary, lesson field, tomorrow's top three (§5.6).
- Daily local notification at a user-chosen time, inexact scheduling, Android 13+ permission (§10.1).
- Day rollover time (default 4 AM); missed day fails an attempt on every active boss with one shared lesson (§5.4, §5.6).
- Embers: earn, carry, bank at the bonfire. Gentle mode only (§5.8).
- Flasks and light days (§5.7).
- Settings: reminder time, rollover hour, haptics, hold-to-tap. The sound setting is deferred to Stage 5: no audio exists yet, so a switch would do nothing.

**Gate:** the loop runs for several real days without bugs or missed reminders.

---

## Stage 4: Commitments and health (gentle mode)

**Goal:** turn the task list into a commitment system.

- Commitments with deadlines; open tasks without deadlines (§5.12).
- Free first extension; second extension costs a flask.
- Player health derived from health events; loss by weight 1 / 2 / 3; Tried costs half.
- Death at zero health: failed attempt on the final-blow boss, freeze remaining commitments, fallen screen with "N promised, M kept".
- Rest after a fall: rise the same day at the bonfire (§5.6).
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
- Sound setting and tones (deferred from Stage 3; needs the licensed sounds from Stage 0).

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

## Stage 11: AI planning assistant

**Goal:** help the user turn a goal into phases and tasks faster. Optional and online only; the app stays fully usable offline without it.
**Detailed plan:** `STAGE11_PLAN.md` (not written yet).

- **Headline: guided learning plan.** The user names something they want to learn. The AI interviews them first, one adaptive question at a time (goal and what they want to build, hours per week, current level, what they tried, what stopped them), so "learn coding" becomes a concrete goal. Tap-to-answer options plus a free-text escape.
  - Cap at about 5 to 8 questions, with a visible "enough context, build my plan" step.
  - After the interview, the model researches (learning paths, resources, typical timelines) and returns a `BossDraft`: phases, tasks with weights, a defeat meaning from the user's own goal, and a realistic target date.
  - Tasks are concrete actions with source links the user can check; show sources and avoid precise unverifiable claims. No judging the user's level or time; frame it as an editable starting point.
  - The first phase starts small, matching the gentle tone. Interview answers (hours, blockers) can later feed the daily plan helper and the task splitter.
  - Quick versions of the same flow: title to tasks, and the boss definition helper below.
- Image to boss: a photo (notes, whiteboard, syllabus) becomes a `BossDraft`.
- Title to tasks (quick version of the guided plan, no interview): a boss or phase title becomes suggested tasks with weights.
- Phase suggestion: given a task title and the existing phases, suggest a phase or a new phase name.
- Lesson coach: after a failed attempt, read the attempt history and the user's lesson, ask one or two probing questions, and suggest a smaller first step for the next attempt. Opt-in.
- Task splitter: for a task that keeps being missed, suggest smaller or lighter tasks (works with weights).
- Daily plan helper (needs Stages 3 and 4): suggest how much to commit today from open tasks and past planning accuracy.
- Estimate check: flag tasks whose weight looks off against similar past tasks.
- Boss definition helper (quick version of the guided plan): turn a vague goal into a clear defeat meaning and a target date.
- Fallen screen message: a short, gentle message based on what the user actually did. Template first; AI polish is opt-in and reviewable.
- Weekly reckoning summary (§16.1): wins, patterns, misses.
- Voice capture: a spoken goal becomes a `BossDraft`, reusing the image-to-boss path.
- Recurrence detection: offer to make a task recurring when the user keeps adding it.
- AI never touches health or commitment math; that stays deterministic and tested. Emotional screens (fallen, failure) stay opt-in so the gentle tone holds.
- Output always opens in the existing boss editor as a draft. Nothing is saved until the user taps Save; the model never writes to Drift.
- An `AiPlanner` interface in `lib/data/` with a provider, so tests use a fake. It validates the model's JSON (enums, empty titles, size caps) and returns drafts.
- The Anthropic API key never ships in the app. Calls go through a backend proxy with per-user rate limits (decide: small standalone proxy, or the Stage 7 backend).
- Clear offline, error, and rate-limited states, with the manual flow always available.
- Privacy: tell the user what is sent (text, image) before the first use.
- Decide the free/paid split alongside Stage 9 (§5.13). The guided plan makes several model calls plus web research, so it is likely paid-tier with per-user limits.

Security and abuse prevention (design in from the start, not later):
- Not a chatbot. Each feature is a fixed task: structured input in, JSON matching a schema out. There is no open "ask anything" endpoint.
- The backend proxy owns the system prompt, model, `max_tokens`, and tool list. The app sends only task type and user data; it can never send or override a system prompt, model, or limits.
- Every output is parsed against the schema and rejected if it does not fit. Free-text fields have length caps. Anything that is not a plan (code, essays, off-topic answers) fails validation and is never shown.
- All user text, image content, and web research results are untrusted data, not instructions (prompt injection). The prompt marks them as data, and the model has no tools that act on the user's account or the database.
- Scope guard: the interview checks that the goal is a personal goal the app can plan. Off-topic requests ("solve this coding problem") get a short refusal, with a cheap classifier or the model's own refusal field.
- Input limits: max characters per answer, max image size and count, max questions per interview, max turns per session.
- Abuse limits: per-user auth, per-user daily and monthly request and token budgets, a global spend cap, and a kill switch that turns AI off remotely. Rate limits per device and IP.
- Only real app installs can call the proxy (Play Integrity on Android, App Attest on iOS), so scripts and cloned clients are rejected.
- Log usage per user and alert on unusual volume, repeated validation failures, and refusal spikes.
- Tests: a malicious-input suite (prompt injection in text, in an image, in a research result; off-topic requests; oversized input) that must pass against the validator.

**Gate:** the malicious-input suite passes (off-topic and injected requests produce no output), and with a fake planner the interview ends in a reviewable `BossDraft` (and stops at the question cap), each other feature produces a reviewable draft and malformed model output is rejected without a crash; with the real proxy, a photo of a handwritten list becomes a saved boss.

---

## Differences from the design document's build order (§11.3)

- "Feel" is a separate stage (Stage 2), so the hold and fallen screen are tested before more features depend on them.
- Victory and relics are in the MVP (Stage 5), matching §11.1.
- Monetization comes after launch, matching §11.2.
