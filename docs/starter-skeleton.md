# Admin9 App Starter Skeleton

This Starter runs without a backend account or remote page configuration. It
provides startup initialization, onboarding, privacy admission, optional verified startup
media, configurable navigation, Settings and a local account flow.

## Local page configuration

`assets/config/page_configuration.json` is a bundled, versioned configuration.
`schemaVersion` is 1 and `revision` is an integer. `navigation` references
`pages` by `pageId` and matching `pageType`. IDs are lowercase path segments
(`a-z`, digits, `_`, `-`, starting with a letter). Unknown types, duplicate IDs,
unregistered icons, dangling references and unsupported fields fail validation
before the shell opens. The error page identifies the local configuration and
asks the developer to correct it and rebuild; it does not retry a remote source.

Navigation fields are `pageId`, `pageType`, `label`, `icon`, optional `visible`
(default true) and `order` (default 0). Lower order appears first; equal values
retain JSON order. Icons are `home`, `blocks`, `play`, `settings`, and
`sliders-horizontal`. Hidden entries are omitted from both the Tab Router and
Home shortcuts. Multiple instances of a registered type can have different IDs.

Each page accepts `title`, `actions`, `tabs`, `regions`, and `appearance`:

- `title` supplies the page header. `appearance.showTitle` defaults to true.
- `actions` currently allows only `open_settings`, a semantic header action.
- `tabs` contains `id`, `label`, optional `order`, and optional `regions` overrides.
  Standard page tabs use Forui `FTabs`; their bodies use the registered page type.
- Home regions are `introduction`, `components`, `media`, and `settings`.
  Settings regions are `account` and `appearance`; legal/cache controls remain
  accessible. Other registered types support `content`. A missing flag is true.
- `placeholder` renders the shared empty copy and supports independent page tabs.

```json
{
  "pageId": "inbox",
  "pageType": "placeholder",
  "title": "消息",
  "tabs": [
    {"id": "unread", "label": "未读", "order": 0},
    {"id": "read", "label": "已读", "order": 1}
  ]
}
```

The shell creates generated `PageConfigurationShellRoute(pageId: ...)` entries
inside AutoRoute's nested Tab Router, each keyed by its path. A `PageRegistryRoute`
resolves the initial page. Each branch retains its own detail stack, including
upstream Components and Media detail pages. Home shortcuts use the same visible,
ordered list as the bottom navigation. No parallel navigation service or Tab
controller is introduced.

To add a type, add its explicit schema/region allowlist in
`lib/app/page_configuration/page_configuration.dart` and its renderer in
`lib/app/routing/page_registry_page.dart`, then add the JSON definition and
navigation reference. Add generated typed detail routes only when that type has
a real detail-page consumer. JSON cannot contain Dart, Widget trees, arbitrary
routes, URLs, network/API parameters, caching strategies, or business data.

The upstream Examples removal command also removes its page definition,
navigation entry and registry/schema integration. Home, Settings, Media,
authentication and the standalone admin9_ui package are preserved.

## Startup advertisements

[Product Startup Flow](product-startup-flow.md) is the single authority. The
first icon launch and policy-change launch never show an advertisement. External
entries bypass onboarding and advertising after any required privacy decision.
Foreground resume keeps the current route; backgrounding an advertisement ends
it rather than pausing it.

The default Starter has no placement endpoint and therefore disables advertising.
There is no bundled advertisement JSON or pretend cache. To activate an owned
first-party placement, configure `STARTUP_AD_ENDPOINT`, `STARTUP_AD_API_HOSTS`,
`STARTUP_AD_MEDIA_HOSTS`, and any approved `STARTUP_AD_EXTERNAL_HOSTS` via build
defines, following the authority document. Home/resume refreshes only after
consent, for the next cold launch. Startup only reads complete validated cache;
it never fetches media. Missing, expired, corrupt, untrusted or timed-out data
continues directly to Home. The no-op metrics sink remains the default.

The campaign/cache tests use consumer fixtures and local temporary files. Device
integration tests inject a test-only transport for licensed bundled photographs;
this proves the real cache and renderer on hardware, not a live backend or a
production advertising deployment.

## Authentication

The authentication flow is guest-first. `AuthenticationGateway` and
`SessionStore` are provider-neutral ports. The Starter wires a local account
implementation backed by `SharedPreferencesAsync` so registration, login,
logout and session restoration can be exercised without a server. It is a
development implementation; a product replaces the gateway and store before
using production credentials.

SMS, Apple, WeChat, carrier, Laravel and member-profile integrations are
product responsibilities and are outside this Starter.

Registration and login replace one another within a single authentication route
slot, then return to the entry page after success. Settings keeps the current
account as status and exposes a separately labelled logout action. The tests use
synthetic local accounts only; no production identity provider is configured.

## Verification

The [2026-11-01 acceptance report](acceptance/starter-2026-11-01.md) records
source checks, Android/iPhone physical-device results, screenshots and the
bound runtime source. Use `tool/run_starter_device_acceptance.py` to repeat the
integration flow with real OS background/foreground actions on a connected
device. Unexecuted production and accessibility checks remain explicit in the
report.
