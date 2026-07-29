# Admin9 Design System

> Version: v1.0.0
> Status: frozen normative baseline
> Scope: Android and iOS Flutter apps derived from Admin9 App Foundation

## 1. Purpose and authority

Admin9 Design System is the single specification source for shared product semantics, platform behavior, visual foundations, public `App*` component contracts, page patterns, accessibility, and quality gates. `Admin9 UI` means its Flutter implementation layer; it is not a competing system.

The Design System version, Foundation Git version, Foundation tag, app version, and customer business version are independent. Design System v1.0.0 does not imply app version 1.0.0 or completed runtime implementation.

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

The implementation remains repository-local under future `lib/core/design_system/`, exported only by future `lib/admin9_ui.dart`; Brand enters only through future `lib/app/brand/app_brand_theme.dart`. No runtime files exist yet. A package is reconsidered only when a second real project needs synchronized fixes, an independent version cadence is required, or this repository cannot own Gallery, tests, and documentation.

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
flutter analyze tool/design_system/design_system_contract_probe.dart
dart run tool/design_system/verify_rule_links.dart
node tool/design_system/verify_documentation.mjs
```

The declaration probe is non-exported and contains abstract declarations/value objects only. It proves Dart syntax, generic bounds, nullability, `Key`, callback, and state-owner shapes; it does not claim a runtime implementation.

## 7. Current boundary

v1.0.0 freezes the specification and executable contracts. It does not authorize edits to `lib/`, runtime tests, platform projects, dependencies, navigation, theme, or business behavior. Runtime rendering, Gallery isolation, device gestures, readers, IME, and platform accessibility behavior remain implementation-stage gates, explicitly Unknown today.
