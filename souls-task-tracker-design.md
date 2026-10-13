# Souls-Inspired Real-Life Task Tracker: Product and Design Document

Name: **Hearthrise** (USPTO search clear, Oct 2026; domain hearthrise.app)
Platforms: Android first, iOS later
App framework: Flutter
Backend: Node.js with PostgreSQL
Status: Stage 2 feel prototype built (hold-to-strike, health bar, fallen screen). Stage 1 core loop not started. Progress is tracked in `STAGES.md` and `CHECKLIST.md`.

---

## 1. Vision

A task and goal tracker for players of Dark Souls, Elden Ring, and similar games. Instead of fighting literal bosses, users fight their real-life challenges: the big goal, the hard exam, the project, the fitness target. The app borrows the structure and emotional language of those games to teach the lessons the games teach:

- You will fail, and failing is how you learn.
- Persistence beats talent.
- Every attempt, even a failed one, counts as progress.
- Quitting is the only real loss.

The core promise: **"Failing is fine. Quitting isn't."**

The app must make failure feel like progress instead of guilt. That is the single most important difference between this app and a typical productivity tool, and also the single biggest design risk, because the games punish failure and a real-life app must not make people feel worse about their lives.

### Target audience

- People who play and love Souls-like games and relate to their philosophy.
- People who struggle with discipline and consistency and respond well to game framing.
- People who have quit other task apps because a broken streak made them feel like failures.

### What success looks like

- A user returns the day after a failed attempt, not despite it.
- A user can look at a finished boss and see "it took me 9 attempts" as a point of pride.
- The app feels calm, weighty, and atmospheric, not loud and gamified.

---

## 2. Lessons the games teach (and how the app expresses them)

| Lesson from the games | How it shows up in the app |
|---|---|
| Failure is the teacher | Every failed attempt asks one question: "What did this teach you?" The answer is shown at the start of the next attempt. |
| Persistence beats talent | Attempt counter on every boss. The number grows with pride, not shame. |
| Patience over panic | Rule of three: after three failed attempts at the same thing, the app asks what you will change. |
| Know when to retreat | Option to split a failing task into smaller tasks, like going back to level up. |
| Small progress adds up | Effort points are earned for trying, not only for succeeding. Visible progress bars. |
| Preparation matters | Boss phases and planning before each attempt. |
| Rest is part of the journey | The daily bonfire check-in is a built-in ritual of rest and reflection. |
| Humility toward the challenge | Small daily tasks are treated as real enemies with weight, not throwaway checkboxes. |
| Earned victory feels better | A rare, restrained victory screen showing attempts taken and lessons learned. |
| Community helps | Optional later feature: sharing a lesson for others to see (not in the MVP). |

---

## 3. Design principles

1. **Restraint.** The games say little. No confetti, no loud popups, no "Great job!!!" Silence makes rare moments land harder.
2. **Weight.** Actions feel deliberate. Completing a task is a small committed act, not a casual checkbox tap.
3. **Honest consequences, without shame.** Failure is acknowledged plainly and never punished harshly. Loss may exist, but it is soft, capped, and recoverable.
4. **Atmosphere over information.** Show less on screen. Every element earns its place.
5. **Effort always earns embers. Health measures promises kept.** A real try is always paid in embers, even when it falls short of a promise. Only doing nothing earns nothing.
6. **The user is in control.** Gentle mode and hardcore mode, adjustable difficulty, accessibility alternatives to every gesture.
7. **Calm, never nagging.** One gentle reminder per day. No guilt notifications, no loss-streak alarms.

---

## 4. Terminology: original names for game concepts

To keep the tone without trademark risk, the app uses its own vocabulary. The table below is a starting point; final names can be changed freely.

| Game concept | Real-life meaning | App term (working) |
|---|---|---|
| Boss | A big, scary goal | **Boss** (generic word, safe to use) |
| Quest | A multi-step goal | **Quest** |
| Enemy / mob | A small daily task | **Foe** or **Mob** |
| Death | A failed attempt or missed day | **Fallen** |
| "You Died" screen | The failure moment | A quiet "Fallen" screen with an original line |
| Bonfire | Daily check-in and rest | **Bonfire** or **Hearth** |
| Estus flask | Limited recovery charges | **Flask** or **Vial** |
| Runes / souls | Effort points | **Embers** |
| Bloodstain | Where you fell, with dropped points | **Bloodstain** or **Mark** |
| Level up | Spending points on stats | **Rise** |
| Victory screen | Boss defeated | **"Foe vanquished"** (original wording) |

