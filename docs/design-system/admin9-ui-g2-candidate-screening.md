# Admin9 UI Unification G2 Candidate Screening

Date: 2026-08-23
Reference commit: `cf68a24844e45c16d983d29fb4878ad2f14bfd41`
Status: package-code entry evidence

## Decision boundary

This screening does not select the production implementation. It admits one
primary package to a removable POC and keeps at most one evidence-only backup.
The comparison remains:

1. the unchanged current implementation as control;
2. a new first-party unified candidate;
3. one package candidate behind an Admin9 adapter;
4. a mixed route only if both single routes have a named measured gap.

No package type, Theme, controller, callback, style, enum, context extension,
or initialization API may cross the internal adapter into `App*`, business
pages, the App host, or the route tree.

## Primary: Forui 0.25.0

| Check | Evidence | Assessment |
| --- | --- | --- |
| Exact artifact | pub.dev `forui` 0.25.0, published 2026-08-02; archive SHA-256 `bf2a76293044ec8fbe8869032a67e79b6dfb12a471c9c3ecacb45626e69744d2` | Fixed for this POC round |
| Toolchain | Dart `>=3.12.0-0 <4.0.0`, Flutter `>=3.44.0-0`; repository uses Dart 3.12.1 and Flutter 3.44.1 | Compatible |
| Resolution | Exact dry-run adds `forui 0.25.0`, `forui_assets 0.25.0`, and `sugar 4.0.0`; the other direct requirements are already SDK or locked transitive packages | Small incremental graph |
| License | Package `LICENSE` contains MIT for Forui and OFL 1.1 for bundled Inter | Acceptable only with notices preserved |
| Fonts/assets | Package declares Inter and Inter Italic assets | POC must explicitly override typography with Admin9/system styles and must not make Inter the brand default |
| Native code | Published library contains no `.so`, `.dylib`, `.framework`, or `.aar`; package dependencies are Dart/Flutter packages | No native-plugin surface found |
| Maintenance | `duobaseio/forui` is public, unarchived, 2,302 stars, 133 forks, 58 open issues, and was pushed 2026-08-22 | Active, but repository popularity is not a stability guarantee |
| Advisories | OSV Pub query for `forui` 0.25.0 returned no known vulnerabilities on 2026-08-23 | No known advisory; not proof of absence |
| Component coverage | Button, text field, tile, switch, bottom navigation, dialog, alert, progress, toast, theme, focus and semantics APIs are present | Enough to enter the four-scenario POC, not proof of full `App*` parity |
| Confirmed gaps | No determinate circular progress; indeterminate progress freezes when Forui accessibility motion is disabled; tile detail truncation needs an Admin9 pressure-layout branch | Prevents a full unmodified `App*` replacement |
| Theming | `FThemeData` exposes colors, typography, icons, base style, and widget styles | Brand mapping is testable without changing the App root Theme |
| Input/system behavior | `FTextField` exposes Flutter controller, focus, keyboard, IME, autofill, selection and context-menu APIs | Can retain platform input behavior behind the adapter |
| Accessibility | Controls expose Flutter semantics/focus surfaces; `FAlert` uses live-region semantics and `FSwitch` supplies merged switch semantics | Must be verified against the Admin9 announcement and focus contract; package claims alone do not pass |
| Testability | Widgets are ordinary Flutter widgets and can run in Widget/Golden tests under an internal `FTheme` | Testable without routing or business state |
| Performance plan | Compare build/layout/rasterized surface size and repeated pump time for the same four POC scenarios; no native startup cost is expected | Evidence required before recommendation |
| Upgrade risk | Version is pre-1.0 and its public design/style API is broad | Explicit P1 risk; all package use must remain in one adapter root |
| Exit cost | Remove the dependency, adapter, package-only tests and Golden files; business code, route tree, App host and public `App*` API must remain unchanged | Mandatory removal drill before G2 exit |

The published package includes approximately 2.63 MB of raw Inter, Inter
Italic, and Lucide font assets. This is not the final APK/IPA delta, but it is a
real packaging and notice surface that must be measured before any production
adoption.

### Primary admission

Forui is admitted as the only package implemented in the first G2 POC. This is
not a recommendation to adopt it. It can be eliminated for public API leakage,
system-font failure, semantics/focus regression, insufficient visual control,
material performance cost, or a failed removal drill.

## Backup evidence: shadcn_ui 0.56.1

| Check | Evidence | Assessment |
| --- | --- | --- |
| Exact artifact | pub.dev `shadcn_ui` 0.56.1, published 2026-08-04; archive SHA-256 `f7569c3c249bf6eaeb9cf992e852ef596e92fc00ce1ba4878b81d7654b88ddac` | Fixed evidence-only backup |
| Toolchain | Dart `>=3.11.0 <4.0.0`, Flutter `>=3.41.0` | Compatible |
| Direct graph | Declares `boxy`, animation, SVG/vector, Lucide icons, Slang, theme-codegen annotation, two-dimensional scrolling, universal image, and web packages in addition to common Flutter dependencies | Materially broader dependency and upgrade surface than Forui |
| Resolution | Exact dry-run did not finish within the bounded observation and was stopped | Resolution cost is evidence; it is not a security failure |
| License/activity | MIT; `nank1ro/flutter-shadcn-ui` is public, unarchived, 2,784 stars, 191 forks, 36 open issues, pushed 2026-08-16 | Active |
| Advisories | OSV Pub query for `shadcn_ui` 0.56.1 returned no known vulnerabilities on 2026-08-23 | No known advisory; not proof of absence |

The backup receives no code unless Forui is eliminated or a named unresolved
gap makes a second package necessary. A general desire for more examples is
not a trigger.

## Evidence sources

- `https://pub.dev/api/packages/forui`
- `https://github.com/duobaseio/forui`
- `https://api.osv.dev/v1/query`
- local pub archive and source under the pub cache for `forui-0.25.0`
- `https://pub.dev/api/packages/shadcn_ui`
- `https://github.com/nank1ro/flutter-shadcn-ui`

Network and repository activity values are snapshots from 2026-08-23 and must
be refreshed before production adoption or release.
