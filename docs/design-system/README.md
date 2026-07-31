# Admin9 Design System

> Version: v1.0.3
> Status: frozen normative baseline
> Scope: Android and iOS Flutter apps derived from Admin9 App Foundation

## 1. Purpose and authority

Admin9 Design System is the single specification source for shared product semantics, platform behavior, visual foundations, public `App*` component contracts, page patterns, accessibility, and quality gates. `Admin9 UI` means its Flutter implementation layer; it is not a competing system.

The Design System version, Foundation Git version, Foundation tag, app version,
and customer business version are independent. Design System v1.0.3 does not
imply app version 1.0.0. This Foundation's Phase 0D-6 runtime implementation is
complete, but derived projects must still record and verify their own exact
Foundation commit and compatibility tuple.

Normative words are fixed:

- **MUST**: mandatory; a deviation requires written approval.
- **SHOULD**: expected; a documented, evidence-backed exception may be approved.
- **MAY**: optional within the stated boundary.

<a id="ds-gov-001"></a>

Every normative rule records its layer, platforms, default behavior, permitted overrides, prohibited overrides, evidence, verification, and deviation route. This directory is the only normative Design System source. The [implementation plan](../architecture/admin9-ui-implementation-plan.md) is downstream and MUST conform. Product baselines, audits, Phase 0 reports, and Phase 0C assets are evidence only. A conflict is resolved by: user safety and accessibility hard requirements, platform system behavior, business semantic consistency, Design System consistency, then brand preference.

## 2. Three-layer model

| Layer | Owns | May vary | Must not do |
| --- | --- | --- | --- |
| Admin9 Core | semantic tokens, platform mapping, component states, page patterns, accessibility, responsive rules, quality gates, public API and import boundary | only through a reviewed Design System version change | read business models/services; expose raw platform styling escapes; weaken system behavior |
| Brand Theme | brand color, logo, launch assets, approved font choice and limited visual character | through the single theme input | alter state meaning, hit targets, contrast, system text, semantics, keyboard or back behavior |
| Business Layer | real routes, content, fields, identity, permissions, services and dangerous-operation conditions | per derived app | import Core internals, select Material/Cupertino directly, or promote first-use business code to Core |

The implementation remains repository-local under `lib/core/design_system/`, exported only by `lib/admin9_ui.dart`; Brand enters only through `lib/app/brand/app_brand_theme.dart`. Phase 0D installs the real non-visual contracts and boundary mechanisms at those paths. Concrete visual Widgets enter the public barrel only when their owning implementation phase completes. A package is reconsidered only when a second real project needs synchronized fixes, an independent version cadence is required, or this repository cannot own Gallery, tests, and documentation.

## 3. Rule record

All modules use this compact rule shape:

| Field | Meaning |
| --- | --- |
| Layer/platform | Core, Brand, or Business; Android, iOS, or both |
| Default | the one Admin9 behavior |
| Allowed override | the only supported customization entry |
| Prohibited override | behavior that cannot be weakened or bypassed |
| Evidence | official guidance plus Admin9 product/reference evidence |
| Verification | automated and/or device evidence |
| Deviation | owner, reason, scope, evidence, expiry, and recovery condition |

## 4. Modules

- [Foundations](01-foundations.md)
- [Platform adaptation](02-platform-adaptation.md)
- [Components](03-components.md)
- [Page patterns](04-page-patterns.md)
- [Derived-project contract](05-derived-project-contract.md)
- [Accessibility and quality](06-accessibility-quality.md)
- [Conflict register](evidence/admin9-design-system-v1-conflicts.md)
- [Normative rule register](evidence/admin9-design-system-v1-rule-register.md)
- [Official source and evidence ledger](evidence/admin9-design-system-v1-sources.md)
- [Visual calibration record](evidence/admin9-design-system-v1-visual-calibration.md)
- [Machine manifest schema](schema/admin9-foundation.schema.json)
- [Approved compatibility registry](schema/admin9-foundation-compatibility.json)
- [Manifest fixtures](fixtures/foundation-manifest/valid.yaml)
- [Owners](OWNERS.md)
- [v1.0 acceptance report](admin9-design-system-v1-acceptance-report.md)
- [Changelog](CHANGELOG.md)

Unknown business components are not pre-abstracted. A visual reference demonstrates shared rules; it is not a page template, business schema, or DSL.

## 5. Governance

A proposal enters the system as: original observation -> professional diagnosis -> industry practice -> one Admin9 recommendation -> severity -> delivery phase -> acceptance evidence. User preference alone does not freeze a token or create a defect.

Deviation requests MUST name the rule, owner, affected apps, business reason, accessibility/platform impact, evidence, expiry date, and removal condition. Core owners decide. Permanent product-specific variation belongs in Brand or Business, not a silent Core fork.

## 6. Machine contracts

Each derived project keeps a repository-root `admin9-foundation.yaml`. Its canonical v1 serialization is JSON syntax, which is valid YAML 1.2, so the validator uses the bundled Dart SDK and adds no dependency. This Foundation repository intentionally has no root manifest until it is cloned as an app. Verify this repository's contract with `--fixtures`; a derived project validates its own root file:

