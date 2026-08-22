# Admin9 UI Unification Visual Calibration

> **Working G1 evidence:** These generated boards are a reversible visual
> comparison fixture for the Demo-first UI unification initiative. They are not
> current App, simulator, or device screenshots and do not freeze final Tokens.

## 1. Asset entry

Each board is a 2400x1200 PNG with matching generated SVG source. It contains
four 390 logical-pixel fixtures: light/Standard baseline, dark/Standard of the
same baseline state, light/App Extra Large `1.24 x system standard`, and one
light/Standard page-specific alternate state. Android and iOS use one Admin9
visible contract; system interaction differences are annotated for separate
runtime acceptance.

| Page | Android | iOS | Covered states |
| --- | --- | --- | --- |
| Main navigation and list | [PNG](visual-references/android/account.png) / [SVG](visual-references/android/account.svg) | [PNG](visual-references/ios/account.png) / [SVG](visual-references/ios/account.svg) | guest, signed-in sample, missing identity field, selected navigation, large-text danger endpoint |
| Login and registration | [PNG](visual-references/android/auth.png) / [SVG](visual-references/android/auth.svg) | [PNG](visual-references/ios/auth.png) / [SVG](visual-references/ios/auth.svg) | register, login comparison, field errors, unavailable notice, focus/hit annotations |
| Settings form | [PNG](visual-references/android/settings.png) / [SVG](visual-references/android/settings.svg) | [PNG](visual-references/ios/settings.png) / [SVG](visual-references/ios/settings.svg) | defaults, selected choice, system/App conflict, switches |
| Dialog and feedback | [PNG](visual-references/android/feedback.png) / [SVG](visual-references/android/feedback.svg) | [PNG](visual-references/ios/feedback.png) / [SVG](visual-references/ios/feedback.svg) | confirmation, long text, loading, empty, recoverable error, disabled command |

## 2. Repeated rules versus page exceptions

Repeated across all four scenarios and both platforms: semantic palette,
semantic type roles, page-bar hierarchy, visible control language, one-column
task layout, section rhythm, explicit state text, visual/hit-bound separation,
content-driven growth, and 640/480 maximum-width rules.

Scenario exceptions: identity summary and danger endpoint; auth field schema,
errors, route-local draft and unavailable result; settings system/App
effective-state explanation; dialog modality and feedback timing. These do not
automatically become Tokens or generic components.

## 3. Contrast calculation

Method: WCAG sRGB relative luminance as specified in Foundations. Values below are calculated from exact hex pairs; `Pass` means the frozen color pair meets the mathematical target, not that Flutter/device output has passed.

| Pair | Ratio | Target | Result |
| --- | --- | --- | --- |
| light text/background | 16.41:1 | 4.5 | Pass |
| light text/surface | 17.44:1 | 4.5 | Pass |
| light primary/onPrimary | 7.01:1 | 4.5 | Pass |
| light secondary/onSecondary | 6.46:1 | 4.5 | Pass |
| light outline/surface | 4.76:1 | 3.0 | Pass |
| light danger/onDanger | 6.54:1 | 4.5 | Pass |
| light warning/onWarning | 7.75:1 | 4.5 | Pass |
| light info/onInfo | 7.45:1 | 4.5 | Pass |
| light success/onSuccess | 6.43:1 | 4.5 | Pass |
| light disabled text/container | 4.98:1 | 4.5 | Pass |
| dark text/background | 16.76:1 | 4.5 | Pass |
| dark text/surface | 15.37:1 | 4.5 | Pass |
| dark primary/onPrimary | 8.30:1 | 4.5 | Pass |
| dark secondary/onSecondary | 9.20:1 | 4.5 | Pass |
| dark outline/surface | 6.22:1 | 3.0 | Pass |
| dark danger/onDanger | 7.71:1 | 4.5 | Pass |
| dark warning/onWarning | 8.39:1 | 4.5 | Pass |
| dark info/onInfo | 7.65:1 | 4.5 | Pass |
| dark success/onSuccess | 7.31:1 | 4.5 | Pass |
| dark disabled text/container | 6.15:1 | 4.5 | Pass |
| light focus/background | 6.60:1 | 3.0 | Pass |
| light focus/surface | 7.01:1 | 3.0 | Pass |
| light focus/surfaceContainer | 6.18:1 | 3.0 | Pass |
| dark focus/background | 10.86:1 | 3.0 | Pass |
| dark focus/surface | 9.95:1 | 3.0 | Pass |
| dark focus/surfaceContainer | 8.51:1 | 3.0 | Pass |

Pressed/focus state-layer composites require post-composite calculation in implementation and remain Unknown; the solid 2px focus-ring pairs above are calculated. High-contrast resolved colors, grayscale rendering, and device antialiasing remain Unknown.

## 4. Bounds and responsive calibration

Visual fields measure 54lp at Standard and grow to 62lp in the `1.24`
fixture; main buttons measure 48lp and grow to 56lp. Rows start at 56lp and
grow to 72lp; settings rows use 78lp where trailing controls need additional
separation. These are replaceable fixture measurements proving rhythm and
content growth, not fixed runtime Tokens. OS status-bar text and board
annotations are evidence chrome, not App semantic roles. Dashed overlays sample
primary, secondary, password-toggle, switch, modal action, and bottom-navigation
hit bounds. Static coordinates are not runtime evidence.

320/360 move trailing values below labels before truncation; 390 uses the reference fixture; 600 centers page content within 640 and forms within 480; phone landscape remains a scrollable single task. Full extra-width and landscape high-fidelity permutations are intentionally not produced. Widget canvases and devices later prove actual layout.

Focus and expected reading order follow visible order: back, title, page
content, primary action, secondary actions, notices, then later sections.
Route-entry title announcement does not force keyboard focus. Selection exposes
selected state; switches expose App preference while adjacent text explains
system and effective state. The navigation boards preserve selected/unselected
roles and separate Android 48dp from iOS 44pt hit gates without changing the
visible family. Dialog boards keep business hierarchy aligned while leaving
modal focus, dismissal, back, safe-area, and reader behavior to runtime gates.
All eight boards were visually inspected at 2400x1200 after regeneration; no
text crop, overlap, control loss, or platform color-swap imitation was observed.

## 5. Reproduction and integrity

The source generator is [generate_visual_references.mjs](sources/generate_visual_references.mjs). Run:

```bash
node docs/design-system/evidence/sources/generate_visual_references.mjs docs/design-system/evidence/visual-references
for f in docs/design-system/evidence/visual-references/*/*.svg; do
  sips -s format png "$f" --out "${f%.svg}.png"
done
node docs/design-system/evidence/sources/verify_visual_references.mjs docs/design-system/evidence/visual-references --write
node docs/design-system/evidence/sources/verify_visual_references.mjs docs/design-system/evidence/visual-references
```

The checked [asset manifest](visual-references/visual-assets.json) records
dimensions, byte sizes, SHA-256, generator, and reproduction commands for all
16 SVG/PNG assets. The verifier fails on missing required labels, stale hashes,
or any dimension other than 2400x1200.
