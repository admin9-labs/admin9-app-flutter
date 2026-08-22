# Admin9 Paired UI References

Status: G1 working reference
Evidence type: generated design reference, not App, simulator, or device output

## Purpose

These boards define the common target used to compare the current `App*`
implementation and third-party candidates. Android and iOS use the same data,
copy, state, information hierarchy, and brand-owned visual language. Platform
behavior is annotated separately and is not simulated by a static board.

The geometry and palette are reversible working values. Candidate evaluation
may change them before Demo implementation; a board is not a frozen Token file.

## Four paired scenarios

| Scenario | Same data and state | Brand-owned result | Platform behavior retained |
| --- | --- | --- | --- |
| Login and registration | `admin9@example.com`, local validation, mismatched confirmation, service unavailable | Same field labels/order, errors, button hierarchy, notice and content rhythm | IME, caret/selection, autofill/password manager, back gesture |
| Main navigation and list | Home/Account destinations, signed-in account rows, legal/support rows, list empty, and recoverable list error | Same page bar, navigation language, row/section rhythm, selected state, empty/error recovery, and danger boundary | Safe area, predictive/edge back, route transition, accessibility focus |
| Settings form | Theme, App text size, grayscale, high contrast, reduce motion | Same section/list/switch hierarchy, selected/value language and effective-state notice | Native accessibility switching, system preference signals, back gesture |
| Dialog and feedback | Action menu with normal/disabled/destructive/cancel commands, confirmation, pressed/focused/disabled controls, determinate and indeterminate loading, empty, feedback, and recoverable error | Same modal hierarchy, action order, tones, interaction states, and loading/empty/error composition | Modal focus, dismissal gesture, live-region announcement, safe area |

Generated assets:

| Scenario | Android | iOS |
| --- | --- | --- |
| Main navigation and list | [PNG](evidence/visual-references/android/account.png) / [SVG](evidence/visual-references/android/account.svg) | [PNG](evidence/visual-references/ios/account.png) / [SVG](evidence/visual-references/ios/account.svg) |
| Login and registration | [PNG](evidence/visual-references/android/auth.png) / [SVG](evidence/visual-references/android/auth.svg) | [PNG](evidence/visual-references/ios/auth.png) / [SVG](evidence/visual-references/ios/auth.svg) |
| Settings form | [PNG](evidence/visual-references/android/settings.png) / [SVG](evidence/visual-references/android/settings.svg) | [PNG](evidence/visual-references/ios/settings.png) / [SVG](evidence/visual-references/ios/settings.svg) |
| Dialog and feedback | [PNG](evidence/visual-references/android/feedback.png) / [SVG](evidence/visual-references/android/feedback.svg) | [PNG](evidence/visual-references/ios/feedback.png) / [SVG](evidence/visual-references/ios/feedback.svg) |

## State coverage

| State | Auth | Navigation/list | Settings | Dialog/feedback |
| --- | --- | --- | --- | --- |
| Light and dark | Yes | Yes | Yes | Yes |
| Standard and large text | Yes | Yes | Yes | Yes |
| Long Chinese/reflow | Two-line field errors and notice | Identity/list values and two-line recovery copy | Effective-state and persistence copy | Error and empty-state recovery copy |
| Focus/pressed | Focused account field | Not represented on static board | Not represented on static board | Pressed button and keyboard-focus ring |
| Disabled | Not represented on static board | Not represented on static board | Not represented on static board | Disabled menu command and button |
| Loading | Not represented on static board | Not represented on static board | Not represented on static board | Determinate 45% and indeterminate loading |
| Empty | Not applicable to form data | List empty state | Not applicable | Empty state shown |
| Error | Two field errors and service boundary | Recoverable list error with retry | Persistence error with retry | Persistent recoverable error with retry |

Static boards mark the state rather than proving runtime focus, animation,
reader output, or hit testing. Those move to Widget and device gates.

The verifier requires the named state labels above, dimensions, hashes, and
normalized Android/iOS structure. The SVG source, PNG rendering, and manifest
belong to one reference round. If generator source or the manifest changes,
control and every candidate must be rerun against the commit containing the new
manifest; evidence from mixed reference commits is invalid.

## Unity acceptance

Paired review passes only when a reviewer can identify both boards as the same
Admin9 product without relying on the platform label, while still being able to
use expected system gestures and capabilities in the running App.

Cross-platform pixel equality is not required. The following are failures:

- different title placement, component families, corner language, density, or
  icon styles solely because the target platform changed;
- different action order, copy, state meaning, validation, or recovery;
- platform-branded visual components that dominate the Admin9 identity;
- a “unified” custom control that breaks keyboard, autofill, safe-area,
  accessibility, or back behavior.

## Runtime matrix after implementation

- Widths: 320, 360, 390, and 600 logical pixels; phone landscape.
- Appearance: light, dark, grayscale, and high contrast.
- Text: system standard, Android 200%, iOS maximum Dynamic Type, App large and
  extra large, Bold Text, and long Chinese.
- Interaction: focus, pressed, disabled, loading, empty, error, retry, modal
  dismissal, predictive/edge back, IME next/done, and autofill.
- Accessibility: semantic role/name/value/order in Widget tests; TalkBack,
  VoiceOver, Switch Access/Control, and external keyboard on target devices.
