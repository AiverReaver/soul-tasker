---
name: design-version
description: Use when the user asks for a new version of the Hearthrise design ("make v4.3", "update the design into a new version", "new artifact called v…") or asks what changed between two design versions.
argument-hint: "<new version name> [base artifact URL] <what to change>"
---

# design-version

Make the next design version as a new artifact. Change only what was asked, and record what changed with proof, so there's never a "list everything that differs from v4.1" session again.

`docs/design/VERSIONS.md` is the log. Its first entry is the current version.

## 1. Pin the inputs

- **Base:** the URL the user gives, otherwise the top entry in `VERSIONS.md`. Say which one you used.
- **New name:** what the user asked for, otherwise the next point version (v4.2 becomes v4.3).
- **Changes:** restate them as a numbered list of board-level changes, for example "Home: tasks grouped by chapter". If a change could touch more than one board, list each board it touches.

## 2. Snapshot the base

Read every board source of the base into `<scratchpad>/design/<base>/`. Each board is about 10-30 KB and comes back inline, so read the boards in batches of about 10 and work from the saved files:

1. `Artifact` `list` with scope `files`.
2. `read` with `paths` set to all of `project/*` (boards and `canvas.json`) and `out_dir` set to that folder.

Capture the boards you're about to change. Open the base in the built-in browser, press ▷, pick the board and take a screenshot. Save each as `before-<Board>.png`. Before the first click, ask the user to allow claude.ai once so the browser doesn't prompt for every action.

## 3. Create the new version

Get a fresh Design artifact with `Artifact` `quickstart` (`intent: "design"`), or publish from the Design type's `type_url` with `title: "Hearthrise <new name>"`. Fill it by following the instructions the type returns.

Bring over every base board unchanged first. HTML can't be copied server side, so publish the sources you read in step 2 as they are. Then edit only the boards on the change list.

Each board in the base keeps its file name, so the diff in step 4 lines up.

## 4. Diff, then write the changelog

Read the new version's `project/*` into `<scratchpad>/design/<new>/`, then run:

```bash
python3 -I docs/design/board_diff.py <scratchpad>/design/<base> <scratchpad>/design/<new> [Old=New ...] [--full]
```

Don't use a plain `diff -rq` here. Every version changes the `<title>` on every board, so a plain diff flags all of them. `board_diff.py` ignores the title. When a board was renamed, pass `Old=New` (for example `Main=Home`, from v4.1 to v4.2) so links to it count as the same. It prints the boards that were removed, added, changed, and how many are identical. `--full` adds the exact lines.

- **A board that differs but isn't on the change list** is an accident. Restore it from the base and diff again.
- **A board on the change list that doesn't differ** means the change is missing. Make it.
- **For each changed board,** capture `after-<Board>.png` in present mode. Then run `docs/ui-tour/vs.sh <scratchpad>/design/vs-<Board>.png before=... after=...` and `Read` the result. Write each difference as element plus attribute (spacing, radius, colour token, type, copy, icon, layout, motion), with numbers where you can measure them.
- **Leave out sample data:** boss names, task titles, dates, counts, greetings.

## 5. Record it

Add an entry at the top of `docs/design/VERSIONS.md`:

```
## <new name> — <URL>
Base: <base name> · <date>
- <Board>: <difference> (checked: diff + before/after)
- Unchanged: every other board (identical sources)
```

If an implementation checklist exists (`V4*_CHECKLIST.md`), add a `[ ]` row for each change that needs code.

## 6. Hand back

Give the user:
- The link.
- The changelog entry.
- The before/after images for changed boards, sent with `SendUserFile`.

Don't claim a board is unchanged unless the diff says so.

## To answer "what changed between A and B"

Do step 2 for both A and B, then step 4. Report only the boards the diff shows, each with before/after images. If A or B is in `VERSIONS.md`, compare its entry with the diff and point out where they disagree.
