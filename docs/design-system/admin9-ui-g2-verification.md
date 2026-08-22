# Admin9 UI Unification G2 Verification

Date: 2026-08-23
Baseline commit: `cf68a24844e45c16d983d29fb4878ad2f14bfd41`
Candidate commit: `46d359f39197978b20271c1c1120f348887cc532`
Supervision revision: this document's commit
Gate: bounded candidate POC and recommendation
Status: supervision P1 closed; ready for bounded fixed-SHA closure review

## Scope

G2 compares the unchanged control, one new first-party unified candidate, and
Forui 0.25.0 in one shared harness. `shadcn_ui` remains evidence-only because
Forui was not eliminated before the comparison and no named second-package gap
was opened.

The POC is not routed from the Demo, exported from `admin9_ui.dart`, or used
by business pages. `lib/app`, `lib/ui`, the route tree, the root Theme,
feature state, models, Starter migration, release and production adoption
remain outside G2.

## Fixed reference content

| Scenario | Baseline | Alternate / recovery |
| --- | --- | --- |
| Auth | Registration, account and obscured password fields, focus, autofill, primary and disabled actions | Login and a long field error |
| Account | Coherent signed-in identity, list rows and selected bottom navigation | Empty state, recoverable load error and retry |
| Settings | Switch, long preference explanation and effective setting | Persistence error and retry |
| Feedback | Action menu, cancel, disabled/destructive actions, determinate and indeterminate progress, loading | Business confirmation dialog, cancel/confirm, appearing error and undo |

All three renderers receive the same scenario, content, state, platform,
brightness, text scale, high-contrast and viewport inputs. This proves bounded
POC comparability. It does not prove full route coverage, real-device behavior,
or production integration.

## Verification evidence

| Evidence | Result | Meaning |
| --- | --- | --- |
| Widget contracts | 21 focused tests pass | Both platforms cover executable button/switch semantics, disabled actions and the 320x720 at 3x matrix; the focused registration input test covers keyboard/autofill/focus/password metadata; navigation, empty/error/menu/dialog/progress and appearing feedback are also covered |
| Announcement contract | Appearing error has one live-region node, survives rebuild without duplication, and retains the prior focus for first-party and Forui | Static `liveRegion` presence is not treated as sufficient evidence |
| Golden contracts | 110 pass: 96 scenario matrix images, 6 pressed images and 8 first-party 320x720 dark/high-contrast/3x stress images | Matrix inputs are deterministic; Android/iOS images are not expected to be pixel-equal |
| Golden matrix | Each renderer/platform/scenario has baseline light, baseline dark, baseline light at 1.24x and alternate light | Dark, scaled text and recovery content are no longer inferred from one light image |
| Manual visual review | All 110 images were reviewed in three renderer contact sheets | The regenerated CJK subset removes missing business glyphs; first-party stress states have no incoherent overlap; Forui's long settings subtitle still truncates and is recorded as a candidate limitation |
| Pressed evidence | Representative Android pixel delta: control 0, first-party 16,687, Forui 16,695 | The current control lacks a stable visible pressed frame under reduced motion; first-party and Forui provide real, non-identical evidence |
| System-font check | Forui Text, nested TextSpan and EditableText styles contain no bundled Inter family/package | The package assets are still bundled even when rendering uses Admin9/system typography |
| Candidate isolation | `1` positive and `22` exact negative fixtures plus repository scan pass | Forui imports remain prefixed under the adapter root and no candidate type reaches `App*` |
| Import isolation | `4` positive and `19` negative fixtures plus final repository phase pass | No business, route, root Theme or App-host bypass was introduced |
| Full repository regression | `flutter analyze`, 169 non-Golden tests and 129 tagged Golden tests pass | The 129 images are 110 G2 plus 19 existing Goldens |
| Release builds | Android Release APK 52.9 MB and iOS no-codesign Release app 19.7 MB build successfully | Local build-chain evidence only; neither artifact is real-device acceptance |
| Packaged assets | Both Release asset trees contain Inter, Inter Italic and Lucide fonts totaling 2,627,296 bytes | The package footprint is real even though the POC is unrouted |

The control also records an existing semantics defect: `AppNotice` can merge
its explicit error label with descendant title/body labels and repeat content.
G2 does not change production code; this is a G3 acceptance item.

## Candidate comparison

