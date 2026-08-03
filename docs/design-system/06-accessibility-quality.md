# Accessibility, Quality, and Governance

> Scope: normative terms in this module apply only to implementations and
> contributions proposed for inclusion in the upstream Admin9 App Starter
> repository. They do not govern independent forks or add license conditions.

## 1. Non-negotiable gates

<a id="ds-acc-001"></a>
<a id="ds-acc-002"></a>

| Area | MUST pass | Evidence |
| --- | --- | --- |
| contrast | ordinary text 4.5:1; large text and critical non-text boundaries 3:1 | reproducible color-pair table plus rendered review |
| hit targets | Android 48x48dp; iOS 44x44pt | Widget geometry for every control plus physical operability in the representative flow; visual and hit bounds separate |
| system text | nonlinear system scaling preserved; App options only add growth | 320/360/390/600 and landscape Widget matrix plus one representative large/max-size physical smoke per platform |
| semantics | correct name, role, value, enabled, selected/toggled, error, action, live region | semantics tests plus one representative reader walkthrough per platform |
| focus/keyboard | visual, focus, and reading order match; visible focus; next/done; first error | Widget/integration plus one real software-keyboard Next/Done flow; external-keyboard repetition is P2 |
| system appearance | brightness, Bold Text, high contrast, reduce motion, grayscale merge correctly | effective-state tests plus representative Dark or large/max-size device observation; exhaustive system-setting combinations are P2 |
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

Severity is fixed for this release:

| Severity | Meaning | Release treatment |
| --- | --- | --- |
| P0 | crash, privacy bypass, or a critical flow is wholly inoperable | block and fix |
| P1 | core task cannot complete; focus traps or is permanently lost; critical state is undiscoverable; system return or installation fails | block and fix |
| P2 | one extra gesture/refocus reveals state; non-critical announcement is delayed; an alternative assistive technology is not sampled | tracked backlog |
| P3 | wording, pause, repetition or similar reader polish | tracked backlog |

Device acceptance is risk-tiered without weakening the non-negotiable outcomes
in section 1. Automation and code review own deterministic component states,
focus requests, Semantics, validation, responsive layout, tokens, platform
mapping and business boundaries. Human evidence owns only actual reader output,
system gestures, real IME behavior, safe areas and release install/cold launch.
Each human-only capability uses one representative flow per platform; equivalent
controls are not repeated on every page.

A contemporaneous device-owner transcript is acceptable human evidence when it
records the exact device/artifact, system setting, scenario, expected result and
actual observation. Screenshots, audio and video strengthen provenance but are
not mandatory when the observed fact is spoken output or a gesture outcome and
the transcript is explicit. A transcript MUST NOT be described as media and a
generic unbound `passed` statement is insufficient.

P0/P1 failures and missing P0/P1 human-only evidence block release. Switch
Access/Control repetition, password-manager and external-keyboard sampling,
every-page reader traversal and every Dialog/Notice/AppFeedback variant are P2
by default after their automated contracts pass. They remain explicit backlog,
not inferred passes, and become blockers when a real consumer, observed failure
or user report raises their risk. The representative accessibility evidence set
MUST still cover privacy entry, primary navigation/back, one choice, one switch,
first form error, password visibility state and the truthful unavailable-service
boundary on both platforms. It MAY combine one human reader traversal, the
real-IME task result and deterministic Semantics/focus tests; it MUST identify
which evidence proves each fact and MUST NOT describe machine evidence as spoken
output. A later artifact may reuse the human traversal only when the intervening
reader-sensitive source delta is enumerated, automatically regressed and limited
to an additive fix whose final artifact is separately build/install bound.

Android API 34+ predictive back is a manual hard gate: record gesture start, visible progress, cancellation, and completion; cancellation preserves state and completion pops once. Repeat core regression on API 36. Integration tests only assert application state before/after back and MUST NOT claim system-gesture evidence.

iOS uses current Xcode-available small and regular simulators with model,
runtime and logical width recorded; do not invent a 320pt simulator. Simulator
automation proves route state, keyboard-driven layout, Picker/Dialog mapping and
safe-area constraints. One human edge-swipe cancellation/completion and one
physical safe-area observation remain the device gate; repeating every mapped
control on simulators is not a second human hard gate.

The complete long-horizon device backlog includes:

