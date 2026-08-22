# Admin9 UI Unification G2 Verification

Date: 2026-08-23
Reference commit: `cf68a24844e45c16d983d29fb4878ad2f14bfd41`
Gate: bounded candidate POC and recommendation
Status: ready for fixed-SHA independent review

## Scope

G2 compares the unchanged control, one new first-party unified candidate, and
Forui 0.25.0 against the same four scenarios. `shadcn_ui` remains evidence-only
because no primary-candidate elimination or unresolved second-package gap was
triggered.

The POC is not routed from the Demo, exported from `admin9_ui.dart`, or used by
business pages. `lib/app`, `lib/ui`, the route tree, the root Theme, feature
state, models, Starter migration, release and production adoption are outside
this change.

## Same-scenario evidence

| Evidence | Result | Meaning |
| --- | --- | --- |
| Four scenarios | Auth, account/list, settings, feedback/progress use one shared data/state harness | Candidate comparison does not choose its own easier content |
| Platforms | Control, first-party and Forui render on Android and iOS inputs | Platform is an input, not a separate business implementation |
| Widget contracts | 16 focused tests pass | Four scenarios, keyboard/action/autofill metadata, switch semantics, 320-wide 3x text pressure, feedback/progress semantics and system-font mapping are covered |
| Golden contracts | 24 tests pass: 4 scenarios x 3 renderers x 2 platforms | Each renderer/platform has a deterministic regression image; images do not prove cross-platform pixel equality |
| Manual visual review | All 24 390x844 images reviewed as one contact sheet | No missing CJK glyph, blank output, clipping or incoherent overlap; first-party and Forui visibly converge more than the control |
| Candidate isolation | `1` positive and `22` exact negative fixtures plus repository scan pass | Forui imports remain prefixed under the adapter root and no candidate type reaches `App*` |
| Import isolation | Final import-boundary phase passes | No business, route or App-host bypass was introduced |
| Release builds | Android APK 52.9 MB and iOS no-codesign `Runner.app` 19.7 MB build successfully | Local build-chain evidence only; neither artifact was installed or treated as real-device acceptance |
| Packaged assets | Both Release asset trees contain Inter, Inter Italic, and Lucide fonts totaling 2,627,296 bytes | The candidate's bundled font footprint is real even though the POC is not routed from the Demo |

The control records one existing semantics defect: `AppNotice` merges its
explicit error label with descendant title/body labels and may repeat content.
Both candidates expose the exact single business label in the POC. This does
not change production code in G2; it becomes a G3 acceptance item for the
recommended route.

## Candidate comparison

| Dimension | Control | First-party candidate | Forui candidate |
| --- | --- | --- | --- |
| Visible unity | Fails the product observation because visible Material/Cupertino branching remains | Same branded structure and primitives on both platform inputs | Close visual convergence after an Admin9 theme and wrapper layer |
| POC implementation | Existing only | 270 lines | 319 adapter lines plus package code |
| Local repeated render sample | 1,180 ms, max 403 elements | 550 ms, max 398 elements | 1,145 ms, max 399 elements |
| System font | Existing system policy | Inherits Admin9 tokens | Requires a complete `FTypeface` rebuild and a private metadata placeholder to avoid bundled Inter |
| Semantics | Existing notice repeat remains | Exact feedback/progress/button/switch contract in POC | Requires explicit outer semantics and exclusion of package child semantics |
| Dynamic text | Existing specialized pressure handling | Passes 320-wide 3x text matrix | Needs an Admin9 pressure branch for tile details |
| Progress parity | Existing contract | Can implement determinate/indeterminate linear/circular with Flutter SDK primitives | No determinate circular control; busy progress freezes when package motion is disabled |
| Dependency/lifecycle | No new package | No new package | Pre-1.0 API, MIT plus OFL notices, three added resolved packages and about 2.63 MB raw font assets |
| Exit | Not applicable | First-party POC can be replaced behind `App*` | Removal drill passes but requires deleting the dependency, adapter and Forui POC branches/assets |

The elapsed values are one local sequential Widget-test sample over 40 scenario
pumps per renderer. They are directional engineering evidence, not device frame
timings, APK/IPA size, startup, P90 raster or release performance claims. Those
remain G3/release gates for the winning implementation.

## Removal drill

The current working tree was copied to an isolated temporary directory. In the
copy only the candidate dependency classification, Forui adapter, Forui POC
branches, package-specific font loader/test, and eight Forui Golden files were
removed.

Results:

- `flutter pub get`: removed `forui 0.25.0`, `forui_assets 0.25.0`, and
  `sugar 4.0.0` from the lock file;
- `flutter analyze`: pass;
- `flutter test --exclude-tags golden`: 157 tests pass;
- candidate fixtures: pass, `1` positive and `22` negative;
- candidate repository scan: pass;
- final import boundary: pass;
- residual scan for package imports, adapter names and the Forui enum branch:
  zero;
- directory/file comparison for `lib/app`, `lib/ui`, route ownership and
  `app_theme.dart`: zero differences.

The temporary copy was not a Git worktree and made no repository or branch
change.

## Recommendation

**Recommend the first-party unified route for G3. Do not carry Forui into the
Demo implementation.**

Forui is technically usable behind `App*`, and the POC proves that third-party
libraries were evaluated rather than excluded by preference. It does not win
this comparison: the adapter is larger than the first-party POC, local render
cost is materially higher in the bounded sample, typography and semantics need
extra compatibility work, progress parity is incomplete, and pre-1.0 plus
font/notice costs remain.

A mixed route is not justified. The first-party candidate has no named POC gap
that requires Forui, while keeping Forui only for button/text-field/switch/alert
would retain its dependency and lifecycle costs without solving a missing
capability.

## G3 entry conditions

1. Three independent reviewers inspect one fixed G2 commit and return Go with
   no open P0/P1.
2. G3 removes the Forui dependency and POC adapter before integrating the
   first-party route into production `App*` internals.
3. G3 preserves public `App*`, the route tree, App host and system capability
   ownership.
4. G3 fixes the notice repeated-semantics behavior and proves the required
   keyboard, autofill, focus, safe-area, back and representative Android/iOS
   runtime gates for affected components.

## P2 follow-up

- Decode generated/static PNG pixels mechanically only if G3 changes the
  reference rendering pipeline.
- Collect device/profile P90 build/raster and final APK/IPA asset-size evidence
  for the winning implementation; local Widget elapsed time is not a release
  performance gate.
- Reconsider a third-party package only when a named first-party capability or
  maintenance gap exists, using a fresh version/license/advisory snapshot.
