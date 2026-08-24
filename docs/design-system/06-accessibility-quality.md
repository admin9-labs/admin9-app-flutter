# Accessibility, Quality, And Governance

> Scope: normative terms in this module apply only to implementations and
> contributions proposed for inclusion in the upstream Admin9 App Starter
> repository. They do not govern independent forks or add license conditions.

## 1. Non-Negotiable Gates

<a id="ds-acc-001"></a>
<a id="ds-acc-002"></a>

| Area | MUST pass | Evidence |
| --- | --- | --- |
| contrast | ordinary text 4.5:1; large text and critical non-text boundaries 3:1 | reproducible color pairs plus rendered review |
| hit targets | Android 48x48dp; iOS 44x44pt | Widget geometry plus physical operability when device acceptance is in scope |
| system text | nonlinear system scaling preserved; App options only add growth | 320/360/390/600 and landscape Widget matrix plus current device evidence when claimed |
| semantics | correct name, role, value, enabled, selected/toggled, error, action, live region | semantics tests; reader walkthrough only when explicitly executed |
| focus/keyboard | visual, focus, and reading order match; visible focus; next/done; first error | Widget/integration; real software keyboard when device acceptance is in scope |
| system appearance | brightness, Bold Text, high contrast, reduce motion, grayscale merge correctly | effective-state tests plus current device observation when claimed |
| state meaning | not color-only; errors and unavailable states explain recovery/boundary | Widget and visual review |

When App theme is `system`, use system brightness; an explicit App light/dark
choice controls App brightness. Only App preferences persist. System Bold Text
always takes effect. Effective high contrast and reduce motion are `system OR
App`; reduce motion does not replace platform navigation. Grayscale controls
only the App filter and cannot negate operating-system display settings.

## 2. Automated Matrix

<a id="ds-rsp-001"></a>

This is the canonical minimum automated layout matrix. `System 1.0/2.0/3.0`
means a deterministic test `TextScaler`, not Android/iOS device evidence. Every
implemented Core component and reference page pattern runs A-L. Component-
specific states and callbacks are additional tests, not replacements.

| Row | Platform | Canvas | Theme | Contrast | App mode/factor | Test system scaler | Required stress |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A | Android | 320x720 | light | standard | Standard/1.00 | 1.0 | longest label and trailing value stack |
| B | iOS | 320x720 | light | standard | Extra Large/1.24 | 1.0 | disclosure and action reachability |
| C | Android | 360x800 | dark | standard | Large/1.12 | 1.0 | error growth and disabled state |
| D | iOS | 360x800 | dark | standard | Standard/1.00 | 1.0 | grouped list and selected trait |
| E | Android | 390x844 | light | standard | Extra Large/1.24 | 1.0 | exact visual-calibration fixture |
| F | iOS | 390x844 | dark | standard | Extra Large/1.24 | 1.0 | dark Extra Large Golden case |
| G | Android | 600x960 | dark | high | Standard/1.00 | 1.0 | max-width and non-color states |
| H | iOS | 600x960 | light | high | Large/1.12 | 1.0 | max-width and focus visibility |
| I | Android | 844x390 | light | standard | Large/1.12 | 1.0 | IME inset, scroll endpoint, primary action |
| J | iOS | 844x390 | dark | standard | Extra Large/1.24 | 1.0 | focus, first error, scroll endpoint |
| K | Android | 390x844 | light | high | Extra Large/1.24 | 2.0 | synthetic 200% system stress; no total cap |
| L | iOS | 390x844 | dark | high | Extra Large/1.24 | 3.0 | synthetic extreme stress; no Dynamic Type claim |

Acceptance is no overflow, crop, overlap, hidden action, lost scroll endpoint,
or forced text shrink. The test report records the exact combinations so a
missing row fails the gate.

Business tests use keys, visible text, semantics, callbacks, and state results.
Import boundaries use analyzer AST directives and a declaration allowlist. The
current `--mode=clean` repository scan rejects Core imports of App/Business,
Core-internal imports outside Core/the public barrel, cross-feature imports,
Business imports of App internals except the exact route-name/App-identity
allowlist, private Flutter source, interactive platform imports, and Business
platform/Core/App re-exports. `lib/admin9_ui.dart` must equal its exact current
export allowlist. Positive and exact negative fixtures are mandatory; there is
no active legacy-debt mode.

The App host has exact analyzer-checked Core-internal seams. These mechanisms
remain absent from `lib/admin9_ui.dart`, so Business cannot bypass the Brand
entry, resolve host-only appearance state, or register debug tooling.

Representative Goldens cover A, F, G, L and component-specific critical states.
Goldens do not replace semantics, computed contrast, interaction tests, or
devices. Gallery has one route-registry seam guarded by `!kReleaseMode`; tests
and the release boundary gate protect profile reachability and release absence.

