# Hearthrise: first-session UX audit

Date: 5–6 Nov 2026
Build: `spike/native-glass` at `e66f27f`, including the uncommitted glass changes. Fresh install of `lib/main.dart` on an iPhone 16 Pro simulator (iOS 18.5).
Goal used: "Finish my tax return".

Each finding is marked by how it was checked: **seen** (in the app), **code** (read in the source only), or **DB** (confirmed in the database).

## Status: read this before picking an issue

| Issue | Status |
| --- | --- |
| #1 Quick task becomes daily | **DONE**: `dcc8bcd` on `fix/critical-first-run` |
| #2 Skip deletes the boss | **DONE**: `dcc8bcd` on `fix/critical-first-run` |
| #3 Fail on one tap | **DONE**: `dcc8bcd` on `fix/critical-first-run` |
| #4 Strikes don't cover the day | **DONE**: `dcc8bcd` on `fix/critical-first-run` |
| #5–#21 | OPEN |

"DONE" means committed on the branch, not merged. That branch is local, so a session that starts from `main` or `spike/native-glass` won't have these fixes. Build on `fix/critical-first-run`, or merge it first. When you finish an issue, update this table and the issue's status line.

## Verdict

The emotional idea is rare and real: failure is treated with dignity, and lessons come back. But the daily mechanics punished the wrong people, and the app asks users to learn its fiction before it helps them with anything. In its first-session state I would not have kept using it.

## Coverage

**Seen:** onboarding (all 5 steps); Home; Today; Bonfire before and after rest; Profile with an empty Hall of Relics; Settings; All bosses; the boss screen; Edit boss; Fallen; the add-task sheet; the task, boss and strike-result sheets; the reminder prompt. Home was also checked at three text sizes: about 194%, 235% and 310%.

**Not seen:**
- Victory and the relic screens
- The Day screen
- The new-boss flow
- The task edit sheet and the "Strikes at" picker
- Promise, extend and rule-of-three sheets
- Flask, missed-day and away dialogs, and falling from health loss
- Time pickers and delete confirms
- Sign-in and sync
- The other four biomes, and the Today filter chips
- VoiceOver, real haptics and sound, and measured contrast and touch-target sizes

Multi-day use was not tested. Back-dating the database did not trigger the missed-day dialog, because the test bosses were created that same day.

## Issues

### Critical: all four DONE (see "Fixes made" below)

**1. Quick task silently becomes daily forever** (seen + DB)
- **Status: DONE** (`dcc8bcd`, branch `fix/critical-first-run`)
- **Where:** the Home `+` sheet, "Add to today" (`BossDao.addQuickTask`, `new_foe_sheet.dart`).
- **What a user feels:** adds "Call the accountant", does it, and finds it back the next morning. "I did this. Why is it back?"
- **Why it harms:** it breaks the basic contract of a task list. The list fills with dead chores, and each one reads as a bug.
- **Fix:** default to one-time for today, with a "Repeat daily" switch that is off by default.

**2. Skip on the last onboarding step deletes the boss** (code)
- **Status: DONE** (`dcc8bcd`, branch `fix/critical-first-run`)
- **Where:** onboarding step 5. `onSkip` called `_finish(save: false)`.
- **What a user feels:** typed a goal, chapters and dailies, skipped only the reminder, and landed on an empty app.
- **Why it harms:** silent data loss in the first 60 seconds, and trust does not recover.
- **Fix:** on step 5, Skip saves the boss and skips only the reminder.

**3. "This attempt failed" fires on one tap** (seen)
- **Status: DONE** (`dcc8bcd`, branch `fix/critical-first-run`)
- **Where:** the boss `⋯` sheet, last row, right next to "Declare victory".
- **What a user feels:** explores the menu, mis-taps, and gets a full-screen "Fallen." and Attempt 2. There is no confirm and no undo.
- **Why it harms:** the app's heaviest moment becomes an accident, which cheapens every real fall.
- **Fix:** confirm first: "End attempt N? Your embers stay." with "Keep fighting" / "End attempt".

**4. Finishing every task did not protect the day** (code for the penalty; seen for the delayed reward)
- **Status: DONE** (`dcc8bcd`, branch `fix/critical-first-run`)
- **Where:** `missed_days.dart` said "Striking alone does not cover it". In the app, embers stayed 0 and the streak stayed "Begins today" until I rested.
- **What a user feels:** does all the work, closes the app, and next morning reads "A day passed without rest", with the choice to use a flask or let it fall.
- **Why it harms:** it punishes exactly the behaviour you want. Onboarding never mentions the rule. This is the likeliest quit point.
- **Fix:** any strike covers the day and updates the streak at once. Resting becomes a bonus: it banks embers and restores a flask.

