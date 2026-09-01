# Application Architecture

## Current Target

This repository defines a Flutter Starter/Skeleton that uses Forui as its UI
design system and base component source. In addition to running as an
application, a Starter may show adopters recommended structure, extension points,
and complete examples from their first day. A derived project owns its product
features, routes, identities, platforms, and acceptance evidence through its
repository-local authority.

The architecture is requirement-driven. It does not preserve compatibility with
superseded Dart APIs, presentation code, routing, tests, tools, or documents.
Authorized obsolete files are deleted directly after their current consumers
have been checked. Git history, tags, and remotes are not rewritten or deleted.

See [UI](ui.md) for the Forui, theme, generation, and UI acceptance rules. The
upstream repository's bundled example is intentionally separated into
[Upstream Starter](starter.md); it is not a downstream product contract.

## Minimal Structure

Only create paths that have a confirmed responsibility:

```text
lib/
|-- main.dart                         # starts the application only
|-- app/                              # startup composition and app host
|   |-- bootstrap.dart                # only when startup work exceeds main()
|   |-- admin9_app.dart               # root application host
|   `-- routing/
|       |-- app_router.dart           # AutoRoute declarations and configuration
|       `-- app_router.gr.dart        # generated and never hand-edited
|-- theme/                            # Forui CLI theme output
|   |-- theme.dart
|   |-- colors.dart
|   |-- typography.dart
|   |-- style.dart
|   |-- icons.dart
|   `-- styles/                       # only generated styles in current use
|-- shared/ui/                        # stable categorized Admin9 UI APIs/patterns
|   `-- <category>/                   # e.g. layout/grid, not a generic bucket
`-- features/<feature>/               # confirmed product or example Features
    |-- presentation/
    |   |-- pages/                    # complete route pages
    |   |-- providers/                # Riverpod state and dependency wiring
    |   `-- widgets/                  # feature-owned presentation pieces
    |-- data/                         # only after a real data source exists
    |   |-- models/                   # API or persistence data structures
    |   |-- repositories/             # storage and data-source coordination
    |   `-- services/                 # external API, storage, or platform access
    `-- domain/                       # only complex or reusable business rules
```

The tree describes recommended ownership, not a requirement to create every
directory. Do not add top-level `lib/examples/` or `lib/widgets/`. Create a
Preferences implementation only for real persistence. Create privacy code only
for an explicit product or compliance requirement.

## Starter Channels And On-Demand Layers

The Starter may establish a specifically named `shared/ui/<category>/` channel
from the first day when it contains a stable Admin9 UI API or App-wide page
pattern with a clear name, real use, a runnable example, documentation, and
tests. Appropriate responsibilities include branded layout components, empty,
error, and loading states, or a responsive page body. `shared/ui/` is not a
generic Widget bucket and must not contain mechanically renamed Forui
primitives or vague files such as `common_card.dart` or `utils.dart`.

Shared ownership follows two rules:

- ordinary business code usually stays with its first Feature and moves after a
  second real Feature needs the same responsibility; and
- the Starter may provide one canonical pattern earlier when a current example
  consumes it and its behavior is runnable, tested, and documented.

The Starter has one approved runnable Admin9 UI Showroom Feature at
`lib/features/examples/`. It owns the Foundation, Forms, Content, and Feedback
groups and their Playgrounds, translations, tests, and routes. Settings remains
an independent real Feature. The Showroom lets adopters browse a capability,
configure a realistic scenario, interact with its states, and reset the
scenario. It does not turn its scenarios into downstream product requirements.

Official capability ownership and route ownership are deliberately different.
Several related Forui capabilities may map to one complete Playground when they
form one coherent scenario. Do not create a shallow route merely to preserve a
one-capability/one-page ratio. The version-bound capability ledger and the
Playground registry in [Upstream Starter](starter.md) retain the many-to-one
mapping and its focused evidence.

