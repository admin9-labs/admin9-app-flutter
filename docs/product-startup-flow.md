# Product Startup Flow

## Authority And Terms

This document is the product authority for the Android/iOS startup flow. Code,
tests, reviews, and backend placement changes must preserve it. The removable
Examples Showroom does not replace or weaken this contract.

Use these terms precisely:

- **Native launch screen** is the static Android/iOS screen before Flutter's
  first frame. It contains no network, consent, advertising, or timer logic.
- **App initialization state** is Flutter UI while local startup state and the
  launch destination are resolved.
- **Startup advertisement** is optional first-party operational media shown only
  after initialization on an eligible icon cold launch. Do not call either of
  the first two states an advertisement or use `splash` as a shared name.

## State And Precedence

The fixed precedence is privacy requirement, external destination, onboarding,
startup advertisement, then `MainShell/Home`.

| Launch state | Required result |
| --- | --- |
| First icon launch | Native launch screen -> initialization -> privacy -> optional onboarding -> MainShell/Home; no advertisement |
| Privacy declined | Privacy -> limited MainShell/Home; no advertisement, personalization, telemetry, third-party data SDK, push registration, or media prefetch |
| Policy version changed | Privacy -> full or limited MainShell/Home; suppress the advertisement for that launch |
| Eligible icon cold launch | Initialization -> verified cached advertisement -> MainShell/Home |
| Missing, invalid, failed, or timed-out advertisement | MainShell/Home without another blocking page |
| Notification, share, or deep link | Privacy when required, then the allowed target; bypass onboarding for that launch and never show an advertisement |
| Foreground resume | Preserve the current route; never enter the startup advertisement |
| Advertisement backgrounded | End it and continue to the pending destination or MainShell/Home |

`StartupCoordinator` owns state decisions but never imports AutoRoute or
navigates. `StartupGatePage` renders the selected state and performs generated
typed navigation. An unknown or disallowed destination is discarded and lands
on MainShell/Home. A target requiring consent is discarded when the user chooses limited
browsing. Authentication remains action- or route-triggered and must return to
the original operation; the repository currently has no authentication backend,
notification provider, or share-intent provider, so those integrations remain
`Unknown` and must not be simulated.

## Persistence And Privacy

SharedPreferences stores only versioned consent, onboarding completion/skip,
and local frequency timestamps. A legacy consent Boolean without policy version,
operator identity, and policy-text equivalence is not valid consent. Credentials,
refresh tokens, encryption keys, advertising identifiers, stable install IDs,
location, contacts, photo-library inventories, clipboard content, and device
fingerprints do not belong in this store or startup requests.

Limited browsing permits bundled legal documents, anonymous first-party public
content, appearance/accessibility preferences, and necessary content cache. A
public request may carry only platform, App version, distribution channel, and
language. Server IP/time access logs need a documented purpose, access policy,
retention period, and deletion process. Camera, photos, location, and notification
permissions are requested only when the user starts the corresponding feature.