<a id="ds-gal-001"></a>

## 3. AppFeedback Matrix

Widget tests cover info/success 3-second and warning/error 5-second dismissal
when no action exists and `accessibleNavigation == false`. Separate cases cover
action and accessible-navigation persistence, visible Close, action exactly
once, replacement, one live-region announcement, no focus stealing, executable
semantics actions, and hit bounds. Tests MUST NOT use `semanticsEnabled` as a
persistence proxy. Absent device reader evidence remains `Unknown`.

## 4. Platform Device Gates

| Severity | Meaning | Release treatment |
| --- | --- | --- |
| P0 | crash, privacy bypass, or a critical flow is wholly inoperable | block and fix |
| P1 | core task cannot complete; focus traps or is lost; critical state is undiscoverable; system return or installation fails | block and fix |
| P2 | one extra gesture/refocus reveals state; non-critical announcement is delayed; alternative assistive technology is unsampled | tracked backlog |
| P3 | wording, pause, repetition, or similar reader polish | tracked backlog |

Automation and code review own deterministic component states, focus requests,
Semantics, validation, responsive layout, tokens, visible mapping, and business
boundaries. Human evidence owns actual reader output, system gestures, real IME
behavior, safe areas, and release install/cold launch. Every human record names
the exact source, artifact, device, system setting, scenario, expected result,
and actual observation. A generic or unbound `passed` statement is insufficient.

P0/P1 failures and missing required human-only evidence block a release that
claims those capabilities. A later artifact may reuse a human observation only
when the intervening sensitive source delta is enumerated, automatically
regressed, and separately build/install bound. Historical evidence is not
silently promoted to the current source.

Android predictive back evidence records gesture start, visible progress,
cancellation, and completion; integration tests only assert application state.
iOS edge-back evidence similarly separates automation from human gesture
delivery. Real IME, password manager, TalkBack, VoiceOver, safe-area, and system-
bar claims require the corresponding current environment.

| P2/P3 backlog | Owner | Upgrade trigger | Review point |
| --- | --- | --- | --- |
| Switch Access / Switch Control representative sampling | Admin9 Core accessibility owner | feature adoption, user report, reproduced failure, Flutter upgrade, or release scope | feature or SDK-upgrade review |
| external-keyboard flow and password-manager behavior | Core accessibility owner with Business flow owner | same triggers | authentication/input review |
| every-page maximum text and every Dialog/Notice/AppFeedback reader variant | Core component owner | same triggers | component or release review |
| password-toggle immediate announcement | Core input owner | focus/state becomes undiscoverable or completion fails | next input-component review |

These entries are `Backlog`, not `Pass`. Representative evidence is a minimum
usable baseline, not WCAG conformance or complete assistive-technology
certification.

## 5. SDK Upgrade Review

<a id="ds-upg-001"></a>

After every Flutter SDK upgrade, recheck Material/Cupertino signatures and
defaults, `PageTransitionsTheme`, predictive back, edge-to-edge/target SDK,
deprecations, nonlinear `TextScaler`, Semantics, hit-target defaults, locale
delegates, Gallery release exclusion, Goldens, and declaration probes. Record
Flutter/Dart versions and device runtimes.

## 6. Upstream PR Checklist

- change belongs to Core, Brand, or Business and follows ownership/import rules;
- public contract and changelog are updated when applicable;
- no Feature platform branch, raw interactive platform control, fixed text cap,
  or Business dependency enters Core;
- Android/iOS visible mapping, semantics, responsive, contrast, and hit bounds
  are tested;
- Gallery state is added only for shared component or pattern behavior;
- required device gates are run or recorded `Unknown` with an owner and trigger;
- exceptions do not weaken accessibility, truthful state, or platform behavior;
- tested source, artifact, and Design System version remain accurate.

This checklist governs upstream pull requests only. There is no downstream
deviation registry, expiry record, certification, or release approval.

## 7. Current Evidence State

Automated tests protect token resolution, nonlinear scaling, system-preference
merging, Gallery boundaries, public API and imports, component bounds,
Semantics, A-L layout, effective appearance, first-error focus, feedback
lifecycle, routes, and truthful Business boundaries. Production Goldens protect
the checked pixels for their exact controlled environment.

Historical fixed-source Android/iOS simulator build, install, cold-launch, and
minimal navigation smoke is recorded as bounded `Pass`. Current physical-device,
real IME/password-manager, TalkBack/VoiceOver, gesture delivery, and final brand
acceptance remain `Unknown` or `Pending` as stated in
[Delivery](../delivery/README.md). Historical Foundation device observations do
not upgrade the current source.
