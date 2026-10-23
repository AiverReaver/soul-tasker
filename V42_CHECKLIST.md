# Hearthrise v4.2 checklist

Tick a box only when the work is done, tested and (for UI) seen in a screenshot.

## Code now (animation and screenshot fixes)

- [x] 1. Task rows are keyed by task id, so a strike's animation stays on its row when the list reorders. Test: widget test.
- [x] 2. A struck task stays in its slot for the strike animation (about 1.4 s), then leaves or moves. Test: unit test on `todayTasks` + widget test on Home.
- [x] 3. Home filter chips are inset 20 px like the rest of Home (they touched the screen edge). Test: widget test. Screenshot checked.
- [x] 4. Simulator check: hold a task on Home and see charge, hit, shatter, settle. Screenshots taken (charge edge, slash, flecks, dust seen; the bone hit flash lasts ~110 ms and was not caught in a frame).
- [x] 5. `flutter analyze` clean and full suite green (1048 tests).
- [x] 5b. Found while checking: the strike result sheet used glass pills with clipped notes. Now plain rows (test + screenshot).
- [x] 5c. Held row trembles 1 px while charging, as in the design (test).

## Design first (artifact "Hearthrise v4.2", https://claude.ai/artifact/Pp9srMzpYmmy7H5Gs8zXsb)

`[~]` = written and published, not yet viewed by me. Tick only after someone looks at the rendered board.

- [~] 6. Home groups tasks by phase when the boss has phases, and the rows save space.
- [~] 7. Quick add and the default boss "The Day" (health follows today's tasks).
- [~] 8. Plain action rows (no glass buttons) in the task actions, boss actions and boss edit sheets.
- [~] 9. Strike animation on the Home row: charge fill, hit flash, shatter, struck row holds its slot.
- [~] 10. Chip row inset 20 px.

## Code later (after the design is approved)

- [ ] 11. Home phase grouping in the app.
- [ ] 12. Day boss polish in the app (Home card, empty state).