- Android: TalkBack, Switch Access, 200% text, hardware keyboard, IME/autofill, gesture/three-button navigation, cutout, edge-to-edge and system-bar contrast.
- iOS: VoiceOver, Switch Control, maximum Dynamic Type, Bold Text, Increase Contrast, Reduce Motion, software/hardware keyboard, autofill/password manager, home indicator and edge back.
- Both: light/dark, grayscale, high contrast, reduced motion, hit-target spot checks, both reference flows, scroll endpoints, errors, dialogs, notices, and feedback.

Phase 6 release blocking uses the representative P0/P1 subset above; remaining
items retain an owner and trigger in backlog. This evidence policy does not
permit lowering contrast, hit targets, system text, Semantics, focus, platform
navigation or truthful business-state requirements.

| P2/P3 backlog | Owner | Upgrade trigger | Review stage |
| --- | --- | --- | --- |
| Switch Access / Switch Control representative sampling | Admin9 Core accessibility owner | upstream feature adoption, user report, reproduced upstream failure, Flutter upgrade, or release scope | upstream feature or SDK-upgrade review |
| external-keyboard full flow and password-manager behavior | Admin9 Core accessibility owner with Business flow owner | same triggers | upstream authentication/input review |
| every-page maximum text and every Dialog/Notice/AppFeedback reader variant | Admin9 Core component owner | same triggers | upstream component or release review |
| password-toggle immediate announcement | Admin9 Core input owner | focus/state becomes undiscoverable or task completion fails | next input-component review |

These entries are non-blocking only while automated contracts pass and the
representative Android/iOS flows remain usable. They are `Backlog`, not `Pass`.
Passing Phase 6 establishes a minimum usable accessibility baseline only; it is
not WCAG conformance or complete assistive-technology certification.

## 5. SDK upgrade review

<a id="ds-upg-001"></a>

After every Flutter SDK upgrade, recheck Material/Cupertino constructor signatures and defaults, PageTransitionsTheme, predictive-back integration, edge-to-edge/target SDK behavior, deprecations, nonlinear TextScaler, Semantics, hit-target defaults, locale delegates, Gallery release exclusion, Goldens, and all declaration probes. Upgrade evidence names Flutter/Dart versions and device runtimes.

## 6. Upstream PR checklist

- change belongs to Core, Brand, or Business and follows ownership/import rules;
- public contract and changelog updated when applicable;
- no feature platform branch, raw interactive platform control, raw color, fixed text cap, or business dependency in Core;
- Android/iOS mapping, semantics, responsive, contrast, and hit bounds tested;
- Gallery state added only for shared component/pattern behavior;
- required device gates run or recorded Unknown with an owner and phase;
- any requested exception is resolved in upstream review without weakening
  accessibility or platform navigation;
- tested source, artifact, and Design System version remain accurate.

This checklist governs only upstream pull requests. There is no downstream
deviation registry, expiry record, provenance contract, or release approval.

## 7. Current Unknowns

Phase 1 has verified Flutter token resolution, nonlinear TextScaler composition, runtime system-preference merging, debug/profile Gallery reachability, and Gallery exclusion from the installed Android release package. These results are no longer Unknown and remain protected by the Phase 1 automated and release-package gates.

Runtime component bounds, Semantics, A-L layout, effective appearance,
first-error focus, feedback lifecycle and business boundaries now have automated
implementation evidence. The hash-bound Android release passes representative
TalkBack, privacy announcement, appearance/persistence and real-IME evidence.
Native-mouse API 34/API 36 predictive back and API 36 gesture/three-button
cutout, edge-to-edge, safe-area and visible-IME review also pass on the named
emulators; Android 14+ physical hardware remains separately Unknown.
Final-source iPhone signing, install, unlocked cold launch and process binding
pass. The representative iPhone VoiceOver flow, real-IME Next/Done path, App
Extra Large safe-area endpoint and human edge-back cancellation/completion also
pass on the hash-bound final candidate. The P2/P3 table above remains explicit
backlog. Static assets and documents did not substitute for those device-only
observations. Phase 6 therefore establishes the minimum usable accessibility
baseline on representative Android/iOS flows only; Android 14+ physical
hardware and the named alternative-technology samples remain non-blocking
Unknown/backlog rather than inferred passes.
