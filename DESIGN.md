# Admin9 App Starter Design

Admin9 App Starter is an Android/iOS Flutter starting point. It owns the
upstream app host, shared Design System, platform adaptation, accessibility,
local preferences, default identity, and repository quality gates. It does not
own downstream products, customer data models, permissions, services, delivery,
or release processes.

## 1. Responsibility Boundaries

| Area | Current upstream responsibility | Change rule for upstream contributions |
| --- | --- | --- |
| Core | tokens, public `App*` components, platform mapping, accessibility and quality behavior | reusable, business-neutral changes with tests |
| Brand | default colors, visual traits, Logo and launch resources | one App Brand entry; optional configuration may regenerate it |
| Business | real routes, copy, state and feature behavior in this repository | feature-first; shared locally only after a real second consumer |
| App Host | startup, composition, privacy gate, navigation, identity, settings and legal hosts | composition only; no fabricated backend state |

These are dependency and maintenance boundaries for code proposed to this
upstream repository. They are not additional Apache 2.0 conditions and do not
govern independent forks.

Business code accesses shared Core UI through `lib/admin9_ui.dart`. Core does
not import feature models, ViewModels, repositories, providers, services,
sessions, permissions, or product content. The App Host has a small, explicit
allowlist for composition-only Core internals.

## 2. Feature-First Runtime

The repository uses feature-first folders under `lib/ui/features/`. The first
consumer stays in its feature. Code moves to `lib/ui/shared/` only when another
feature in this repository has the same responsibility. Promotion into Core
requires a general, business-neutral responsibility and a stable public API.

The current app has no real remote data source, so it intentionally has no
empty Repository, Service, or Domain layers. A feature introduces those layers
when it receives the corresponding real responsibility.

## 3. Truthful Product State

The runtime starts as a guest. `SessionController` models the guest/session
boundary, but no startup or authentication form can create a real authenticated
session. Authentication and account-sensitive actions perform local validation,
then report that the service is unavailable. They do not create a user, token,
verification message, persisted session, or success result.

The privacy gate persists only the user's local consent choice. Appearance and
accessibility preferences are local. Legal-document hosts show an explicit
empty state until verified content is supplied; the Starter does not invent a
legal entity, filing number, address, telephone number, or policy text.

## 4. Platform And Accessibility

The Starter supports Android and iOS. Public `App*` components select the
Material 3 or Cupertino implementation inside Core. Feature code does not make
platform-widget choices. System text scaling, Bold Text, high contrast, reduce
motion, grayscale, hit targets, semantics, focus, keyboard behavior, safe areas,
and navigation gestures follow the [Design System](docs/design-system/README.md)
and its automated/device evidence model.

## 5. Optional Identity And Brand Tool

The repository has no required manifest. `app-config.yaml` is an optional,
user-chosen input described by
[the customization quickstart](docs/customization/quickstart.md). It contains
only App identity and Brand values. It has no source commit, ownership,
compatibility, deviation, expiry, or provenance fields.

The tool may synchronize Dart identity, Brand Theme, `pubspec.yaml`, Android
identity/resources, and iOS identity/resources. Its validator checks the data
shape, asset containment, PNG dimensions, and primary-color focus contrast. Its
verifier checks generated output for drift. Passing these checks means only
that the requested files match the configuration; it is not certification or a
compatibility claim.

The Starter rename does not change the Dart package name
`admin9_app_flutter`, Android namespace/application ID
`com.admin9.app.foundation`, Kotlin package path, or iOS bundle ID. Those
identifiers affect package imports, installation continuity, and signing and
therefore change only through a separate, intentional migration.

## 6. Upstream Releases

Upstream releases use SemVer, the Design System Changelog, CI, Flutter analysis
and tests, Android/iOS builds when relevant, and evidence tied to the tested
source/artifact. Existing Git history and tags are not rewritten. Historical
Foundation reports remain historical evidence and do not impose current rules
on forks.

Current omissions remain explicit: there is no backend, OIDC, token lifecycle,
push, messaging, remote configuration, business content, formal legal content,
Web, Desktop, macOS, dynamic module system, or published standalone UI package.