### High

**5. Nothing says what the app is**
- **Where:** onboarding step 1, "Failing is fine. Quitting isn't."
- **What a user feels:** good line, but "is this a game, a journal or a therapy app?"
- **Why it harms:** the words "task", "goal" and "habit" never appear, so a store visitor has no anchor.
- **Fix:** add above the line: "Turn the goal you keep avoiding into a boss. Fight it a little every day."

**6. Too many terms, almost none explained**
- **Where:** everywhere. The terms are boss, chapter, strike, embers, carried, banked, flask, health, relic, bonfire, hearth, The Day, attempt and biome.
- **What a user feels:** "Carried 1, Banked 1?" The ten white bars on Today and Profile have no label. "Flasks restored" appears before resting.
- **Why it harms:** high load before any payoff, so users stop reading the meters.
- **Fix:** explain each term on first use, for example "Embers: earned by striking. Rest to keep them." Label the bars "Health 10/10". Show one ember number until the first rest.

**7. Onboarding forces every goal into game-shaped chapters plus dailies**
- **Where:** steps 3 and 4. They are prefilled with "Learn the pattern" and "The fight", and the only task input is daily.
- **What a user feels:** taxes have no "fight" and are not a daily task. They accept the defaults and get empty chapter headers.
- **Why it harms:** the first boss feels fake. A boss with only dailies reads "This task is worn down by habit", has no health, and has no clear way to be beaten.
- **Fix:** replace steps 3 and 4 with one question, "What's the very next step?" (a one-time task). Offer chapters and dailies later. Aim for 3 steps.

**8. The boss screen has no way to add a task**
- **Where:** the boss screen. Empty chapters show as bare labels, and "Beyond the chapters" is unclear.
- **What a user feels:** finds nothing to tap. The real path is `⋯` → Edit → Add a task → Save.
- **Why it harms:** the app's main object is read-only at the moment the user wants to act.
- **Fix:** an inline "Add a task" under each chapter. Rename "Beyond the chapters" to "Other tasks".

**9. Navigation duplicates itself** (see the Home vs Today section)
- **Where:** Home and Today list the same tasks. Profile is both a header icon and a tab. Bonfire and Profile are root tabs that still have a back button.
- **What a user feels:** "What's the difference between Home and Today?" Back on a tab jumps to Home.
- **Why it harms:** four tabs for roughly two jobs, and the back button implies a hierarchy that doesn't exist.
- **Fix:** merge Home and Today. Tabs: Today, Bosses, Profile. Bonfire becomes a card that appears in the evening. Remove the back button from root tabs and the Profile icon from the header.

**10. The core gesture is hidden, and there is no undo**
- **Where:** the Home task row. A tap opens the menu. A short tap on the needle showed no change. "Hold to strike" appears only on Today. No undo exists in the code.
- **What a user feels:** taps, gets a menu, and assumes the check mark is broken.
- **Why it harms:** users may never find the signature mechanic on the default screen, and a wrong strike can't be reversed.
- **Fix:** coach the first row on first run with "Press and hold to strike." A short tap on the needle shakes it and shows that line. After a strike, show a snackbar: "It is done · Undo".

**11. A survey interrupts every strike**
- **Where:** after the hold, a sheet asks "How did the strike land?" with "Clean strike" and "A real try". Cancel rolls the strike back.
- **What a user feels:** the payoff is followed by admin. "Promise kept" appears even when no promise was made.
- **Why it harms:** it spends the reward moment on a form, every time, and it duplicates "Mark as tried" in the row menu.
- **Fix:** a hold means a clean strike, instantly. Show a snackbar: "It is done · Only partly?" Show "Promise kept" only when a promise exists.

**12. Bonfire, the emotional peak, ends in nothing**
- **Where:** after "Rest at the hearth".
- **What a user feels:** rests, gets a reminder prompt, and is dumped on Home, where numbers changed silently. Home still says "All tasks struck. Rest at the bonfire" while Today says "Rested". The Bonfire tab stays blank apart from "You have rested." A strike after resting leaves embers carried with no way to bank them that day.
- **Why it harms:** there is no closure and no reason to end the day here, and the stale line reads as a bug.
- **Fix:** add a closing screen: "Night 1. 2 tasks struck. 1 ember kept. Tomorrow: Write before noon." Replace the stale line with "You've rested. See you tomorrow." Show the same recap on the Bonfire tab.

**13. Edit boss loses changes without warning** (seen + DB)
- **Where:** Edit boss → back button. I typed a meaning and tapped back. There was no prompt, and the field in the database was empty.
- **What a user feels:** assumes it saved, as most mobile forms do.
- **Why it harms:** silent data loss, found later.
- **Fix:** when there are unsaved changes, ask "Discard changes?" with "Keep editing" / "Discard".

