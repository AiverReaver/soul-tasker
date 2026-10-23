# Paper/ink content layer + Liquid Glass chrome layer: hybrid UI design principles

Method note: about 15 tool calls. Apple's own HIG and "Adopting Liquid Glass" pages are JS-rendered and did not fetch (title only), so Apple rules below come from a WWDC25 session 219 transcript mirror (nonstrict.eu) plus secondary write-ups. Anything not tied to a URL is under "Inferences".

## 1. Apple's content-layer vs functional-layer rule, and how custom aesthetics combine with it

### Takeaway
Apple's rule: glass is a floating functional layer (controls, navigation) above content; content stays in its own layer and large content (tables, lists) must not become glass. A paper/ink content layer fits this rule naturally. I found no sourced case study of an illustrated or hand-drawn iOS 26 app doing this, so the hybrid is largely inference.

### Cited Findings
- Liquid Glass forms a distinct functional layer for controls and navigation that floats above content and gives content a larger canvas; large content such as a table view should stay in the content layer so hierarchy stays clear — [WWDC25 219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/); session page [Apple](https://developer.apple.com/videos/play/wwdc2025/219)
- HIG (quoted via a mirror, not apple.com): do not use glass in the content layer, it adds complexity and muddies hierarchy; use sparingly, especially on custom controls; exception for transient controls (sliders, toggles) that take on glass while interacted with — [HIG mirror, per search summary](https://glama.ai/mcp/servers/@tmaasen/apple-dev-mcp/blob/b82f0efe2115dc4539c83a2374a714a84aeb350a/content/universal/materials.md) (page body not retrievable; treat as unverified wording)
- Two variants, never mix: Regular (adaptive, any size, supports content on top) and Clear (permanently more transparent, no adaptive behavior, needs a dimming layer; only for media-rich backgrounds, when dimming does not harm content, and content above is bold/bright) — [WWDC25 219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- Tinting: generates tones mapped to content brightness; reserve for primary elements/actions; tinting everything makes nothing stand out; decorative color belongs in the content layer — [WWDC25 219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- Avoid glass on glass; things placed on glass should use fills, transparency and vibrancy as a thin overlay — [WWDC25 219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- Small glass (tab/nav bars) can flip light/dark with background; large glass (menus, sidebars) adapts but does not flip. In steady states avoid overlapping content with glass; reposition or scale content to keep separation — [WWDC25 219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- Practitioner rules: glass for toolbars, tab bars, floating buttons; glass on every list row looked cluttered; an opaque background on the view hides the glass; check icon contrast; group neighbours in `GlassEffectContainer` (Apple-recommended for rendering efficiency and merge/morph) — [Donny Wals](https://www.donnywals.com/designing-custom-ui-with-liquid-glass-on-ios-26/)
- Linear built its own tab bar since the stock iOS 26 one cannot be meaningfully reshaped — evidence that teams with strong identity re-skin chrome — [Linear](https://linear.app/blog/linear-liquid-glass)
- Apple keeps a gallery of iOS 26 redesigns (e.g. Sky Guide, Linearity, GrowPal) — [Apple gallery](https://developer.apple.com/design/new-design-gallery/?page=2) (I did not inspect individual apps for illustrated styles)
- Hades menus are illustrated 2D art animated by a dedicated UI animator/illustrator team (job listings); no technique breakdown found — [Supergiant UI illustrator listing](https://www.supergiantgames.com/blog/job-opportunity-ui-illustrator-for-hades-ii), [UI animator listing](https://www.workwithindies.com/careers/supergiant-games-ui-animator-hades-ii)

### Inferences
- Paper = content layer (cards, lists, pages, illustrations, body type); glass = functional layer (tab bar, circle buttons, sheets, alerts, switches). This maps one-to-one onto Apple's split, so the app can claim Apple-consistent hierarchy while keeping its own material.
- Sheets and alerts are modal chrome. Glass sheets over paper content is consistent with "navigation layer"; keep sheet body copy on an opaque paper inset rather than raw glass (Apple's "thin overlay on glass" and "avoid large glass content" point the same way).
- Use Regular-style (frosted, adaptive) behavior, not Clear, because the paper layer is flat and not media-rich; Clear's three conditions will rarely hold.
- Tint only the primary action; everything else neutral. Palette color lives on paper.
- A custom (non-system) glass in Flutter cannot use the system material, so it must emulate: blur + tint + rim + shared light. Honor the same accessibility fallbacks Apple applies (section 5).

### Gaps
- Apple HIG Materials and "Adopting Liquid Glass" exact text not retrieved.
- WWDC25 356 (not fetched) and no shipped iOS 26 illustrated/skeuomorphic app case study located.

## 2. Paper / ink / risograph / cut-paper traits, what reads as "paper", pitfalls

### Takeaway
The recurring recipe: flat opaque fills, a single near-black key line, hard zero-blur offset shadows, restrained spot palette, grain and slight misregistration, editorial type. Grain and low-contrast spot colors are the main pitfalls.

### Cited Findings
- Neobrutalist recipe: borders about 2-5px, single flat near-black; shadows with zero blur producing a solid offset shape — [Superdesign brutalism](https://www.superdesign.dev/styles/brutalism/components) (design-library page, practitioner source)
- Riso-style guidance: warm off-white paper, few spot colors, paper grain, halftone, imperfect registration; offset print-shadow; fluorescent accent as the interaction color — [riso skill listing](https://skillselion.com/skills/bergside/awesome-design-skills/riso); effect tool exposes grain scale/opacity/softness and per-channel registration shift — [effect.app](https://effect.app/effects/risograph)
- Die-cut sticker look = subject with a white keyline — [Pressed app](https://mwm.ai/apps/pressed-risograph-halftone/6782635292)
- Contrast caveat: acid yellow needs black text and a black border, never white; saturated clashing colors can fatigue even with high contrast; one UX Collective author argues neubrutalism can increase visual load (untested claim) — [Superdesign login guide](https://superdesign.dev/styles/brutalism/login), [UX Collective](https://uxdesign.cc/neubrutalism-is-taking-over-the-web-e9d09e0fe441)
- Bold offset outlines make better focus states than faint rings — [Superdesign](https://www.superdesign.dev/styles/brutalism/components) (practitioner)
- Flutter grain: repaint boundaries help only if the layer is static; a constantly changing layer thrashes the raster cache; each cache entry costs width x height x 4 bytes GPU memory — [omr.it.com](https://omr.it.com/blog/flutter-engine-raster-cache-tuning/) (low-authority blog, unverified); Paper Shaders Flutter port has a deterministic-frame option for golden tests — [pub.dev](https://pub.dev/documentation/paper_shaders/0.0.2/)

### Inferences
- "Paper-ness" comes from: opaque fills (no alpha), consistent ink line weight, hard unblurred offset shadow in a darker paper tone or ink, slight irregularity (hand-cut corner jitter, misregistration of fill vs line), and a serif display face. Remove any one and it drifts toward generic flat/neobrutalist.
- Bake grain as a single tiled static texture (tiled ImageShader, or pre-rendered asset) drawn once under a RepaintBoundary; never animate it; keep opacity low so it does not reduce text contrast. Drop it under Reduce Transparency/low-power if profiling shows cost.
- Hard offset shadows are cheap (a shifted solid path) and deterministic in goldens, unlike blurred shadows. Good for performance and tests.
- Dark-fantasy variant: swap off-white stock for dark parchment/ink-black stock and invert the key line to a lighter ink or gold; verify the 3:1 line contrast again, since near-black line on dark paper vanishes.

### Gaps
- No authoritative (primary/academic) source for paper-UI traits; all are practitioner pages.
- No measured grain performance numbers for Flutter on device.

## 3. Ink key line and paper scrim on glass; light-source consistency; rim, inner shadow, sheen

### Takeaway
I found no sourced treatment of an ink key line on glass; this section is mostly inference grounded in Apple's description of lensing/specular highlights and in contrast standards. The key idea: key line + paper scrim give glass "object-ness" and legibility, and one shared light must drive every glass part.

### Cited Findings
- Apple: lensing (bending/concentrating light) is the main way glass defines itself; specular highlights respond to geometry; lights move during interactions and in some cases respond to device motion, so the material seems aware of the real world — [WWDC25 219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- Clear glass needs a dimming layer for legibility (localized dimming for small elements); without it legibility drops noticeably — [WWDC25 219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- Increased Contrast makes glass mostly black/white with a contrasting border — [WWDC25 219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- WCAG 1.4.11: if a control has a visual boundary or state indicator it needs 3:1 against adjacent colors; indicators not strictly required — [W3C Understanding](https://w3.org/WAI/WCAG22/Understanding/non-text-contrast)
- Critics say Liquid Glass buttons rely almost entirely on faint edges to differentiate from the background — [UX Collective](https://uxdesign.cc/did-apple-abandoned-its-own-design-heuristics-accessibility-principles-2d616ed7ace5) (as summarized by search; opinion)

### Inferences
- An ink key line on the glass (about 1-1.5px, same ink token as paper outlines) gives the glass the same "cut and inked" grammar as paper, so chrome and content read as one world while still differing by material (blur/sheen vs flat). It also supplies the 3:1 boundary that Apple's faint edge lacks, and it is effectively a built-in Increased Contrast border.
- Paper-colored scrim (semi-opaque paper tone behind glass, e.g. 55-80% alpha, scaling up with Reduce Transparency to ~100%) acts as Apple's dimming layer, but in the theme's own color rather than black. Choose alpha so worst-case content behind (darkest ink fill or brightest illustration) still gives 4.5:1 for label text.
- Layer order for a glass part, bottom to top: backdrop blur, paper scrim, tint (primary only), inner shadow along the edge opposite the light, sheen gradient, specular rim on the lit edge, ink key line, glyph/label. Key line outside, specular rim inside it, so the line never gets washed out.
- Light consistency: one Atmosphere/tilt value (already present in the repo as shared glass tilt) should drive rim angle, sheen offset, and inner-shadow side on all glass parts; paper hard shadows should fall in the same direction as that light. Sensor (gyro/accelerometer) tilt when permitted and motion is not reduced; otherwise slow idle drift; under Reduce Motion, freeze at a fixed 'upper-left' angle. (Apple: lights respond to device motion in some cases; the sensor/idle policy is my design choice.)
- Keep sheen subtle and low-alpha so that it never crosses text; text gets its own contrast against the scrim, not against sheen.

### Gaps
- No sourced guidance on key lines on glass, nor measured alpha/contrast values for paper scrims; values above need verifying with contrast tests per theme.
- Idle drift vs sensor: no source comparing them.

## 4. Motion personality: stepped paper vs spring glass; reduced motion

### Takeaway
Apple documents elastic/fluid behavior for glass and its Reduce Motion fallback. For stepped "paper" motion I found no usable sources; the stop-motion/on-twos recommendations are inference only.

### Cited Findings
- Reduced Motion lessens intensity of some glass effects and disables elastic properties; Reduced Transparency makes glass frostier; these apply automatically to system glass — [WWDC25 219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- `.interactive()` gives glass a slight grow and shimmer on touch; GlassEffectContainer enables merge/morph — [Donny Wals](https://www.donnywals.com/designing-custom-ui-with-liquid-glass-on-ios-26/)
- Hand-made paper animation uses separate cut pieces and visible crumple/fold changes (stop-motion tributes) — [A.V. Club](https://avclub.com/consider-this-hand-drawn-super-mario-bros-level-a-pape-1832563914), [Nintendo Life](https://nintendolife.com/news/2024/05/random-fan-recreates-iconic-paper-mario-ttyd-boss-battle-in-glorious-stop-motion)
- NN/g: unprompted animation (tabs wiggling, pulsing buttons, shimmering titles) is distracting: "Motion for motion's sake is not usability" — [NN/g](https://www.nngroup.com/articles/liquid-glass/)

### Inferences
- Paper content: animate on twos/threes (about 12 or 8 distinct poses per second) via held/stepped curves for entrances, shuffles, stamps; glass chrome: continuous springs with slight overshoot for press and morph. The contrast between the two is itself the cue for "layer".
- Reduced Motion rules: paper becomes instant or a single-frame crossfade (no stepped wobble); glass springs become critically damped (no overshoot), idle drift off, sensor tilt off, light fixed. Never rely on motion alone for state.
- No ambient looping motion on chrome (NN/g critique); only motion tied to input.

### Gaps
- No source found for "animation on twos" applied to UI or for Hollow Knight, Silksong, Hades or Inscryption motion breakdowns; searches returned nothing relevant.

## 5. Critiques and accessibility problems of Liquid Glass, and mitigations

### Takeaway
NN/g's critique: contrast loss over busy backgrounds, text on text, floating/crowded tab bars, motion for its own sake. Apple's response was the iOS 26.1 Clear/Tinted switch plus existing Reduce Transparency / Increase Contrast. A themed app should build its own fallbacks.

### Cited Findings
- NN/g (Raluca Budiu): translucent controls lose contrast over busy backgrounds; text-on-text in Mail search; crowded, smaller tab bar touch targets; search button detached; tab bar changes layout when search activates; unpredictable motion — [NN/g](https://www.nngroup.com/articles/liquid-glass/)
- NN/g summary quotes: "restless, needy, less predictable, less legible"; Apple "prioritizing spectacle over usability" — [Anderegg](https://anderegg.ca/2025/10/12/nielsen-norman-group-on-ios-26-usability)
- iOS 26.1 added Settings > Display & Brightness > Liquid Glass: Clear (more transparent) vs Tinted (more opacity and contrast); Tinted is "nearly opaque" per reviewers; interaction with Reduce Transparency/Increase Contrast reported inconsistently across 26.1/26.2 — [Tom's Guide](https://www.tomsguide.com/phones/iphones/ios-26-1-lets-you-adjust-liquid-glass-transparency-on-your-iphone-heres-how-to-do-it), [Fast Company ZA](https://fastcompany.co.za/tech/2025-11-10-how-to-adjust-apples-liquid-glass-in-ios-26/)
- Critics frame accessibility settings as optional patches rather than design foundations — [UX Collective](https://uxdesign.cc/did-apple-abandoned-its-own-design-heuristics-accessibility-principles-2d616ed7ace5)
- MacStories reports iOS 27 adds more personalization of the glass material (iOS 26 offered only Clear or Tinted) — [MacStories](https://www.macstories.net/stories/ios-and-ipados-27-review/2/) (snippet-level; verify before relying)
- Unverified: a claimed NN/g "January 2026 readability report" figure could not be confirmed; do not use.

### Inferences
- Make the Tinted-equivalent the default for a themed app: high scrim opacity, key line always on. Offer a Clear-like option only where behind-content is guaranteed bounded (e.g. glass over a known paper tone), since our backdrop is paper not photography.
- Honor `MediaQuery.highContrast` / `disableAnimations` / accessibleNavigation equivalents: Reduce Transparency to scrim ~100% with no blur; Increase Contrast to thicker key line and ink-on-paper label colors; Reduce Motion as in section 4. Also respect the OS 26.1 setting if readable; Flutter exposure of it is unverified.
- Keep tab bar targets at least 44pt with generous gaps and a stable layout (NN/g); no layout shifts on state change.
- Dark-fantasy variant risks: low-luminance everything lowers glass-vs-content separation; rely on rim light and ink key line in a lighter tone, and test 4.5:1 text and 3:1 boundaries in both themes. Test at 200% text.
- Never place glass text over illustration without scrim; avoid text-on-text (paper text scrolling under chrome needs a scroll-edge fade or opaque paper strip).

### Gaps
- Apple's exact documented behavior for 26.1/26.2 interplay unresolved (sources conflict).
- No Flutter-specific API source for reading Clear/Tinted preference.

## 6. Test strategies for visual systems

### Takeaway
Goldens for structure, computed contrast tests against tokens, a source scan banning raw colors, and an explicit manual device checklist. Deterministic goldens need loaded fonts, pinned platform, opaque/hard shadows, and fixed light/grain.

### Cited Findings
- Flutter widget tests default to the Ahem font; gallery goldens load real fonts; goldens are run on one platform (macOS CI) because text rendering differs across platforms; shadows made opaque to reduce flakiness — [Flutter gallery test_goldens](https://dart.googlesource.com/external/github.com/flutter/gallery/+/8f5d333cc8d61affe07204b262f3f2d9b5b4a607/test_goldens)
- Ahem-placeholder mode keeps text geometry predictable; multiple text scales per test — [golden_matrix](https://pub.dev/packages/golden_matrix/versions/0.19.1); per-environment text scale and optional pixel-tolerance comparator (zero by default) — [Zoloto](https://pub.dev/packages/zoloto/versions/0.0.1)
- Mac vs Linux golden mismatch reported — [VeryGood Ventures](https://verygood.ventures/blog/alchemist-golden-tests-tutorial.md)
- WCAG 1.4.11 3:1 for component boundaries/states (plus 4.5:1 text under 1.4.3, general knowledge) — [W3C](https://w3.org/WAI/WCAG22/Understanding/non-text-contrast)

### Inferences
- Goldens: render each glass part and paper part over a fixed backdrop matrix (lightest paper, darkest ink fill, busy illustration), in each theme, at text scale 1.0 and 2.0, with tilt fixed and grain deterministic or off. Use a small tolerance only for blur; keep hard-shadow paper goldens at zero tolerance.
- Contrast tests (pure unit tests, no pixels): composite scrim over worst-case backdrop colors from tokens, assert label >= 4.5:1 and key line/rim vs surrounds >= 3:1, for each theme and each accessibility mode (normal, reduce-transparency, high-contrast).
- No-raw-color scan: a test that greps `lib/` for `Color(0x`, `Colors.` and hex literals outside the palette/token file, failing on hits (aligns with the repo's token-based design).
- Behavior tests: with `disableAnimations` true, tilt and idle drift produce a constant value; paper stepped controllers finish in zero frames.
- Manual device checks (cannot automate): real gyro tilt feel, blur cost and frame time on an older device, grain visibility on OLED, 200% text, Increase Contrast/Reduce Transparency/Reduce Motion toggles, Clear/Tinted setting, sunlight legibility, VoiceOver focus order and 44pt targets.

### Gaps
- No source for automated contrast testing in Flutter specifically; search returned nothing.
- No source for a canonical no-raw-color lint; recommendation is mine.

## Overall source-quality caveats
- Strong: WWDC25 219 transcript mirror, NN/g article, W3C Understanding page, Flutter gallery repo notes.
- Weak/secondary: HIG mirror (not apple.com), practitioner design-library pages, low-authority performance blogs, snippet-level news.
- Not found: Apple HIG exact text; shipped illustrated-app iOS 26 case studies; Hollow Knight/Silksong/Hades/Inscryption UI breakdowns; Josh Comeau/Ahmad Shadeed pieces on glass/paper shadows; Smashing Magazine coverage.
