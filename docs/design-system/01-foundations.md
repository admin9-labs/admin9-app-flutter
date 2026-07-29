# Foundations

## 1. Color

<a id="ds-clr-001"></a>

Layer: Core for semantic relationships; Brand for the permitted accent inputs; both platforms.

Feature code MUST consume semantic roles, never raw colors. Brand Theme MAY replace `primary` and `secondary` pairs after contrast verification. It MUST NOT replace danger/error meaning, disabled relationships, focus visibility, state-layer behavior, or minimum contrast.

### Admin9 default palette

| Role | Light | On light | Dark | On dark | Brand override |
| --- | --- | --- | --- | --- | --- |
| background | `#F7F8FA` | `#171A1F` | `#111418` | `#F2F4F7` | prohibited |
| surface | `#FFFFFF` | `#171A1F` | `#191D22` | `#F2F4F7` | prohibited |
| surfaceContainer | `#EEF1F4` | `#171A1F` | `#242A31` | `#F2F4F7` | prohibited |
| primary | `#2457A7` | `#FFFFFF` | `#AFC6FF` | `#102A56` | allowed as a pair |
| secondary | `#52606D` | `#FFFFFF` | `#C4CCD5` | `#202830` | allowed as a pair |
| outline | `#687482` | n/a | `#929EAC` | n/a | prohibited |
| danger/error | `#B3261E` | `#FFFFFF` | `#FFB4AB` | `#5F1513` | prohibited |
| warning | `#714B00` | `#FFFFFF` | `#F4C06A` | `#3D2800` | prohibited |
| info | `#245A7A` | `#FFFFFF` | `#A9D1EA` | `#12384D` | prohibited |
| success | `#246B45` | `#FFFFFF` | `#8FD5AA` | `#123B25` | prohibited |
| disabled text | `#606872` on `#EEF1F4` | n/a | `#A1AAB4` on `#242A31` | n/a | prohibited |
| focus | `#2457A7` | shape + 2px ring | `#AFC6FF` | shape + 2px ring | follows primary pair |

`state layer` uses the current semantic foreground at 8% hover, 10% focus, and 10% pressed opacity. Selected state uses the platform component's indicator/marker plus label and semantics; no universal selected-opacity token overrides Material or Cupertino selection treatment. Disabled, selected, error, warning, success, grayscale, and high contrast MUST NOT rely on color alone. Brand primary replacement MUST recalculate the 2px focus ring against background, surface, and surfaceContainer in both themes, as well as primary/onPrimary.

The former `ColorScheme.fromSeed(#263238)` is **adjusted**: generated Material roles remain an implementation aid, but `#263238` is retired as a fixed Admin9 brand color. The former fixed warning/info pairs are **replaced** by the table above after contrast calculation. Current red/teal source accents are **not** Core tokens; Brand may adopt a verified accent pair.

Contrast uses WCAG relative luminance on sRGB: linearize each channel, compute `0.2126R + 0.7152G + 0.0722B`, then `(Llighter + 0.05) / (Ldarker + 0.05)`. Ordinary text MUST be at least 4.5:1; large text and critical non-text boundaries MUST be at least 3:1. Exact calculations are in [visual calibration](evidence/admin9-design-system-v1-visual-calibration.md).

## 2. Typography

<a id="ds-typ-001"></a>

The default is the platform system font; no font dependency is added. Brand MAY nominate a font only after Chinese coverage, Bold Text, maximum system size, loading cost, and fallback review.

| Semantic role | Android mapping | iOS mapping | Intended use |
| --- | --- | --- | --- |
| display | `displaySmall` | large title | rare identity/empty-state emphasis, never marketing hero text |
| pageTitle | `titleLarge` | navigation title | page bar |
| sectionTitle | `titleMedium` | section header | grouped content |
| body | `bodyLarge` | body | primary content and fields |
| supporting | `bodyMedium` | subheadline | secondary explanation |
| label | `labelLarge` | callout/semibold | buttons and controls |
| caption | `bodySmall` | footnote | metadata and footer |

The theme bridge freezes the following standard-mode base geometry. The line value is the logical line height; pages still consume semantic roles rather than writing these numbers.

| Semantic role | Android size / line / weight | iOS size / line / weight |
| --- | --- | --- |
| display | `36 / 44 / bold` | `34 / 41 / bold` |
| pageTitle | `22 / 28 / bold` | `17 / 22 / bold` |
| sectionTitle | `16 / 24 / bold` | `13 / 18 / bold` |
| body | `16 / 24 / regular` | `17 / 22 / regular` |
| supporting | `14 / 20 / regular` | `15 / 20 / regular` |
| label | `14 / 20 / semibold` | `17 / 22 / semibold` |
| caption | `12 / 16 / regular` | `12 / 16 / regular` |

