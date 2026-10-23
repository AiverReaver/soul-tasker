---
name: step
description: Use when the user names a plan step or range to build ("c7", "do c8 to c15", "start B2", "step 6", "checklist 11", "/step d1"). Finds the step in the plan files, builds it test-first, runs the gate, ticks the checklist and makes one commit per step.
argument-hint: "<step id or range> [plan file]"
---

# step

Build one plan step (or each step in a range) the way `CLAUDE.md` and `STAGES.md` "Development method" require: test first, gate green, one commit per step.

## 1. Find the step

Search the plan files at the repo root, newest first, unless the user named one:

| Format | Where | Example |
| --- | --- | --- |
| `**C7. Title.** ...` paragraph | `V41_PLAN.md` (A1-A4, B1-B4, C1-C18, D1-D2) | `c7`, `C7` |
| `### Step N: Title` section | `STAGE<n>_PLAN.md`, `THEME_PLAN.md` | `step 6`, `stage 8 step 3` |
| `- [ ] N. ...` box | `V4*_CHECKLIST.md` | `checklist 11`, `11` when a checklist is the active plan |

```bash
grep -nE '^\*\*C7\.|^#{2,4} Step 6:|^\s*- \[[ ~x]\] 11\.' V4*_PLAN.md V4*_CHECKLIST.md STAGE*_PLAN.md THEME_PLAN.md
```

- **Several matches:** pick the newest plan, and say which file and line you used.
- **No match:** stop and ask.
- **Already ticked:** say so, and ask before redoing it.

Then read the whole step plus anything it points to: decisions (D1-D11), questions (Q1-Q6), and the boards it names. If it says "after X", check that X is done (`git log --oneline`, the checklist).

## 2. State the step before coding

Post a short summary covering:

- What the step builds.
- The tests it lists, which you'll write first. If the plan lists none, name the tests you'll write.
- The files you expect to touch.
- Any open decision the plan leaves to the user.

If a decision changes what gets built, ask it with `AskUserQuestion`. Do this before writing any code. Otherwise continue without waiting.

## 3. Red, green, refactor

1. **Red.** Write the tests:
   - Logic: unit tests with in-memory Drift (`test/data/harness.dart`) and the fixed `StepClock`.
   - Screens: a widget test through `test/features/pump.dart`.
   - New `lib/ui/` widgets: a widget test of their own.

   Run only the new tests and check they fail for the right reason:
   ```bash
   cd app && flutter test test/<path>_test.dart
   ```
2. **Green.** Write the smallest code that passes. UI goes in `lib/ui/` as a `StatelessWidget` (values and callbacks in). State goes in a thin container in `lib/features/`. Before making something new, check `lib/ui/` for a widget you can reuse.
3. **Refactor**, keeping the tests green.

## 4. Gate

```bash
cd app && dart format lib test && flutter analyze && flutter test
```

All three must pass. If the step touched the server, also run `cd server && npx vitest run`.

- A golden failure in `test/golden/` means a screen changed. If this step meant to change it, show the user the diff (`test/golden/failures/`). Run `flutter test --tags golden --update-goldens --plain-name "<biome> <screen>"` only after they approve.
- If anything fails that this step didn't touch, stop and report it. Don't paper over it.

## 5. See it (UI steps)

If the step changes anything visible, run the demo app on the simulator, screenshot the screen with `docs/ui-tour/shot.sh <step>-<screen>` and `Read` the screenshot. If the plan names a board, put them side by side with `docs/ui-tour/vs.sh`.

If something can't be seen on the simulator (tilt, haptics, real device feel), list it as a manual check in the report. Don't claim it.

## 6. Tick and commit

- Tick the step in the active checklist (`[x]`) with the test names. For UI, add "screenshot checked". Use `[~]` only for designed-but-not-viewed work.
- Make one commit per step in Conventional Commits style, matching `git log`:
  `feat(<area>): <what it does> (<step id>)`, for example `feat(bonfire): mood check-in, one-thing field and tomorrow's foes sheet (C7)`.
  `<area>` is the feature folder (`home`, `boss-edit`, `strike`, `day`, `glass`). Use `fix`, `perf` or `test` when one of those fits better.
- Stage only this step's files. Leave unrelated changes (handoff files, other work) unstaged.
- Never add a Claude trailer. The repo's `commit-msg` hook strips one anyway.
- Don't push unless asked.

## 7. Ranges

For "c8 to c15", do steps 1-6 for each step in order, one commit each.

Stop at the first step that:
- needs a decision from the user,
- fails a gate you can't fix inside that step, or
- the plan marks as blocked.

Report what's done and what's next. Don't skip ahead past a stopped step.

## 8. Report

End with:
- The commit hashes.
- Test count before and after.
- What you saw on the simulator, with screenshot paths.
- Any manual checks left.
- The next step in the plan.