Reusable structure that exists only to compose a Playground belongs under
`lib/features/examples/presentation/widgets/`. This includes preview frames,
configuration sections, interaction feedback, and reset controls. It does not
move to `shared/ui/` merely because several Showroom pages use it; `shared/ui/`
remains reserved for stable App-wide or Admin9 brand APIs.

Examples may depend on `shared/ui/`; `shared/ui/` must not import Examples,
AutoRoute, App routing, or a business Feature. Existing root-level shared UI
files are not moved merely to make the category tree look complete. New shared
UI uses a responsibility-specific category such as `layout/grid/`.

The App router consumes Examples through one route-group integration point. The
current five destinations remain Foundation, Forms, Content, Feedback, and
Settings. The four visible Showroom destinations may retain separate nested
stacks, but their
route declarations remain owned by the Examples group rather than four separate
Features. Removing the bundled Examples Feature requires removing that one
mount, regenerating AutoRoute output, and deleting its routes, tests,
`examples.*` translations, and Starter coverage claims. The removal must not
delete independent shared UI APIs or the Settings Feature.

The approved reusable Admin9 brand component for this iteration is owned at:

```text
lib/shared/ui/layout/grid/
|-- a_grid.dart
|-- a_grid_item.dart
`-- a_grid_style.dart
```

AGrid remains independent of Examples so a derived project can remove the
Showroom without removing the brand API. Its style extends the existing Forui
Theme contract; it does not introduce a parallel App Theme. Other category
directories and APIs are created only after their own responsibility and
consumer are approved.

Data, Domain, Repository, Service, Use Case, and shared layers require a real
consumer and a specific responsibility. Do not create empty layers or placeholder
interfaces merely to display a complete folder tree. Add Domain or Use Case code
only for complex, reusable, or cross-Repository rules; do not create a Use Case
that forwards a single call. Do not create a generic `core/ui`, `patterns`,
`common`, or `helpers` layer.

## Naming

- Directories and files use `snake_case`.
- Route pages use `*_page.dart` and a corresponding `*Page` class.
- Riverpod declarations use responsibility-specific `*_provider.dart` files.
  A state coordinator uses a corresponding `*Notifier` class when needed.
- Each file has one primary public responsibility.
- Names describe a domain or UI responsibility. Names such as `utils.dart`,
  `helpers.dart`, and `common.dart` are prohibited.

## Dependency Direction

- `main.dart` starts the application and delegates composition to `app/` when
  startup work needs more than a direct `runApp` call.
- The app host composes the selected theme, confirmed features, and any routing
  that the product actually requires.
- Feature Pages and feature-owned Widgets may depend on Flutter, Forui, and
  feature-owned Riverpod providers.
- Riverpod Providers and Notifiers may depend on Repository, Service, or Use Case
  contracts, but do not depend on Forui, AutoRoute, or `BuildContext`.
- Feature Models, Preferences, Services, Repositories, Domain code, and Use Cases
  do not depend on Flutter presentation, Forui, AutoRoute, `BuildContext`, or
  Riverpod.
- Shared presentation code, including an Admin9 brand UI API or documented
  Starter pattern, remains presentation code. It must not acquire business
  decisions merely because one or more Features render it, and it does not
  depend on AutoRoute.

Feature presentation uses a Forui `F*` widget directly when it already satisfies
the requirement. An Admin9 `A*` API is justified only by a stable, observable
brand visual, interaction, behavior, or API difference. It may wrap or extend an
`F*` implementation, or independently implement a confirmed Forui capability
gap, without exposing that internal choice through its public API. A Widget used
only by one Feature remains Feature-owned. See [UI](ui.md#ui-ownership-model)
for the decision rules.

## Riverpod State And Dependency Scope

`flutter_riverpod` is the Starter's default state management and dependency-
wiring library. The root application provides one `ProviderScope`; each Feature
owns the providers for its presentation state and dependencies.

Use a Provider or Notifier for asynchronous data, state shared by multiple
Widgets, lifecycle-aware work, or dependencies that tests need to override.
Keep text editing, scrolling, animation, focus, temporary expansion, and other
strictly Widget-local state in the Widget that owns it.

Provider files stay inside their Feature. App-wide session, theme, playback, or
other state moves to an explicitly named App or shared capability only after a
real cross-Feature consumer exists. Do not create a generic root `providers/`
directory.

Start with manual `flutter_riverpod` providers. Hooks and Riverpod code generation
are optional implementation tools and require a demonstrated benefit before they
are added. Repository, Service, Model, Preferences, and Domain implementations
remain ordinary Dart or platform-boundary classes; providers construct or expose
them without making those classes depend on Riverpod.

## Routing Architecture

AutoRoute is the Starter's selected routing system. AutoRoute and typed route
generation are baseline infrastructure. Specific Tab Routers, Guards, Observers,
notification/share destinations, platform deep links, and process restoration
still require an approved product consumer or a runnable, documented, and tested
Starter example.

Initialize Forui with its router template, then configure `MaterialApp.router`
from one App-owned `AppRouter`. Annotate route Pages with `@RoutePage` and use
generated Route objects for App navigation. Commit generated router source for a
reproducible Starter, regenerate it from declarations, and never hand-edit it.

Use a nested AutoRoute Tab Router only when approved persistent destinations need
independent branch stacks. Add a Guard only for a named rule such as
authentication, permission, content access, or duplicate-route prevention; do
not turn Guards into a generic business-logic layer.

Use adaptive route behavior by default:

```dart
@override
RouteType get defaultRouteType => const RouteType.adaptive();
```

AutoRoute maps adaptive routes to Cupertino transitions on iOS/macOS, no
transition on Web, and Material transitions on other platforms. This is the
platform-appropriate Route foundation, not proof that iOS edge back or Android
system/predictive back has passed. Custom transitions and platform gesture
configuration require fresh acceptance.

Page-level Pages may call `context.pushRoute`, `context.replaceRoute`, and
`context.maybePop` directly. Reusable leaf Widgets receive semantic callbacks.
Do not add a `NavigationService`, Router Facade, navigation event bus, or
provider-based routing protocol solely to hide AutoRoute. Riverpod Providers and
Notifiers do not navigate.

Platform deep linking remains a separate Android/iOS contract: define approved
domains and paths, configure App Links and Universal Links, and test cold and
warm entry on both platforms. Route declarations alone do not prove platform
deep-link delivery.

Use precise navigation-state terms:

- **Cold-start deep-link reconstruction:** parse an external location and build
  the intended Route stack.
- **In-process branch-stack retention:** keep each implemented Tab Router's
  Navigator history while the App process remains alive.
- **Process state restoration:** rebuild navigation and page state after the OS
  terminates the Flutter process.

The first two do not prove process state restoration. AutoRoute exposes page
`restorationId` and router `navRestorationScopeId` integration points, but process
restoration is not a baseline claim. If approved later, define the restoration
scope, serializable parameters, persisted business state, interruption cases,
and Android/iOS acceptance separately.

AutoRoute imports are allowed only in `app/routing/`, route Pages, and generated
router files. Reusable leaf Widgets use semantic callbacks. Riverpod Providers/
Notifiers, Models, Repositories, Services, and Domain/Use Case code do not depend
on AutoRoute.

### Route Generation Contract

Use this compatible baseline:

```yaml
dependencies:
  auto_route: ^11.1.0

