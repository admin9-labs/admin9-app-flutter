# Admin9 Design System v1.0 Visual Calibration

> **Historical evidence:** This v1.0 snapshot preserves its original values.
> It is not a current Admin9 App Starter specification, compatibility promise,
> or rule for independent forks.

## 1. Asset entry

Each board is a 2400x1200 PNG with matching generated SVG source. It contains four 390 logical-pixel fixtures: light/Standard baseline, dark/Standard of the same baseline state, light/App Extra Large `1.24 x system standard`, and one light/Standard page-specific alternate state. Every asset says “design reference” and is not a current App, simulator, or device screenshot.

| Page | Android | iOS | Covered states |
| --- | --- | --- | --- |
| Personal center | [PNG](visual-references/android/account.png) / [SVG](visual-references/android/account.svg) | [PNG](visual-references/ios/account.png) / [SVG](visual-references/ios/account.svg) | guest, signed-in sample, missing identity field, large-text danger endpoint |
| Authentication | [PNG](visual-references/android/auth.png) / [SVG](visual-references/android/auth.svg) | [PNG](visual-references/ios/auth.png) / [SVG](visual-references/ios/auth.svg) | register, login comparison, field errors, unavailable notice, focus/hit annotations |
| Settings | [PNG](visual-references/android/settings.png) / [SVG](visual-references/android/settings.svg) | [PNG](visual-references/ios/settings.png) / [SVG](visual-references/ios/settings.svg) | defaults, radio/checkmark selection, system/App conflict, switches |

## 2. Repeated rules versus page exceptions

Repeated across all three pages and both platforms: semantic palette, system type roles, one-column task layout, 20lp 390-width inset, 6lp field/notice radius, 8lp action/group radius, 24lp section rhythm, explicit state text, visual/hit-bound separation, content-driven growth, and 640/480 maximum-width rules.

Page exceptions: identity summary and danger endpoint; auth field schema, errors, route-local draft and unavailable business result; settings system/App effective-state explanation. These do not become tokens or generic components.

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

Visual fields measure 54lp at Standard and grow to 62lp in the `1.24` fixture; main buttons measure 48lp and grow to 56lp. They intentionally are not equal-height tokens. Standard 16 text becomes 19.84, 14 becomes 17.36, 13 becomes 16.12, and bottom-navigation label 11 becomes 13.64 in the third fixture. OS status-bar text and board annotations are evidence chrome, not App semantic roles, and are intentionally excluded. Rows grow from Android 56/iOS 52 to 72lp; settings rows use 78lp where trailing controls need additional separation. These are calibration measurements proving rhythm and content growth, not fixed runtime component heights. Dashed overlays sample primary, secondary, password-toggle, switch, and bottom-navigation hit bounds; row and back-action full geometry remains a mandatory Widget/device measurement rather than a claim made from static coordinates. Static coordinates are not runtime evidence.

320/360 move trailing values below labels before truncation; 390 uses the reference fixture; 600 centers page content within 640 and forms within 480; phone landscape remains a scrollable single task. Full extra-width and landscape high-fidelity permutations are intentionally not produced. Widget canvases and devices later prove actual layout.

Focus and expected reading order follow visible order: back, title, page content, primary action, secondary actions, notices, then later sections. Route-entry title announcement does not force keyboard focus. Selection exposes selected state; switches expose App preference while adjacent text explains system and effective state. Personal-center boards show Android `NavigationBar` intent and iOS `CupertinoTabBar` intent with selected/unselected roles, minimum hit bounds, bottom safe-area position, and no overlap with the scrolled danger endpoint. Authentication boards include both flow-switch and account-recovery secondary actions where applicable. The six boards were visually inspected at 2400x1200 after regeneration; no text crop, overlap, control loss, or Android/iOS color-swap imitation was observed.

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

The checked [asset manifest](visual-references/visual-assets.json) records dimensions, byte sizes, SHA-256, generator, and reproduction commands for all 12 SVG/PNG assets. The verifier fails on missing required labels, stale hashes, or any dimension other than 2400x1200.