**Rule:** do not use the exact names, fonts, art, sounds, logos, or screen text from the games (for example the exact "You Died" text and styling, or the game's own terms like "Estus" or "Runes") in the app or store listing. Use original wording that evokes the same mood.

---

## 5. Core concepts and mechanics

### 5.1 Bosses

A boss is a big goal the user wants to defeat (finish the app, pass the certification, run a 10k).

- Each boss has a title, a short description of what "defeated" means, and an optional target date.
- A boss is divided into **phases** (2 to 4 recommended), like a real boss fight with stages.
- A boss has an **attempt number**, shown prominently ("Attempt 7").
- A boss has a segmented **health bar**. Completing tasks and phases damages it.
- A user can have **any number of bosses active at the same time**. There is no limit. Real life has several big goals at once (a career goal, a fitness goal, a personal project), and the app should reflect that.
- Each boss runs independently: its own phases, tasks, attempt counter, health bar, lesson notes, and bloodstain.
- Optional status for a boss: **active** (being fought), **waiting** (paused by choice, no pressure), or **defeated**. Waiting bosses never trigger falls or reminders.
- Optional **focus pin**: the user can pin one or more bosses to the top of the home screen. This is a convenience, never a restriction.
- **Reset on a failed attempt**: each boss has a setting for what a failed attempt undoes, because goals differ (a fitness streak may want a clean restart, a long project should never lose finished work). Chosen when the boss is created and editable later. The app-wide default is set in Settings.

| Setting | What a failed attempt does | Default |
|---|---|---|
| **Nothing** | Struck tasks stay struck. The health bar stays where it was. | Yes |
| **Current phase** | Tasks in the current phase (the earliest phase not fully done) reopen. Earlier phases stay done. | |
| **Whole boss** | Every task reopens. The boss returns to full health. | |

  In every case the attempt counter rises, the lesson is kept, and embers already earned stay earned. Reopened tasks can be struck again but do not pay embers a second time.

### 5.2 Phases

Phases make a large goal feel tractable and give visible progress mid-fight.

- Each phase has its own name and a set of tasks.
- Completing a phase removes a large segment of the boss's health bar.
- Phases can be reordered or adjusted between attempts, reflecting the "learn the pattern" idea.

### 5.3 Tasks (foes)

Tasks are the small units of real-world action.

- Each task belongs to a phase (or stands alone as a daily task).
- Each task has a **difficulty weight**: Light, Heavy, or Boss-tier.
- Tasks can be one-time or recurring (for example daily).
- Two ways to resolve a task:
  - **Strike** (completed).
  - **Tried** (attempted but not finished). This still earns effort, but fewer points than a strike.
- Doing nothing earns nothing. This is how the app rewards effort over outcome.

### 5.4 Attempts

An attempt is one real try at a boss, phase, or task.

- Each boss keeps a running attempt count.
- A boss attempt fails, and the boss's counter rises by one, in exactly three cases:
  1. **Declared:** the user marks the attempt as failed on the boss screen.
  2. **Health death:** the player's health reaches zero (5.12). Only the boss of the task that dealt the final blow is affected.
  3. **Missed day:** a day ends (see 5.6, day rollover) with no bonfire check-in. Every **active** boss is affected. Waiting bosses are not. A day covered by a flask charge or marked as a light day is not a missed day.
- A task or phase attempt fails when the task is marked Tried or its deadline is missed. These failures feed the rule of three (5.10) and do not raise the boss counter on their own.
- A failed attempt creates a **fallen log entry** with a one-line lesson. When one event fails several bosses at once (a missed day), the user sees one fallen moment and writes one lesson, which is stored on every affected boss.
- What a failed attempt resets depends on the boss's reset setting (5.1).
- The most recent lesson is shown at the start of the next attempt: "Attempt 7. Last time: rushed the second phase."
- Attempt history is kept so the victory screen can show the full journey.

### 5.5 The fallen moment

When an attempt fails, a day is missed, or health reaches zero (see 5.12):

1. The screen dims slowly. No red, no alarms.
2. A single quiet line appears (for example "Fallen. Rest, then rise.").
3. One prompt: **"What did this teach you?"**
4. The user writes one short line (or skips, with a small effort penalty only on the lesson bonus, never on the attempt itself).
5. The lesson is stored with the attempt and shown at the start of the next try.
6. The boss's reset setting (5.1) is applied.
7. A bloodstain is created if the embers system is active (see 5.8).

The goal is to turn the worst moment of the loop into the most useful one.

### 5.6 The bonfire (daily check-in)

A calm, once-a-day ritual screen.

- Review what you did today.
- Write one lesson or note (optional).
- Choose tomorrow's top three tasks, drawn from any of the user's bosses.
- Carried embers (shared across all bosses) are **banked** (made permanently safe).
- One flask charge is restored on rest (up to a cap).
- Health is restored to full (default rule; see open questions).
- Planning accuracy for the day is shown, along with the weekly trend.
- A single gentle local notification invites the user to the bonfire at a time they choose.

The bonfire is the habit anchor: the app's most important loop is "do, rest, bank, plan."

**Day rollover.** A day ends at the daily check-in, or at a set rollover time if the check-in was skipped. The rollover time defaults to 4 AM local time and is adjustable in Settings, so a bonfire at 1 AM still belongs to the evening before. A day that reaches rollover without a check-in is a missed day (5.4). Health refills at rollover even when the check-in was skipped, so no one starts a day already wounded.

**Rest after a fall.** After a health death (5.12), the user can rest at the bonfire the same day to rise again. A rest is shorter than the daily check-in:

- Health is restored to full.
- Carried embers are banked.
- Remaining commitments whose deadlines have not passed are unfrozen and can cost health again. Commitments already missed stay missed.
- No flask charge is restored, and a rest does not count as the daily check-in or as a steadfast day.
- There is no limit on rests per day. Each death still counts as a failed attempt on the boss that dealt the final blow.

### 5.7 Flasks (recovery charges)

Flasks protect against bad days so the streak bends instead of snaps.

- Each user gets a small number of charges (for example 3 per week).
- Spending a flask lets the user skip or lighten a day without a fall.
- A flask also pays for a second deadline extension on a commitment (the first extension is free; see 5.12).
- No flask is needed for a lighter day: the user can mark a "light day" that only requires one small task.
- Flasks are restored at the bonfire or on a weekly reset (final rule to be decided in testing).

### 5.8 Embers (effort points) and bloodstains

This is the app's version of the runes-loss mechanic. It is the strongest and riskiest feature, so it is designed with soft edges.

**How it works**

1. **Earning.** Completing or attempting tasks earns **embers**. Heavier tasks earn more.
2. **Carried vs. banked.**
   - *Carried embers* are earned during the day and are at risk.
   - *Banked embers* are safe forever. They are banked at the daily bonfire check-in.
3. **Spending.** Banked embers can be spent at the bonfire to **rise**: increase personal stats such as Discipline, Focus, and Resilience. Spent embers are permanent and can never be lost.
4. **The fall.** If a user fails an attempt, misses a day before checking in at the bonfire, or runs out of health from missed commitments (see 5.12), some of their carried embers drop at a **bloodstain** attached to the failed task (or, for a health death, the task that dealt the final blow).
5. **Recovery.** To reclaim the embers, the user returns to that same task on their next attempt and does even a small version of it (a five-minute version counts). Doing so restores the dropped embers. This is the "go back to where you fell" moment, and it nudges people to return to the thing they avoided.
6. **One bloodstain per boss.** If the user falls again on the same boss before recovering, the older bloodstain on that boss fades and its embers are lost. Because users can fight several bosses at once, a fall on one boss never erases the bloodstain waiting on a different boss. (Whether this should instead be one bloodstain per user is listed as an open question.)

**Softening rules (to prevent guilt and quitting)**

- Only carried embers are ever at risk. Banked embers and stat levels are never touched.
- Partial loss: only a portion (for example half) of carried embers drops, and the portion is adjustable.
- Effort is always paid: the embers earned from the failed attempt itself are kept.
- Flask charges protect: spending a flask on a bad day means nothing drops.
- Lessons recover some: writing the "What did this teach you?" note returns a small portion of what was lost.
- A ceiling caps the sting: even in hardcore mode, one terrible stretch cannot wipe out a large share of progress.

**Modes**

| Mode | Loss rule | Default |
|---|---|---|
| **Gentle** | No loss. The bloodstain is only a reminder marker. | Yes |
| **Hardcore** | Full drop-and-lose rule with the softening rules above. | Opt-in |

Tone for this feature: calm and plain. Example lines: "Your embers lie where you fell. Return to claim them." and "The embers are gone. What remains is what you learned." No red text and no loss alarms.

### 5.9 Stats and rising

Banked embers can be spent to raise a small set of personal stats.

- Suggested stats: Discipline, Focus, Resilience (final list to be decided).
- Stats are mostly cosmetic and motivational in the MVP, shown on a simple profile screen.
- Later versions could tie stats to unlockable themes or titles.
- Keep this simple in the MVP: a single "level" is enough to start.

### 5.10 The rule of three

After three failed attempts at the same task or phase, the app asks one question:

> "Same path, same result. What will you change?"

Options presented calmly:

- Change the approach (edit the task or add a note).
- Split it into smaller foes.
- Rest first (use a flask and return later).
- Keep going as is (no judgment).

This is the "adapt your approach" lesson, built into the loop.

### 5.11 Victory

Defeating a boss triggers a rare, earned, restrained screen.

- One line, such as "Foe vanquished."
- Then the numbers that matter: attempts taken, days spent, total effort.
- Then the lesson notes the user wrote along the way, shown as a quiet scrolling list.
- The point is to show "it took 9 tries" as the real story.
- Then a **relic** is revealed: a keepsake of the fight, created from the boss's story (see 5.14). The user can add one final line about what the fight taught them.
- The boss is archived, and its relic is placed in the user's **hall of relics**, which they can revisit.

### 5.12 Commitments, deadlines, health, and death

This system turns the app from a list of things the user hopes to do into a **commitment system**. The user declares what they will do and by when. If they do not deliver, they lose health, and if they lose enough, they fall. It teaches something the games teach indirectly: knowing your own limits. A beginner who promises ten tasks, finishes three, and falls learns more about planning than any tip could teach. Early failure from over-committing is an intended part of the lesson, and the app turns it into a number the user can watch improve.

All numbers below are starting values to be tuned in testing.

**The commitment**

- At the start of the day, or at any time during it, the user commits to a task and chooses a **deadline**: in one hour, in a few hours, or by tonight.
- Choosing the time is part of the lesson. The app makes the user decide, not just list.
- A task without a deadline is an **open task**. It sits in the backlog, earns embers when done, and carries no health risk.
- There is no cap on how many commitments a user can make. If the total looks heavy, the app shows a calm note ("That is nine hours of promises.") and lets the user decide. Letting people fail is the lesson, and the app does not stop them.
- Commitments can belong to any boss or stand alone.

**Health**

- The player has a small health bar (default 10 points, adjustable). Health belongs to the player, not to any single boss, since a missed commitment on any boss costs the same health.
- Health may be tracked in half points.
- Each missed commitment costs health based on its difficulty:

| Task weight | Health lost on a miss |
|---|---|
| Light | 1 |
| Heavy | 2 |
| Boss-tier | 3 |

**What happens at the deadline**

| Outcome | Health | Embers |
|---|---|---|
| **Strike** before the deadline | No loss | Full embers |
| **Tried** before the deadline | Half the normal loss (a promise was not kept) | Reduced embers (effort is rewarded) |
| **Extension** used (see guardrails) | No loss, deadline moves | Unchanged |
| **Miss** (nothing marked by the deadline) | Full loss | None |
| **Late strike** (marked done after a miss) | The health stays lost | Partial embers (doing it late beats not doing it) |

**Health restore**

- Health is restored to full at the daily bonfire check-in, so each day begins as a fresh fight. This is the default; whether some of the damage should carry over is listed as an open question.

**Death**

- When health reaches zero, the player falls.
- The carried embers drop at a **bloodstain** on the task that dealt the final blow (on that task's boss). Recovery works as described in 5.8: return to that task and do even a small version.
- The boss of the task that dealt the final blow counts a failed attempt (5.4) and applies its reset setting (5.1).
- The rest of the day's commitments are **frozen**. They cause no further health loss, and the user can still complete them for embers. New tasks added while fallen carry no health risk.
- The user can rise the same day by resting at the bonfire (5.6, rest after a fall), which restores health and unfreezes commitments that are still before their deadline. Otherwise the fallen state lasts until the daily check-in or rollover.
- The fallen screen (5.5) appears with the usual lesson prompt, and adds the plain numbers: "You committed to nine tasks and finished three. What will you promise tomorrow?"
- In **gentle mode**, health loss is still shown and death still happens as a moment of reflection, but no embers drop. In **hardcore mode**, the full drop rule applies, with the softening rules from 5.8.

**Planning accuracy**

- The app tracks **planning accuracy**: commitments kept on time divided by commitments made.
- It is shown on the fallen screen, the bonfire screen, and the profile as a daily and weekly trend.
- The real progress for a beginner is not "I never fail." It is "I promise less, and I keep more of what I promise."

**Guardrails so it teaches instead of discouraging**

- **Free extension.** Each commitment can be pushed back once at no cost, because meetings and emergencies happen. A second extension costs a flask charge.
- **Newcomer grace.** For the first week, health losses are reduced and death never drops embers, so a new user does not die five times on day one and uninstall.
- **Calm notes, not blocks.** The app informs and never refuses.
- **Honesty is on the user.** The app cannot verify that a task was done, and that is acceptable. The only person being cheated is the player.
- **Waiting bosses are exempt.** Commitments on a waiting (paused) boss do not expire while it waits.
- **Recurring tasks** create a fresh commitment each day, with their own deadline.

**Deadline checking and reminders**

- Deadlines are checked using stored timestamps whenever the app opens, and on a schedule while it is running. Health is calculated from the recorded deadlines, so it works offline and never depends on a background job that a phone manufacturer might kill.
- If the app is reopened after deadlines have passed, it resolves them calmly in one summary ("While you were away, two deadlines passed.") instead of a wall of penalties, and the user can mark a task as done late.
- Deadline reminders are **opt-in per task** ("remind me 10 minutes before") and off by default, so the app stays within the "one gentle reminder a day" rule. On Android, precise alarm timing may need the exact-alarm permission, so these reminders should be treated as a convenience and never as the source of truth.

**Example of a beginner's first day**

A beginner commits to nine tasks, six of them heavy. They finish three, then miss five heavy ones in a row. That is ten points of health, so they fall after the fifth miss. The fallen screen shows "nine promised, three kept," asks what they learned, and tomorrow they commit to five. Over the following weeks, their planning accuracy climbs, and that climb is the visible proof that they are getting better.

### 5.13 Consistency rewards and subscription discounts

Some features of the app are paid (a subscription). Users can **earn a discount on the subscription by showing consistency over time**. The discount follows consistency, not the raw number of embers earned.

Why consistency and not embers:

- It matches the app's core lesson: persistence, not volume.
- It is much harder to farm than an ember total, which could be inflated by creating and striking many trivial tasks.
- It keeps embers as pure in-game progress. **Embers are never sold, bought, or exchanged for money.**

**Principles**

1. Rewards follow consistency, not volume.
2. Embers stay inside the game and never become a currency.
3. Discounts are applied through the app stores' own subscription offers, so payment always stays inside the stores' billing.
4. The core loop stays free. Discounts are calm and never nagging, and the app never blocks a user for not earning one.

**Steadfast days**

A **steadfast day** is the unit of consistency. A day counts when:

- the user completes the bonfire check-in, and
- at least one task was struck or tried that day (a "tried" counts), or the user fell and wrote the lesson note afterward.

Flask days and light days count, so the streak bends instead of snapping. A day on which the player fell still counts if they reach the bonfire and write the lesson, which supports the persistence lesson. Days when the user has no active boss do not count.

**Tiers (starting values, to be tuned)**

Consistency is measured over a rolling 30-day window.

| Tier (working names) | Rule | Example discount |
|---|---|---|
| **Kindled** | 12 steadfast days in the last 30 | Small (for example 10%) |
| **Steadfast** | 20 steadfast days in the last 30 | Medium (for example 20%) |
| **Unbroken** | 26 steadfast days in the last 30, plus planning accuracy above a set level | Largest (for example 30%) |

Discount sizes are examples only. They should be set based on margins and tested.

**Redemption rules**

- Consistency is calculated on the server from recorded events. The app cannot set or edit it.
- Once a tier is reached, it is **locked in for a short redemption window** (for example 7 days), so one bad day right after earning it does not take it away.
- One redemption per billing period. The discount applies to the next purchase or renewal through a store offer (see 10.6).
- Redeeming is the user's choice. The bonfire shows a calm note when a discount has been earned, and nothing nags afterward.
- Progress toward the next tier is shown plainly, with no warnings about losing progress.

**Protecting against abuse**

- Steadfast days are computed from server timestamps, not from client claims.
- A day only counts with meaningful activity (see above).
- Plausibility checks can disqualify a day, for example many trivial tasks created and struck within seconds of each other, or a very large number of tasks in one day.
- A daily cap on counted tasks.
- Discounts do not stack, and each period allows one redemption.
- Honesty is still on the user for individual tasks, but because the reward is capped and tied to months of behavior, farming it costs more effort than it saves.

**What is free and what is paid (proposed)**

- **Free:** bosses, phases, tasks, attempts, the fallen flow and lesson notes, the bonfire, embers, commitments and health, flasks, and the victory screen. The persistence lesson is the product, so it stays free.
- **Paid candidates:** cloud sync and backup, long-term stats and planning accuracy history, a home screen widget, themes, sound packs, and extra cosmetic effects.
- The final split is an open question.

**Tone and copy (examples)**

| Moment | Line |
|---|---|
| Discount earned | "A discount has been earned. Use it when you are ready." |
| Progress toward next tier | "Twenty days at the bonfire. The path rewards those who return." |
| Redemption window | "This reward waits for you." |

### 5.14 Relics from defeated bosses

When a boss is defeated, it leaves behind a **relic**: a permanent keepsake of the fight. A relic turns the story of the struggle into something the user can keep and revisit. It is the "it took 9 tries" moment made lasting, and it is the one game-inspired collectible included in the first version. Other game-inspired ideas are collected in Section 16 for later.

**What a relic contains**

- The boss's title and what "defeated" meant.
- Attempts taken, days spent, and total effort (embers earned on that boss).
- The phases that were fought.
- A snapshot of every lesson note the user wrote along the way, in order.
- An optional **final inscription**: one line the user writes at the victory screen, answering "What did this fight make of you?"
- The date of the victory.

**How it looks**

- Each relic has a simple, original emblem. The emblem reflects the *struggle*, not the score. More attempts give a more weathered, scarred, or worn look, so a relic won after many failures looks more earned, not less. A first-try win is never shown as better than a persistent one.
- Emblem variants are a small set of original designs (for example a handful of weathering levels) to keep the first version cheap to build. No game art or shapes are copied.
- A relic is named plainly from the boss ("Relic of the Final Exam").

**The hall of relics**

- A quiet gallery on the profile screen shows all relics, most recent first.
- Tapping a relic opens its story: the numbers, the final inscription, and the lesson notes as a timeline from the first attempt to the last.
- The hall is a place to return to on hard days. Reading how many times you fell and rose again is the persistence lesson at its strongest.

**Rules**

- A relic is created automatically when a boss is defeated.
- Relics are permanent. They can never be lost, spent, or taken away, including in hardcore mode.
- A relic keeps its own copy of the boss's story, so it remains complete even if the original boss or its tasks are later edited or deleted.
- Relics have no ember value, no money value, and cannot be traded or bought. They are not part of the reward tiers in 5.13.
- The final inscription can be edited later.
- Relics work offline and sync like every other record.

**Tone and copy (examples)**

| Moment | Line |
|---|---|
| Relic revealed | "A relic remains." |
| Inscription prompt | "What did this fight make of you?" |
| Hall of relics, empty | "No foes vanquished yet. The first relic awaits." |
| Opening a relic | "Nine attempts. Every one of them counted." |

---

## 6. User experience

### 6.1 Core screens

**Home (the wasteland)**
- Shows the user's active bosses as a vertical list of cards. Each card shows the title, attempt number, phase progress, and a compact health bar.
- Pinned bosses appear first; the rest follow in a user-chosen or most-recently-fought order. Waiting bosses are tucked into a collapsed section.
- A **Today** view gathers the day's tasks from all bosses in one place, grouped by boss, so the user can fight without hopping between screens. A filter lets the user view a single boss.
- A faint ambient effect (drifting embers or fog) sets the mood.
- A small indicator shows health, flask charges, and which bosses have a bloodstain waiting.
- The Today view shows each committed task with its deadline, ordered by the nearest deadline, so the user always knows what is due next.
- To keep the calm feel with many bosses, cards stay minimal, and only the most relevant information is shown on the home screen. Details live on each boss screen.

**Boss screen**
- Large title in the display typeface.
- Segmented health bar split by phases.
- A single line showing the last lesson note: "Attempt 7. Last time: rushed the second phase."
- Phase list with tasks, difficulty markers, and any bloodstain marker with its ember amount.

**Task completion (the strike)**
- See Section 7 for the full interaction design.

**Fallen screen**
- Slow dim, one quiet line, one prompt for the lesson note. See 5.5.

**Bonfire screen**
- Calm, minimal. Today's summary, a lesson field, tomorrow's top three, embers banking, and the option to rise.

**Victory screen**
- See 5.11.

**Profile and stats**
- Banked embers, stats, flasks, planning accuracy, and the hall of relics from defeated bosses.

**Settings**
- Mode (gentle or hardcore), reminder time, day rollover time (default 4 AM), default reset on a failed attempt (nothing, current phase, or whole boss), sound on/off, haptics on/off, hold-to-tap accessibility option, and data export.

### 6.2 Onboarding

Keep onboarding short and in tone.

1. A one-line promise: "Failing is fine. Quitting isn't."
2. Create your first boss (title and what defeat means).
3. Split it into two or three phases (with simple suggestions).
4. Add the first few daily foes.
5. Choose the mode (default gentle) and the bonfire reminder time.

Under two minutes, so the user is fighting before they lose interest.

### 6.3 Tone and copy

- Calm, quiet, slightly cryptic, never mocking.
- Short sentences. Few exclamation marks (none, ideally).
- Encouraging underneath: the mood is dark but the message is supportive.

Example lines (all original):

| Moment | Line |
|---|---|
| Strike lands | "It is done." |
| Tried, not finished | "You tried. That counts." |
| Fallen | "Fallen. Rest, then rise." |
| Lesson prompt | "What did this teach you?" |
| Next attempt | "Attempt 7. Last time: [lesson]." |
| Bonfire | "Rest. Tomorrow, the path continues." |
| Rule of three | "Same path, same result. What will you change?" |
| Victory | "Foe vanquished." |
| Reminder notification | "The bonfire waits." |
| Making a commitment | "What will you do, and by when?" |
| Deadline approaching (opt-in) | "The hour grows short." |
| Deadline missed | "The hour has passed." |
| Late strike | "Late, but done." |
| Health low | "You are wounded." |
| Fallen from lost health | "Fallen. Nine promised, three kept. What will you promise tomorrow?" |
| Extension used | "Time granted. Use it well." |
| Rest after a fall | "You rest. You rise." |
| Missed day (on next open) | "The bonfire went cold. Every fight remembers." |

---

## 7. The "weight" of completing a task

Weight means that completing a task takes a small, deliberate effort and the app responds in a way the user can feel. It is the main source of the Souls feel at the task level, and it works through four parts together.

### 7.1 Hold instead of tap

Instead of a checkbox, the user presses and holds the task for a short time (about 0.6 seconds for the default weight).

- Holding the full duration completes the task.
- Releasing early cancels, and the progress rolls back smoothly.

This prevents accidental completions and adds a brief moment of honest reflection: "Did I really do this?" That half-second is what makes completion feel like a committed act.

### 7.2 Feedback during the hold

The hold must feel like something is building, otherwise it just feels like lag.

- **Visual:** an ember glow or a thin fill line grows across the task as the hold progresses.
- **Haptic:** a faint vibration that grows slightly stronger as the hold continues.
- **Completion moment:** a firm haptic pulse and a short slash or fade effect when the strike lands.
- **Optional sound:** a low tone building, then a deep note on completion (off by default).

### 7.3 A visible consequence

After the strike lands, something in the app visibly changes.

- The task dims and slides into a done state.
- The boss's health bar loses a segment.
- Embers are added to the carried total.

This connects the real-life action to visible damage on the boss, which is what gives the act meaning.

### 7.4 Weight scales with the task

Not every task deserves the same ceremony.

| Task type | Examples | Interaction | Why |
|---|---|---|---|
| **Light** | Drink water, reply to a message | Quick tap or about 0.3 second hold | Tiny things need no ceremony |
| **Heavy** | Finish a chapter, do a workout | About 0.6 second hold (default) | The standard weight |
| **Boss-tier** | Submit the project, final phase | About 1.2 second hold with a bigger effect | Big moments should feel big |

### 7.5 Accessibility and avoiding friction

- A setting converts every hold into a simple tap, for users who cannot hold a press comfortably.
- If testers find the hold annoying, shorten it or restrict it to heavy and boss-tier tasks.
- The goal is for finishing a task to feel like an accomplishment, not a chore on top of the chore.

---

## 8. Visual, audio, and haptic language

### 8.1 Visual

- **Palette:** near-black background, ash-grey text, and one ember-gold accent reserved for important things (active boss, victory, bonfire).
- **Typography:** a serif display typeface for boss names and major moments, plain and highly readable text for everything else. Use fonts with a license that permits commercial app use.
- **Motion:** slow fades (roughly 300 to 600 milliseconds), no bouncy animation. A faint drifting ember or fog on the home screen.
- **Boss health bar:** segmented by phase, drawn with a custom look; each strike removes a segment with a slow drain.
- **Bloodstain marker:** a faint mark beside the relevant task that fades as time passes.
- **Art:** original illustration or abstract shapes only. No game art.

### 8.2 Audio (optional, off by default)

- A low ambient hum on the bonfire screen.
- One deep tone on victory.
- A muted thud on a fallen attempt.
- Use original or properly licensed sound only.

### 8.3 Haptics

| Moment | Haptic |
|---|---|
| Hold in progress | Light ticks that build |
| Small task complete | Light tick |
| Heavy or boss-tier strike | Heavy pulse |
| Fallen | Heavy, single pulse |
| Victory | Slow double pulse |

All haptics can be turned off in settings.

---

## 9. Data model (conceptual)

This is a description of the information the app stores, not a final schema.

### 9.1 Entities

| Entity | Purpose | Key fields |
|---|---|---|
| **User** | The person using the app | id, display name, mode (gentle or hardcore), reminder time, day rollover time, default reset on a failed attempt, banked embers, carried embers, flask charges, current health, maximum health, level and stats, signup date (for newcomer grace) |
| **Boss** | A big goal | id, user, title, description, status (active, waiting, defeated), attempt number, reset on a failed attempt (nothing, current phase, whole boss), target date, created and defeated times |
| **Phase** | A stage of a boss | id, boss, name, order, status |
| **Task** | A small unit of action | id, phase (or standalone), title, difficulty (light, heavy, boss-tier), recurrence, status, commitment deadline (empty for open tasks), extensions used, resolved outcome (strike, tried, missed, late strike), resolved time |
| **Attempt** | One real try | id, boss or task, attempt number, outcome (strike, tried, fallen), cause of a fall (declared, health death, missed day), embers earned, lesson note, time |
| **Bloodstain** | Dropped embers at a failure point | id, user, task, attempt, amount, created time, recovered time, lost time |
| **Bonfire check-in** | The daily ritual, or a rest after a fall | id, user, date, kind (daily check-in or rest after a fall), summary note, lesson, embers banked, flasks restored |
| **Flask use** | A spent recovery charge | id, user, date, reason (skip day, light day, second extension) |
| **Health event** | One change to health | id, user, task, amount (negative for loss, positive for restore), reason (miss, tried, bonfire restore, rest after a fall, rollover restore, newcomer grace), time |
| **Daily summary** | The day's commitment record, used for planning accuracy | id, user, date, commitments made, commitments kept on time, health lost, fell (yes or no), counted as a steadfast day (yes or no) |
| **Reward tier** | A consistency tier the user has reached | id, user, tier, reached time, lock-in expiry, redeemed time (empty until used) |
| **Reward redemption** | A discount actually used through a store offer | id, user, tier, store (Google Play or App Store), offer identifier, billing period, purchase verified (yes or no), time |
| **Relic** | A permanent keepsake created when a boss is defeated | id, user, boss, name, emblem variant, attempts taken, days spent, total effort, phases fought, lesson notes snapshot, final inscription (optional), created time |

### 9.2 Key rules

- A user can have any number of active bosses. There is no limit on bosses.
- A boss can have at most one active bloodstain at a time (neither recovered nor lost). Different bosses can each hold their own.
- Embers (carried and banked) belong to the user and are shared across all bosses.
- Banking at the bonfire moves carried embers into banked embers.
- A new bloodstain on a boss automatically marks any older unrecovered bloodstain on that same boss as lost.
- A waiting (paused) boss does not create falls, bloodstains, or reminders.
- Health belongs to the user and is shared across all bosses. Current health is derived from the recorded health events, not overwritten.
- A commitment is a task with a deadline. Tasks without a deadline are open tasks and never cost health.
- A missed deadline is resolved from stored timestamps when the app opens or on a schedule, so it works offline and does not depend on background jobs.
- Each task can be extended once for free; further extensions cost a flask charge.
- When health reaches zero, the user falls, the remaining commitments for the day are frozen (no more health loss), and in hardcore mode a bloodstain is created on the task that dealt the final blow.
- Planning accuracy is calculated from daily summaries: commitments kept on time divided by commitments made.
- Steadfast days, reward tiers, and redemptions are calculated and stored on the server. The app can display them but cannot change them.
- A reached tier is locked in for its redemption window and allows one redemption per billing period.
- Embers never convert to money and are not part of reward calculations.
- Defeating a boss creates exactly one relic. A relic stores its own copy of the boss's story and is never deleted or altered by later changes to the boss, except for the user editing the final inscription.
- Relics are permanent and never at risk, in any mode.
- Every attempt belongs to exactly one boss or task and keeps its own lesson note.
- A boss's attempt number rises only on a declared failure, a health death whose final blow came from that boss, or a missed day while the boss is active (5.4). A missed day writes one failed attempt per active boss, all sharing one lesson.
- A failed attempt applies the boss's reset setting. Reopened tasks never pay embers twice, and embers already earned are never removed by a reset.
- A day ends at the daily check-in or at the user's rollover time. Health refills at either.
- A rest after a fall restores health, banks carried embers, and unfreezes commitments still before their deadline. It does not restore flasks or count as the daily check-in.
- In gentle mode, bloodstains are markers only and no embers are removed.

### 9.3 Offline-first requirement

- Every write is saved on the phone immediately.
- Each record carries a last-updated time and a synced marker.
- The app pushes changes to the server when a connection is available.
- A bonfire check-in or fallen log must never fail because of poor signal.

---

## 10. Technical plan

### 10.1 App (Flutter)

Chosen framework: Flutter, for fine control over visuals and animation, which suits an atmospheric interface.

| Need | Suggested approach |
|---|---|
| State management | Riverpod |
| Local database | Drift (typed SQLite) |
| Navigation | go_router |
| Models | freezed with json_serializable |
| Daily reminder | flutter_local_notifications using inexact scheduling; request the Android 13+ notification permission at a sensible moment |
| Haptics | Built-in Flutter haptic feedback |
| Audio (optional) | just_audio |
| Animation | Built-in animation controllers and custom painting for the health bar and ember effects |
| Hold gesture | Gesture detection with an animation controller driving progress |
| Sign-in (later) | Google sign-in, with the backend verifying the ID token |
| Home widget (later) | home_widget package, with some native Android code |

A fragment shader for fog or ember glow is a nice-to-have after the MVP.

### 10.2 Backend (Node.js and PostgreSQL)

- A Node.js API (Fastify or Express) with PostgreSQL, mirroring the entities in Section 9.
- Sync endpoints that accept batches of changes and return updates since a given time.
- An OpenAPI description of the API, used to generate the Dart client so the models are not written twice.
- Google ID token verification for sign-in.
- Conflict handling: last-write-wins by updated time for most records, with care for the bloodstain rule (one active per boss) and for embers totals, which should be derived from the record of events instead of overwritten.

### 10.3 Project structure (feature-based)

- **core:** theme, routing, utilities
- **data:** local database, repositories, sync service
- **features:** bosses, tasks, attempts, bonfire, embers and stats

### 10.4 Android-first notes

- Google Play charges a one-time developer fee (check the current amount).
- New personal developer accounts may be required to run a closed test with a minimum number of testers for a minimum number of days before publishing to production. Rules change, so verify Google's current requirements and recruit testers early.
- Test on at least one small and one large screen.
- Some manufacturers kill background tasks aggressively, which can delay reminders; scheduled local notifications are the most reliable approach.
- Android users tend to be price-sensitive: favor a free core app with an optional one-time or low-cost premium upgrade.

### 10.5 Keeping iOS easy later

- Prefer cross-platform packages over Android-only ones.
- Keep platform-specific code (such as widgets) in separate modules.
- Keep art, fonts, and copy free of game trademarks now to avoid a rewrite for Apple review.
- Remember that Apple requires Sign in with Apple if other social logins are offered, and has a paid yearly developer program.

### 10.6 Subscriptions and store offers (for consistency rewards)

The discounts in 5.13 are delivered through each store's own subscription offers. The offers are **fixed tiers created in advance**, not arbitrary prices calculated on the fly. The app and server choose which pre-created offer a user qualifies for. This section reflects the stores' documentation as of October 2026. Limits and rules change, so re-check the current documentation before building.

**Android (Google Play), first release**

- Create one subscription with one or more base plans (for example monthly and yearly).
- Create one **developer-determined offer** per reward tier, for example one each for Kindled, Steadfast, and Unbroken. Offers can only be attached to auto-renewing base plans.
- With developer-determined eligibility, the app's own logic decides who qualifies, so the server must verify the user's tier before the app presents or launches an offer. Do not rely on the app alone.
- A subscription can have up to 250 base plans and offers in total, with 50 active at a time, which is far more than three tiers need.
- If a billing helper library such as RevenueCat is used, check how it applies developer-determined offers automatically, and tag the reward offers so they are not applied to everyone by mistake.

**iOS (App Store), later**

- **Promotional offers** suit existing and previous subscribers (for example, "you earned a discount on next month"). They need a server-side signature, which the Node.js backend can generate after checking the user's tier. Up to 10 active offers are allowed per subscription.
- **Offer codes** suit first-time subscribers: the server can issue a code to a user who has earned a tier, and the user redeems it through the App Store.
- The two iOS paths follow different rules, so iOS reward behavior should be designed separately from Android.

**Server responsibilities**

- Calculate steadfast days and tiers from recorded events.
- Return the user's earned tier, redemption window, and the matching offer identifier.
- Verify every purchase with the store's server APIs and record the redemption so a tier cannot be used twice in one billing period.
- Handle subscription status changes (renewal, cancellation, billing problems) by listening to store notifications.

**Policy review before building**

- Read the Google Play Subscriptions policy and Apple's App Review Guidelines for in-app purchases and subscriptions.
- The documentation checked so far does not say how either store treats discounts earned through in-app behavior. Confirm this before shipping.
- Never allow a subscription or paid feature to be purchased with embers directly. Discounts go through official store offers only.

---

## 11. MVP scope and build order

### 11.1 In the MVP

1. Create a boss with phases and tasks.
2. Hold-to-strike completion with visual and haptic feedback.
3. Attempt counter and the fallen flow with the lesson note.
4. Bonfire check-in with a daily local notification.
5. Embers: earn, carry, bank (gentle mode only at first).
6. Commitments with deadlines, health, and a death state (gentle mode first), including the free extension and the planning accuracy stat.
7. Flexible streak using flask charges.
8. Victory screen with the relic reveal and the hall of relics.

### 11.2 Not in the MVP

- Social features and sharing.
- Multiple character classes.
- A shop or cosmetic store.
- Hardcore-mode embers loss (add after gentle mode feels right).
- Home screen widget.
- Sound design beyond a few basics.
- iOS release.
- Subscriptions and consistency-based discounts (add after the core loop is proven and the policy review in 10.6 is done).
- The game-inspired ideas in Section 16 (shortcuts, new cycle, earned items, persistence achievements, weekly reckoning, classes, summons, messages, capacity meter, and cosmetics). Relics (5.14) are the only one included in the first version.

### 11.3 Build order

1. Local-only app: bosses, phases, tasks, attempts, and lesson notes.
2. Hold-to-strike interaction and boss health bar.
3. Bonfire check-in and daily local notification.
4. Embers, the flexible streak, and commitments with deadlines and health (gentle mode).
5. Closed testing on Google Play with early testers (recruit from the start).
6. Backend sync and Google sign-in.
7. Hardcore mode and bloodstain recovery.
8. Production launch on Android.
9. Widget, then iOS.

---

## 12. Testing and validation

The mood and the emotional balance matter more than feature count, so test them early.

**Questions to answer with a few real testers (ideally Souls players):**

- Does the hold feel satisfying or annoying?
- Does the fallen screen feel supportive or discouraging?
- Does the bloodstain motivate people to return, or make them avoid opening the app?
- Do people come back the day after a failed attempt?
- Does the attempt counter read as pride or as a record of failure?
- Is the reminder helpful or nagging?
- Do deadlines feel motivating or stressful?
- Do beginners learn to promise less? Does their planning accuracy improve over the first few weeks?
- Does falling from lost health feel like a lesson or like a punishment?

**Signals to watch:**

- Next-day return rate after a fallen moment.
- How often people use "Tried" versus "Strike".
- How often lesson notes are written.
- How often the hold is turned into a tap in settings.
- Whether testers ever feel worse after using the app (ask directly).
- Planning accuracy over time, and the average number of commitments made per day in week one versus week four.
- How often free extensions are used, and how often users mark tasks done late.
- How many users fall in their first week, and whether they return the next day.

Start everyone in gentle mode and only offer hardcore after the basic loop feels good.

---

## 13. Risks and how to handle them

| Risk | Why it matters | Mitigation |
|---|---|---|
| Loss mechanic causes guilt and quitting | Real life is not a game; people already feel behind | Gentle mode default, capped and partial loss, flasks, lessons recover embers, test early |
| Hold gesture feels like friction | Adds effort to every task | Scale by difficulty, allow tap alternative, shorten if testers dislike it |
| Too dark or heavy in tone | Could discourage vulnerable users | Keep the underlying message supportive; avoid red alarms and shaming language |
| Trademark and IP issues | Store rejection or legal trouble | Original names, art, fonts, sounds, and screen text; no game logos |
| Unreliable reminders on some Android phones | Habit loop depends on the bonfire reminder | Use scheduled local notifications, guide users on battery settings if needed |
| Google Play testing requirements delay launch | New developer accounts may need a closed test period | Check current rules early and recruit testers from the start |
| Sync conflicts in ember totals | Offline-first can create inconsistent numbers | Derive totals from recorded events and keep a clear single-bloodstain rule |
| Users farm the discount | Money at stake gives people a reason to game unverifiable tasks | Reward consistency over months (not ember totals), compute on the server, require meaningful activity, plausibility checks, caps, one redemption per period |
| Store policy on earned discounts is unclear | The documentation checked does not address rewards earned through behavior | Read the policies before building, use official store offers only, never accept embers as payment |
| Discounts reduce revenue | Each redeemed tier lowers income | Start with small tiers, measure redemption and retention, adjust sizes |
| Embers start to feel like money | It would cheapen the effort and persistence message | Keep embers non-convertible and reward consistency milestones instead |
| Deadlines and health loss cause stress or early quitting | Beginners will over-commit and fall in the first days | Newcomer grace week, free extension, gentle mode default, calm tone, and clear framing that early falls are the lesson |
| Deadlines depend on unreliable background tasks | Some Android phones kill background work | Resolve deadlines from stored timestamps whenever the app opens, treat reminders as a convenience only |
| The app cannot verify that tasks were done | Users can cheat or forget to mark tasks | Accept it: honesty is on the user, and the only person cheated is the player; offer late marking |
| Too many active bosses cause overwhelm | No limit on bosses means users may spread themselves thin and feel buried | Keep home cards minimal, offer pinning and a waiting status, use a grouped Today view, and watch in testing whether people with many bosses drop off |
| A missed day raises every active boss's attempt count | One skipped bonfire with many active bosses can make every counter jump, which may read as a record of failure | One fallen moment and one lesson for all of them, flasks and light days prevent a missed day, waiting bosses are exempt; watch in testing whether this discourages people with many bosses |
| Feature creep | Solo developer, limited time | Strict MVP scope; add features only after the core loop feels good |
| Users in real distress using the app as a crutch | A task app is not mental health support | Keep language about effort and habits; do not make health or therapeutic claims |

---

## 14. Open questions

1. ~~What is the app's original name?~~ Resolved: Hearthrise.
2. Final stat names and how much they matter in the MVP.
3. Exact flask rules: how many, and how they restore.
4. What portion of carried embers drops in hardcore mode, and what is the cap?
5. How many lesson-note embers are returned?
6. Should recurring daily tasks count as fights against a boss, or live separately as "daily foes"?
7. Pricing model: free with optional one-time upgrade, or something else?
8. Will there be an optional community feature later, and if so how is it moderated?
9. How are bosses and tasks backed up or exported by the user?
10. Which sound assets will be used, and what are their licenses? (Fonts resolved: Cormorant Garamond and Inter, both SIL OFL 1.1; see `DESIGN.md`.)
11. With multiple bosses, should bloodstains be one per boss (current design) or one per user, as in the original games? One per user is more tense but means a fall on any boss can erase a bloodstain on another.
12. Should the app show a gentle hint when many bosses are active at once (for example "You are fighting 8 bosses"), or stay silent and leave it entirely to the user?
13. Should the Today view limit how many tasks it shows at once so the home screen stays calm, or show everything due?
14. Should embers earned on a boss be tracked per boss for statistics (for example "most effort went into this boss") even though spending is shared?
15. Should health refill fully every day at the bonfire (current default), or should some damage carry over so a bad day affects tomorrow?
16. ~~After a health death, can the player rise again the same day, or only the next day?~~ Resolved: same day, by resting at the bonfire (5.6).
17. What is the right starting health (currently 10) and the right loss per task weight (currently 1, 2, and 3)?
18. Should there be a short grace window after a deadline (for example a few minutes) for users who finished the task but forgot to mark it?
19. How long should newcomer grace last, and exactly which penalties does it remove?
20. ~~Should a "tried" before the deadline cost half health (current design), or nothing?~~ Resolved: half health. Principle 5 now separates embers (effort) from health (promises kept).
21. Should open tasks without deadlines ever convert into commitments automatically (for example at the morning check-in), or only when the user chooses?
22. What exactly counts as a steadfast day: is a bonfire check-in plus one tried task enough, and does a fallen day with a lesson note always count?
23. What are the right tier thresholds, window length (currently 30 days), and discount sizes?
24. Does the discount apply to monthly plans, yearly plans, or both? Does it apply to renewals, new purchases, or both?
25. How long should an earned tier stay locked in for redemption (currently 7 days)?
26. What is the final split between free and paid features?
27. What do the store policy reviews in 10.6 conclude about discounts earned through in-app behavior, and does iOS need different reward rules from Android?
28. Should the planning accuracy requirement for the top tier be fixed, or should it ramp up gradually for newer users?
29. Is 4 AM the right default day rollover time?
30. Should missed-day attempts be shown differently from declared failures in the attempt history (for example "the bonfire went cold"), so the counter reads as persistence rather than neglect?

---

## 15. Next steps

1. Decide the app name and finalize the vocabulary in Section 4.
2. Sketch the main screens (home, boss, fallen, bonfire, victory) as low-fidelity mockups.
3. Prototype the boss screen: segmented health bar, hold-to-strike, and the fallen prompt. These three carry most of the feel.
4. Define the local data structure from Section 9 and the sync rules.
5. Recruit a handful of Souls-playing testers early for feedback on tone and feel.
6. Start the Google Play developer account and testing requirements early so launch is not delayed.

---

## 16. Future ideas (not in the MVP)

These ideas are inspired by the games and fit the app's lessons, but they are saved for after the core loop has been tested. Relics (5.14) are the only game-inspired collectible in the first version. Each idea below should be judged against the central test at the end of this document before it is built.

### 16.1 Likely first additions

These cost the least to build and fit the core lesson best.

**Shortcuts**
- In the games, opening a shortcut makes every later run easier. Here, finishing a phase unlocks a **shortcut**: a minimum version of that routine (for example about five minutes) that counts on bad days.
- It teaches "do the smallest version instead of nothing" and matches the bloodstain rule that even a small version counts.
- Open questions: does a shortcut earn full embers or reduced embers, and does it count as a steadfast day?

**Persistence achievements**
- Titles for the behaviors the app teaches, such as "Tenth attempt," "Fell and wrote the lesson ten times," and **"Returned"** after a week away.
- "Returned" welcomes someone back instead of shaming them, which matters a lot for retention.
- Achievements reward behavior, never raw volume, and carry no money value.

**Weekly reckoning**
- A weekly bonfire ritual that shows the planning accuracy trend, the week's lessons, and lets the user choose next week's focus.
- It fits naturally on top of the existing bonfire and daily summaries.

### 16.2 Later, once the loop is proven

**New cycle**
- After defeating a boss, the user can rematch a harder version: a higher bar (for example run the 10k faster) or sustaining the habit for 30 days.
- It gives long-term engagement beyond a finished goal. Each cycle would produce its own relic.

**Earned items**
- Small consumables with short lore-style descriptions that carry a real-life tip. Working ideas:
  - **Ward:** absorbs one missed commitment.
  - **Hourglass:** one extra deadline extension.
  - **Whetstone:** bonus embers on one chosen heavy task.
- Earned from milestones such as reward tiers, defeated bosses, and weekly reckonings.
- Items are capped and are never sold for money, so they cannot undermine the persistence lesson.

**Capacity meter**
- Shows the hours promised today against what the user's history says they usually finish.
- Purely informational. It never limits how many commitments a user can make.

**Cosmetics**
- Bonfire styles, ember colors, and fog themes, either earned through reward tiers or offered as paid extras.
- Must use original art and sound (see Section 4).

### 16.3 Needs more design or moderation

**Classes**
- Starting archetypes (for example fitness, study, craft, balanced) that set boss templates and stat emphasis.

**Summons**
- Invite a friend to fight a boss alongside you as an accountability partner. Needs a design for privacy, invitations, and what each person can see.

**Messages**
- Short pre-written notes shown to other players on the fallen screen ("Try again," "Rest at the bonfire"). Needs moderation, so only fixed phrases, not free text.

**Sharing relics**
- Export a relic as an image to share. Needs a decision on what is shown by default, since lesson notes can be personal.

### 16.4 Ideas deliberately skipped

| Idea | Why it is skipped |
|---|---|
| Random loot drops | Unpredictable rewards feel like gambling and break the promise that effort always pays |
| PvP or invasions | Adversarial play does not fit a discipline app |
| Items that bypass effort, or can be bought to avoid health loss | Pay-to-win teaches the opposite of the app's lesson |

---

*The central test for every feature: does it make a person more likely to try again tomorrow? If it does, keep it. If it makes them feel worse, soften it or cut it.*
