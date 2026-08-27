# Admin9 Design System

Current recorded release: `2.0.0`

Admin9 Design System defines the public UI, platform adaptation,
accessibility, responsive behavior, and quality gates maintained in the
upstream Admin9 App Starter repository.

## 1. Scope Of Normative Language

<a id="ds-gov-001"></a>

`MUST`, `MUST NOT`, `SHOULD`, and `MAY` throughout this directory apply only
to implementations and contributions proposed for inclusion in the upstream
Admin9 App Starter repository. They are upstream engineering and review rules,
not additional Apache 2.0 license conditions. Independent forks may adopt,
change, or remove them and are not certified, tracked, or supported by this
project.

The current normative modules are:

1. [Foundations](01-foundations.md)
2. [Platform Adaptation](02-platform-adaptation.md)
3. [Components](03-components.md)
4. [Page Patterns](04-page-patterns.md)
5. [Upstream Contribution Boundaries](05-upstream-contribution-boundaries.md)
6. [Accessibility and Quality](06-accessibility-quality.md)

The [rule register](evidence/admin9-design-system-v1-rule-register.md) maps
stable rule IDs to current modules and automated evidence. Prior acceptance
reports and device artifacts are historical records; see
[Historical Records](../HISTORY.md).

Generated [visual references](visual-references.md) support paired design
review but do not override source, tests, Goldens, or device evidence.

## 2. Three-Layer Model

| Layer | Upstream responsibility | Allowed change in upstream | Not accepted into upstream Core |
| --- | --- | --- | --- |
| Core | semantic tokens, public `App*` components, platform mapping, accessibility and quality behavior | business-neutral, reusable API and implementation changes with tests | customer state, content, permissions, services, feature imports, raw product styling |
| Brand Theme | default primary/secondary pairs, optional font, limited radius character, Logo and launch resources | verified changes through the single Brand entry or optional App config | state meaning changes, reduced hit targets/contrast, navigation or semantics changes |
| Business | real pages, routes, copy, state, data and feature rules in this repository | feature-first implementation and local sharing | automatic promotion into Core based on visual similarity |

The App Host composes these layers. They are repository dependency boundaries,
not a mandatory runtime architecture for forks.

## 3. Product And Platform Principle

The Design System follows one rule: one Admin9 brand appearance and business
experience, with operating-system interaction differences retained.

- Brand-owned visible controls use one first-party Admin9 language on Android
  and iOS behind the public `App*` API.
- Feature code does not choose interactive Material/Cupertino controls or
  branch on the target platform.
- Routes, back gestures and transitions, keyboards, autofill/password managers,
  permissions, sharing, system pickers, safe areas, system bars, and operating-
  system accessibility behavior remain platform-owned.
- Business information, action order, copy, state, feedback meaning, and
  recovery remain identical across platforms.

Static references prove design intent only. Widget tests prove deterministic
state and layout. Installed builds and device observations are required for
system gestures, readers, real IME behavior, safe areas, signing, installation,
and cold launch.

## 4. Public Surface And Ownership

`lib/admin9_ui.dart` is the exact public Core barrel. Analyzer-based gates
enforce its export set and import direction. Gallery code remains debug/profile
only and is absent from the release route surface.

`docs/design-system/OWNERS.md` and `.github/CODEOWNERS` assign review
responsibility only inside this upstream repository. Forks choose their own
maintainers and process.

## 5. Optional App Configuration

No manifest or configuration file is required. The optional App configuration
contains only App identity and Brand values:

- schema: [app-config.schema.json](schema/app-config.schema.json)
- example: [valid.yaml](fixtures/app-config/valid.yaml)
- guide: [App and Brand customization](../customization/quickstart.md)

```bash
dart run tool/design_system/validate_app_config.dart --fixtures
dart run tool/design_system/validate_app_config.dart path/to/app-config.yaml
dart run tool/design_system/apply_app_config.dart path/to/app-config.yaml .
dart run tool/design_system/verify_app_config.dart path/to/app-config.yaml .
```

The schema has no source commit, remote, ownership, compatibility, deviation,
expiry, or provenance fields. Validation and generated-output verification are
local consistency checks, not compatibility approval or certification.

## 6. Upstream Machine Gates

| Gate | Upstream evidence |
| --- | --- |
| format/analyze/test | Dart style, static analysis, Widget and unit behavior |
| contract probes | public declaration and implementation shape |
| import boundaries | Core/App/Brand/Business dependency direction and public barrel |
| UI candidate boundary | candidate package adapter isolation, public API leakage, and root Theme independence |
| Gallery boundary | debug/profile reachability and release isolation |
| paired visual references | generated asset dimensions, required state labels, hashes, and explicitly allowed platform differences |
| App configuration | optional schema fixtures, default identity, native display names, and generated drift |
| rule links | stable IDs, module anchors, and named quality gates |
| upstream ownership | current upstream `OWNERS.md` and `CODEOWNERS` records |
| documentation | Markdown structure and local links |
| platform builds | Android release and unsigned iOS release compilation |

The canonical command list is maintained in
[Validation](../validation/README.md) and CI. These gates apply to upstream
changes only.

## 7. Versioning And Change Control

Design System changes follow SemVer and are recorded in [CHANGELOG.md](CHANGELOG.md).
Public API removals require an appropriate version change and migration note.
Existing tags are immutable and are never moved or recreated.

The `design-system-v1.0.0` through `design-system-v1.0.3` tags and historical
device evidence preserve their original Foundation-era facts. They do not
establish a current downstream compatibility matrix. `design-system-v2.0.0`
is the current Starter baseline. Later changes remain `Unreleased` until a
separate release decision is made.

## 8. Current Evidence Boundary

Automated tests cover public contracts, import boundaries, platform mappings,
responsive matrices, semantics, contrast, focus, persistence, and truthful
unavailable-service behavior. Historical device evidence remains valid only for
the exact source/artifact it names. Later unexecuted device or assistive-
technology checks remain `Unknown`; no compatibility or accessibility
certification is inferred from earlier evidence.

The first-party visible component route is the current implementation. Its
former comparison POC and temporary gate documents are historical; no candidate
package remains in production. Current build and device limits are maintained
only in [Delivery](../delivery/README.md), and superseded decisions are indexed
in [History](../HISTORY.md).
