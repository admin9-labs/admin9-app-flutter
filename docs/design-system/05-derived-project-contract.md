# Derived-Project Contract

## 1. Source record

<a id="ds-der-001"></a>

Every derived project MUST keep one repository-root `admin9-foundation.yaml`. No alternative filename or free-form Markdown record satisfies this gate. The authoritative [JSON Schema](schema/admin9-foundation.schema.json), [compatibility registry](schema/admin9-foundation-compatibility.json), [valid fixture](fixtures/foundation-manifest/valid.yaml), and invalid fixtures define the complete field contract. Canonical v1 files use JSON syntax, which is valid YAML 1.2 and can be parsed by the dependency-free Dart validator.

The full Foundation commit is mandatory. `tag` contains the exact source tag when one exists and is `null` otherwise; it is never invented. `upstreamRemote` is the approved canonical HTTPS source `https://github.com/admin9-labs/admin9-app-flutter.git`. Each derived repository configures that URL as a fetch-only remote named `foundation`, sets its push URL to the literal `DISABLED`, and keeps its customer-owned push remote separate. The governance validator rejects a missing, renamed, writable, SSH, or different Foundation remote.

| Field | Required value |
| --- | --- |
| Foundation source | full commit SHA and exact tag or `null` |
| Design System | exact specification version `1.0.2` and source tag `design-system-v1.0.2` |
| App identity | app name/version, Android application ID, iOS bundle ID |
| Brand evidence | theme version/hash, actual primary/secondary light-dark pairs, Logo and launch asset paths |
| Toolchain | Flutter and Dart versions |
| Ownership/paths | Core, Brand, Business owners and frozen paths |
| Exports | public barrel, Brand entry, Core-internal root |
| Compatibility | Design System range and exact-commit policy |
| Deviations | rule ID, reason, owner/Core approver, apps/platforms, user/accessibility impact, scope, evidence, dates, recovery condition |
| Provenance | generator and UTC generation timestamp; validator prints its actual run time |

Foundation, Design System, and customer business versions remain independent.

`brandConfiguration` is the only machine brand-evidence record and corresponds to `lib/app/brand/app_brand_theme.dart` plus generated native assets; it does not create another brand entry. `approvedFont` is a reviewed family name or `null`; `radiusDelta` is an integer from -2 through 2. Logo and launch sources are square PNG files. The Logo is at least 1024x1024 because it generates Android launcher and iOS AppIcon sizes; the launch source generates Android and iOS launch images. Both paths MUST resolve canonically inside the manifest-adjacent `assets/` subtree; dot-segment and symlink escapes are rejected. `themeSha256` is SHA-256 of UTF-8 JSON with no whitespace and this exact property order: `primaryPair`, `secondaryPair`, `approvedFont`, `radiusDelta`, `logoSha256`, `launchAssetSha256`; each color pair keeps `light`, then `dark`. The hash excludes `themeSha256`, paths, app identity, and timestamps. The validator recomputes all three hashes relative to the manifest directory, validates real calendar dates and exact UTC timestamps, and rejects edited theme data, escaped assets, or plausible-looking digests.

The Dart Brand entry exposes only the same primary/secondary light-dark values, approved font, radius delta, and asset paths. Core derives `onPrimary` and `onSecondary` from the frozen semantic contrast policy; a derived app cannot inject untracked foreground colors. The manifest fixture intentionally demonstrates a derived customer's different valid brand values and is not the Admin9 default theme. A derived project first validates its root manifest, then runs `dart run tool/design_system/generate_brand_entry.dart admin9-foundation.yaml .`. The generator writes the Dart Brand/App identity, `pubspec.yaml` version and asset list, Android namespace/application ID/label/Kotlin package/icons/launch image, and iOS bundle ID/display names/icons/launch images from the same validated source. `dart run tool/design_system/verify_brand_contract.dart admin9-foundation.yaml .` checks every generated text and binary output without writing. Hand-editing generated outputs is prohibited; a changed manifest is regenerated and reviewed instead.