dev_dependencies:
  auto_route_generator: ^10.6.0
  build_runner: ^2.16.0
```

The generator accepts Analyzer `>=10.0.0 <14.0.0`, while build_runner 2.16.0
requires Analyzer `>=13.3.0 <15.0.0`; their valid intersection is Analyzer
`>=13.3.0 <14.0.0`. The old direct `analyzer: 10.1.0` constraint is incompatible.
During replacement, remove that direct dependency unless current source imports
the Analyzer API, and let Pub resolve and lock a compatible transitive version.

Generated router files are committed tool output. On a clean CI checkout run:

```shell
dart run build_runner build
git diff --exit-code
test -z "$(git status --porcelain --untracked-files=all)"
```

The diff check detects changed tracked output; the status check also detects new
untracked generated files. Any output fails the generation-drift gate.

## Capability Adoption Gates

Dependencies are selected only for a clear responsibility and an approved
consumer. The presence of a contract, platform API, or possible future scenario
does not by itself authorize a dependency, generated code, or a new layer.

The following map preserves preferred candidates without promoting them to the
App baseline. A listed candidate still requires an approved Feature, its trigger
below, and a fresh review of version compatibility, maintenance, licensing, and
platform behavior. Only an explicit project decision can change its status.

| Technology or capability | Role | Adoption trigger | Status |
| --- | --- | --- | --- |
| Forui, Riverpod, AutoRoute, EasyLocalization | UI, state/DI, typed routing, and App copy | Initial Starter | Frozen baseline |
| Generated OpenAPI client | Typed backend contract and requests | Approved Feature needs an API with an authoritative OpenAPI contract | Conditional preferred |
| Drift | Local database and reactive queries | Approved offline or persisted-data Feature | Conditional preferred |
| Freezed | Immutable Models, unions, and generated value semantics | Repeated Model/state boilerplate creates maintenance cost | Conditional preferred |
| `flutter_secure_storage` | Keychain/Keystore-backed secret storage | Approved authentication or cryptographic secret | Conditional preferred |
| `background_downloader` | Background transfer, recovery, and system progress | Approved transfer must continue outside the foreground UI | Conditional preferred |
| `worker_manager` | Dart isolate worker pool | Profiling confirms a CPU-bound workload | Conditional preferred |
| WebSocket or Socket.IO | Realtime transport | Approved backend realtime protocol is defined | Protocol-dependent |
| Pigeon | Typed Dart-to-native bridge generation | Approved native capability lacks a suitable maintained Flutter plugin | Conditional preferred |
| Media player package | Video, live, or audio playback | Approved media formats and platform capabilities are defined | Requirement-dependent |
| `mocktail` | Test doubles | A hand-written fake is less clear or more costly | Test-as-needed |

### Baseline Engineering

The initial Starter uses Forui, Riverpod, AutoRoute with
`auto_route_generator: ^10.6.0`/`build_runner: ^2.16.0`, Flutter analysis,
focused unit and Widget tests, `easy_localization` for App-owned copy, and a small
App error/logging boundary. Logs must not contain credentials, tokens, personal
data, or production media content. Add a logging package or remote telemetry
only when its destination, retention, redaction, and failure behavior are
defined.

### Backend Contract And Authentication

When an approved Feature needs a backend API and an authoritative OpenAPI
document exists for that API, generate the Dart client from it. A contract file
without an approved consumer does not trigger dependencies, generated files,
Services, or Repositories. Treat generated files as replaceable output, never
hand-edit them, and keep them behind Feature Services and Repositories so
Presentation and Domain code do not depend on generator-specific types.

Use platform-backed secure storage for access tokens, refresh tokens, encryption
keys, and other real secrets. Preferences are for non-sensitive App settings and
must not store authentication secrets.

### Optional Runtime Capabilities

Add durable offline storage only when an approved Feature needs persisted data
or reactive local queries. The change must include schema ownership, migrations,
Repository boundaries, and storage tests; do not add an empty database
foundation.

Add background execution only when approved work must continue outside the
foreground UI. Add an isolate or worker pool only after profiling identifies a
CPU-bound workload. Add realtime transport only after the backend protocol,
connection lifecycle, recovery, and authentication behavior are defined.

Choose any specialized platform or media implementation only after its Feature,
capability contract, supported platforms, lifecycle, and acceptance plan are
approved. Do not adopt a reference application's pinned or custom dependencies
without independent selection and verification.

### Model Generation And Testing

Use ordinary immutable Dart classes first. Add model generation only when
repeated `copyWith`, equality, serialization, or sealed-state boilerplate creates
real maintenance cost. Do not introduce another generator solely to make a small
Model look more formal.

Test Riverpod Providers/Notifiers and Repositories independently, use Widget
tests for Forui presentation and interaction, and use `integration_test` for
approved critical flows. Add a mocking package only where a hand-written fake is
less clear or more costly.

### Localization

Use `easy_localization` for App-owned product copy. Chinese is the initial
supported and fallback locale; translation assets and the central supported-
locale list are part of the App contract. Add another locale only when complete
translations, platform locale declarations, layout checks, and acceptance have
been approved.

With only one supported locale, set `saveLocale: false`; there is no user locale
choice to persist. Enable locale persistence only when approved locale switching
exists and its storage behavior is tested.

Forui component labels and messages remain owned by `FLocalizations`. Flutter
3.47's `material_ui.MaterialApp` also requires the external
`material_ui`/`cupertino_ui` delegates, which EasyLocalization 3.0.8 does not
replace. The root App combines the EasyLocalization delegates,
`GlobalMaterialLocalizations.delegates`, and exactly one
`FLocalizations.delegate`, in that order. Use the App's supported locale list
rather than advertising every locale Forui can technically render.
EasyLocalization does not replace Forui localization, and Forui localization
does not translate App-owned copy.

Start with translation assets and runtime key lookup. EasyLocalization key/code
generation is optional and requires a demonstrated maintenance benefit before
adding another generator to the Starter.

### Native Interop With Pigeon

A custom native capability is product-owned behavior that must run in Android
Kotlin/Java or iOS Swift/Objective-C and is not adequately exposed by an existing
maintained Flutter plugin. A possible future platform API does not trigger this
layer; the native behavior and its consumer must be approved first.

Use an existing maintained plugin first. When a custom bridge is necessary,
Pigeon generates the typed Dart and host-platform messaging interfaces; engineers
still implement the native behavior. Pin one Pigeon version, generate both sides
with that version, keep generated bridge code internal, and test the Dart/native
contract on both platforms. Do not expose generated Pigeon types as public App
or package APIs.

### Explicit Non-Defaults

- AutoRoute and its route generator are approved baseline dependencies. Do not
  add `go_router`, `go_router_builder`, or another routing system alongside them.
- Do not add Riverpod hooks, Riverpod generation, model generation, offline
  storage, background execution, workers, or realtime transport without an
  approved consumer and the applicable capability contract.
- Do not build a parallel UI package; Forui is this Starter's UI foundation.
- Do not add unapproved locales or a second App localization framework.
  EasyLocalization and Forui localization have the separate responsibilities
  described in [UI](ui.md#language-and-localization).
- Do not adopt Git-pinned or custom platform dependencies without an approved
  requirement, provenance review, and platform acceptance plan.

## Platform Boundary

Forui owns visible product UI, theme, and base components. Flutter and the host
operating systems own platform interaction, including system back behavior,
keyboard and text input, text selection, safe areas, permissions, sharing, and
native pickers. Use those platform capabilities instead of recreating them.

Use maintained Flutter plugins before writing platform channels. Project-owned
native code and Pigeon bridges are reserved for the capability gap defined in
[Native Interop With Pigeon](#native-interop-with-pigeon).

Ordinary business pages have one Forui presentation. Do not build separate
Android and iOS page implementations. Platform-specific code is reserved for a
real capability or behavior difference that Flutter cannot represent uniformly.

Legal policies, required third-party notices, Android application IDs, iOS
bundle IDs, signing configuration, and still-used native capabilities are
protected boundaries. Their age is not a deletion criterion.

The upstream runnable Starter uses `dev.admin9.starter` for its Android
namespace/application ID and iOS Runner bundle ID; its test bundle uses
`dev.admin9.starter.RunnerTests`. This identity belongs to the upstream example
described in [Upstream Starter](starter.md), not to every derived product.
Changing an installation identity creates a separately installed App and needs
an explicit data, signing, delivery, and upgrade review.