**14. Copy bug at the most serious moment** (seen)
- **Where:** the Fallen screen read "The Finish my tax return remains". `fallen_screen.dart:117` puts "The" in front of any title. The "10 / 10" beside it has no label.
- **What a user feels:** a line meant to console reads as machine-generated.
- **Why it harms:** it exposes the template exactly when sincerity matters, and most goal titles trigger it.
- **Fix:** "'Finish my tax return' remains, and so do you." Label the number "Health 10/10".

### Medium

**15. The keyboard covers primary actions** (seen)
- **Where:** the add-task sheet and the Fallen "Rise" button; you must tap "done" first. The boss field on step 2 doesn't get focus automatically.
- **Fix:** pin the main action above the keyboard, let Return submit, and autofocus step 2.

**16. Layout breaks at large text sizes** (seen)
- **Where:** Home.
  - About 194%: fine, apart from the header buttons scrolling away.
  - About 235%: the greeting breaks as "Evenin / g." and the label as "STREA / K".
  - About 310%: STREAK stacks one letter per line, text overlaps, and tasks fall off-screen.
- **Fix:** limit how far the display serif scales, stack the streak label and value at large sizes, and never break inside a word.

**17. Action sheets give every action the same weight** (seen)
- **Where:** task and boss sheets. "Delete" looks like "Edit". "Leave for now" is unclear. "Pin" sits next to "This attempt failed".
- **Fix:** group common actions apart from consequential ones, with a gap between. Rename "Leave for now" to "Pause this boss". Give the fail row a subtitle: "Ends this attempt. Embers stay."

**18. The glass chrome reads as decoration, or as a rendering bug** (seen, on the uncommitted spike code)
- **Where:** every sheet, button and the tab bar. A hard diagonal wedge crosses the text, and a white arc and dot repeat in each corner.
- **Why it harms:** this is the most AI-template element in the app, and it contradicts DESIGN.md's "restraint". The ruled diamond divider has the same problem: it appears up to twice per screen.
- **Fix:** remove the wedge and the corner glint, and keep a soft blur only on the tab bar and sheets. Use the diamond divider only on ritual screens. Re-check against `main`, because this branch carries work-in-progress glass changes.

**19. Onboarding has no Back, and its controls jump** (seen + code)
- **Where:** steps 2 to 5. There is no Back control and swiping is disabled. When the step 2 title is empty, the buttons turn into small centred text; otherwise they are a large button with Skip on the left.
- **Fix:** add Back. Keep one layout and disable the button in place. Explain why it is disabled: "Name it to continue."

**20. A borrowed world, and every boss looks the same** (seen)
- **Where:** the "Pharloom" biome is Silksong's kingdom name, and the horned, masked figure with a needle strongly evokes Hornet. Taxes and marathons get the same mascot.
- **Why it harms:** the identity is borrowed rather than owned. It may also draw a trademark complaint or a store rejection; get legal advice before launch.
- **Fix:** rename the biomes in your own words (for example "Ember Night"). Generate boss variants from the title (mask, horns, weapon). A boss that looks like *your* taxes is the best thing to share.

### Low

**21. Small polish** (seen)
- "+1 embers" should be "+1 ember".
- "Strikes at" is unclear; use "Belongs to".
- Settings shows a raw "Copy tester report" row; hide it in release builds.
- Step 5 says "nothing is lost but health" before health has been introduced. Use "Fall as often as you need. You keep what you earned." instead, or cut the line.

## Home vs Today: bad

The two tabs show the same header (Hearthrise, the date, "Evening.", the ember tally and the level badge) and the same "Today's tasks" list with the same grouped rows.

- **The real differences are small.** Home adds the streak card and All bosses. Today adds the bonfire card, health bars, Carried/Banked and filter chips.
- **The second tab feels broken.** Switching tabs barely changes the screen.
- **The names collide.** Home has a section called "Today's tasks", so the "Today" tab tells you nothing new.
- **Features are split for no reason.** The hold hint, health and filters live only on Today. The streak and the `+` button were seen only on Home. The hint matters most on Home, the first screen people see.
- **It is one view shipped twice.** `today_view.dart` has an `isHome` flag, so the same view renders twice with small changes. Sharing the code is fine; shipping it as two tabs is not.

Two tabs doing one job means nobody decided what the main screen is.

**Fix:** keep one screen, Today, in this order: the greeting, one status line, then the tasks. Show streak, health and embers compactly above the list. Give bosses their own tab.

## Top 5 improvements, by priority

