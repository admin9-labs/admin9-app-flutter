# Admin9 UI Phase 4 Acceptance Report

Status: Go for Phase 4 implementation; Phase 6 physical-device gates remain open

Date: 2026-07-29

## Scope

Phase 4 implements the frozen form and action contracts: `AppButton`,
`AppTextField`, `AppNotice`, internal `AppDialog`, internal
`AppActionMenu<T>`, and the application interaction presenter. It migrates the
privacy gate, authentication, account, legal, About, and Contact flows without
adding a backend, creating a production session, changing route destinations,
or converting the honest `服务尚未接入，当前操作不会提交或保存。` result into
success.

## User-flow result

- Guest Account exposes Login, Register, account recovery, Settings, legal, and
  About; it does not expose profile, security, logout, or deletion.
- Auth flows keep persistent labels, field-local errors, first-error focus,
  next/done keyboard actions, password visibility, flow-correct autofill roles,
  and `finishAutofillContext(shouldSave: false)` for the unavailable result.
- Test-only authenticated state proves profile/security visibility, a single
  final Session section, cancel-safe logout, and confirmed sign-out. No runtime
  path fabricates authentication.
- Legal copy remains selectable through the one exact read-only primitive
  exception. Privacy-gate legal routes and nested account/auth routes show the
  actual iOS parent title.
- At 320 logical pixels, guest Login/Register actions stack vertically; wider
  layouts keep the frozen horizontal arrangement.

## Review closure

Independent Flutter architecture, cross-platform UI, iOS HIG, and Android
Material reviews were run against the Phase 4 worktree. The following
contract-relevant findings were closed before the final mechanical run.

| Severity | Finding | Resolution |
| --- | --- | --- |
| P1 | single-field auth exposed Next instead of Done | flow-specific input actions plus page regression |
| P1 | account-deletion validation did not restore first-error focus | owned focus node and validation regression |
| P1 | password autofill roles and unavailable completion could invite credential storage | password/new-password mapping and `shouldSave: false` channel evidence |
| P2 | iOS dialog used a Material route | `showCupertinoDialog` with frozen result and focus behavior |
| P2 | action menu allowed repeated dispatch while its route was closing | Core-owned one-shot selection guard and Android/iOS repeated-tap test |
| P2 | simultaneous Cupertino field errors all announced as live regions | every error remains visible; only the focused first-invalid field is live |
| P2 | authenticated Account structure lacked regression evidence | test-only authenticated controller covers visibility, order, cancel, and confirm |
| P2 | Dialog and ActionMenu did not execute the A-L pressure matrix | both components run the canonical A-L sizes/scales with reachability checks |
| P2 | legal `SelectableText` exception depended on a file-specific debt entry | exact `show SelectableText` rule now applies to Phase 0D and final gates; reusable fixture passes |
| P2 | iOS parent labels did not match multi-entry navigation sources | route calls pass a validated parent label; defaults remain deterministic |
| P2 | 320-width guest actions did not use the frozen vertical reflow | width-driven column plus Android/iOS Widget regression |

Nonblocking P3 visual cleanup remains for Phase 5: page-specific Material
identity visuals in Account/Profile are part of the existing final-import debt.
Phase 5 may replace them while migrating and clearing boundaries, but must not
redesign the page.

## Mechanical evidence

| Command | Result |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test integration_test tool` | Pass, 99 files unchanged |
| `dart run tool/design_system/validate_foundation_manifest.dart --fixtures` | Pass, 1 valid and 12 invalid rejected |
| contract and implementation probe analysis | Pass |
| rule-link validator | Pass, 22 stable rules |
| documentation validator | Pass, 16 Markdown files |
| visual-reference validator | Pass, 12 assets |
| Brand contract fixtures | Pass |
| Gallery boundary | Pass |
| import-boundary fixtures | Pass, 4 positive and 19 negative |
| Phase 0D repository import gate | Pass |
| `flutter analyze` | Pass, no issues |
| `flutter test -r expanded` | Pass, 127 tests |
| `git diff --check` | Pass |

## Runtime evidence and limits

| Target | Command | Result proved |
| --- | --- | --- |
| Android emulator `emulator-5554`, Android 16 / API 36 | `flutter test integration_test/foundation_smoke_test.dart -d emulator-5554 -r expanded` | Build, install, privacy/auth/settings/account/legal task and ordinary application back state pass |
| iPhone 17e simulator `C10E0968-4695-4C02-BC55-8C322531239A`, iOS 26.5 | `flutter test integration_test/foundation_smoke_test.dart -d C10E0968-4695-4C02-BC55-8C322531239A -r expanded` | Build, install and the same application task pass with Cupertino mappings |

These runs do not claim physical-device, exact spoken-output, password-manager,
iOS edge-swipe, or Android predictive-back evidence. The currently connected
device list contains the two simulators above and no physical phone. VoiceOver,
TalkBack, Switch Control/Access, external keyboard, real IME/autofill, iOS
edge-back cancel/complete, and predictive-back start/progress/cancel/complete
remain Phase 6 hard gates.

## Decision

All Phase 4 P0-P2 findings that affect the frozen contract, accessibility,
regression, or stage acceptance are closed. Automated and currently executable
simulator gates pass. Phase 4 is `Go` and may be committed. Phase 5 is limited
to remaining migration, old-wrapper cleanup, Gallery/Golden completion, public
export closure, and final import boundaries; it must not reopen page design.
