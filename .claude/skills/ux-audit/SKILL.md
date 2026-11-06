---
name: ux-audit
description: Use when asked to evaluate, audit, critique or review the Hearthrise app as a real user (first impression, usability, retention, friction, accessibility, "AI slop"), or to rerun or update the first-session audit. Walks a fresh install on the iOS simulator, makes deliberate mistakes, checks the code behind what it sees, and writes a report with a status table that later sessions update.
argument-hint: "[focus: first-session | a screen or flow | all] [branch]"
---

# ux-audit

Use the app the way a new user would, then report what breaks, with proof. Be candid and specific. Never write "improve the UI".

**The rule: tag every finding with how you know it.**
- **seen:** you saw it on the simulator.
- **code:** you read it in the source but didn't trigger it.
- **DB:** you confirmed it in the database.

Never tag a finding "seen" from code alone. If you didn't reach a screen, list it under "Not seen".

## Files

| What | Where |
| --- | --- |
| Last audit (format, open issues, status table) | `reports/2026-11-05-first-session-audit.md` |
| Real entry point (fresh install, onboarding) | `app/lib/main.dart` |
| Seeded data, already onboarded | `app/lib/main_demo.dart` |
| Design rules to judge against | `DESIGN.md`, `souls-task-tracker-design.md` |
| Screenshot helpers | `docs/ui-tour/shot.sh`, `docs/ui-tour/burst.sh` |

## Steps

### 0. Read the last report first

Open the newest `reports/*-audit.md`. Its status table lists which issues are **DONE** and on which branch. Don't re-report a DONE issue unless it is broken again on the build you test. Confirm that the branch you test contains those fixes (`git log`).

### 1. Pick the build

Say which branch and commit you test. Uncommitted changes count, so name them. `main` can be far behind the working branch: run `git log main..HEAD` before you trust it.

### 2. Back up, then install fresh

The simulator may hold the user's own test data. Before you uninstall anything:

```bash
U=<udid>
D=$(xcrun simctl get_app_container $U com.hearthrise.app data)
ditto "$D" "<scratchpad>/app-data-backup"
xcrun simctl uninstall $U com.hearthrise.app
```

Then:
1. Call `mcp__Claude_Code_iOS_Simulator__control` `attach`, so the user can watch.
2. Run `cd app && flutter run -t lib/main.dart -d $U` in the background.
3. Wait for the line `Flutter run key commands`.

### 3. Walk real journeys with a real goal

Use a dull, real-world goal, such as "Finish my tax return", not a game-shaped one. Then walk:

1. **Onboarding:** accept the defaults the way a hurried user would.
2. **Home:** the first strike. Try a plain tap before the hold.
3. **The strike result:** the sheet after the strike.
4. **Bonfire:** rest, and see what comes after.
5. **Add a task** with `+`.
6. **All bosses and the boss screen:** try to add a task there.
7. **The `⋯` menu:** fail an attempt, then edit the boss and leave without saving.
8. **Profile, Settings** (scroll to the bottom) and **Today**.

At each screen, note what a real user would think, feel or do. Judge every screen through these lenses:
- **First impression:** is the purpose clear within seconds?
- **Usability:** can the core task be done without confusion?
- **Emotion:** does it feel trustworthy, satisfying, worth returning to?
- **Retention and hype:** what builds momentum, delight or sharing, and what kills it?
- **Friction:** unclear copy, weak hierarchy, dead ends, hidden actions, slow feedback.
- **Human behaviour:** attention, cognitive load, habit, anxiety, motivation.
- **Accessibility:** readability, contrast, touch targets, error recovery.
- **AI slop:** anything generic, template-like or decorative without purpose.

Also compare screens with each other. Two tabs that show the same content (as Home and Today did) is a finding.

### 4. Make mistakes on purpose

- Tap where people tap, not where the design expects: rows, icons, labels.
- Leave a form without saving. Skip on every step. Tap destructive rows.
- Type, then look for the primary button: the keyboard often hides it.
- Text size: run `xcrun simctl ui $U content_size accessibility-large`, which is about 200%, then `accessibility-extra-large` and `accessibility-extra-extra-extra-large`. Screenshot Home at each size. Set it back to `large` afterwards.

### 5. Back each finding with code

For every bug you see, find the cause and give its `file:line`. Use code-only checks for what the simulator can't reach in one session:
- missed days (`lib/core/missed_days.dart`, `DayDao.pending`)
- recurrence (`BossDao`, `boss_view.dart`)
- confirms (`boss_screen.dart` `_openActions`)

Use the database to confirm what was saved:

```bash
sqlite3 "$D/Documents/hearthrise.sqlite" "select title, recurrence from tasks;"
```

### 6. Write the report

Write `reports/<YYYY-MM-DD>-<focus>-audit.md`, in the same format as the last report:

1. **Status table at the top**: every issue is OPEN or DONE (commit, branch). Add a note that DONE means committed, not merged.
2. **Coverage**: what you saw and what you didn't.
3. **Issues ranked Critical, High, Medium, Low.** Each issue has a title, where it occurs, what the user thinks or feels, why it harms, its severity, and an exact fix with copy where useful. Tag each one seen, code or DB.
4. **Top 5 improvements**, in priority order.
5. **Strongest moments** worth keeping.
6. **Hype potential.**
7. **Verdict**: would you keep using the app after one session, and why?

Severity guide:
- **Critical:** data loss, an irreversible action on one tap, or a rule that punishes the intended behaviour.
- **High:** a core task is blocked or confusing.
- **Medium:** friction or accessibility breakage.
- **Low:** polish.

### 7. Clean up

1. Stop `flutter run`.
2. Restore the backup over the data container with `ditto "<backup>" "${D:?}"`. Reinstalling gives the app a new container, so run `get_app_container` again for `D` first. Use `${D:?}`: a bare `$D` in `rm` or `ditto` is blocked by the safety check.
3. Check the database matches the backup with `cmp`.
4. Tell the user the installed app is now your build.

### 8. Fixing (only when asked)

- Make a new branch from the branch you audited, not `main`. Use a worktree so the user's uncommitted work isn't touched.
- Follow `CLAUDE.md`: write a failing test first, then `flutter analyze` and the full `flutter test`.
- Check each fix on the simulator.
- Then mark it **DONE** in the report, in the status table and under the issue, with the commit and branch.

## Gotchas

- A screenshot taken right after typing can lag. Take it again before you call it a bug.
- When back-dating `settings.last_resolved_day`, the missed-day flow fires only for bosses created before the missed day. Same-day test bosses just move the day on silently.
- The app's day starts at 04:00 (Settings → "Day starts at"), so 00:15 still counts as the previous day.
- The glass look differs between branches. Name the branch in any visual finding.

## Keep it findable

This skill and the reports are files in the repo. A session on another branch or worktree sees them only once they are committed there. Commit new reports and status updates when the user agrees.

## Don't

- Don't call a finding "seen" when you only read the code.
- Don't uninstall the app before backing up its data.
- Don't fix anything during the audit unless the user asks.
- Don't drop the status table. Other sessions use it to avoid redoing work.
