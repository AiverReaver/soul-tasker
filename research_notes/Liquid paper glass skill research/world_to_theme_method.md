# World-to-Theme Method: turning a source world into a multi-theme UI palette and token system

Research note. Fetch/search depth was limited: several primary pages (M3 color roles, M3 how-the-system-works, US Copyright Office PDFs, Primer/Polaris/Atlassian token docs) returned no usable text. Those items are in Gaps; the report writer should not treat the Inferences as sourced.

## 1. Palette extraction from reference imagery (k-means, HCT, OKLCH) and keeping exact designer hexes

### Takeaway
Material Color Utilities provides a ready pipeline: quantize image to N colors (Celebi = Wu then WSMeans), score for UI suitability, build HCT tonal palettes. OKLCH is the better working space for hand-tuned tokens. For a "world" theme, use extraction only to propose candidates; the designer's exact hexes should be stored as literal values (primitives) and never regenerated from a seed.

### Cited Findings
- Material Color Utilities is a set of low-level algorithms behind Material 3 dynamic color; ports exist in C++, Dart, Java, Swift, Kotlin, TypeScript. — [Material Color Utilities (GitHub)](https://github.com/material-foundation/material-color-utilities)
- HCT = hue, chroma, tone, "based on CAM16 x L*, that accounts for viewing conditions"; the library also has blend (interpolate/harmonize in HCT), contrast (measure/obtain contrastful colors), dynamiccolor (adapts to dark theme, style, preferences, contrast level), scheme (from one color or a core palette). — [GitHub](https://github.com/material-foundation/material-color-utilities)
- Quantizer "turns an image into N colors", composed of Celebi, which runs Wu then WSMeans; a separate score component ranks colors for theming suitability. — [GitHub](https://github.com/material-foundation/material-color-utilities); quantizer class names also listed in [Flutter material_color_utilities API](https://api.flutter.dev/flutter/material_color_utilities)
- A core palette groups six key palettes: primary, secondary, tertiary, neutral, neutral variant, error; tonal palettes are indexed by tone 0-100. — [MaterialColorUtilities NuGet README](https://www.nuget.org/packages/MaterialColorUtilities)
- OKLCH: L is perceived lightness (0-1), C practically below ~0.37, H 0-360; hue anchors approx red 20, yellow 90, green 140, blue 220, purple 320. Unlike HSL, adding lightness is consistent across hues; unlike LCH, no blue-to-purple hue shift. — [Evil Martians, OKLCH in CSS](https://evilmartians.com/chronicles/oklch-in-css-why-quit-rgb-hsl)
- Evil Martians: "All backgrounds with L>=87% have good contrast with black text", but a changelog note says use APCA to detect contrast; OKLCH alone is not enough. — [Evil Martians](https://evilmartians.com/chronicles/oklch-in-css-why-quit-rgb-hsl)
- Gamut: Chrome/Safari clip out-of-gamut colors fast, which can shift hue; article recommends manual gamut mapping and an sRGB-safe base value overridden in `@media (color-gamut: p3)`. Relative color syntax example: `oklch(from var(--accent) calc(l + 0.1) c h)` (use 0.1, not 10%, inside calc). Suggested stylelint ban on hex/rgb/hsl. — [Evil Martians](https://evilmartians.com/chronicles/oklch-in-css-why-quit-rgb-hsl)
- Tooling: OKLCH.com picker/converter by Evil Martians. — [Exploring the OKLCH ecosystem](https://evilmartians.com/chronicles/exploring-the-oklch-ecosystem-and-its-tools)

### Inferences
- Proposed pipeline (not from a single source): (1) collect 5-15 reference images per theme (screenshots, concept art, photos, brand sheets); (2) run Celebi/WSMeans quantizer to ~128 colors, then score; (3) also take a k-means (k=6-8) in OKLab to get dominant hues and surface/ink extremes; (4) a human picks roles from candidates; (5) store picked values as literal hex primitives, record the source image in a manifest; (6) use OKLCH only to audit (lightness steps, chroma outliers) and to derive missing neutrals/states.
- "Keep exact hexes": seed-generated schemes (e.g. `ColorScheme.fromSeed`) re-derive every role, so brand hexes drift. Instead define each role as an explicit hex per theme and per brightness; use HCT/OKLCH tonal derivation only for roles the designer left unspecified, and mark them as "derived" in the token file so tests can distinguish them. Add a test asserting designer-pinned roles equal the declared hex.
- Quantizer output is dominated by large areas (sky, skin, backgrounds); weight by chroma and sample salient regions, otherwise accents get lost. Heuristic, unsourced.

### Gaps
- Exact scoring rules of `Score.ranked` (thresholds on chroma/population) not found in fetched pages.
- M3 tone mappings per role (e.g. primary = tone 40 light / 80 dark) not retrievable: the M3 pages returned empty. Verify at m3.material.io before citing.

## 2. Semantic token architecture for many themes

### Takeaway
Use layered tokens: raw primitives (per-world hexes) -> semantic roles (surface, raised, ink, accent, onAccent, text, muted, danger) -> optional component tokens. Themes swap only the primitive-to-semantic mapping; widgets read only semantic roles. In Flutter, a `ThemeExtension` with `copyWith` and `lerp` carries the roles and gives cross-fade for free.

### Cited Findings
- Common three-tier model: primitives are raw values and should not be used in components; semantic tokens alias primitives and swapping that mapping drives theme switching; component tokens reference semantic tokens. Sources are third-party blogs/skill listings, so illustrative only. — [design token structure listing](https://skills.cat/skills/dylantarre/design-system-skills/design-tokens-structure); [token architecture note](https://cdn.jsdelivr.net/npm/@memi-design/cli@2.6.2/notes/token-architecture/token-architecture.md)
- Flutter `ThemeExtension<T>`: abstract interface for custom additions to `ThemeData`, "typically used for custom colors"; subclass defines fields and implements `copyWith` and `lerp`; should have a const constructor; `lerp(other, t)` linearly interpolates with another extension of the same type, which keeps property changes smooth when the theme switches; `type` getter. — [Flutter ThemeExtension API](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)
- Typical implementation: `Color.lerp` per field, return `this` if `other` is not the same type; `copyWith` falls back to existing field when param is null. Boilerplate generators exist (theme_extensions_builder, theme_tailor). — [ITNext tutorial](https://itnext.io/custom-theme-using-theme-extensions-8afb67248d2b); [theme_extensions_builder](https://pub.dev/documentation/theme_extensions_builder/7.5.0/); [theme_tailor](https://pub.dev/documentation/theme_tailor/latest/)
- Material dynamic color adapts roles to dark theme, style, preferences and contrast level. — [GitHub](https://github.com/material-foundation/material-color-utilities)
- CSS side: relative color syntax lets states derive from one token (`oklch(from var(--accent) calc(l + 0.1) c h)`). — [Evil Martians](https://evilmartians.com/chronicles/oklch-in-css-why-quit-rgb-hsl)

### Inferences
- Suggested role set (project-specific, from the brief): `surface` (page), `raised` (cards/sheets), `ink` (strong line/icon), `text`, `muted` (secondary text), `accent`, `onAccent`, `danger`, plus `onDanger`, `outline/hairline`, `focus`, and optional `glassTint`, `shadow`. Pair every filled role with an `on*` role so contrast is testable per pair.
- Structure: one `ThemeWorld` definition = id + display name + `light: Palette` + `dark: Palette` + non-color axes (see section 4). Palette -> `ThemeExtension` instance. Both brightnesses are explicit palettes, not computed by inversion.
- Cross-fade: lerp in Flutter is per-field `Color.lerp` (sRGB, can go muddy through mid-tones); lerping in OKLab/OKLCH gives more even midpoints. Non-color fields (corner radii: `lerpDouble`; font: snap at t=0.5; enums: snap) need explicit rules. Drive with a single animation `t` (e.g. `TweenAnimationBuilder` or `AnimatedTheme`).
- Equivalent mappings: CSS custom properties on `[data-theme="x"][data-mode="dark"]`; SwiftUI: custom `EnvironmentKey` holding a theme struct or asset-catalog colors with light/dark variants. I did not source SwiftUI specifics.
- Keep widgets from reading `Theme.of(context).colorScheme` directly for world-specific roles, or world colors leak and themes get incoherent. A lint/grep test can enforce "no raw `Color(0x...)` outside the palette files".

### Gaps
- Atlassian, GitHub Primer, Shopify Polaris theming docs were not retrieved (search returned only generic blogs). Their exact token naming/structure remains unverified.
- SwiftUI environment theming: no source gathered.

## 3. Contrast gates per theme (WCAG 2.2, APCA, color-blind safety), automated

### Takeaway
Gate every theme x brightness on explicit foreground/background pairs: 4.5:1 normal text, 3:1 large text and non-text UI, computed with unrounded WCAG 2 luminance. Treat APCA as an advisory second opinion, and add a luminance-separation check so state colors do not rely on hue alone.

### Cited Findings
- SC 1.4.3 (AA): 4.5:1 normal text, 3:1 large-scale text; large = at least 18pt or 14pt bold (about 24px / 18.5px). Ratios are not rounded: 4.499:1 fails. — [W3C Understanding 1.4.3](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
- Formula: L = 0.2126 R + 0.7152 G + 0.0722 B with channel linearization (<=0.04045: /12.92; else ((c+0.055)/1.055)^2.4); ratio = (L1+0.05)/(L2+0.05), range 1-21. — [W3C Understanding 1.4.3](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
- Exemptions: inactive components, decoration, logotypes. Brand-guideline text that is not a logo is not exempt. — [W3C](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
- SC 1.4.11 (AA): 3:1 for UI component states/boundaries needed to identify them and for meaningful graphics, measured against adjacent colors; examples: form-field borders, focus indicators, icon-only controls. Logos, photos exempt. — [Pearson accessibility guidelines](https://www.pearson.com/accessibility-guidelines/perceivable-principle/non-text-contrast.html); [Disability World summary](https://www.disabilityworld.org/toolkit/standards/wcag/1-4-11-non-text-contrast/)
- SC 1.4.1: where lightness differs as well as hue, that can serve as an additional distinction if the luminance difference reaches 3:1 (WCAG 2.0 Understanding doc; a WebAIM reply says 3:1 does not alone guarantee compliance, and color must not be the only means). — [W3C Understanding 1.4.1](https://www.w3.org/WAI/WCAG20/Understanding/use-of-color); [WebAIM thread](https://webaim.org/discussion/mail_message?id=50434)
- Color-blind: WCAG ratios measure fg/bg and can miss reduced differences between adjacent UI components under CVD; paper recommends user studies. — [arXiv 2401.10357](https://arxiv.org/pdf/2401.10357)
- APCA minimums (Lc, absolute values): body text 90 preferred / 75 minimum (>=18px, weight 400); content text 60 (24px/400 or 16px/700); large headline 45 (36px or 24px bold); non-text 15 absolute min, 30 for large solid semantic elements; other text (placeholder, disabled) 30; AAA adds 15. Negative Lc = light text on dark. APCA is a WCAG 3 candidate still in development, range-based not pass/fail. — [APCA easy intro](https://git.apcacontrast.com/documentation/APCAeasyIntro)
- Apple: Liquid Glass responds to Reduce Transparency / Increase Contrast / Show Borders; iOS 26.1 added Tinted (more opaque, more contrast) vs Clear; custom components must honor accessibility settings themselves; test over scrolling content, not static mockups. — [TidBITS](https://tidbits.com/?p=72096); [Fast Company ZA](https://fastcompany.co.za/tech/2025-11-10-how-to-adjust-apples-liquid-glass-in-ios-26/); [Firefox Acorn iOS 26 note](https://acorn.firefox.com/latest/mobile/patterns/i-os-26-and-liquid-glass-w2oH48nk) (secondary sources)

### Inferences
- Gate table to implement as tests (per world x light/dark): text/surface >=4.5; text/raised >=4.5; muted/surface >=4.5 (or >=3 only if muted is used solely for large text; safer to hold 4.5); onAccent/accent >=4.5; onDanger/danger >=4.5; accent/surface >=3 (non-text, e.g. icon, toggle); outline/surface >=3 for control boundaries; focus ring/adjacent >=3; danger/surface >=3. Use exact hex, no rounding; add small safety margin (e.g. fail under 4.55) to survive rounding by other tools.
- Glass/translucent surfaces: test text over the worst-case backdrop (lightest and darkest plausible), not just the nominal tint; snapshot-composite the layer stack, then compute ratio. Provide a Reduce Transparency fallback palette that also passes.
- Color-blind check: require lightness (OKLCH L or relative luminance) separation between semantically paired states (success vs danger vs warning) of at least 3:1 luminance ratio or deltaL >= ~0.15 (heuristic), plus a non-color cue (icon/label/shape). Optionally simulate protan/deutan/tritan with a matrix and check deltaE between state colors. Thresholds here are my heuristics, not sourced.
- Run APCA as a warn-only test (fail a hard gate only for WCAG 2.x), since WCAG 2.2 is the conformance standard and APCA is unfinalized.
- Automation: pure-Dart function `contrast(Color a, Color b)`; a parameterized test iterating all registered worlds x brightness x pair list; fail message prints world, pair, ratio. Also test every theme in at 200% text scale manually.

### Gaps
- Exact WCAG 2.2 wording of 1.4.11 was not fetched from w3.org (relied on secondary summaries).
- No authoritative luminance-separation number for CVD safety found; the figures above are heuristics.
- Apple HIG pages on Liquid Glass/color not retrieved directly.

## 4. Mix-and-match axes and coherence rules

### Takeaway
Palette, material, shape, type pairing, motion personality, iconography, light direction are mostly independent if each is a separate token group with a defined interface. Incoherence arises from cross-axis dependencies, which should be encoded as validation rules, not left to taste.

### Cited Findings
- Material You/dynamic color: a single input color plus preferences (style, contrast level, dark) yields a whole scheme, i.e. the axes "seed", "variant/style", "contrast", "brightness" are independent inputs. — [GitHub](https://github.com/material-foundation/material-color-utilities)
- Apple Liquid Glass offers user-selectable Clear vs Tinted material as an independent setting layered over any app palette. — [TidBITS](https://tidbits.com/?p=72096)

### Inferences (no direct sources found for this section; design reasoning)
- Independent axes and their token groups: (a) palette (color roles); (b) material (opaque/paper/glass: blur sigma, tint alpha, border alpha, noise); (c) shape (corner radius tiers, e.g. sm/md/lg/pill, stroke width); (d) typography pairing (display + text family, scale, weights); (e) motion personality (duration/curve set: snappy, soft, springy); (f) iconography (stroke weight, fill vs outline, corner style); (g) light direction (shadow offset/angle, highlight edge, specular tilt); (h) density/spacing (usually leave global).
- Coherence rules to encode as validators:
  1. Material x palette: glass/translucent material requires palette surfaces with enough luminance spread to hold text contrast over backdrop; fail if the text/surface gate (section 3) fails under the material's worst-case backdrop.
  2. Shape x iconography: icon corner style matches radius tier (sharp icons with pill shapes clash); stroke weight of icons within ~1 step of border stroke.
  3. Type x shape: heavy display faces pair with larger radii tiers; thin faces with thin strokes; do not mix more than 2 families.
  4. Motion x material: heavy/glass materials get slower, softer curves; snappy motion with paper cutout theme fine; respect reduce-motion by collapsing durations to ~0 for all personalities.
  5. Light direction must be a single global vector shared by shadows, highlights, glass specular; all components read it from one token (so mixed parts never disagree).
  6. Dark variant must keep the same hue family and light direction; do not simply invert.
  7. Provide curated presets ("recipes") per world plus a "mix" mode that runs validators and shows warnings instead of blocking.
- Implementation: each axis a small immutable class; `ThemeRecipe(paletteId, materialId, shapeId, typeId, motionId, iconId, lightId)`; validators return list of warnings; golden tests render a component sheet for each recipe.

### Gaps
- No sourced examples quantifying which combinations users judge incoherent; no game UI analysis article was retrieved (search budget).

## 5. Legal / IP hygiene when theming a copyrighted world

### Takeaway
Treat the world as inspiration for a palette and mood, not as an asset source. Do not use names, logos, characters, screenshots, extracted art, or the original fonts. Avoid trademarked names in the shipped product and store listing. This is practical guidance, not legal advice.

### Cited Findings
- Fan art is technically an unlicensed derivative work; Pokemon Company/Nintendo generally tolerate wholesome fan art but have sent hundreds of takedowns to fan games, and commercial use (merch, trademark-adjacent branding) has drawn cease-and-desist letters. — [Plagiarism Today](https://www.plagiarismtoday.com/2025/07/29/the-pokemon-plagiarism-controversy/); [Axios](https://www.axios.com/2022/01/24/fan-made-game-escapes-nintendo); [Techdirt](https://archive.techdirt.com/articles/20140819/10013428255/nintendo-goes-copyright-woman-making-pokemon-inspired-planters.shtml)
- Search summary noted that trademark and copyright can apply to logos even in non-commercial use. — [Plagiarism Today](https://www.plagiarismtoday.com/2025/07/29/the-pokemon-plagiarism-controversy/) (secondary)
- W3C: logotype text is exempt from contrast rules, which is unrelated to IP but means brand wordmarks are treated as artwork. — [W3C](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)

### Inferences (from general knowledge, unsourced here; verify with the Copyright Office Circular 33 and Compendium ch. 300 before relying)
- In the US, ideas, general styles and bare colors/color combinations are generally not protected by copyright; specific expression (character art, key art, logos, UI art assets) is. Typeface designs are generally not copyrightable in the US as such, but font software and licenses are enforceable by contract; many countries differ.
- Practical rules for the skill: (1) hex values should be hand-picked or derived, not copied pixel-for-pixel from official assets, and the theme name should be generic/evocative ("Ember Woods", not the franchise name); (2) no franchise names in app name, store keywords, or theme IDs shown to users; "inspired by" in credits is lower risk than "official"/"X theme" but is still not a license; (3) no logos, character sprites, iconography lifted from the game, or screenshots in the bundle; (4) fonts: use OFL/Apache fonts (Google Fonts) or fonts you license; never extract a game's or brand's font; pick a lookalike of the mood, not the same face; (5) keep a provenance manifest per theme (which reference images informed it, what was original); (6) sounds, music, haptic patterns, and texture/pattern art count as expression too; (7) a user-built "own world" feature should put the responsibility and a content notice on the user, and ship only original presets.
- A skill that lets anyone theme any world should include a pre-flight checklist: names, logos, characters, fonts, assets, store text.

### Gaps
- US Copyright Office Circular 33 and Compendium chapter 300 PDFs were fetched but unreadable (compressed), so no direct citations on colors, familiar symbols, typefaces, titles.
- No source on trade dress for UI themes, or on specific game UI cases.
- Not jurisdiction-specific (EU/UK/India differ).

## 6. Examples of themed design systems with many variants

### Takeaway
Material You (single seed -> full scheme with contrast and variant knobs) and Apple Liquid Glass (Clear/Tinted system modes) are the best-documented examples found. No game-UI analysis sources were retrieved.

### Cited Findings
- Material You/Material 3: seed or image -> quantize -> score -> HCT tonal palettes -> schemes that adapt to dark/contrast/style. — [GitHub](https://github.com/material-foundation/material-color-utilities)
- Apple iOS 26 Liquid Glass: Clear vs Tinted (26.1), responds to Reduce Transparency/Increase Contrast; HIG updated 9 Sep 2025 with guidance on semantic use, legibility, contrast, avoiding unnecessary glass layers. — [TidBITS](https://tidbits.com/?p=72096); [Fast Company ZA](https://fastcompany.co.za/tech/2025-11-10-how-to-adjust-apples-liquid-glass-in-ios-26/)

### Inferences
- Lessons: (a) offer a small number of system-level "knobs" (contrast, transparency) that sit above any theme; (b) accessibility modes need their own tested palettes/material fallbacks; (c) themes are data, widgets are generic.

### Gaps
- Atlassian, Primer, Polaris, and game-UI (e.g. per-faction/per-biome UI skins) case studies not retrieved; no sources on how games structure skins.
