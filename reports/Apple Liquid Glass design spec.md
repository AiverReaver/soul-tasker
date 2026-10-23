# Recreating Apple's Liquid Glass faithfully in CSS

Liquid Glass is Apple's iOS 26 material, defined by **lensing**: it bends and concentrates the light behind it in real time, instead of scattering it like older blur materials ([WWDC25 219](https://nonstrict.eu/wwdcindex/wwdc2025/219/)). It is restricted to a floating functional layer (tab bars, toolbars, sheets, menus, alerts), never to content. It comes in two variants. Regular is adaptive and the default. Clear is permanently more transparent and needs a dimming layer. It reacts to touch by flexing and glowing from within, and it morphs between shapes. Apple publishes almost no numbers: no blur radius, opacity, refraction, corner radius or contrast ratio. Every pixel value in a mockup is therefore a community approximation tuned by eye, and the build spec below labels each one. A faithful 390x844 mockup needs five things: a capsule-shaped, concentric floating layer; edge refraction (an SVG displacement map, Chromium-only) or at least a rim highlight over blur and saturation; an adaptive shadow; quiet-at-rest, energised-on-press motion; and a solid fallback for Reduce Transparency, Increase Contrast and Reduce Motion. For Hearthrise's dark-fantasy look, the main risk is legibility. The material is dark, busy and ember-lit, and the critics' main complaint is text over busy content.

## Apple defines the material by physics, then restricts where it may live

Apple's press release says the material "reflects and refracts its surroundings", uses real-time rendering, and "dynamically reacts to movement with specular highlights" ([Apple Newsroom](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/)). Session 219 adds the specifics. Highlights respond to geometry and to device motion. Shadows are content-aware: opacity rises over text and falls over a solid light background. Larger glass simulates thicker material, with deeper shadows, stronger lensing and softer scattering. A chosen tint "generates a range of tones that are mapped to content brightness" beneath the element ([WWDC25 219](https://nonstrict.eu/wwdcindex/wwdc2025/219/)). Glass has no color of its own and takes it from what is behind it. Small elements such as tab bars flip between light and dark with the content, while large ones such as sidebars look more opaque and do not flip, because flipping would distract ([HIG Color](https://developer.apple.com/design/human-interface-guidelines/color), [WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)).

