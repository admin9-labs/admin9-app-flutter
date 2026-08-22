# Admin9 UI Unification G3 Verification

Date: 2026-08-23
G2 gate commit: `06a398a747178e1aaed4933f96806ced3c498ad8`
Initial implementation commit: `3b9ea41540440f8b518546110fdbd3e7fc2def7d`
Supervision revision: this document's commit
Gate: Demo implementation and local delivery evidence
Status: three supervision P1 findings closed; ready for bounded closure review

## Result

G3 implements the first-party route selected by G2 for the Demo. Android and
iOS now use one Admin9-owned visible component language behind the unchanged
`App*` API. This local result is ready for independent review; it is not
real-device acceptance, Starter migration, a release, or final brand-art
approval.

Forui 0.25.0, `forui_assets`, `sugar`, the candidate adapter, the two POC
renderers, their harness/tests and all 110 candidate-only Goldens are removed.
No package type, Theme, controller or context extension reaches production.

## Production scope

The shared visible implementation covers:

- page and shell scaffolds, top/bottom navigation and one Admin9 icon mapping;
- buttons, loading, text fields, validation, password visibility and focus;
- settings sections, rows, pressure reflow, switches and single-choice lists;
- business dialogs, action menus, feedback, notices and progress indicators.

The change does not alter business information, action order, copy, recovery,
feature state, routes or the `MaterialApp` host. Keyboard/IME, autofill/password
managers, safe areas, Android back dispatch, iOS edge-back and route transition
mechanics, permissions, sharing, system pickers and OS accessibility services
remain platform-owned.

## Local evidence

| Evidence | Result | Boundary |
| --- | --- | --- |
| Static analysis | `flutter analyze` passes with no issues | Source-level only |
| Business and component regression | `flutter test --exclude-tags golden` passes 146 tests | Includes both platform variants and the added semantics-action closure; not real-device proof |
| Production Golden compare | 23 tests pass | 19 migrated production views plus paired Android/iOS component and AppPage scenarios |
| Manual Golden review | All 23 images reviewed | No incoherent overlap or component-family drift; 3.72x samples retain ordered, scrollable content |
| Candidate boundary | One positive and 22 exact negative fixtures plus repository scan pass | Candidate package list is empty |
| Import boundary | Four positive and 19 exact negative fixtures plus final-phase scan pass | Public `App*`, App host and route ownership remain intact |
| Other repository gates | App configuration, upstream ownership, public API parity, Gallery, 16 visual references, 20 stable rules, Android plugins and documentation pass | Local deterministic evidence |
| Android build | Release APK builds, 51,005,113 bytes | Not installed on a physical device in G3 |
| iOS build | Release no-codesign `Runner.app` builds, 17.1 MB | Not signed or installed in G3 |
| Package exit | Source, package configuration and both release asset trees contain no Forui, Inter or Lucide candidate artifact | Confirms the G2 package footprint is removed |

Local handoff artifacts for this revision:

- Android: `build/app/outputs/flutter-apk/app-release.apk`, 51,005,113 bytes,
  SHA-256 `033da5010261a37bc0d62c188e7596a2fb82cdf7a8a6cfb8bfea7c65a26b5bc8`.
- iOS: `build/ios/iphoneos/Runner.app`, 16,804 KiB on disk. The sorted
  per-file SHA-256 manifest digest is
  `3acf0a47d54924b49c5088a32562f9b40e8deced452a2c93bf027e55db7a418d`.
  This is an unsigned app bundle, not an IPA or installable release signature.

The paired production Goldens use identical content, state, brightness, text
scale and 390x844 viewport inputs for both platform variants. They cover both
the component set and an `AppPage` top bar. Pixel equality is not required
because system font rasterization may differ; visible hierarchy, component
family, state meaning and action priority are the acceptance target.

## Accessibility and interaction

The shared controls retain minimum 48 logical-pixel targets. Form tests cover
controller identity, external updates, validation priority, focus,
keyboard/action metadata, autofill and password visibility. Dialog, menu,
feedback and navigation tests retain cancellation, single dispatch, barrier,
back and focus-restoration behavior.

`AppNotice` now exposes one tone/title/message semantics node without consuming
its independent recovery action. Error notices remain live regions. Switch,
button, progress, feedback and validation semantics are exercised in the full
regression suite.

These checks prove Flutter semantics contracts, not actual TalkBack or
VoiceOver announcement timing. Assistive-technology delivery remains part of
the physical-device handoff.

## Supervision revision

The architecture reviewer returned Go on `3b9ea41`. Product/brand and
QA/accessibility review found three direct P1 issues; the revision is limited to
their closure:

1. `AppPage` and `AppSingleChoiceList` now explicitly center the brand-owned
   page title on both platforms. A same-content Android/iOS `AppPage` Golden
   pair covers the top bar instead of inferring it from component-only images.
2. Persistent feedback action and close nodes expose executable semantic tap
   actions. Android/iOS tests activate each through the semantics pipeline,
   verify the recovery action fires exactly once and prove close does not fire
   recovery.
3. Long or highly scaled field labels move above the input as an unconstrained,
   wrapping label. The 3.72x iOS Golden shows the complete label and the A-L
   form matrix mechanically rejects exceeded label lines.

No business content, route, App host, system capability or dependency changed
in this revision. Final review is bounded to these closures and direct P0/P1
regressions.

## Real-device handoff checklist

Run the same representative flow on one supported Android device and one
supported iPhone:

1. Confirm the app is immediately recognizable as the same Admin9 product:
   page hierarchy, buttons, fields, rows, navigation, dialogs, menus, loading,
   empty/error states and feedback use one visual language.
2. Complete registration/login validation and account/settings flows. Confirm
   information order, action priority, state meaning and recovery are the same.
3. Exercise Android system/predictive back and iOS edge-back. Confirm native
   transition behavior remains natural and no business state is lost.
4. Exercise real keyboards, IME actions, autofill/password managers, focus
   movement and keyboard dismissal on both devices.
5. Inspect status/navigation/home-indicator safe areas in portrait and after
   any supported orientation or keyboard transition.
6. Trigger permissions, sharing and system pickers where the Demo exposes them;
   their system UI may differ while the surrounding explanation/result stays
   Admin9-consistent.
7. With TalkBack and VoiceOver, check reading order, names, roles, values,
   toggled/disabled states, validation, one-time error announcements, dialog
   focus restoration and recovery actions.
8. Repeat representative screens in light/dark mode, high contrast where
   available and large system text. Record any overlap, truncation, unreachable
   action or inconsistent hierarchy as P0/P1 before acceptance.

## Recorded non-blocking limits

- Final type metrics, icon family, spacing, radius and art direction still
  require user approval; G3 uses the existing Admin9 token direction.
- Local Goldens and builds do not replace physical-device gesture, keyboard,
  safe-area, TalkBack/VoiceOver or perceived-brand acceptance.
- Device/profile frame-time P90 and installed package size are deferred to the
  real-device/release evidence stage; no performance superiority is claimed.

## Stop condition

After three independent reviewers return Go on one fixed G3 commit, hand these
builds and this checklist to the user. Do not migrate Starter, assign a Design
System version, push, publish or release until the user explicitly accepts both
real-device experiences.
