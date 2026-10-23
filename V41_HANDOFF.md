Continue the Hearthrise v4.1 design work in /Users/ashishvagish/Documents/projects/soul-tasker (branch theme-biomes).

Read first:
- V41_PLAN.md (committed): the implementation plan. Section 1 is the design language, section 4 the decisions D1–D11, section 5 the answered questions (5a boards added later, 5b re-skin-only screens), section 6 the steps, section 7 the order.
- CLAUDE.md, plus STAGES.md "Development method" and "UI components". TDD is mandatory: tests first in every step. Reusable widgets go in app/lib/ui/ as StatelessWidgets; stateful behaviour lives in a thin container in app/lib/features/. Run `flutter analyze` and the full suite from app/ before calling a step done. One commit per step, each ending with the Co-Authored-By line from the session reminder.
- THEME_PLAN.md and DESIGN.md: the v3 palette, biomes and needle-cut shapes v4.1 builds on.

Design source: the "Hearthrise v4.1" canvas, https://claude.ai/artifact/5bU9fETFefqgD6a1UAeZfM (version 18). Read board sources with the Artifact tool (action read, path project/<Name>.dc.html). The last row, "Glass system", is the reference for every glass part (Glass.dc.html plus one board per biome). Don't publish canvas.json unless the layout changes; the user moves boards by hand.

Decisions already made (don't reopen):
- Q1 Today tab opens the pinned boss's fight; with no pinned boss it opens TodayView re-skinned.
- Q2 "Leave for now" sets the boss to Waiting and returns Home. Q2b: the ⋯ circle on Boss opens a Boss actions glass sheet (Leave for now, Edit, Pin/Unpin, Declare victory, then "This attempt failed").
- Q3 the full-screen "Struck." plays only when a strike ends a phase; other strikes play in their row, then the "How did the strike land?" sheet opens. The outcome is saved only when the user chooses; leaving writes nothing and the row reopens.
- Q4 Bonfire mood is SignalKind.mood (append to the enum), no game effect. Q5 tomorrow's three becomes a "Tomorrow's foes" row on Bonfire (max 3). Q5b health bar and accuracy move to Profile.
- Q6 biome names are Silksong place names; rename before release (separate task).
- Tapping a foe row (not its hold button) opens the Foe actions sheet. It replaces TaskRow's ⋮ menu (step C16).
- Keep the real Weight values (Light/Heavy/Boss-tier, 1/3/6 embers). The design's +10/+20/+30 are illustrations.
- Sheet headers: small label and serif title on the left, glass Cancel/Close pill on the right. The glass glint stays fixed top-left; content is padded down to clear it. The hold button is a 48 px ring, 1.5 px ink border, border-radius not clip-path, no blur.

Done and committed (suite: 914 tests, analyze clean):
- A1 glass tokens in HearthPalette (+ glassSheen/Ring/Rim/Glint consts). A1b the Glass system board.
- A2 GlassTilt + Atmosphere drift (lib/core/glass_tilt.dart).
- A3 GlassSurface, GlassShape, GlassPainter, GlassShadowPainter (lib/ui/glass_surface.dart; has edge and edgeWidth params).
- A4 GlassCircleButton, GlassPillButton, GlassSwitch, GlassTabBar, GlassSheet + showGlassSheet, GlassAlert + showGlassAlert, HoldButton; support: StrokeIcon/StrokeIcons, GlassTapTarget, PressTracker (features/shell).
- B1 StrikeBeat, strikeBeatAt, rowShakeAt (ui/strike_sweep_view.dart).
- B2 TaskRowTile rebuilt (pips, meta, RowPhase, menu/trailing slots, struck look); HoldToStrike now drives the HoldButton only (ready at 0.8); bossName param on TaskRow/HoldToStrike. test/support/hold_finders.dart has holdButton(title) for tests.
- B3 BossStage gains stamp and felled; the hit flash paints in palette.mask.

State to know: none of the glass parts are wired into screens yet (C steps). The sweep still runs 700/1100 ms, so the settle beat (500–1300 ms) is not reached until B4. The v3 slashBeat/strikeShake and StrikeChoiceDialog stay until B4 replaces their users. The ⋮ menu still sits beside the hold button until C16.

Next: step B4 (result sheet and the new strike order, D8), test first, as written in V41_PLAN.md section 6: hold, then the sweep, then the "How did the strike land?" GlassSheet; outcome written only on the choice; wire BossStage stamp/felled; the sweep length becomes 1300 ms. Then B-phase is done; Phase C screens follow (C1, C2, C4 first, C16 right after C4).
