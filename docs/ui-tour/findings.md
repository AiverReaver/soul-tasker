# Findings during the UI walk (fresh install, iPhone 16 sim, iOS 18.5)

1. Onboarding step 2: typing into the empty "The boss" field keeps only the first character; the field loses focus when the Next button appears (disabled text -> filled button). Typing again after re-tapping works. Seen 2026-10-19.
2. Reminder time picker (Material time picker): the selected AM/PM chip is teal, a colour outside every biome palette. Seen on onboarding step 5.
3. Time picker dial mode: the selected hour box shows the digit in near-black on the dark box (low contrast), while minutes are bone.
4. New boss: the "Save" glass pill looks the same when disabled (no title/tasks) as when enabled.
5. New/edit boss: Back discards typed edits with no "discard changes?" confirm (typed title "Run a 10K", tapped Back, boss gone).
6. Task sheet "Chapter" uses a stock Material dropdown menu (flat grey popup) inside a glass sheet; nothing else in the app looks like it. "+1 embers" also reads ungrammatical (should be "+1 ember").
7. Boss edit: the header has no backdrop, so scrolled fields show through around the thread divider (frame edges peek at y~127).
8. BUG: GlassAlert action labels ("Delete", "Not yet") render with the yellow double underline Flutter uses for Text with no DefaultTextStyle/Material ancestor. Seen on the boss-editor confirms (delete chapter, delete boss) and the "Leave the fight?" alert, The same "Mark this boss as defeated?" alert is clean when opened after a strike but underlined when opened from the boss ⋯ menu ("Declare victory"), so it depends on the BuildContext that opens it (likely one under no Material).
9. Copy: boss screen hint reads "Each strike takes shards from the Run a 10K." (article "the" before a user title). Cormorant old-style figures also make "10K" read like "1oK" in the boss name.
10. Strike result sheet: "Clean strike" note says "Done in full. Promise kept." even when the task had no promise.
11. Task row with a deadline chip: the meta line wraps ("Run a 10K · +3 / embers") because the chip takes the width.
12. Observation: splitting a task raises the boss health shown (6/12 -> 8/12) because segments are recounted. Might read as the boss healing.
13. Leave alert says "you keep 0 embers" right after a clean Boss-tier strike (+6) and three tries on the same boss. Today tab shows "Carried 13 · Banked 0": the alert counts only banked embers, so "you keep 0 embers" is technically right but reads as losing the 13 carried ones. (Same yellow underline as #8 on "Keep fighting"/"Leave for now".)
14. Home "Today's tasks" says "1 of 3 struck" but lists only 2 rows, both open: the struck task belongs to the boss that was just left (waiting) and is hidden, yet still counted. Header ember counter also still 0 after +6 and 3 tries (embers may only bank at rest; if so, #13 and this need a hint).
15. BUG: Home filter chip "The Day" (no tasks on The Day) shows "1 of 1 struck" and "All tasks struck. Rest at the bonfire". The struck count comes from Run a 10K (waiting boss) and ignores the chip filter. "Ship the portfolio" chip also keeps "1 of 3 struck". Count should follow the chip and skip waiting bosses.
16. Inconsistency: "Name the task" caption is bold sentence-case in the Home new-task sheet but small letter-spaced in the boss-editor task sheet. Default weight also differs (Light here, Heavy in the editor).
17. Quick tasks added to "The Day" are saved as daily ("Call the bank · daily"), so a one-off errand comes back every morning. Confirm intended.
18. BUG: Home flash line ("It is done.") is drawn flush to the left screen edge (x=0), not inset 20 px like the rest of Home. 
19. Home filter chips reorder after a strike ("The Day" jumped ahead of "Ship the portfolio") while a chip is selected.
20. Home: "All tasks struck. Rest at the bonfire" shows ABOVE the struck rows that are still listed under the group; reads as two competing states. Also no full stop on that line, unlike every other message.
21. BUG: All bosses card for "The Day" reads "Attempt 1 · All chapters done" (it has no chapters) once it has a struck quick task; before it read "Daily tasks".
22. Boss card long-press opens a plain Material bottom sheet ("Unpin" / "Set active"): no glass, no title, no Cancel, 16 px inset. Every other action list in the app is a glass sheet.
23. BUG: Long-press "The Day" offers "Set waiting"; tapping it closes the sheet and silently does nothing (BossDao throws StateError "The Day always stays active." which is swallowed). Hide the row for The Day.
24. Nav: with a pinned active boss, the "Today" tab opens that boss full-screen (tab bar disappears, Today is never shown selected) and Back lands on Home. The /today view is unreachable until the boss is unpinned.
25. BUG: On Home, the long-press boss sheet opens UNDER the floating glass tab bar; the bar covers the sheet bottom (space under "Set waiting" is hidden).
26. Counts disagree: Home says "2 of 8 struck" (includes the struck one-time "Run the 10K"), Today tab group "RUN A 10K" says "0 of 4 struck" (struck one-time task dropped from both list and count).
27. Copy: Bonfire "Fought well" note says "The Warden felt it." "The Warden" is never named elsewhere in the app. The reminder caption under "Rest at the hearth" sits right against the floating tab bar (partly behind it once a mood note shows).
28. Tomorrow picker: the "Three is enough for one day." line is inserted above the list, pushing every row down ~34 px under the finger, and the "Set tomorrow" button scrolls off screen.
29. Profile: the health pips row has no label (Flasks above it does), so the bar reads as decoration.
30. Settings "Day starts at" dialog does not mark the current value (4:00 AM looks like every other row).
31. BUG?: Tester report says "Bonfire lessons: 0" right after resting with the lesson "Start the tempo run before work." filled in.
32. Settings (all biomes): scrolled rows pass under the header and show through around the thread divider (text "On a failed attempt, reset" visible behind the line). Same cause as #7.
33. Light biomes (Moss): the glass hold buttons cast a strong shadow that is clipped by the task row edge, and the white glass buttons look stuck on rather than set in. The level number on the diamond badge is thin serif on dark green, hard to read.
34. Settings biome list in Moss Grotto: the last row ("Greymoor") is drawn without its frame border.
35. Unconfirmed: two taps on the lower half of the last biome row ("Greymoor", y≈743-746 pt) did nothing; a tap at y≈730 worked. Could be simulator input, worth a check on device.
36. Fallen copy: "Attempt 1 ends. The Run a 10K remains, and so do you." Prefixing "The" to any title reads badly (same as #9). The thread under the subtitle is broken mid-way (intended snap) but the gap sits off-centre.
37. BUG (layout): Fallen screen "BOTTOM OVERFLOWED BY 133 PIXELS" when the keyboard opens for the lesson field. Rise / Rest buttons are hidden behind the keyboard; the field return key adds a newline, and tapping outside does not close the keyboard: the user is stuck on this screen with the keyboard up (BLOCKER). Body is not scrollable.
38. Confirm dialogs make the destructive action the highlighted default ("Delete" filled, "Not yet" plain) for delete boss / chapter / task.
39. Same number (14) is labelled "Embers" on the Victory screen and "Effort" on the Relic screen. Relic "Save" button sits flush under the inscription field (no gap).
40. After victory Home shows "4 of 6 struck" with three rows (one struck): tasks of the defeated boss stay in the count (same root as #14/#15/#26).
41. Away summary: after "Done late", the row just loses its button and still reads "−1 health"; no sign it was marked done late. The dialog also re-centres (jumps) as the row shrinks.
42. Struck task title that wraps to two lines: the strike-through line is drawn only through the first line ("Write 200 words ·"), not "daily".
43. Today's Three: two of the picked tasks ("Warm up", "Tempo") were struck the day BEFORE the plan day and belong to a now-defeated boss, yet show as already done today, so "The three are done." after a single strike today. The tomorrow picker allowed picking tasks of a boss about to be won.
44. Flask choice dialog ("A day passed without rest.") is a stock Material AlertDialog: flat shell box, no glass, buttons stacked oddly ("Let it fall" right-aligned above a full-width "Use a flask"). Every other alert is a GlassAlert.
45. "Use a flask" closes the dialog with no confirmation line (no flash like "A flask spent."); flask count change is only visible on Profile/Bonfire.
46. Flask choice plural: "2 days passed without rest." uses a digit while the away summary spells "Two deadlines passed."; button still says "Use a flask" when it would spend two.
47. BUG: The missed-day Fallen screen (after "Let it fall") is drawn under the shell, so the glass tab bar floats over it and is tappable. The declared-fall Fallen screen covers the tab bar. Also: no explanation of what fell (which day, which boss).
48. "Use a flask" with 3 missed days and 2 flasks goes straight to "Fallen." with no line explaining that two days were covered and one fell.
49. Check-in card answers ("Never", "Sometimes", "Often") are rounded stadium outline buttons; every other choice in the app is a needle-cut segment. "Flasks restored · 0 of 3" also reads oddly after flasks were spent.
50. Largest Dynamic Type (AX5): boss title wraps mid-word ("Spanis" / "h"); header "Chapter II of II" wraps to two lines between the circle buttons. (DESIGN.md asks layouts to survive 200%; AX5 is ~310%, but the mid-word break also appears at smaller sizes for long words.)
51. At ~200% text (AX Medium): the flash line ("That is six promises, three…") is cut off and overlapped by "Today's tasks" because its slot is a fixed 36 px; the row title squeezes to 3 lines because the deadline chip and hold button keep their width.
52. New task sheet: "Add to today" looks enabled with an empty name and does nothing on tap (no hint, no disabled look).
53. Copy: an empty boss (no tasks, e.g. The Day on a fresh install) says "This task is worn down by habit." It is a boss, and it has no tasks; no hint to add one.
54. Pinned panel for an empty The Day shows "Boss health 0 / 12" with an empty meter (reads as already beaten), while the boss screen shows no meter for the same boss.
