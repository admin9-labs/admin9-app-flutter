# Accessibility, Quality, and Governance

## 1. Non-negotiable gates

<a id="ds-acc-001"></a>
<a id="ds-acc-002"></a>

| Area | MUST pass | Evidence |
| --- | --- | --- |
| contrast | ordinary text 4.5:1; large text and critical non-text boundaries 3:1 | reproducible color-pair table plus rendered review |
| hit targets | Android 48x48dp; iOS 44x44pt | Widget geometry plus device spot check; visual and hit bounds separate |
| system text | nonlinear system scaling preserved; App options only add growth | 320/360/390/600 and landscape Widget matrix; Android 200%; iOS max accessibility size |
| semantics | correct name, role, value, enabled, selected/toggled, error, action, live region | semantics tests and reader walkthrough |
| focus/keyboard | visual, focus, and reading order match; visible focus; next/done; first error | Widget/integration plus hardware/software keyboard |
| system appearance | brightness, Bold Text, high contrast, reduce motion, grayscale merge correctly | effective-state tests and device settings |
| state meaning | not color-only; errors and unavailable states explain recovery/boundary | Widget/visual review |

Theme brightness is: when App preference is `system`, use current system brightness; when App preference is explicit `light` or `dark`, use that App choice. Only the App theme enum persists. System Bold Text always takes effect and has no App off switch; any approved Brand font must respond to it. High contrast effective value is `system OR App`. Reduce motion effective value is `system OR App`; it does not replace platform navigation builders. Grayscale controls only the App filter and cannot negate OS display adjustments. Only App preferences persist; all system values are transient inputs.

## 2. Automated matrix

<a id="ds-rsp-001"></a>

The following table is the one canonical minimum automated layout matrix. `System 1.0/2.0/3.0` means a deterministic test `TextScaler`, not claimed Android/iOS device evidence. Every implemented Core component runs A-L; a component without text still proves bounds, focus, and state at each row. Reference page-pattern fixtures also run A-L. Component-specific variants and callbacks are additional tests, not replacements.

| Row | Platform | Canvas | Theme | Contrast | App mode/factor | Test system scaler | Required stress |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A | Android | 320x720 | light | standard | Standard/1.00 | 1.0 | longest label and trailing value stack |
| B | iOS | 320x720 | light | standard | Extra Large/1.24 | 1.0 | disclosure and action reachability |
| C | Android | 360x800 | dark | standard | Large/1.12 | 1.0 | error growth and disabled state |
| D | iOS | 360x800 | dark | standard | Standard/1.00 | 1.0 | grouped list and selected trait |
| E | Android | 390x844 | light | standard | Extra Large/1.24 | 1.0 | exact visual-calibration fixture |
| F | iOS | 390x844 | dark | standard | Extra Large/1.24 | 1.0 | dark Extra Large automated/Golden case |
| G | Android | 600x960 | dark | high | Standard/1.00 | 1.0 | max-width and non-color states |
| H | iOS | 600x960 | light | high | Large/1.12 | 1.0 | max-width and focus visibility |
| I | Android | 844x390 | light | standard | Large/1.12 | 1.0 | IME inset, scroll endpoint, primary action |
| J | iOS | 844x390 | dark | standard | Extra Large/1.24 | 1.0 | focus, first error, scroll endpoint |
| K | Android | 390x844 | light | high | Extra Large/1.24 | 2.0 | synthetic 200% system stress; no total cap |
| L | iOS | 390x844 | dark | high | Extra Large/1.24 | 3.0 | synthetic extreme stress; no Dynamic Type claim |

Acceptance is no overflow, crop, overlap, hidden action, lost scroll endpoint, or forced text shrink. The test report records the exact combination table so a missing required case fails the gate.

Target-platform tests assert Android/iOS bottom implementation types only inside Design System tests. Business tests use keys, visible text, semantics, callbacks, and state results. Import boundaries use analyzer AST directives and a declaration allowlist, not text search. Phase 0D immediately rejects Core imports of App/Business, Core-internal imports outside Core/the public barrel, cross-feature implementation imports, Business imports of App internals except the exact route-name/App-identity allowlist, private `package:flutter/src` imports, and Business platform/Core/App re-exports. The public barrel must equal its phase-specific exact export allowlist. These Business rules cover both `lib/ui/features/**` and `lib/ui/shared/**`. Existing Business Material/Core debt is stored as an exact path-plus-canonical-URI baseline: additions and stale entries both fail. Business may import `package:flutter/widgets.dart` only with an explicit `show` list contained in the frozen non-interactive declaration allowlist. Positive and exact negative fixtures are mandatory. The same validator's `--phase=final` mode requires the legacy baseline to be empty and becomes a hard repository gate in Phase 5 after migration. This staged enforcement records existing debt without pretending it is already migrated.

