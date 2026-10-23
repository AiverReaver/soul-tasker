# Apple Liquid Glass: visual physics (iOS 26 / macOS Tahoe 26, incl. 26.1)

Labels: [APPLE] = Apple-stated. [COMMUNITY] = third-party recreation or approximation. Apple's pages (developer.apple.com docs/HIG) are JS-rendered and returned only titles to my fetcher, so Apple claims below come from the WWDC25 session 219 transcript (via nonstrict.eu mirror) and the Newsroom release. Nothing from the HIG or GlassEffectContainer doc pages was verified; see Gaps.

## How does Apple describe the material (lensing, refraction, highlights, shadows, tint, variants, interaction, morphing)?

### Takeaway
Apple defines Liquid Glass by lensing (real-time bending and concentration of light), not by scattering/blur like older materials. It adds environment-driven specular highlights, content-aware shadows, brightness-mapped tint, Regular (adaptive) vs Clear (permanently more transparent, needs dimming) variants, touch "illumination from within", and morphing between controls.

### Cited Findings
- [APPLE] Press release: material "is translucent and behaves like glass in the real world", "reflects and refracts its surroundings", uses real-time rendering and "dynamically reacts to movement with specular highlights", and "intelligently adapts between light and dark environments"; color informed by surrounding content. — [Apple Newsroom, 9 Jun 2025](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/)
- [APPLE] Session 219: "The primary way Liquid Glass visually defines itself is through something called Lensing"; it "dynamically bends, shapes, and concentrates light in real time" (contrast: older materials scatter light). — [WWDC25 219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/); session page [developer.apple.com/videos/play/wwdc2025/219](https://developer.apple.com/videos/play/wwdc2025/219)
- [APPLE] Specular highlights: light sources in the environment shine on the material, "producing highlights that respond to geometry"; device motion/moving lights change them. — [219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- [APPLE] Shadows adapt: element is aware of what is behind it, raises shadow opacity over text, lowers it over a solid light background. Larger glass casts "deeper, richer shadows", stronger lensing/refraction, softer light scattering. — [219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- [APPLE] Tint: choosing a color "generates a range of tones that are mapped to content brightness underneath the tinted element"; use only for primary actions. — [219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- [APPLE] Regular: most versatile, adaptive, any size, default. Clear: no adaptive behavior, "permanently more transparent"; use only over media-rich content, when a dimming layer is acceptable, and with bold bright content above. Needs a dimming layer for legibility (localized for small elements). Never mix the two variants. — [219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- [APPLE] Interaction: "instantly flexing and energizing with light"; on touch "the material illuminates from within"; glow can spread to nearby glass; elements can lift into glass only while touched. — [219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- [APPLE] Morphing: glass "dynamically morphs" between controls across contexts, keeping one floating plane; menus "pop open" from their button. — [219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- [COMMUNITY] GlassEffectContainer (SwiftUI): grouped glass shapes blend/merge when within `spacing`, and `glassEffectID` + namespace morph them; glass cannot sample other glass, hence the container. This came from the fetch tool's general knowledge, NOT page text. Treat as unverified. — [API page](https://developer.apple.com/documentation/swiftui/glasseffectcontainer)

### Inferences
- CSS/SVG equivalent of "lensing": displacement of backdrop concentrated in a bezel near the edge (convex profile), flat/undistorted centre.
- Merge/morph in web: animate shape (border-radius/width/position) or use an SVG gooey filter (blur + alpha threshold) over adjacent glass shapes; not documented by Apple for web.
- Regular = blur + saturation + adaptive shadow/tint; Clear = almost no blur, little tint, plus an optional scrim.

### Gaps
- No Apple-published numeric values (blur radius, refractive index, opacity). Session transcript is qualitative.
- HIG Materials and GlassEffectContainer doc text not retrievable; verify manually.

## What do real iOS 26 surfaces look like (numbers)?

### Takeaway
I found no measured/reverse-engineered values for blur radius, saturation, rim light, shadow or corner radius. Only community approximations exist, so treat every number below as a tunable starting point.

### Cited Findings
- [COMMUNITY] A write-up estimates Apple boosts backdrop saturation 10-20% before display and uses a Gaussian blur, often at lower resolution; author's inference, no measurement. — [Medium: Engineering behind Apple Liquid Glass UI](https://medium.com/@manavkaushal756/engineering-behind-apple-liquid-glass-ui-fb51b1d599ad)
- [COMMUNITY] Rim light modeled by kube.io as intensity from the surface normal vs a fixed light direction, default angle -60 degrees, composited by feBlend over refracted image. — [kube.io](https://kube.io/blog/liquid-glass-css-svg/)
- [COMMUNITY] kube.io demo parameters (specular opacity / saturation / refraction / blur): lens 0.50/9/1.00/-; searchbox 0.20/4/0.70/1.0; switch 0.50/6/1.00/0.2; slider 0.40/7/1.00/0.0; music player 0.40/6/1.00/1.0 with glass background opacity 0.60. Saturation figures are the author's scale, not CSS percent. — [kube.io](https://kube.io/blog/liquid-glass-css-svg/)
- [COMMUNITY] Ekino/dev.to recipe layers: overlay `rgba(255,255,255,0.25)`, rim `box-shadow: inset 1px 1px 0 rgba(255,255,255,0.75), inset 0 0 5px rgba(255,255,255,0.75)`, radius 1rem. — [dev.to](https://dev.to/fabiosleal/how-to-create-the-apple-liquid-glass-effect-with-css-and-svg-2o06)
- Single-surface sizing: SwiftUI examples use `.rect(cornerRadius: 16)` but that is a usage example, not Apple's default. — [search summary, pub.dev/Medium sources](https://pub.dev/documentation/cupertino_liquid_glass/0.7.0/)

### Inferences
- Reasonable starting CSS (my synthesis, unverified against device): light Regular: `backdrop-filter: blur(~12-20px) saturate(~160-180%)`; fill white at 0.12-0.25; 1px inner rim white ~0.5-0.75 brightest top-left, fading bottom-right; soft shadow ~0 8px 32px rgba(0,0,0,0.12-0.2). Dark: fill white/black 0.05-0.15, rim white ~0.2-0.35, shadow stronger. Radii: fully round (capsule) for controls, concentric with container/device corners (Apple stresses concentricity; not verified here).
- Shadow opacity should rise when content (text) is under the glass (Apple-stated behavior), so make it a variable driven by backdrop busyness.

### Gaps
- Real iOS blur radius, saturation multiplier, rim gradient, shadow radii, corner radii, light vs dark values, tint-over-bright vs dark behavior: no authoritative source found. Needs device screenshots/pixel sampling.

## Known CSS/SVG recreations: recipes and browser limits

### Takeaway
Faithful refraction needs an SVG `feDisplacementMap` fed by a bezel-shaped displacement map, applied through `backdrop-filter: url(#f)`, which works only in Chromium. Elsewhere fall back to blur+saturate+rim highlight.

### Cited Findings
- [COMMUNITY] kube.io physics: Snell's law, air n=1 to glass n=1.5, single refraction, flat 2D shape; convex profiles (circle `y=sqrt(1-(1-x)^2)`, squircle `y=(1-(1-x)^4)^(1/4)`) keep rays inside; lip profile for switches; Apple "appears to favor convex". — [kube.io](https://kube.io/blog/liquid-glass-css-svg/)
- [COMMUNITY] kube.io pipeline: ray trace 127 samples along one radius, rotate around shape, encode `r=128+x*127, g=128+y*127, b=128, a=255` into a data-URL `<feImage>`; `<feDisplacementMap in="SourceGraphic" xChannelSelector="R" yChannelSelector="G" scale=maxDisplacement>` with `color-interpolation-filters="sRGB"`; animating `scale` fades the effect without rebuilding the map; second feImage holds specular highlight, merged via feBlend; map size must match element size. — [kube.io](https://kube.io/blog/liquid-glass-css-svg/)
- [COMMUNITY] Cheap recipe (feTurbulence): `<feTurbulence type="fractalNoise" baseFrequency="0.008 0.008" numOctaves="2" seed="92">` then `<feGaussianBlur stdDeviation="2">` then `<feDisplacementMap scale="70" xChannelSelector="R" yChannelSelector="G">`; applied as `filter:url(#lg-dist)` on a pseudo/child layer with `backdrop-filter: blur(0px)` to create the stacking context. Gives random wobble, not a true lens. — [dev.to](https://dev.to/fabiosleal/how-to-create-the-apple-liquid-glass-effect-with-css-and-svg-2o06); [Ekino/Medium search summary](https://medium.com/ekino-france/liquid-glass-in-css-and-svg-839985fcb88d)
- [COMMUNITY] Layer stack: container (overflow hidden, radius) / filter layer / tint overlay / specular inset-shadow layer / content. — [dev.to](https://dev.to/fabiosleal/how-to-create-the-apple-liquid-glass-effect-with-css-and-svg-2o06)
- Browser limits: only Chromium renders SVG filters in `backdrop-filter`; Firefox supports `blur()` only; reports of failure in Safari macOS/iOS; fallback is blur plus edge highlights. — [kube.io](https://kube.io/blog/liquid-glass-css-svg/); [Mozilla Connect request](https://connect.mozilla.org/t5/ideas/support-svg-filters-in-backdrop-filter-for-advanced-glass/m-p/98453); [dev.to roundup](https://dev.to/devyatov/liquid-glass-on-the-web-6-ways-to-build-it-with-css-and-svg-3m07)
- `backdrop-filter` affects only pixels inside the element box, so Apple's refraction that spills past edges cannot be reproduced; SVG filters can be heavy. — [LogRocket (via search summary)](https://blog.logrocket.com/how-create-liquid-glass-effects-css-and-svg/)
- Conflict: dev.to claims SVG filter/`backdrop-filter` works across Chrome, Firefox, Safari, Edge; that refers to plain `backdrop-filter: blur()` and normal `filter: url()`, not `backdrop-filter: url()`. kube.io and Mozilla Connect contradict a broader reading. — [dev.to](https://dev.to/fabiosleal/how-to-create-the-apple-liquid-glass-effect-with-css-and-svg-2o06) vs [kube.io](https://kube.io/blog/liquid-glass-css-svg/)

### Inferences
- Flutter target (this repo): Flutter has no SVG-filter path; use `BackdropFilter(ImageFilter.blur)` + saturation ColorFilter + gradient rim stroke + shadow, or a fragment shader for true lensing. HTML/CSS spec is only relevant for web prototypes or a design reference.
- For Safari/Firefox web: ship the fallback stack as default, enable the SVG `backdrop-filter:url()` layer only via `@supports`/UA check for Chromium.

### Gaps
- LogRocket and Ekino pages returned 403; their details are search-summary only. CSS-Tricks and Josh Comeau pieces not found/fetched. No verified Safari-26 behavior statement.

## Accessibility fallbacks and iOS 26.1 Tinted/Clear

### Takeaway
Reduce Transparency makes glass frostier and hides more background; Increase Contrast pushes elements toward black/white with a border; Reduce Motion lowers effect intensity and disables elastic behavior. iOS 26.1 adds a user-level Clear/Tinted switch that is separate from these.

### Cited Findings
- [APPLE] Reduce Transparency "makes Liquid Glass frostier and obscures more of the content behind it"; Increase Contrast makes elements mostly black or white with a contrasting border; Reduce Motion "decreases the intensity of some effects and disables any elastic properties"; all apply automatically system-wide. — [219 transcript](https://nonstrict.eu/wwdcindex/wwdc2025/219/)
- [COMMUNITY/press] iOS 26.1: Settings > Display & Brightness > Liquid Glass; Clear is default and maximally transparent; Tinted "reduces this default transparency to give Liquid Glass elements a more frosted look" and can improve label readability; requires iOS 26.1+. — [Fast Company SA](https://fastcompany.co.za/tech/2025-11-10-how-to-adjust-apples-liquid-glass-in-ios-26/)
- Apple wording as quoted by CNET (search summary only, page not fetchable): "Clear is more transparent, revealing the content beneath"; "Tinted increases opacity and adds more contrast". First seen in iOS 26.1 beta 4, October 2025; also iPadOS and macOS 26.1. — [Search summary of press coverage](https://m.gsmarena.com/the_latest_ios_261_beta_lets_you_tone_down_the_liquid_glass-amp-69987.php)
- Reduce Transparency lives in Settings > Accessibility > Display & Text Size and is a separate, stronger control. — [Fast Company SA](https://fastcompany.co.za/tech/2025-11-10-how-to-adjust-apples-liquid-glass-in-ios-26/)

### Inferences
- Three-tier model for the app: Clear (low fill, high blur-through), Tinted (higher fill ~0.5-0.7 plus contrast, my guess), Reduce Transparency (near-opaque frosted/solid surface). Map to `MediaQuery.disableAnimations`, `highContrast`, and platform transparency flags in Flutter.
- CSS mapping: `prefers-reduced-transparency`, `prefers-contrast: more`, `prefers-reduced-motion`.

### Gaps
- Exact opacity values for Tinted and Reduce Transparency unpublished. Apple release notes for 26.1 not fetched; no check of changes after 26.1 (late 2026) was possible.
