# Admin9 UI

Forui-based Flutter components maintained independently of application business code.
This local pilot contains `ACarousel` and the existing `AGrid` family. It is not
published. Flutter 3.47.2 / Dart 3.13.2 and Forui ^0.27.3 are required.

## Public Widget Inventory

The package exports four public Widgets: `ACarousel` for horizontal paging,
`AGrid` for action layout and optional paging, `AGridItem` for item interaction,
and `AGridBadge` for semantic badges. `ACarouselItem` is caller-content data;
`AGridStyle` is a Forui style extension. Neither is counted as a Widget.

## Consumption

Import only `package:admin9_ui/admin9_ui.dart`. Do not import `lib/src` from an
application, copy implementations, or commit local dependency overrides.
The Starter uses a path dependency; downstream apps can pin a Git revision and
`path: packages/admin9_ui`. The application commits its dependency lockfile.

## Carousel

```dart
ACarousel(
  loop: true,
  caption: ACarouselCaption.overlay,
  items: [
    ACarouselItem(
      id: 'cover',
      child: Image.asset('assets/cover.jpg', fit: BoxFit.cover),
      title: 'Featured content',
      semanticsLabel: 'Open featured content',
      onPress: openContent,
    ),
  ],
)
```

Decorative children and images belong to the caller. Each item is one accessible
unit: semanticsLabel must provide its complete name, and onPress owns its optional
action. Child semantics are excluded; nested interactive controls are outside
this pilot. Looping may mount the same item on adjacent virtual pages, so children
must not share GlobalKeys across those pages. The package does not load URLs, cache
images, fetch content or navigate. IDs must be unique and stable. `caption`
selects none, overlay or below. `autoplay` is opt-in; `interval` must be positive.
`active: false`, disabled TickerMode, background lifecycle, reduced motion, accessible navigation, keyboard focus and
pointer/drag interactions pause automatic paging. A host must set `active` when
offscreen retention does not disable TickerMode. Manual paging remains available.
Finite autoplay stops at the last item; loop mode wraps. Content updates retain
the selected ID when it still exists, otherwise select the first item.
`onChanged` reports user/automatic paging and content updates that change the
selected index or ID. It excludes initial construction and empty updates.
Unrelated host rebuilds preserve the autoplay interval. Indicators use a bounded window.
This pilot excludes vertical banners, video, fullscreen and custom transitions.

## Grid

Register `AGridStyle.inherit` in the host's Forui `FStyle.extensions`, using the
host colors, typography, radius and focused outline. No independent theme is
created. Existing `AGridItem` custom labels remain supported.

```dart
AGrid(
  columns: 5,
  rowsPerPage: 2,
  children: [
    AGridItem.text(
      key: const ValueKey('entry'),
      icon: Image.asset('assets/entry.png'),
      label: 'Service entry',
      onPress: openService,
    ),
  ],
)
```

`columns` is a maximum. Text items provide measurable labels, default to one
line and retain their full semantic labels; large text can reduce columns.
Use `labelMaxLines: 2` for wrapping. `rowsPerPage: null` expands all rows;
a positive row count pages horizontally with equal page height. Set a stable
PageStorageKey on the grid for in-process page retention and unique stable keys
on paged items. Identity comparison uses key equality, never printed key text. Changed columns,
capacity or item identities reset the paging scope. `showIndicators: false`
hides only the visual hint. Icons accept caller-provided image Widgets.
Badge, surface, enabled and selected contracts remain unchanged.

## Verification

Run `flutter pub get`, `flutter analyze`, and `flutter test` in this directory.
CI checks both `flutter pub downgrade` (declared minimum dependencies) and
`flutter pub upgrade` (latest compatible dependencies), followed by analysis
and tests for each. The application lockfile remains fixed independently.
Tests use local Widgets rather than network or device services. The standalone
suite also enforces production dependency boundaries; the Starter suite rejects
both package-internal imports and relative source imports into the package. App and
Playground integration tests remain in the Starter's test directory.