The App host has exact Core-internal seams, each represented by one analyzer-AST allowlist pair. `admin9_app.dart` may import the feedback and interaction presenters, theme resolver, effective-appearance resolver, and appearance-controller implementation. `app_routes.dart` may import the theme resolver, Gallery registry, and Gallery page. No directory wildcard is allowed. These internal mechanisms remain absent from `lib/admin9_ui.dart`, so Business cannot bypass the Brand entry, resolve host-only appearance state, or register debug tooling.

Phase 5 freezes representative Goldens for A, F, G, and L plus component-specific critical states; earlier phases run the same matrix as value, layout, and interaction tests without calling those results Golden evidence. Goldens do not replace semantics, computed contrast, interaction tests, or devices. Gallery has one route-registry seam guarded by `!kReleaseMode`: Phase 0D proves the registry contract and that it is absent from the public barrel; it does not create a Gallery page. Phase 1 adds the real debug/profile route, a profile integration test proving reachability, `flutter build apk --release`, and an installed release deep-link/menu reachability test proving absence. Until those Phase 1 checks pass, release exclusion remains Unknown rather than Pass.

<a id="ds-gal-001"></a>

## 3. AppFeedback matrix

Widget tests cover info/success 3-second and warning/error 5-second dismissal when no action exists and `accessibleNavigation == false`. Separate cases cover action and `accessibleNavigation == true` persistence; visible close; action exactly once; replacement by a new message; live-region announcement once; no focus stealing; and close/action hit bounds. Tests MUST NOT use `semanticsEnabled` as a persistence proxy. Device readers confirm announcement, operability, and whether the platform sets the accessibility-navigation signal; absent device evidence remains Unknown.

## 4. Platform device gates

Android API 34+ predictive back is a manual hard gate: record gesture start, visible progress, cancellation, and completion; cancellation preserves state and completion pops once. Repeat core regression on API 36. Integration tests only assert application state before/after back and MUST NOT claim system-gesture evidence.

iOS requires current Xcode-available small and regular simulators with model, runtime, and logical width recorded; do not invent a 320pt simulator. Record short edge swipe cancel and full completion, route state, keyboard, picker/dialog, and safe areas.

Device walkthroughs include:

- Android: TalkBack, Switch Access, 200% text, hardware keyboard, IME/autofill, gesture/three-button navigation, cutout, edge-to-edge and system-bar contrast.
- iOS: VoiceOver, Switch Control, maximum Dynamic Type, Bold Text, Increase Contrast, Reduce Motion, software/hardware keyboard, autofill/password manager, home indicator and edge back.
- Both: light/dark, grayscale, high contrast, reduced motion, hit-target spot checks, both reference flows, scroll endpoints, errors, dialogs, notices, and feedback.

## 5. SDK upgrade review

<a id="ds-upg-001"></a>

After every Flutter SDK upgrade, recheck Material/Cupertino constructor signatures and defaults, PageTransitionsTheme, predictive-back integration, edge-to-edge/target SDK behavior, deprecations, nonlinear TextScaler, Semantics, hit-target defaults, locale delegates, Gallery release exclusion, Goldens, and all declaration probes. Upgrade evidence names Flutter/Dart versions and device runtimes.

## 6. PR and derived-project checklist

- change belongs to Core, Brand, or Business and follows ownership/import rules;
- public contract and changelog updated when applicable;
- no feature platform branch, raw interactive platform control, raw color, fixed text cap, or business dependency in Core;
- Android/iOS mapping, semantics, responsive, contrast, and hit bounds tested;
- Gallery state added only for shared component/pattern behavior;
- required device gates run or recorded Unknown with an owner and phase;
- deviation record added/updated; no expired deviations;
- source provenance and Design System version remain accurate.

## 7. Deviation record

<a id="ds-dev-001"></a>

A deviation includes rule ID, reason, affected platforms/apps, owner, approving Core maintainer, evidence, user/accessibility impact, start date, expiry, and removal condition. Expired deviations fail acceptance. A deviation cannot lower system accessibility or platform navigation requirements.

## 8. Current Unknowns

Phase 1 has verified Flutter token resolution, nonlinear TextScaler composition, runtime system-preference merging, debug/profile Gallery reachability, and Gallery exclusion from the installed Android release package. These results are no longer Unknown and remain protected by the Phase 1 automated and release-package gates.

Concrete component bounds and Semantics, full-page maximum-size layout, device appearance, screen readers/Switch Access/Switch Control, IME/autofill, Android predictive back, iOS edge back, and cutout/system-bar behavior remain Unknown until their owning implementation and device phases. Static assets and documents do not satisfy those gates.