The manifest validator also computes WCAG relative luminance for both primary values. Light primary MUST provide at least `3:1` focus contrast against light background, surface, and surfaceContainer; dark primary MUST meet the same threshold against all dark surfaces. Core retains the frozen preferred foreground when it reaches `4.5:1`, otherwise chooses the higher-contrast black or white foreground. Runtime theme resolution repeats the focus check and rejects invalid manually constructed Brand data instead of rendering an inaccessible theme.

## 2. Ownership and imports

| Area | Owner | Allowed consumers | Rule |
| --- | --- | --- | --- |
| `lib/core/design_system/` implementation | Core maintainers | `lib/admin9_ui.dart` public barrel only | derived apps do not edit internals for branding |
| `lib/app/brand/app_brand_theme.dart` | app/brand owner, Core review | app host only | the only Brand Theme data entry; Business cannot import it |
| `lib/app/app_identity.dart` | app owner | app host and Business read-only consumers | stable name/product/version/Logo identity; no token or platform-control access |
| `lib/ui/features/<feature>/` | Business feature owner | same feature; public feature route/contracts | no cross-feature implementation imports |
| app host/navigation | Foundation owner | feature routes through declared boundary | feature does not replace Core controls or platform mapping |
| Gallery | Core maintainers | debug/profile only | no release route or tree-shaken dependency leakage |

Business MUST NOT depend on Core internal files or unexported types. Business may import only `lib/app/app_route_names.dart` and the read-only `lib/app/app_identity.dart` from App; every other `lib/app/**` path is denied. Core MUST NOT import feature models, ViewModels, repositories, providers, services, sessions, or customer content.

Phase 0D creates these exact paths with real non-visual declarations, token lookup, Brand data, import checks, and Gallery registration isolation. It MUST NOT create an empty barrel or placeholder theme object. Visual components are added to the same Core/public paths only in their owning implementation phase.

## 3. Override matrix

| Item | Allowed | Review required | Prohibited |
| --- | --- | --- | --- |
| app name, logo, launch assets | `admin9-foundation.yaml#app` and `#brandConfiguration`, generated into the two fixed App files | asset hashes, platform generation, legibility and safe-area review | hand-editing generated identity/Brand data, editing Core, or inventing another entry |
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
| v1.0.1 Phase 0D contract | `1c91f21eaee511f081d5addbe765151f27a53fb9` Foundation source baseline | 3.44.1 / 3.12.1 | specification plus non-visual boundary mechanisms; visual runtime remains unavailable |
| v1.0.2 Phase 6 delivery | `54d139c70d6e4b873d7bc97b445e10b0264d450d` Foundation implementation | 3.44.1 / 3.12.1 | approved runtime, release and representative-device baseline; named P2/P3 backlog and Android 14+ physical Unknown remain explicit |

An app is specification-conforming only when its manifest passes the validator and its exact tuple appears as `approved` in the machine compatibility registry. The validator rejects merely format-valid unapproved commits, unknown rule IDs, expired/invalid deviations, reversed date ranges, invalid UTC provenance timestamps, asset-subtree escapes, extra fields, and unauthorized overrides. It is runtime-conforming only after a compatibility row names an implemented Foundation commit and all required implementation/device gates pass. Arbitrary version mixing is prohibited; v1.0.1 does not claim that Phase 0D implements visual components, while v1.0.2 is approved only for the exact Phase 6 implementation commit above.

1. Record current Foundation and Design System sources.
2. Configure and verify the read-only source, then fetch it: `git remote add foundation https://github.com/admin9-labs/admin9-app-flutter.git`, `git remote set-url --push foundation DISABLED`, `dart run tool/design_system/verify_repository_governance.dart --derived-root .`, and `git fetch foundation --tags`.
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

A new project is specification-conforming only when the manifest validator exits 0, the repository-root generator and Brand/native verifier both pass, its compatibility pair is approved, its fetch-only `foundation` remote passes the governance validator, it imports shared UI only from `lib/admin9_ui.dart`, has no forbidden imports/platform branches/raw interactive controls, passes automated gates, records device Unknowns honestly, and has no expired deviation. A cloned app with changed colors but unverified contrast or stale native identity is not conforming.