This engineering boundary follows the minimum-necessary and basic-service
principles in the [Personal Information Protection Law](https://www.npc.gov.cn/WZWSREL25wYy9jMi9jMzA4MzQvMjAyMTA4L3QyMDIxMDgyMF8zMTMwODguaHRtbD9yZWY9aW1i),
the [necessary personal information rules for common Apps](https://www.cac.gov.cn/2021-03/22/c_1617990997054277.htm),
and the [Network Data Security Management Regulations](https://xzfg.moj.gov.cn/mobile/law/detail?LawID=1734).
Product launch still requires the operator's legal review of the final policy,
agreements, processing inventory, third-party list, retention, contact, and
withdrawal behavior.

## First-Party Placement Contract

The backend OpenAPI is authoritative. The checked-in
`test/fixtures/startup_ad/campaign.json` is a consumer fixture, not a competing
API definition. The client request is:

```text
GET <STARTUP_AD_ENDPOINT>
  ?placement=app_startup
  &platform=android|ios
  &app_version=<version>
  &channel=<channel>
  &locale=zh-CN
```

It sends no account, token, advertising/install ID, push token, location, or
device fingerprint. A `204` means no campaign. A `200` campaign contains schema,
placement/campaign/creative IDs, active status, priority, UTC window, server and
update times, freshness, 3-5 second display duration, local frequency rule,
platform/version/channel filters, media, fallback, and action.

Media requires type (`image`, `gif`, or `video`), HTTPS URL, exact MIME and byte
length, pixel dimensions, SHA-256, focal point, and a meaningful semantic label.
The initial image decoder accepts JPEG and PNG; GIF and MP4 use their own types.
GIF and video require a static image fallback. Actions are limited to `none`, a
client allowlisted `internalRoute` with typed string parameters, or an allowlisted
HTTPS external URL. Arbitrary route class names, schemes, scripts, and redirects
are rejected.

Runtime activation uses explicit build configuration:

```text
STARTUP_AD_ENDPOINT=https://api.example.com/v1/placements/startup
STARTUP_AD_API_HOSTS=api.example.com
STARTUP_AD_MEDIA_HOSTS=cdn.example.com
STARTUP_AD_EXTERNAL_HOSTS=www.example.com
APP_CHANNEL=official
```

Missing endpoint or allowlists keeps the repository disabled and routes directly
to MainShell/Home. The App version constant must be updated with `pubspec.yaml` in every
release until an approved package-metadata consumer replaces it.

## Cache, Media, And Failure Rules

Startup reads only a complete cached campaign. Home/resume may refresh after
consent for the next cold launch; startup never waits for a new media download.
Configuration has an 800ms timeout. Media download has an 8s timeout and validates
HTTPS and every redirect, host allowlist, declared size, MIME, signature, SHA-256,
and type budget before an atomic rename and manifest write.

Budgets are 8MiB image, 15MiB GIF, 30MiB video, and 50MiB total. The cache keeps
only the manifest, primary media, and required fallback; orphaned or corrupt data
is deleted. Images/GIFs render from a local file. Video initializes within 800ms,
loops within the configured display period, starts muted, and exposes a mute
control. Reduced-motion users receive the static fallback. Failure order is
primary media, fallback image, then immediate MainShell/Home; no generated gradient,
description page, or fake advertisement is allowed.

The skip action is available from the first rendered frame. Frequency is recorded
only when that frame is visible, not when a candidate is selected. The in-memory
campaign/creative exposure pair must suppress the identical first-viewport Home
placement for the session; if no alternative exists, Home collapses that slot.

## Visual And Accessibility Acceptance

| Surface | Responsibility and acceptance |
| --- | --- |
| Native launch screen | Static brand mark, matching light/dark background and Flutter initialization first frame; no animation or artificial delay |
| Initialization | Brand bitmap plus semantic progress only; no advertisement, Card, Alert, or explanatory page |
| Privacy | Scrollable Chinese disclosure and policy links; full-width equal access to accept and limited browsing; large-text safe |
| Onboarding | Three licensed bitmap photographs, one user benefit per page, skip on every page, final action directly to MainShell/Home; no completion page |
| Startup advertisement | Real image/GIF/video, promotion label, immediate skip, muted video control, semantic label, safe-area placement |
| Home transition | Short default transition, reduced-motion compatible, no repeated campaign creative in the first viewport |

Acceptance covers 320/390 widths, common tall screens, landscape, safe areas,
light/dark themes, the largest supported App font preference, 2x system text,
screen-reader order, 44/48dp targets, contrast, image focal cropping, and absence
of overflow. Automated geometry does not replace current-source screenshot and
human visual review.

## Metrics And Release Boundary

`StartupMetricsSink` is No-op by default. A future sink may receive events only
after current-version consent: initialization duration/reason, consent accepted,
onboarding skipped/completed, campaign visible/finished with reason, and Home
interactive. Fields are restricted to low-sensitivity enums, platform/version,
and campaign/creative IDs. Raw URLs, share payloads, user input, device IDs, and
pre-consent decline events are prohibited.

Release metrics are time-to-interactive P50/P95, eligible cache hit, first-frame
success, failure-direct-to-MainShell/Home, target arrival, login return, and zero duplicate
startup/Home exposure. Campaign `inactive` or API `204` is the operational kill
switch. Android/iOS build, simulator, physical-device, notification/share,
authentication, backend, signing, and release evidence remain `Unknown` until
each is separately configured and executed against current source.