```bash
dart run tool/design_system/validate_foundation_manifest.dart --fixtures
# Derived-project repository only:
dart run tool/design_system/validate_foundation_manifest.dart admin9-foundation.yaml
# Derived-project generation and drift check:
dart run tool/design_system/generate_brand_entry.dart admin9-foundation.yaml .
dart run tool/design_system/verify_brand_contract.dart admin9-foundation.yaml .
dart run tool/design_system/verify_repository_governance.dart --derived-root .
flutter analyze tool/design_system/design_system_contract_probe.dart
flutter analyze tool/design_system/design_system_implementation_probe.dart
dart run tool/design_system/verify_public_api_parity.dart --self-test
dart run tool/design_system/verify_import_boundaries.dart --fixtures
dart run tool/design_system/verify_import_boundaries.dart --phase=final
dart run tool/design_system/verify_gallery_boundary.dart
dart run tool/design_system/verify_brand_contract.dart
dart run tool/design_system/verify_brand_contract.dart --fixtures
dart run tool/design_system/verify_rule_links.dart
node tool/design_system/verify_documentation.mjs
```

After the v1.0.3 implementation commit exists and its compatibility
tuple is updated, the final provenance gate is mandatory:

```bash
foundation_implementation_commit="$(git rev-parse 'design-system-v1.0.3^{commit}^')"
dart run tool/design_system/verify_design_system_release.dart \
  --version=1.0.3 \
  --foundation-commit="$foundation_implementation_commit"
```

The command intentionally fails while README, CHANGELOG, the derived-project
contract, schema, valid fixture or compatibility registry disagree. A commit
cannot name itself: Phase 6 implementation is committed first, then a separate
acceptance/provenance commit records that exact SHA and the final annotated tag
points to the provenance commit.

The declaration probe is non-exported and contains abstract declarations/value objects only. It proves Dart syntax, generic bounds, nullability, `Key`, callback, and state-owner shapes; it does not claim a runtime implementation. The implementation probe instantiates the frozen implementations, while `verify_public_api_parity.dart` compares declaration and implementation constructors through analyzer AST, excludes only the probe-local icon-map helper, permits only the explicitly deferred `AppSelect` and `AppSegmentedControl`, and runs mandatory drift and missing-implementation mutation self-tests.

## 7. v1.0.1 implementation boundary

v1.0.1 makes one non-product clarification to v1.0.0: Phase 0D implements and exports only honest non-visual contracts and mechanisms. It proves value-object construction, immutable token lookup, Brand input, App-host route ownership, analyzer-AST import boundaries, and the debug/profile Gallery registry with a release guard. A concrete visual `App*` Widget is implemented, instantiated, tested, and exported only in its assigned Phase 1-4; `AppSelect` and `AppSegmentedControl` still wait for real consumers. This clarification changes no frozen token, public API shape, platform mapping, or product decision.

Phase 0D does not claim theme rendering, component rendering, Gallery page reachability, device gestures, readers, IME, or platform accessibility behavior. Those remain assigned to Phase 1-6 and are Unknown until their stated gates pass.

## 8. v1.0.2 evidence-policy patch

v1.0.2 changes evidence responsibility and release severity only. It does not
change tokens, public component APIs, platform mappings, page patterns or
product behavior. Deterministic states, focus requests, Semantics, validation,
responsive behavior, tokens, platform mapping, hit targets, contrast and
business truth are automation/code-review responsibilities. Human device review
uses one representative flow per platform only for actual reader output,
system gestures, real IME behavior, safe areas and release install/cold launch.

P0/P1 block release. P2/P3 remain owned, trigger-based backlog and are never
reported as `Pass` without evidence. The Phase 6 claim is limited to a minimum
usable accessibility baseline on representative Android/iOS flows. It is not a
WCAG conformance statement, accessibility certification or proof of every
assistive technology and page combination.

Phase 6 closes with no open P0/P1. The accepted Android and iOS artifacts,
representative human observations, emulator system gates and P2/P3 backlog are
owned by the [Phase 6 report](../architecture/admin9-ui-phase-6-acceptance-report.md).

## 9. v1.0.3 Foundation closure

v1.0.3 closes the two P1 and four blocking P2 findings selected by the final
Foundation review. It fails closed when privacy consent cannot persist, removes
the empty lifecycle owner, makes current-tab reselection explicit, restores
constructor-contract completeness, generates manifest-derived Dart and native
identity without rewriting derived Business native sources, and binds
governance to the canonical repository and named maintainer. iOS AppIcons are
generated as opaque RGB, and the Brand verifier covers that release property.

The v1.0.2 Phase 6 device records remain historical, hash-bound evidence for
their named artifacts and source. v1.0.3 does not relabel those records as a
fresh device run; current physical-device and assistive-technology repetition
remains Unknown until separately executed and recorded.
