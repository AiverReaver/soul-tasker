# Hearthrise v4.2 handoff

Paste this to start the next session.

---

You are continuing work on Hearthrise, a Flutter app in `/Users/ashishvagish/Documents/projects/soul-tasker/app`, on branch `theme-biomes`. Read `CLAUDE.md` first. The rules that matter: all code is written test first (failing test, see it fail, smallest code to pass), every step ends with `flutter analyze` clean and the full suite green from `app/`, reusable widgets live in `app/lib/ui/` as stateless widgets, and commit messages never carry a Claude trailer.

## Where things stand

Commits on `theme-biomes` from the last two sessions:

- `cde112d` perf(ui): sheet action rows are plain framed rows (`ActionRow` in `lib/ui/action_row.dart`, replacing the glass row), and the ambient clock in `lib/features/shell/atmosphere.dart` ticks at 30 Hz instead of the display rate. Heat on a real phone was never measured.
- `d4a27d8` feat(day): a default boss "The Day" (fixed id `boss-the-day`, `lib/data/day_boss.dart`). It is made at startup by `BossDao.ensureDayBoss`, cannot be set aside, defeated or deleted, and is never vanquished. `BossDao.addQuickTask` adds a daily task to it. The Home `+` sheet defaults to it. Its health is today's tasks still open. Boss actions hide leave, victory and fail for it.
- `27b0d47` fix(strike): `TodayView` keeps a freshly struck row in its slot for 1.5 s (`strikeLinger`, `todayTasks(lingering:)`), rows are keyed by task id, a held row trembles 1 px, the strike result sheet uses plain rows, and Home's filter chips are inset 20 px.

Not committed: `V41_HANDOFF.md`, `V42_CHECKLIST.md`, `reports/`, `research_notes/`.

The design source is the artifact "Hearthrise v4.2": https://claude.ai/artifact/Pp9srMzpYmmy7H5Gs8zXsb. Read boards with the Artifact tool (action read, path `project/<Name>.dc.html`). It has 11 boards: Home (interactive, grouped by phase, compact rows, working hold-to-strike), Home-Charge, Home-Hit, Home-Struck, TaskActions, BossActions, BossActions-Day, QuickAdd, StrikeResult, DayBoss, TaskEdit. It was written but never rendered or viewed by the previous session. The older v4.1 canvas is https://claude.ai/artifact/5bU9fETFefqgD6a1UAeZfM (version 18) and is the reference for everything v4.2 does not change.

`V42_CHECKLIST.md` is the working checklist. Tick a box only when the work is done, tested and, for UI, seen in a screenshot. Items 1–5c are done. Items 6–10 are marked "published, not viewed". Items 11–12 are not started.

## First, ask the user

Whether the v4.2 boards look right. Do not code from them until they say so.

## Then do, in this order, test first

1. Home phase grouping (checklist item 11). Group Today's tasks under a label per boss and, when the boss has phases, per phase ("The Certification · Chapter II · Learn", with a "N of M" count). Make rows compact: 52 px high, the ember count on the title line, hold button 44 px. The code lives in `lib/features/today/today_view.dart` and `lib/ui/task_row_tile.dart`; new widgets go in `lib/ui/`. Keep the lingering struck-row behaviour.
2. Day boss polish (item 12): Home card or chip for The Day, an empty state, and the Day boss screen from the DayBoss board. Decide whether The Day should show on the "All bosses" list and count in "N active".
3. Replace the tab labels (Home, Today, Bonfire, Profile) with the design's (Bosses, Today, Bonfire, Relics) only if the user confirms.

## Known open issues

- Victory's "Taken in N attempts": the numeral is bottom-aligned with its labels, but the reference baseline-aligns them. Fix with a `Row` and `CrossAxisAlignment.baseline` in `lib/features/victory/victory_screen.dart` near line 122.
- Bonfire screen has no flame-and-logs art and shows flask dots where the reference has flask icons.
- The "Mark this boss as defeated?" dialog reached from Declare victory showed a yellow double underline on its two labels in Greymoor and Moss (debug-build sign of a missing text style). Not traced.
- Phone heating: the 30 Hz clock is a partial fix at best. If it still heats, profile with `flutter run --profile` and DevTools. Next cuts: stop the clock and tilt ticker when idle, drop backdrop blur on always-visible chrome.
- Boss page art may have extra blank space above it versus the reference stage. Not compared.

## How to verify on the simulator

Build the demo entrypoint, which seeds bosses and marks onboarding done, and reinstall to reseed:

```bash
cd app && flutter build ios --simulator --debug -t lib/main_demo.dart
xcrun simctl uninstall booted com.hearthrise.app
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
xcrun simctl launch booted com.hearthrise.app
```

The iPhone 16 simulator (`EA96FAD7-0D3B-4C9F-B090-75FF81893BFB`) was used. Driving it needs the user to grant access with "Let Claude use it" in the simulator panel. Tap coordinates are in points (393 x 852). For onboarding, install the normal `lib/main.dart` build on a fresh install. To see a theme on onboarding, set `settings.biome` and `settings.onboarded` with `sqlite3` on the app's `Documents/hearthrise.sqlite`.

## Cautions

- The ECC gate hook asks for stated facts before the first write to a new file and before the first Bash command; state them, then retry.
- Do not claim a UI step is verified unless a screenshot was looked at.
