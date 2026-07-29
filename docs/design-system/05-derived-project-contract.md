# Derived-Project Contract

## 1. Source record

<a id="ds-der-001"></a>

Every derived project MUST keep one repository-root `admin9-foundation.yaml`. No alternative filename or free-form Markdown record satisfies this gate. The authoritative [JSON Schema](schema/admin9-foundation.schema.json), [compatibility registry](schema/admin9-foundation-compatibility.json), [valid fixture](fixtures/foundation-manifest/valid.yaml), and invalid fixtures define the complete field contract. Canonical v1 files use JSON syntax, which is valid YAML 1.2 and can be parsed by the dependency-free Dart validator.

The full Foundation commit is mandatory. `tag` contains the exact source tag when one exists and is `null` otherwise; it is never invented. `upstreamRemote` records the approved HTTPS source or `null` when the Foundation source has no canonical remote; a `null` value remains an explicit upgrade Unknown. Each derived repository later configures a non-null approved URL as a fetch-only remote named `foundation`; its customer-owned push remote remains separate. This repository currently has no canonical remote, so the valid fixture records `null` rather than fabricating identity.

| Field | Required value |
| --- | --- |
| Foundation source | full commit SHA and exact tag or `null` |
| Design System | exact specification version `1.0.0` and source tag `design-system-v1.0.0` |
| App identity | app name/version, Android application ID, iOS bundle ID |
| Brand evidence | theme version/hash, actual primary/secondary light-dark pairs, Logo and launch asset paths |
| Toolchain | Flutter and Dart versions |
| Ownership/paths | Core, Brand, Business owners and frozen paths |
| Exports | public barrel, Brand entry, Core-internal root |
| Compatibility | Design System range and exact-commit policy |
| Deviations | rule ID, reason, owner/Core approver, apps/platforms, user/accessibility impact, scope, evidence, dates, recovery condition |
| Provenance | generator and UTC generation timestamp; validator prints its actual run time |

Foundation, Design System, and customer business versions remain independent.

`brandConfiguration` is the only machine brand-evidence record and corresponds to `lib/app/brand/app_brand_theme.dart`; platform build tooling may derive launch assets from its named source, but it does not create another brand entry. `approvedFont` is a reviewed family name or `null`; `radiusDelta` is an integer from -2 through 2. Logo and launch source bytes have separate SHA-256 values, and both paths MUST resolve canonically inside the manifest-adjacent `assets/` subtree; dot-segment and symlink escapes are rejected. `themeSha256` is SHA-256 of UTF-8 JSON with no whitespace and this exact property order: `primaryPair`, `secondaryPair`, `approvedFont`, `radiusDelta`, `logoSha256`, `launchAssetSha256`; each color pair keeps `light`, then `dark`. The hash excludes `themeSha256`, paths, app identity, and timestamps. The validator recomputes all three hashes relative to the manifest directory, validates real calendar dates and exact UTC timestamps, and rejects edited theme data, escaped assets, or plausible-looking digests.

## 2. Ownership and imports

| Area | Owner | Allowed consumers | Rule |
| --- | --- | --- | --- |
| `lib/core/design_system/` future implementation | Core maintainers | `lib/admin9_ui.dart` public barrel only | derived apps do not edit internals for branding |
| `lib/app/brand/app_brand_theme.dart` | app/brand owner, Core review | app host | the only Brand Theme data entry; only approved tokens/assets |
| `lib/ui/features/<feature>/` | Business feature owner | same feature; public feature route/contracts | no cross-feature implementation imports |
| app host/navigation | Foundation owner | feature routes through declared boundary | feature does not replace Core controls or platform mapping |
| Gallery | Core maintainers | debug/profile only | no release route or tree-shaken dependency leakage |

Business MUST NOT depend on Core internal files or unexported types. Core MUST NOT import feature models, ViewModels, repositories, providers, services, sessions, or customer content.

Phase 0D MUST create these exact paths only when real declarations/implementation exist. It MUST NOT create an empty barrel or placeholder theme object. Until then, the paths are contracts rather than current source claims.

## 3. Override matrix