1. **Make the daily loop honest:** strikes cover the day and pay out at once (#4, #11).
2. **Stop losing or corrupting what the user meant:** one-time tasks by default, a safe Skip, a confirm before failing, and a guard on unsaved edits (#1, #2, #3, #13).
3. **Get a new user to a real strike in under 60 seconds:** say what the app is, name the boss, name the next step, hold (#5, #7, #10).
4. **Give Rest a real ending:** a recap and tomorrow's one thing (#12).
5. **Cut the surface:** merge Home and Today, teach terms on first use, remove the glass wedge (#6, #9, #18).

## Worth preserving and amplifying

- **The lesson returning.** "Attempt 2 · Last lesson: *Start before the deadline panic*" on the boss card is the best moment in the app, and no competitor does it. Make it bigger; the small italic is hard to read.
- **"Fallen." followed by "Rest first. Write it tomorrow."** It is quiet, gives permission, and is emotionally intelligent.
- **Attempts instead of resets.** A failure raises a number instead of zeroing one.
- **The strike itself:** hold, needle, dust, "It is done." It is distinctive; protect it from #11.
- **"One thing for tomorrow"** and **"Night 1 at the hearth."**
- **The mood options** "Fought well / Held on / I fell". They are human, and far better than emoji scales.

## Hype potential

Moderate to high, but in this session I saw nothing the user could share.

- **What to share:** a relic card, e.g. "Finish my tax return. Defeated on attempt 4. Lessons: …". It is vulnerable and funny, which is what people post.
- **The hook:** "the to-do app that keeps score of your failures, kindly". It is a clear angle for ADHD and Souls communities.
- **Anticipation:** a boss that visibly weakens day by day, plus art unique to each boss. In my session the boss looked the same throughout.
- **What kills it:** the Silksong echo, identical bosses, and a day-2 punishment for forgetting a ritual.

## Would I keep using it?

Not in the state I tested. I would come back on day 2 out of curiosity about the boss. Then I'd see the accountant call again, possibly take a fall for not resting after doing the work, and quit within a week.

With #1–#4 fixed and a shorter first session, I would likely keep it through one real boss just to see the relic. The heart is right; the system around it needs to get out of its way.

## Fixes made

**Branch:** `fix/critical-first-run`, commit `dcc8bcd` ("fix: four first-session critical issues").
**Worktree:** `.claude/worktrees/fix-critical-first-run`.
**Base:** `spike/native-glass` at `e66f27f`, without the uncommitted glass edits. It is not based on `main`, because `main` lacks the new Home, the streak and The Day.
**Status:** local only; not pushed and no PR.

Each fix started with a failing test. `flutter analyze` is clean and the full suite passes (1167 tests).

| # | Change | Tests | Simulator |
| --- | --- | --- | --- |
| 1 | `addQuickTask` takes `recurrence`, defaulting to `Recurrence.none`. The add-task sheet has a "Repeat daily" switch, off by default. A one-time Day task struck on an earlier day drops out of The Day (`buildBossView`). | `day_boss_test.dart`, `new_foe_sheet_test.dart` | Seen: the task sits under "THE DAY" with no "DAILY" tag |
| 2 | On onboarding's last page, Skip calls `_finish(remind: false)`: the boss is saved and the reminder is skipped. | `onboarding_test.dart` | Not tapped |
| 3 | "This attempt failed" opens "End attempt N?" ("Your embers stay. {boss} waits for the next attempt.") with "Keep fighting" / "End attempt". "Keep fighting" is the default. | `boss_screen_test.dart`; the fall paths in `screens_test`, `sound_cues_test` and `fallen_feel_test` now confirm first | Seen |
| 4 | `missedDays` covers a day with any strike (the `lightDays` parameter is removed). `weekStreak` counts strike days. Home's ember count is carried plus banked. | `missed_days_test.dart`, `day_dao_test.dart`, `missed_day_test.dart`, `home_screen_test.dart`; the `gate_stage3_test` day 2 now has no strike | Seen: 9 unbanked embers, and today kept with no rest |

`STAGE3_PLAN.md` D3 and D8 record the rule change.

**Known limits:**
- Quick tasks already saved as daily stay daily; nothing migrates them.
- "Light day" no longer does anything. No screen in the app ever marked one, so its rows are now just a record.
- The simulator's Hearthrise app is now the demo build from this branch, with your database restored byte for byte. Rebuild your own branch before using it.

## Not yet done (High and below)

Issues #5–#21 are still open. The cheapest high-value ones next: #14 (the "The {title}" copy bug), #13 (the unsaved-edit guard), #12 (the stale "Rest at the bonfire" line), and merging Home and Today (#9).
