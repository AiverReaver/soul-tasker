# Hearthrise: working rules

## TDD is mandatory

All code in this repo is written test-first: write a failing test, see it fail, write the smallest code to pass, then refactor. See `STAGES.md`, "Development method".

- Every plan (stage plans, step lists, task breakdowns) must list the tests before the code for each step, and its "done when" must name the tests that pass.
- Bug fixes start with a failing test that reproduces the bug.
- A step is done only when `flutter analyze` is clean and the full test suite passes (run from `app/`).
- Logic: unit tests with in-memory Drift and a fixed clock. Screens: a widget test for the main path. Gates: an automated test where possible.
- Anything that cannot be automated (device feel, 200% text, real haptics) goes in the plan as an explicit manual check.

## UI lives in `app/lib/ui/`

- All reusable widgets go in `lib/ui/` and are `StatelessWidget`s: values and callbacks in, no providers, Drift, router or `Haptics`. See `STAGES.md`, "UI components".
- Screens in `lib/features/` compose `lib/ui/` widgets. Check there first; if none fits, create a new widget in `lib/ui/` (test first) rather than building UI inline.
- Stateful behavior (hold timer, animation controllers, providers) stays in a thin container in `lib/features/` that passes values down.