| Item | Allowed | Review required | Prohibited |
| --- | --- | --- | --- |
| app name, logo, launch assets | `admin9-foundation.yaml#app`, `#brandConfiguration`, and `lib/app/brand/app_brand_theme.dart` only | asset hashes, platform generation, legibility and safe-area review | editing Core widget implementation or inventing another brand entry |
| primary/secondary color pairs | through Brand Theme | light/dark/high-contrast calculation and visual review | raw feature colors or reduced contrast |
| font | no default override | Chinese/Bold Text/max-size/performance approval | page-local fonts or loss of system scaling |
| spacing/radius personality | none by feature | bounded Brand Theme adjustment documented by Core | hit-target reduction, platform-control reshaping, arbitrary values |
| business copy/content/routes | Business owns | legal/security review where relevant | embedding customer truth in Core |
| platform mapping, gestures, keyboard | none | only a Core spec version change | feature platform branches or direct Material/Cupertino selection |
| semantics, contrast, system text, hit targets | none | only stricter behavior | weakening or suppressing system requirements |
| dangerous operation rules | Business supplies condition/consequence | product/security review | Core guessing consequences or feature bypassing confirmation |

## 4. New business components

<a id="ds-shr-001"></a>

The first real consumer stays inside its feature. A second same-customer consumer with the same domain responsibility first moves to the derived app's `lib/ui/shared/`; this remains Business and cannot be exported by `admin9_ui.dart`. Only evidence of the same general product responsibility across distinct business domains or derived apps triggers a Core sharing request, never automatic promotion. The request MUST include consumers, semantic purpose, state owner, platform mapping, accessibility, responsive behavior, public API proposal, tests, and why composition of existing Core controls is insufficient.

Promotion to Core requires Design System owner approval. Similar appearance without identical responsibility is not reuse evidence. Unknown future business components are not modeled in advance.

## 5. Upgrade and contribution flow

Each approved Design System release adds a compatibility row before a derived project may upgrade:

| Design System | Foundation source | Flutter/Dart | Status |
| --- | --- | --- | --- |
| v1.0.0 specification | `e473dabfeb572fe23bcdb4ccce606eb00f6baf7b` Foundation baseline | 3.44.1 / 3.12.1 | normative contract; runtime implementation remains unavailable |

An app is specification-conforming only when its manifest passes the validator and its exact tuple appears as `approved` in the machine compatibility registry. The validator rejects merely format-valid unapproved commits, unknown rule IDs, expired/invalid deviations, reversed date ranges, invalid UTC provenance timestamps, asset-subtree escapes, extra fields, and unauthorized overrides. It is runtime-conforming only after a later compatibility row names an implemented Foundation commit and all Phase 1/device gates pass. Arbitrary version mixing is prohibited; v1.0.0 does not claim the current runtime implements the system.

1. Record current Foundation and Design System sources.
2. Fetch the read-only `foundation` remote and read the target release changelog/deprecations.
3. Compare Core files, Brand input, public barrel, Gallery, and test gates.
4. Resolve in order: accessibility/system requirement -> platform behavior -> Core semantic contract -> approved Brand Theme -> Business behavior -> local deviation.
5. Re-run analyze, tests, Gallery Goldens, import-boundary checks, and required device gates.
6. Record accepted changes, retained deviations, owner, expiry, and source SHA.

Generic fixes flow back to Foundation with a failing test and no customer data. Customer-specific capability stays in the derived app. Deprecation requires replacement, migration note, first deprecated version, at least one subsequently approved Design System minor-version support window, and a declared removal version. Breaking removal requires a major version. Silent removal is prohibited.

## 6. Package trigger

The implementation remains repository-local. Re-evaluate a versioned `admin9_ui` package when any one condition is confirmed:

- a second real Flutter project must consume the same Core fix;
- Foundation and a derived project require independent release cadence;
- clone-based upgrades repeatedly produce Core merge conflicts;
- the current repository cannot own Gallery, tests, documentation, and compatibility evidence.

The review compares package maintenance cost, source compatibility, release ownership, and migration path. v1.0 creates no package or publishing infrastructure.

## 7. Clone acceptance

A new project is specification-conforming only when `dart run tool/design_system/validate_foundation_manifest.dart admin9-foundation.yaml` exits 0, its compatibility pair is approved, its fetch-only `foundation` remote is recorded in repository setup evidence, it uses `lib/app/brand/app_brand_theme.dart`, imports shared UI only from `lib/admin9_ui.dart`, has no forbidden imports/platform branches/raw interactive controls, passes automated gates, records device Unknowns honestly, and has no expired deviation. A cloned app with changed colors but unverified contrast is not conforming.