Pages MUST use semantic roles, not platform point sizes. The system nonlinear `TextScaler` is the base. App modes are frozen as Standard `1.00`, Large `1.12`, and Extra Large `1.24`. For semantic base size `s`, the resolved size is `systemTextScaler.scale(s) * appFactor`. The factor is always at least `1.00`, preserves monotonic system scaling, and has no total upper cap. Phase 1 removed the former runtime `2.0` clamp; automated stress cases prove `2.0 x 1.24 = 2.48` and `3.0 x 1.24 = 3.72`.

The six visual boards use an exact `1.24` multiplier on every displayed semantic font size in the third fixture. Container height is independently content-driven: field 62lp versus 54lp, button 56lp versus 48lp, and row 72/78lp versus 52/56lp are calibration measurements, not fixed component heights. Automated rows `E`, `F`, `J`, `K`, and `L` in [the canonical matrix](06-accessibility-quality.md#ds-rsp-001) verify Extra Large, including synthetic system stress scalers. Android 200% and iOS maximum Dynamic Type remain device gates and are never inferred from the static boards.

Chinese longest labels, Bold Text, field errors, and maximum accessibility sizes MUST grow the layout, wrap, and remain reachable. Text is never shrunk to preserve a fixed control height.

Bold Text resolution is deterministic and idempotent. `display`, `pageTitle`, and `sectionTitle` retain their already-bold resolved weight; `body`, `supporting`, and `caption` resolve from regular to medium; `label` remains semibold. Applying the resolver twice MUST produce the same weight. An approved Brand font MUST provide those exact regular/medium/semibold/bold mappings. Widget tests assert every resolved role and device review verifies Chinese glyph coverage, wrapping, and clipping.

## 3. Spacing, size, and density

<a id="ds-spc-001"></a>

The Core spacing scale is frozen as `4, 8, 12, 16, 24, 32, 48`. `20` is not a reusable Core spacing token; it is the calibrated 390lp page inset and MUST remain a component/page measurement. The responsive values are:

- compact inline gap: 4 or 8;
- label-to-control and related-item gap: 8 or 12;
- page horizontal inset: 16 at 320/360, 20 at 390, 24 at 600;
- section gap: 24; major task boundary: 32;
- readable content max width: 640; forms max width: 480.

These values are v1.0 implementation requirements. Feature pages MUST NOT invent adjacent reusable values to imitate them; a page exception requires a rule-linked deviation or remains Business-owned content geometry.

Visual bounds and hit bounds are separate records. Android hit targets MUST be at least 48x48dp; iOS at least 44x44pt. Buttons and fields are not forced equal. Interactive containers use minimum constraints and content-driven growth. The former fixed 56 row and 72 navigation heights are rejected as universal tokens.

Responsive rules:

- 320/360/390: one content column; values move below labels before labels truncate.
- 600: centered content within max width; do not stretch form fields edge to edge.
- phone landscape: one scroll column for task forms and settings; actions remain reachable above/after IME.
- large text: promote horizontal rows to vertical stacks, preserve reading order, and scroll to the final operation.

## 4. Shape and elevation

The default character is restrained and work-focused. Field and inline-notice visual radius is `6`; button, dialog, sheet, and grouped Android surface radius is `8`; iOS native grouped lists retain the platform-provided shape. Brand MAY adjust the `6/8` visual character by at most 2 logical pixels through the single Brand entry after contrast and clipping review. Platform-native controls and hit regions are unaffected. The generator, visual boards, token text, and later implementation MUST use these same values.

Elevation is zero for ordinary page sections, lists, fields, and buttons. Android dialogs/sheets/navigation use Material defaults; iOS overlays use Cupertino defaults. No gradients, glassmorphism, decorative cards, nested cards, marketing-scale titles, or elevation without interaction/occlusion meaning.

## 5. Motion

<a id="ds-mot-001"></a>

| Token | Default | Curve | Reduced-motion result | Use |
| --- | --- | --- | --- | --- |
| instant | 0ms | linear | unchanged | state already represented synchronously |
| state | 120ms | easeOutCubic | 0ms | color/selection/visibility state |
| enter | 200ms | easeOutCubic | 0ms for non-navigation content | local content reveal |
| exit | 160ms | easeInCubic | 0ms for non-navigation content | local content removal |

Platform navigation transitions, Android predictive-back, and iOS edge-back builders are never replaced by reduced-motion logic. System `reduceMotion OR App preference` disables only decorative/local motion. Tests MUST assert that the platform page-transition builder remains installed.

## 6. Foundation rule verification

<a id="ds-tok-001"></a>

Palette calculations, three-page repetition, exact `1.24` text sizes, and asset dimensions are machine-reproducible. Widget tests use the single matrix in Accessibility and Quality to verify semantic token resolution, nonlinear scaling composition, hit bounds, and responsive layout. Device gates verify platform rendering, grayscale/high contrast, Bold Text, keyboard, and system gestures. Any Brand override repeats the same checks and records the derived theme hash.
