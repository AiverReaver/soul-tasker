---
name: ui-verify
description: Use when checking whether the Hearthrise app matches a design artifact, or when asked to verify, compare or check every page, screen, sheet or biome in the app (simulator or pixel check). Runs the golden tests, then walks the demo app on the iOS simulator and puts each screen beside its design board.
argument-hint: "<design artifact URL> [screens or biomes to limit to]"
---

# ui-verify

Check the app against a design artifact and report every real difference, with proof.

**The rule: a row counts as checked only when its comparison image exists and you have looked at it.** If a screen wasn't seen, say so. Never write "matches" from code or from memory.

## Inputs

- The design artifact URL (for example the v4.2 board). If none is given, use the newest one named in `V4*_CHECKLIST.md` or `V4*_HANDOFF.md` and say which.
- An optional limit: screens (`home`, `boss`, `strike flow`), biomes (`choral`), or `all`. Default: all.

## Files

| What | Where |
| --- | --- |
| Screen goldens (5 biomes x 7 screens, 393x852, 1 px = 1 pt) | `app/test/golden/` |
| Screenshot of the booted simulator to `shots/NAME.png` (393x852) | `docs/ui-tour/shot.sh NAME` (`SIM=<udid>` if more than one is booted) |
| Timed burst of screenshots for animations | `docs/ui-tour/burst.sh PREFIX 0 0.1 0.25 ...` |
| Side by side, labelled, one PNG | `docs/ui-tour/vs.sh OUT.png design=A.png app=B.png [golden=C.png]` |
| Every element, state and route, with file:line | `docs/ui-tour/CHECKLIST.md` (walk list), `docs/ui-tour/design-system-map.md` (tokens) |
| Seeded data, onboarded, several bosses | `app/lib/main_demo.dart` |

## Steps

### 1. Make the run's checklist first

Create `reports/ui-verify/<YYYY-MM-DD>/CHECKLIST.md`. Use one row per design board, per biome and per state the board shows (sheet open, hold charging, empty), within the limit:

```
- [ ] home · pharloom · board Home.dc.html
```

To get the boards, list the artifact's files (`Artifact` action `list`, scope `files`) and fetch each board with `read` + `path`. Add a row for every app screen in `CHECKLIST.md` that has no board, marked `(no board: check consistency only)`. Report the row count before you start.

### 2. Golden pass (fast, no simulator)

```bash
cd app && flutter test --tags golden
```

A failure means the screen changed since its baseline. Look at `app/test/golden/failures/*_isolatedDiff.png` and note which screens moved. Don't update the baselines yet.

### 3. Render each board

Design boards (`project/*.dc.html`) need the artifact's design runtime (`support.js`), so headless Chrome can't render them on its own. They are 390x844.

1. Open the artifact in the built-in browser.
2. Press ▷ (top right). That opens a menu listing every prototype and static artboard by name.
3. Pick a board and screenshot it.

Clicks on claude.ai can trigger a permission prompt for each action. Before you start, ask the user to allow the site once, and batch the clicks for each board.

Save the renders to `reports/ui-verify/<date>/design/<row>.png`.

### 4. Walk the app on the simulator

1. `mcp__Claude_Code_iOS_Simulator__control` `attach`, so the user can watch.
2. Boot the iPhone 16 by name if nothing is booted: `xcrun simctl boot "iPhone 16"`.
3. To test a fresh install, run `xcrun simctl uninstall booted com.hearthrise.app` first.
4. Run the demo app in the background and wait for `Flutter run key commands`:
   `cd app && flutter run -t lib/main_demo.dart -d <udid>`
5. Change biomes in Settings inside the app.
6. Reach each row with `tap`, `swipe` or `touch_path`. For a hold, pass `tap` a `duration`.
7. Then run `docs/ui-tour/shot.sh <row>-<biome>`. For animations, use `burst.sh`.
8. Run `vs.sh reports/ui-verify/<date>/vs/<row>.png design=<render> app=<shot>`.
9. `Read` the result. Tick the row `[x]` only after reading it, and record the vs path on the row.
10. If a row can't be reached, mark it `[-] (reason)`. Examples: no accelerometer on the simulator, needs the server, needs a past date.

### 5. Describe differences precisely

A difference names the element and the attribute: position, size, spacing, radius, colour token, font, weight, copy, icon, missing or extra element, or motion. Give numbers where you can measure them (`rects.py` gives design rects; count pixels on the 1 pt shot).

Leave these out: demo data that differs from the board (boss names, task titles, dates, counts, greetings). Board text that is plainly sample copy is not a difference either.

### 6. Report

Write `reports/ui-verify/<date>/report.md`:

- Counts at the top: `[x]` checked, `[-]` not reached (with reasons), and differences found.
- The differences, grouped by screen. Each one has the vs image path, the board, what differs and the likely file (from `design-system-map.md`).
- The golden failures from step 2.

Publish the report as an Artifact with the vs images if the user wants to look through it. Then ask which differences to fix. Don't fix anything without asking.

### 7. Fixing (when asked)

- Test first, per `CLAUDE.md`: a widget test for the behaviour or layout.
- After a fix, shoot the screen again and run `vs.sh` again.
- Only once the user approves the look, refresh that screen's baseline:
  `flutter test --tags golden --update-goldens --plain-name "<biome> <screen>"`
- Finish with `flutter analyze` and the full `flutter test`.

### 8. Clean up

Stop `flutter run` (send `q` or kill it). Ask before shutting the simulator down.

## Don't

- Don't tick a row from code reading, test results or an earlier run.
- Don't say "all pages checked" while any row is still `[ ]`.
- Don't run `--update-goldens` over the whole suite to make failures go away.
