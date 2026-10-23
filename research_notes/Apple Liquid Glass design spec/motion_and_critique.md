# Apple Liquid Glass: motion/interaction and critical reception

Provenance legend: [APPLE] = Apple-stated (WWDC25 transcripts fetched directly). [PRESS] = news coverage. [OPINION] = critic/designer. [UNVERIFIED] = secondary/AI-summarised, or my own background knowledge, not confirmed by a fetched source.
Note: Apple's "Adopting Liquid Glass" page body could not be read (fetch returned only title); API-level guidance below from that page is NOT sourced.

## Motion and interaction: how glass animates and responds

### Takeaway
Apple describes motion qualitatively (materialize via lensing modulation, gel-like flex on touch, light spreading to neighbours, bubble-like morph). No official durations/curves were found; only community-published SwiftUI examples (spring ~0.4 response, 0.8 damping; `.smooth`) exist, so timing for a recreation must be tuned by eye against a device.

### Cited Findings
- [APPLE] Glass does not fade in/out: it "materializes" by gradually modulating light bending and lensing, preserving optical integrity. — [WWDC25 Meet Liquid Glass (219)](https://developer.apple.com/videos/play/wwdc2025/219/)
- [APPLE] Touch response: material "instantly flexes and energizes with light", gel-like flexibility; on interaction it illuminates from within and the glow spreads to nearby glass elements. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- [APPLE] Elements can "lift up into Liquid Glass" temporarily on touch, so the resting state stays quiet (e.g. controls look flat/plain at rest, glass appears on press). — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- [APPLE] Morphing: glass morphs between controls as context changes; a menu "bubble simply pops open" inline with the tapped control. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- [APPLE] Larger glass simulates thicker material: deeper shadows, stronger lensing/refraction. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- [APPLE] Small elements (nav/tab bars) adapt and may flip light/dark; large elements (menus, sidebars) adapt but do not flip, because flipping would distract. Shadow opacity rises over text, falls over solid light backgrounds. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- [APPLE] Reduced Motion "decreases intensity of some effects and disables elastic properties". — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- [APPLE] Scroll edge effect: content dissolves into background (soft blur) as it passes under glass; soft is iOS default, hard is mostly macOS; one style per view, don't stack. Over dark content it becomes subtle dimming. Replaces hard dividers; no overlay darkening. — [WWDC25 356](https://developer.apple.com/videos/play/wwdc2025/356/), [219](https://developer.apple.com/videos/play/wwdc2025/219/)
- [APPLE] Concentricity: capsule radius = half height; concentric radius = parent radius minus padding. — [WWDC25 356](https://developer.apple.com/videos/play/wwdc2025/356/)
- [PRESS/community, not Apple] `.interactive()` on glass gives press scale, spring bounce on release, shimmer and touch-point glow; iOS only. — [search summary of community guides](https://playbooks.com/skills/rshankras/claude-code-apple-skills/liquid-glass) (UNVERIFIED detail)
- [community] Morph = shared `glassEffectID` in a `GlassEffectContainer` + animated state change; example spring response ~0.4, damping fraction 0.8. Container `spacing` sets distance at which glass blobs merge. — [Medium reference](https://medium.com/@veersr9/ios-26-liquid-glass-in-swiftui-a-practical-reference-demo-app-liquidglassreference-69b8d46dc055) (parameters are one author's example, not Apple spec)
- [APPLE API] Tab bar minimize: `tabBarMinimizeBehavior` (.automatic, .never, .onScrollDown, .onScrollUp), iOS 26+. Bar shrinks to selected tab's icon, hides label. — [Apple docs](https://developer.apple.com/tutorials/data/documentation/swiftui/view/tabbarminimizebehavior(_:).md), [Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-a-tabview-minimize-on-scroll)
- Minimize only triggers when scroll content significantly exceeds screen height; known bugs with NavigationStack(path:) and a first-tab flash at launch. — [Apple forums](https://developer.apple.com/forums/thread/799604), [forums 839224](https://developer.apple.com/forums/thread/839224)
- [OPINION, NN/g] Motion criticised: carousel dots morph into Search unprompted; tab bars "bubble and wiggle" on switch; camera buttons jerk; Music title pill shimmers while scrolling and jumps; fatigue and linked to nausea. — [NN/g](https://www.nngroup.com/articles/liquid-glass/)
- Web recreations use SVG feDisplacementMap + feSpecularLighting (Chromium-only via backdrop-filter) or WebGL/ray-traced height-field displacement with chromatic aberration. — [LogRocket](https://blog.logrocket.com/how-create-liquid-glass-effects-css-and-svg/), [liquid-glass-js](https://cdn.jsdelivr.net/npm/liquid-glass-js@0.1.0/README.md)

### Inferences
- For Flutter: model press as a short spring scale-up (~1.03-1.08 is my guess) plus brightening/glow, with spring back; resting state flat. Tune against a device; no published numbers.
- Morph between glass shapes should animate geometry (blob merge) rather than crossfade; materialize = animate blur/refraction strength, not just opacity.
- Provide Reduced Motion path: no elastic overshoot, reduced shimmer.
- Do not add unprompted ambient animation (NN/g's main motion complaint).

### Gaps
- No official durations, easing curves or spring constants found (WWDC transcripts lack them). Frame-level measurement of a real device would be needed.
- Tab-bar minimize animation timing/threshold not published; WWDC 219/356 transcripts do not discuss it.
- Sheet-transition behaviour (glass sheet detents, morph from button) not found in fetched sources.

## Critique, contrast and what changed across releases

### Takeaway
Main failure modes: text/icons over busy content, glass-over-text collisions, low contrast (one audit cites as low as 1.5:1, method unstated), excess motion, shrunken/crowded targets, inconsistent controls. Apple answered with frostier betas, then (26.1) a system Clear/Tinted switch, then (26.2) a Lock Screen clock transparency slider.

### Cited Findings
- [OPINION, NN/g, Budiu "Liquid Glass Is Cracked"] Legibility examples: Messages text over patterned wallpaper; Mail search bar over email previews ("illegible mess"); Maps icons blending into food photos; Safari URL truncated, pale search bar easy to miss. Concludes Apple "prioritizing spectacle over usability". — [NN/g](https://www.nngroup.com/articles/liquid-glass/)
- [OPINION, NN/g] Tap targets smaller/crowded vs iOS 18; hidden/relocated controls (Safari tabs into ellipsis, forward button appearing/disappearing); lost back-button labels. Article has no formal recommendations or direct accessibility section. — [NN/g](https://www.nngroup.com/articles/liquid-glass/)
- [PRESS] Fast Company coverage: experts say higher cognitive load; low contrast hard for older adults; Jakob Nielsen says worst effects on people with disabilities. — via [secondary summary](https://anderegg.ca/2025/10/12/nielsen-norman-group-on-ios-26-usability) (not read directly)
- [OPINION] Infinum audit: some screens well below WCAG minimum, as low as 1.5:1 in places; method unspecified. — [Infinum](https://infinum.com/blog/apples-ios-26-liquid-glass-sleek-shiny-and-questionably-accessible/) (snippet only)
- [OPINION] Naumova audit: default bottom-icon contrast failed WCAG (3:1 non-text). — [Medium](https://svetanaumova.medium.com/a-brief-ux-audit-apple-ios-26-liquid-glass-de24e6899204)
- [OPINION] Pimp my Type: lock-screen notification text over partially blurred background poor; floating tab better with Reduce Transparency but active tab still problematic. — [Pimp my Type](https://pimpmytype.com/liquid-glass/)
- No controlled WCAG measurements found. A translucent surface has no single background, so ratio depends on content behind. — [search results, medienbaecker](https://medienbaecker.com/articles/the-web-behind-glass)
- Beta history [PRESS]: iOS 26 beta 3 made glass frostier/less transparent after complaints (e.g. Control Center icons), some developers disliked it ("nerfs Liquid Glass"); beta 4 restored more translucency; heise says beta 6 moved back toward transparency again. Shipped release is the more transparent look. — [Mactrast](https://www.mactrast.com/2025/07/the-third-ios-26-beta-makes-liquid-glass-just-a-bit-frostier/amp/), [9to5Mac beta 4](https://9to5mac.com/2025/07/22/ios-26-beta-4-adds-more-liquid-back-to-liquid-glass-design/), [heise](https://heise.de/-10520832)
- iOS 26.1 beta 4 (Oct 2025): Settings > Display & Brightness > Liquid Glass: Clear (more transparent) vs Tinted (more opaque, more contrast); applies to Apple apps and adopting third-party apps; also more opaque Lock Screen notifications. Apple said users asked for control. — [9to5Mac](https://9to5mac.com/2025/10/20/ios-26-1-beta-4-adds-new-setting-to-tone-down-liquid-glass-transparency/), [TidBITS](https://tidbits.com/2025/10/21/ios-26-1-to-add-optional-opacity-to-liquid-glass/)
- One reviewer: Tinted easier to read on Lock Screen but some Notification Center buttons less readable. — [Tom's Guide](https://www.tomsguide.com/phones/iphones/ios-26-1-lets-you-adjust-liquid-glass-transparency-on-your-iphone-heres-how-to-do-it)
- iOS 26.2 beta: Lock Screen clock "Glass" transparency slider (near-clear to opaque); clock only. — [9to5Mac](https://9to5mac.com/2025/11/04/ios-26-2-adds-liquid-glass-slider-to-customize-your-lock-screen/), [TechRadar](https://www.techradar.com/phones/ios-26-2-will-take-another-big-step-towards-fixing-liquid-glass-for-good)
- [APPLE] Accessibility: Reduced Transparency = frostier, obscures more; Increased Contrast = mostly black/white with contrasting border; Reduced Motion as above. Applied automatically. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- [APPLE] System colors adjusted across Light/Dark/Increased Contrast for harmony with glass. — [WWDC25 356](https://developer.apple.com/videos/play/wwdc2025/356/)

### Inferences
- Apple's own fix path was the same as a recreation should offer: a user-selectable more-opaque variant plus automatic fallbacks, rather than one fixed transparency.
- 1.5:1 figure is unverified; treat as anecdotal.

### Gaps
- Precise 26.0 release/26.0.1/26.2 final-release changes beyond the above not verified; 26.2 coverage is from beta articles.
- NN/g original read OK, but no quantitative contrast data; no reliable contrast measurements anywhere.
- Apple's quoted "32% disabled Liquid Glass" claim (Alibaba guide) is unsourced; ignore.

## Practical guidance: text and icons on glass over arbitrary content

### Takeaway
Apple's rule: separate glass from content; use Regular (adaptive) almost everywhere; Clear only with dimming layer over bold media; keep text off glass/content intersections; tint sparingly. Numeric scrim/tint values are not published.

### Cited Findings
- [APPLE] Regular: adaptive, legible in any context, any size, anything can sit on it. Clear: permanently more transparent, no adaptive behaviour; use only when over media-rich content, dimming won't hurt content, and foreground is bold/bright. Never mix the two. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- [APPLE] Clear needs a dimming layer for symbol/label legibility; local dimming for small elements. No numeric value given. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/), [356](https://developer.apple.com/videos/play/wwdc2025/356/)
- [APPLE] Symbols/glyphs flip light/dark to keep contrast. Avoid steady-state intersections between content and glass; reposition/scale content for separation. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- [APPLE] "Elements using Liquid Glass require clear separation from content"; controls sit on a system material, not directly on content. — [WWDC25 356](https://developer.apple.com/videos/play/wwdc2025/356/)
- [APPLE] Tint: color generates a range of tones mapped to underlying brightness; use for primary actions only, tinting everything removes emphasis. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- [APPLE] Express hierarchy via layout/grouping; drop extra bar backgrounds/borders. Bolder, left-aligned type for alerts/onboarding. — [WWDC25 356](https://developer.apple.com/videos/play/wwdc2025/356/)
- WCAG baseline cited by blogs: 4.5:1 text, 3:1 large text/non-text; with Reduce Transparency use solid backgrounds. — [letsdev](https://letsdev.de/en/blog/ios-26-in-detail-liquid-glass-ui-between-usability-and-accessibility) (opinion)
- [UNVERIFIED, my background knowledge via a non-primary summary] Adopting Liquid Glass advice: avoid glass-on-glass, group in GlassEffectContainer, respect reduceTransparency with opaque fallback. Page body not readable via fetch; confirm in Apple docs.

### Inferences
- Recreation rule set: (1) default to Regular-like behaviour: blur + adaptive tint, never fully clear; (2) only put text on glass whose worst-case backdrop is scrimmed so label contrast >=4.5:1 (icons >=3:1) and verify by sampling pixels; (3) Flutter: no true backdrop luminance read cheaply, so use a fixed dark/light scrim or surface fill under labels; (4) honour MediaQuery.disableAnimations / highContrast / accessibleNavigation analogues and offer a solid fallback; (5) reserve tint for the one primary action per screen; (6) never stack glass on glass; (7) text 200% scaling must not collide with glass edges.
- Concrete scrim opacity numbers: none published; derive empirically against the app's palettes (biomes) using contrast tests.

### Gaps
- No Apple-published scrim/tint opacity, blur radius, or minimum contrast number.
- Deque/WebAIM-specific reviews not located in searches.

## Visual signature checklist: authentic Liquid Glass vs generic glassmorphism

### Takeaway
Authentic = refraction/lensing at curved edges, specular rim light that responds to context/motion, adaptive light/dark, depth via thickness-scaled shadow, quiet at rest and energised on touch, concentric capsule shapes, merging blobs. Generic glassmorphism = flat blur + translucent fill + hairline border.

### Cited Findings
- [APPLE] Lensing is "the primary way Liquid Glass visually defines itself": bends/concentrates light in real time rather than scattering it like prior blur materials. — [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)
- [APPLE] Elements: gel-like flex, inner illumination on touch, glow spreading to neighbours, materialize via lensing, thicker = deeper shadow + stronger refraction, adaptive light/dark flip on small elements, scroll-edge soft blur instead of hard dividers, concentric/capsule geometry, grouped merging. — WWDC25 [219](https://developer.apple.com/videos/play/wwdc2025/219/), [356](https://developer.apple.com/videos/play/wwdc2025/356/)
- [OPINION] Glassmorphism = translucent, frosted blur, soft layering; Liquid Glass adds light bending at curved edges and context-responsive highlights. — [LogRocket](https://blog.logrocket.com/how-create-liquid-glass-effects-css-and-svg/)
- Faithful web builds use displacement map from bezel height-field, specular highlight, chromatic aberration. — [liquid-glass-js](https://cdn.jsdelivr.net/npm/liquid-glass-js@0.1.0/README.md)

### Inferences
- Checklist: refraction at edge (not flat blur); specular rim highlight; subtle chromatic dispersion; adaptive tint by backdrop; shape is capsule/concentric; floats above content with soft shadow; flat at rest, press = scale + glow + neighbour glow; morphs/merges; no glass-on-glass; scroll-edge soft fade; tint only on primary; a more-opaque accessible variant. In Flutter, true refraction needs a fragment shader (and backdrop sampling); a blur+gradient rim is the fallback and reads as "glassmorphism".

### Gaps
- No pixel-level reference measurements (blur radius, rim width, highlight angle) from Apple.
