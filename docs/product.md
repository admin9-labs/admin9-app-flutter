# Product Definition

## Positioning

This repository is an Android/iOS Admin9 UI and mobile engineering reference
application intended to remain suitable for store delivery. It serves Admin9
adopters, technical leads, and product teams by demonstrating Forui components,
formal Admin9 `A*` components, and a runnable Flutter application baseline.

The App proves engineering capability through real product flows and automated
or platform evidence. Architecture is not a standalone navigation destination.

## Information Architecture

The startup flow is outside persistent navigation:

```text
Native launch screen
  -> App initialization
  -> privacy / onboarding / startup placement
  -> MainShell
      |-- Home
      |-- Components
      |-- Media
      `-- Settings
```

Home identifies Admin9 and the current App version, presents component updates,
representative media scenarios, and direct access to the primary capabilities.
Components contains the removable Examples Feature. Media and Settings are
ordinary App Features and remain when Examples is removed.

The complete startup precedence, privacy, persistence, failure, and acceptance
contract is defined only by [Product Startup Flow](product-startup-flow.md).

## Components

Components has separate Forui and Admin9 catalogs. Foundation, Forms, Content,
and Feedback are Forui catalog categories rather than persistent destinations.
The current formal Admin9 component catalog contains one family: `AGrid`,
`AGridItem`, `AGridBadge`, and `AGridStyle` together count as one component.

Every direct Playground must provide a realistic scenario, configuration-driven
preview, observable interaction feedback, reset behavior, responsive and
accessibility coverage, and focused tests. Rendering a component type alone is
not coverage.

## Media

Media is a formal Feature with image preview, video playback, and audio playback.
Prototype content may come from a local Scenario Repository and fixed licensed
or public test sources, but decoding, gestures, playback, lifecycle, background
audio, lock-screen metadata, headset controls, and interruption behavior must be
real. Unverified Android/iOS behavior remains `Unknown`.

The first version excludes DRM, casting, picture-in-picture, offline download,
media publishing, image saving, sharing, and long-press menus.

## Derivation

Examples is removable reference content. A derived App may remove Components,
its Home contribution, Playgrounds, routes, translations, tests, screenshots,
and capability ledger with the repository removal tool. Removal retains the
startup contract, base Home, Media, Settings, Legal, Theme, persistence, and
formal shared `A*` APIs.
