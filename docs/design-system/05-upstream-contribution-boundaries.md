# Upstream Contribution Boundaries

> Scope: `MUST`, `MUST NOT`, `SHOULD`, and `MAY` in this document apply only
> to implementations and contributions proposed for inclusion in the upstream
> Admin9 App Starter repository. They are not additional license conditions and
> do not govern independent forks.

## 1. Repository boundaries

| Area | Upstream owner | Allowed upstream dependency direction |
| --- | --- | --- |
| `lib/core/design_system/` | Design System maintainers | Core depends only on Flutter and business-neutral Core code |
| `lib/admin9_ui.dart` | Design System maintainers | exports the exact supported public UI surface |
| `lib/app/brand/` | App/Brand maintainers | App Host consumes the single Brand Theme entry |
| `lib/app/app_identity.dart` | App maintainers | App Host and approved read-only consumers use stable identity values |
| `lib/ui/features/<feature>/` | feature contributor | the feature, public UI barrel, and explicit App read-only allowlist |
| `lib/ui/shared/` | business UI contributors | shared by features in this repository, never exported as Core by default |
| App Host and navigation | App maintainers | compose features, Core, Brand, privacy, routes, and local state |

Business contributions MUST NOT import Core implementation files or unexported
types. They MAY import only the exact App read-only paths accepted by the import
boundary verifier. Core MUST NOT import feature models, ViewModels,
repositories, providers, services, sessions, permissions, or content.

These checks protect the maintainability of upstream code. A fork may remove,
replace, or change them in its own repository.

## 2. Brand and identity

The upstream default identity is `Admin9 App Starter`. The optional App
configuration schema contains only product identity and Brand values. No
configuration file is required for a fork or for ordinary source use.

When an upstream contribution uses the configuration tool, its configured
values MUST pass schema, asset-containment, PNG, and contrast validation, and
the generated Dart/native output MUST pass drift verification. A passing result
means only that the upstream files match the selected configuration; it is not
certification of another project.

Changing package, application, or bundle identifiers has installation and
signing consequences. An upstream contribution MUST NOT change them as an
incidental part of a display-name or documentation change.

## 3. Shared component promotion

<a id="ds-shr-001"></a>

The first real upstream consumer stays inside its feature. A second consumer in
this repository with the same business responsibility may move the code to
`lib/ui/shared/`; this remains Business code. Promotion to Core requires a
business-neutral semantic responsibility, more than visual similarity, and an
upstream proposal that covers consumers, state ownership, platform mapping,
accessibility, responsive behavior, API shape, tests, and why composition of
existing controls is insufficient.

Unknown future components are not modeled in advance. No fork is required to
request promotion or contribute its fixes upstream.

## 4. App Host and truthful state

Upstream contributions MUST keep backend-free flows truthful. Until a real
service is introduced, authentication and sensitive actions MAY validate local
input but MUST NOT create users, sessions, tokens, verification messages, or
success results. Legal hosts MUST NOT invent formal terms or organization data.

The App Host composes startup, privacy, routing, settings, and feature entry. It
MUST NOT become a customer-specific data layer or dynamic module platform
without a separately accepted product and architecture change.

## 5. Accessibility and platform quality

An upstream contribution that changes shared UI MUST preserve the applicable
Design System rules, platform mapping, semantics, text scaling, focus, keyboard,
contrast, hit targets, responsive matrices, Gallery isolation, and tests. Device
claims MUST be tied to the exact tested source and artifact; unexecuted checks
remain `Unknown`.

Exceptions for upstream code are resolved through the normal review and
versioning process. Product-specific variation that is not accepted upstream
stays outside the upstream Core. There is no downstream deviation registry or
expiry requirement.

## 6. Upstream change and release flow

Upstream contributions SHOULD include a focused test for behavior changes and
update public contracts or the Changelog when applicable. Deprecations identify
a replacement and release window; breaking removals follow SemVer. Releases run
the repository CI and relevant Android/iOS build and device checks.

`CODEOWNERS`, `OWNERS.md`, branch protection, CI, SemVer, and release notes
govern only contributions and releases in this upstream repository. They do not
assign ownership, support obligations, upgrade paths, or release requirements
to forks.