The placement rules are strict. Glass forms "a distinct functional layer for controls and navigation" floating above content, and the content layer uses standard materials instead. The one exception is controls with transient interactivity, such as slider and toggle thumbs, which may take a glass look only while active ([HIG Materials](https://developer.apple.com/design/human-interface-guidelines/materials)). Do not stack glass on glass. Do not mix Regular and Clear. Tint only the one primary action, by coloring its background rather than its symbol or text ([HIG Color](https://developer.apple.com/design/human-interface-guidelines/color)). Regular suits text-heavy surfaces like alerts, sidebars and popovers. Clear is for visually rich media only, and over bright content Apple prescribes a dark dimming layer at **35% opacity**, the one concrete opacity Apple states ([HIG Materials](https://developer.apple.com/design/human-interface-guidelines/materials)). Dimming is unnecessary over dark content, which suits Hearthrise. Apple also asks designers to drop custom bar backgrounds, because they fight the glass and the scroll edge effect ([Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)). The HIG pages were read through a summarizing model, so treat their wording as close paraphrase, not verbatim.

## Component rules are clear but dimensions are mostly community-measured

The tab bar floats at the bottom with items resting on a glass background. It can minimize on scroll, and the search tab can sit separated at the trailing end ([HIG Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars), [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)). Labels are single words, icons are filled SF Symbols, and the bar's background color cannot be changed in iOS 26 per Apple staff ([Forum 796986](https://developer.apple.com/forums/thread/796986)). The only dimensions come from the community: a **62 pt bar inside an 83 pt wrapper** ([Forum 796986](https://developer.apple.com/forums/thread/796986)), a capsule inset **21 pt** from left, right and bottom, and 11 pt labels ([LearnUI](https://learnui.design/blog/ios-design-guidelines-templates.html)). At 390 pt that gives a capsule about 348 pt wide, with radius 31 (half its height). This is derived arithmetic, not an Apple number.

Toolbars and navigation bars drop their backgrounds. Items sit in floating glass groups, about three groups at most, with one prominent tinted primary action trailing. Apple replaces hard dividers with a **scroll edge effect**: soft (a gradual variable blur, the iOS default) or hard (more opaque with a defined edge). Use one per view, and it is not decorative ([HIG Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars), [HIG Scroll views](https://developer.apple.com/design/human-interface-guidelines/scroll-views), [WWDC25 356](https://developer.apple.com/videos/play/wwdc2025/356/)). Sheets use a grabber, medium and large detents, and an inset half sheet with rounder corners. Alerts and popovers use Regular glass. Alerts have a title of about two lines, up to three buttons, and one-to-two-word verb titles ([HIG Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets), [HIG Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts)). Apple published no values for sheet radius, menu width or alert radius.

Geometry follows **concentricity**: a capsule's radius is half its height, and a nested shape's radius is the parent radius minus the padding ([WWDC25 356](https://developer.apple.com/videos/play/wwdc2025/356/)). Hit targets are at least 44x44 pt, and prominent buttons are limited to one or two per view ([HIG Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)). Type uses SF Pro text styles: Large Title 34/41, Headline 17/22 semibold, Body 17/22, Footnote 13/18, Caption2 11/13. Avoid Ultralight, Thin and Light weights, and use vibrant labels on materials ([HIG Typography](https://developer.apple.com/design/human-interface-guidelines/typography), [HIG Materials](https://developer.apple.com/design/human-interface-guidelines/materials)). The base-class canvas is 390x844 pt ([LearnUI](https://learnui.design/blog/ios-design-guidelines-templates.html)). Safe-area figures (status bar 47 pt, home-indicator area 34 pt, device corner radius about 47 pt) come from memory and are not source-confirmed. Verify them in Apple's Figma kit, which was not accessible here.

## Faithful web recreation hinges on an SVG displacement map that only Chromium renders

The best-documented recipe is from kube.io. It models single refraction with Snell's law (air n=1, glass n=1.5) over a convex bezel profile such as a squircle, `y=(1-(1-x)^4)^(1/4)`, and notes that Apple "appears to favor convex". It ray-traces 127 samples along a radius, rotates them around the shape, and encodes the displacement as `r=128+x*127, g=128+y*127, b=128` in a data-URL `feImage`. That feeds an `feDisplacementMap` with `xChannelSelector="R"`, `yChannelSelector="G"`, `color-interpolation-filters="sRGB"` and `scale` equal to the maximum displacement. A second `feImage` carries the specular rim, with a default light angle of -60 degrees, blended on top. Animating `scale` fades the lens without rebuilding the map. The map size must match the element size ([kube.io](https://kube.io/blog/liquid-glass-css-svg/)). The cheaper `feTurbulence` recipe (`baseFrequency 0.008`, `numOctaves 2`, blur `stdDeviation 2`, displacement `scale 70`) yields a random wobble, not a lens, so it reads as a gimmick ([dev.to](https://dev.to/fabiosleal/how-to-create-the-apple-liquid-glass-effect-with-css-and-svg-2o06)).

The hard limit is `backdrop-filter: url(#filter)`, which works only in Chromium. Firefox supports `blur()` only, and Safari reports are negative ([kube.io](https://kube.io/blog/liquid-glass-css-svg/), [Mozilla Connect](https://connect.mozilla.org/t5/ideas/support-svg-filters-in-backdrop-filter-for-advanced-glass/m-p/98453)). One source claims cross-browser support, but it conflates plain `backdrop-filter: blur()` with the SVG-filter variant, and the others contradict the broad reading ([dev.to](https://dev.to/fabiosleal/how-to-create-the-apple-liquid-glass-effect-with-css-and-svg-2o06)). The backdrop filter also acts only inside the element box, so Apple's refraction that spills past the edges cannot be reproduced ([LogRocket](https://blog.logrocket.com/how-create-liquid-glass-effects-css-and-svg/), via search summary). The practical rule is to ship blur, saturation and a rim highlight as the default, and add the SVG layer under `@supports` or a Chromium check. Without refraction and a responsive specular rim, the result is ordinary glassmorphism (flat blur, translucent fill, hairline border) rather than Liquid Glass ([LogRocket](https://blog.logrocket.com/how-create-liquid-glass-effects-css-and-svg/), [liquid-glass-js](https://cdn.jsdelivr.net/npm/liquid-glass-js@0.1.0/README.md)).

## Motion should be quiet at rest, elastic on touch, and fully disableable

Apple describes motion only qualitatively. Glass does not fade; it "materializes" by modulating lensing. On touch it "instantly flexes and energizes with light", illuminates from within, and the glow can spread to nearby glass. Controls can lift into glass only while touched, and menus pop open from the tapped control ([WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)). No durations, easings or spring constants are published. The only figures are one community SwiftUI example (spring response about 0.4, damping fraction 0.8) and a guess of press scale 1.03-1.08. Both are tunables, not specs ([Medium](https://medium.com/@veersr9/ios-26-liquid-glass-in-swiftui-a-practical-reference-demo-app-liquidglassreference-69b8d46dc055)). The tab bar's minimize behavior (`tabBarMinimizeBehavior`, shrinking to the selected icon) has no published timing either ([Apple docs](https://developer.apple.com/tutorials/data/documentation/swiftui/view/tabbarminimizebehavior(_:).md)). In CSS, "materialize" means animating blur and displacement strength, and morphing means animating geometry (an SVG gooey blur-plus-threshold filter is a plausible web analogue), not crossfading. This is my inference, not an Apple statement.

Nielsen Norman Group's critique lists the motions to avoid: unprompted morphing, tab bars that "bubble and wiggle", and shimmer while scrolling. It links them to fatigue and nausea ([NN/g](https://www.nngroup.com/articles/liquid-glass/)). Do not add ambient animation.

## Accessibility fallbacks are three system switches plus a user opacity choice

Apple states three automatic fallbacks. Reduce Transparency "makes Liquid Glass frostier and obscures more of the content behind it". Increase Contrast makes elements mostly black or white with a contrasting border. Reduce Motion "decreases the intensity of some effects and disables any elastic properties" ([WWDC25 219](https://nonstrict.eu/wwdcindex/wwdc2025/219/)). The web equivalents are `prefers-reduced-transparency`, `prefers-contrast: more` and `prefers-reduced-motion`. Apple has since conceded that default transparency was too much. Beta 3 went frostier, beta 4 restored translucency, and iOS 26.1 added Settings > Display & Brightness > Liquid Glass, with Clear as the default and Tinted adding opacity and contrast ([9to5Mac](https://9to5mac.com/2025/10/20/ios-26-1-beta-4-adds-new-setting-to-tone-down-liquid-glass-transparency/), [Fast Company SA](https://fastcompany.co.za/tech/2025-11-10-how-to-adjust-apples-liquid-glass-in-ios-26/)). Exact opacity values for Tinted and Reduce Transparency are unpublished.

The documented failures are concrete. Examples are text over patterned wallpaper, a Mail search bar over previews, Maps icons lost in photos, smaller crowded tap targets, and hidden or relocated controls ([NN/g](https://www.nngroup.com/articles/liquid-glass/)). One audit cites contrast as low as 1.5:1, but its method is unstated, so treat that as anecdotal ([Infinum](https://infinum.com/blog/apples-ios-26-liquid-glass-sleek-shiny-and-questionably-accessible/)). Another found default bottom-icon contrast failing the WCAG 3:1 non-text threshold ([Medium audit](https://svetanaumova.medium.com/a-brief-ux-audit-apple-ios-26-liquid-glass-de24e6899204)). No controlled measurements exist. The implication for the mockup is to scrim the worst-case backdrop under every label, aim for at least 4.5:1 for text and 3:1 for icons, and verify by sampling pixels. Offer the solid variant as a first-class state, not an afterthought.

## Build spec: concrete values for a 390x844 Hearthrise mockup

Labels: **[APPLE]** stated by Apple. **[COMMUNITY]** third-party or single-source approximation. **[DERIVED]** arithmetic from the above. **[TUNE]** my starting value; Apple publishes nothing, so match by eye against a device or the Figma kit. **[UNVERIFIED]** from memory or an unread source.

**Canvas and structure**

| Item | Value | Label |
|---|---|---|
| Frame | 390x844, one flat dark content layer, glass only on tab bar, nav buttons, FAB or search, sheet, menu and alert chrome | [COMMUNITY] size, [APPLE] placement |
| Status bar / home area / device radius | 47 / 34 / ~47 px | [UNVERIFIED] |
| Content cards and list rows | Opaque, no glass | [APPLE] |
| Glass on glass | Never nest; Regular and Clear never mixed | [APPLE] |

**Material tokens (dark, Regular)**

```css
.glass{
  position:relative; overflow:hidden; isolation:isolate;
  border-radius:var(--r);                 /* capsule = height/2 [APPLE]; nested = parent - padding [APPLE] */
  background:rgba(255,255,255,.08);       /* [TUNE] dark fill 0.05-0.15 */
  backdrop-filter:blur(16px) saturate(170%);/* [TUNE] blur 12-20, saturate 160-180 (community est. 10-20% boost) */
  -webkit-backdrop-filter:blur(16px) saturate(170%);
  box-shadow:
    inset 1px 1px 0 rgba(255,255,255,.30), /* top-left rim [TUNE], light-mode community recipe uses .75 */
    inset 0 0 6px rgba(255,255,255,.12),
    0 8px 32px rgba(0,0,0,.35);           /* [TUNE] drop; raise toward .5 over text, lower over flat bg [APPLE behavior] */
}
.glass::after{content:"";position:absolute;inset:0;border-radius:inherit;pointer-events:none;
  background:linear-gradient(135deg,rgba(255,255,255,.22),rgba(255,255,255,0) 40%,rgba(255,255,255,0) 60%,rgba(255,255,255,.10));
  mix-blend-mode:screen}                  /* rim gradient, brightest top-left [COMMUNITY -60deg light] */
```

Size scaling is **[APPLE]**: larger glass gets a deeper shadow (for example `0 16px 48px`) and stronger refraction. Clear variant is **[TUNE]**: fill .03, blur 2-4px, with a **35% black** dimming layer only if the backdrop is bright (**[APPLE]** 35%). On Hearthrise's dark backdrops no dimming is needed (**[APPLE]**). Never use fully clear glass under text.

**Refraction layer (Chromium only, progressive enhancement)**

```css
@supports (backdrop-filter:url(#lens)) { .glass.lens{ backdrop-filter:url(#lens) blur(2px) saturate(170%);} }
```

The SVG uses an `feImage` data-URL displacement map from a convex squircle bezel, `feDisplacementMap` with R/G channels, `color-interpolation-filters="sRGB"` and `scale` about 20-40 for a 62 px bar, plus a second `feImage` specular with `feBlend` (**[COMMUNITY]** pipeline; scale is **[TUNE]**). Map size must equal element size. The centre stays flat and the distortion lives in the bezel. Test the fallback in Safari or Firefox, since this layer will not render there (**[COMMUNITY]**). Add slight chromatic aberration by offsetting R/B displacement scales (**[COMMUNITY]**, liquid-glass-js).

**Components**

| Component | Spec | Label |
|---|---|---|
| Tab bar | Capsule 348x62, left/right/bottom inset 21, radius 31, 11 px labels, filled icons, single-word labels, selected pill inside the capsule, no custom background | [COMMUNITY]/[DERIVED], [APPLE] rules; pill and icon size [TUNE] (icon ~24, pill inset ~4) |
| Nav buttons | Glass circles, >=44x44 hit area, floating with no bar behind; at most 3 groups; one prominent tinted trailing action | hit size [APPLE]; diameter [TUNE] (44) |
| Large title / inline title | 34 bold / 17 semibold; toolbar labels 17 medium | [COMMUNITY] |
| Scroll edge | Soft: a 24-40 px gradient from `rgba(bg,.9)` to 0 plus progressive blur mask, instead of a divider line; one per view | concept [APPLE]; numbers [TUNE] |
| Primary tint | One per screen, tint the glass background, label stays white. Example ember `rgba(255,140,60,.55)` over the same blur | rule [APPLE]; color [TUNE] |
| Sheet | Inset half sheet, grabber, medium and large detents, radius ~32-40, Cancel leading / Done trailing | detents/grabber [APPLE]; radius [TUNE] |
| Menu / popover / alert | Regular glass, popping from the source control; alert title max 2 lines, <=3 buttons, verb titles; width ~270 | rules [APPLE]; dimensions [TUNE] |
| Toggle / slider | Flat at rest; thumb gains glass only while pressed | [APPLE] |
| Spacing | Keep gaps >= 8 px between glass items; concentric radii | [TUNE] |

**Motion tokens (all [TUNE], Apple publishes none)**

- Press: scale 1.04, brightness +10%, inner glow `radial-gradient` at the touch point, using `cubic-bezier(.34,1.56,.64,1)` over about 350 ms. This approximates a spring with response 0.4 and damping 0.8 (**[COMMUNITY]** example).
- Release: spring back with the same curve. Resting state has no animation, shimmer or looping effects.
- Neighbour glow: raise the adjacent glass rim opacity +0.1 for about 300 ms (**[APPLE]** concept).
- Materialize and dismiss: animate the displacement `scale` and blur from 0, not just opacity (**[APPLE]** concept, **[COMMUNITY]** method).
- Morph: animate width, radius and position of one element; optionally use a gooey filter between neighbours (**[TUNE]**).

**Accessibility variants (all required states)**

```css
@media (prefers-reduced-transparency:reduce){
  .glass{background:rgba(28,22,20,.92);backdrop-filter:blur(30px) saturate(120%)} .glass.lens{backdrop-filter:blur(30px)}} /* frostier [APPLE]; values [TUNE] */
@media (prefers-contrast:more){
  .glass{background:#14100e;backdrop-filter:none;box-shadow:inset 0 0 0 1.5px #fff,0 4px 16px rgba(0,0,0,.5)}} /* black/white + contrasting border [APPLE]; values [TUNE] */
@media (prefers-reduced-motion:reduce){
  .glass{transition:none}.glass:active{transform:none}}                     /* no elastic [APPLE] */
```

Also provide a user toggle with a Tinted setting (fill about .5-.65 plus a stronger rim), modeled on iOS 26.1. Apple publishes no value for it, so this is **[TUNE]**.

**Legibility pitfalls checklist**

- Text on glass must sit over a scrimmed worst-case backdrop. Target >=4.5:1 for text and >=3:1 for icons ([WCAG baseline via letsdev](https://letsdev.de/en/blog/ios-26-in-detail-liquid-glass-ui-between-usability-and-accessibility), opinion), and pixel-sample the worst frames.
- Avoid steady-state intersections of text and glass edges ([WWDC25 219](https://developer.apple.com/videos/play/wwdc2025/219/)).
- Do not use Thin, Light or Ultralight weights, tint several controls, or add custom bar backgrounds.
- Keep targets >=44 pt and do not hide controls behind glass or gestures.
- Verify at 200% text size that labels do not collide with glass edges.
- Use warm-neutral content under the bars. Ember glow from the dark-fantasy scene bleeds through the saturate(170%) boost, so check that the glass does not oversaturate.

## Conclusion

The research shows a sharp split. Apple specifies Liquid Glass's physics, placement rules, variants, concentricity and fallbacks precisely in words, but its numbers (blur, opacity, radii, timing, contrast) exist only as community approximation. A "faithful" mockup is therefore a disciplined structure (floating capsule layer, flat content, one tint, concentric shapes) tuned by eye. The test is whether it shows edge refraction, a light-responsive rim and a press response. Without those it is glassmorphism, however much blur it uses.

For Hearthrise, the dark backdrop is a gift: Apple itself says dimming is unnecessary over dark content, and the dark-mode rim and shadow tokens are the least contested part of the community recipe. The open work is empirical: sample real iOS 26 screenshots or Apple's Figma kit to replace the **[TUNE]** values, confirm the safe-area **[UNVERIFIED]** numbers, and test the Chromium-only refraction layer against its fallback. Also check whether the shipped Settings > Display & Brightness > Liquid Glass options changed after 26.1, which this research could not confirm.