| Dimension | Control | First-party candidate | Forui candidate |
| --- | --- | --- | --- |
| Visible unity | Retains broad visible Material/Cupertino branching | Uses the same Admin9-owned visible primitives for both platform inputs | Converges after a substantial Admin9 theme and adapter layer |
| Scenario fit | Misses stable pressed evidence and retains repeated notice semantics | Covers the fixed POC, including dynamic-height buttons and 3x action-menu content | Covers the fixed POC only with wrappers; a long 390-wide tile subtitle still truncates |
| System font | Existing system policy | Inherits Admin9 tokens | Requires a complete `FTypeface` rebuild and private metadata placeholder |
| Semantics | Existing notice repeat remains | Explicit single-node action, switch, feedback and progress contracts | Requires explicit outer semantics and exclusion of package child semantics |
| Progress parity | Existing contract | Flutter SDK primitives can preserve current determinate/indeterminate shapes and reduced-motion policy | No determinate circular control; package busy progress freezes when its motion is disabled |
| Dependency/lifecycle | No new package | No new runtime package | Pre-1.0 API, MIT plus OFL notices, three resolved packages and about 2.63 MB raw font assets |
| Exit | Not applicable | POC is disposable before production integration | Dependency, adapter, package-only tests and assets must all be removed |

One local sequential Widget-test sample over 40 baseline scenario pumps reported:

- control: 1,455 ms, maximum 543 elements;
- first-party: 672 ms, maximum 535 elements;
- Forui: 1,241 ms, maximum 513 elements.

These values are directional diagnostics only. They are not asserted, are
susceptible to test-order and host load, and are not used to claim that one
candidate is materially faster. Device/profile frame data, startup, P90
build/raster and final package size remain G3/release gates.

## Removal drill

The supervision working tree was copied to an isolated temporary directory.
The copy then removed the Forui dependency, the complete G2 POC/adapter,
package-only tests and all 110 G2 Golden files.

Results:

- `flutter pub remove forui`: removed `forui 0.25.0`,
  `forui_assets 0.25.0` and `sugar 4.0.0`;
- residual source/import/package scan: zero;
- `flutter analyze`: pass;
- `flutter test --exclude-tags golden`: 145 original tests pass;
- candidate fixtures/repository scan: pass, `1` positive and `22` negative;
- import fixtures/final phase: pass, `4` positive and `19` negative;
- directory/file comparison for `lib/app`, `lib/ui` and
  `app_theme.dart`: zero differences.

The temporary copy and quarantine did not alter the repository or branch.

## Supervision findings closed

1. First-party buttons and switches now expose executable semantic tap actions;
   Forui's previously unlabeled merged switch node is wrapped as one labeled,
   toggled, executable node.
2. The fixed reference now includes registration, bottom navigation,
   empty/recoverable error, dialog/action menu/cancel, determinate and
   indeterminate progress, focus, pressed, disabled, loading and destructive
   states.
3. The account baseline now presents one coherent signed-in identity.
4. Golden evidence now covers dark mode, 1.24x text, alternate states, 3x
   high-contrast stress and real pressed pixels.
5. The test-only Noto CJK subset was regenerated from current `lib/` and
   `test/` glyphs; missing-glyph claims now match reviewed output.
6. Appearing feedback is tested for timing, single node, rebuild and focus
   retention.
7. The report now limits “same scenario” to the POC matrix and records Forui
   truncation/progress gaps instead of claiming full route parity.

## Recommendation

**Recommend the first-party unified route for G3. Do not carry Forui into the
Demo implementation.**

Forui is technically usable behind `App*`, so G2 rejects the old assumption
that third-party components should be excluded without evidence. It does not
win this comparison: matching the fixed POC still requires extensive Admin9
wrappers, typography/semantics compatibility work, a pressure-layout exception,
progress fallback, pre-1.0 upgrade ownership, license notices and packaged font
assets. The first-party route meets the same POC without those lifecycle and
asset costs.

A mixed route is not justified by G2 evidence. Reconsider it only if G3 exposes
a named first-party capability or maintenance gap that is cheaper to solve with
a separately removable package adapter.

## G3 entry conditions

1. Three bounded reviewers inspect the supervision revision SHA and return Go
   with no open P0/P1.
2. G3 removes the Forui dependency and G2 POC before production integration.
3. G3 preserves public `App*`, the single route tree, App host and
   system-capability ownership.
4. G3 fixes production notice semantics and verifies affected keyboard,
   autofill, focus, safe-area, back and representative Android/iOS runtime
   contracts.

## Recorded P2

- The local elapsed sample remains non-gating and intentionally unasserted.
- The Inter check now traverses nested spans; final package font presence is
  separately measured.
- Forui's determinate-circular/reduced-motion gaps are hard limits; its long
  tile truncation and Admin9 theming effort are calibration limitations.
- Decode PNG pixels mechanically only if G3 changes the rendering pipeline.
- Collect device/profile P90 and final APK/IPA size evidence for the winning
  production implementation.
