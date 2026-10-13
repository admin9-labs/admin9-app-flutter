# Admin9 UI

Forui-based Flutter components maintained independently of application business code.
This local pilot contains carousel, grid, feed-card, announcement and banner
families. It is not published. Flutter 3.47.2 / Dart 3.13.2 and Forui ^0.27.3 are required.

## Public Widget Inventory

The package exports seven public Widgets: `ACarousel` for horizontal paging,
`AGrid` for action layout and optional paging, `AGridItem` for item interaction,
`AGridBadge` for semantic badges, `AFeedCard` for four content layouts,
`AAnnouncement` for wrapping copy with optional rotation, and `ABanner` for
stacked/rotating operation images. `ACarouselItem`, `AAnnouncementItem` and
`ABannerItem` are caller-content data; `AGridStyle` is a Forui style extension.
Data, enums and styles are not counted as Widgets. Internal paging APIs are not
exported and applications must not import them.

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
ACarousel excludes vertical paging, video, fullscreen and custom transitions.
Use ABanner for vertical operation banners.

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

## Feed Card

```dart
AFeedCard(
  title: 'City services improve this week',
  metadata: 'October 13, 2026 · City news',
  semanticsLabel: 'City services improve this week, October 13, City news',
  layout: AFeedCardLayout.trailingImage,
  images: [Image.asset('assets/news.jpg', fit: BoxFit.cover)],
  onPress: openArticle,
)
```

`layout: null` selects three images for 3+ images, a trailing image for 1–2, or
text for none. Explicit layouts are `textOnly`, `trailingImage`, `threeImages`,
and `largeImage`. Missing images degrade to trailing/text; extra images are
ignored. Trailing images use 30% of available width at 4:3; triple images use
3:2 and large images use 16:9. Titles and metadata wrap without a line limit.
Long metadata moves below the trailing-image row. `mediaBadge` is decorative
caller content outside the image, so long durations can wrap; it also appears
in text-only cards. The caller owns its Forui styling and includes its meaning
in the complete `semanticsLabel`. A card has one optional action; nested
interactive images, badges or metadata are outside this API.

## Announcements

```dart
AAnnouncement(
  autoplay: true,
  items: [
    AAnnouncementItem(id: 'hours', title: 'Service hours change this week',
      onPress: openNotice),
    AAnnouncementItem(id: 'guide', title: 'Read the updated service guide',
      onPress: openGuide),
  ],
)
```

Use Forui `FAlert` directly for ordinary static status messages. This component
adds multiple wrapping announcements, optional vertical automatic rotation and
a manual next button. Copy uses Forui body typography; the viewport measures the
tallest item at the current width, locale, direction and text scale. Item IDs must
be unique and stable. `semanticsLabel` defaults to the full title. Autoplay is
opt-in, loops, and shares carousel pause gates. Vertical drags scroll the parent.
The next button remains usable without autoplay and uses Forui localization.

## Banners

```dart
ABanner(
  display: ABannerDisplay.rotating,
  aspectRatio: 4,
  items: [
    ABannerItem(id: 'campaign', child: Image.asset('assets/campaign.jpg',
      fit: BoxFit.cover), semanticsLabel: 'Open service campaign',
      onPress: openCampaign),
  ],
)
```

`stacked` is the default and exposes all items; a single item is a static banner.
`rotating` loops vertically with automatic switching and no drag paging, so
vertical gestures reach the parent scroll view. Extremely wide ratios retain the
Forui item minimum touch height, which takes priority over the requested ratio.
Manual semantic paging remains
available. Focused items also support arrow-key paging: up/down for vertical
content, and direction-aware left/right for horizontal carousels. Keyboard focus
stays on the pager after switching; Enter/Space activates the selected item.
Holding a manual paging control also pauses automatic rotation.
Images, fit, loading, errors and complete accessible names belong to
the caller. IDs must be unique and stable. Loop content must not share GlobalKeys.

Both announcements and banners accept `interval` (positive), `active` and
`onChanged` with the carousel callback contract within rotation. Retained offscreen
hosts must set `active: false` when TickerMode stays enabled. They expose all items
when MediaQuery reduced motion/accessible navigation or Forui disabled motion is
active, preserving every action. Returning from that expanded presentation or
changing Banner display starts a new rotation at the first item. Content updates
within rotation retain the selected ID. The shared internal pager settles
interrupted automatic motion to the nearest item and waits a full interval after
resumption. It does not fetch content, format dates/durations, interpret backend
configuration, navigate, cache images or play media.

The Starter's Content Feed Playground consumes all three APIs in one configurable
news/operations scenario, with local licensed assets, action/paging feedback and
reset. Application models are deliberately absent from the package.

## Verification

Run `flutter pub get`, `flutter analyze`, and `flutter test` in this directory.
CI checks both `flutter pub downgrade` (declared minimum dependencies) and
`flutter pub upgrade` (latest compatible dependencies), followed by analysis
and tests for each. The application lockfile remains fixed independently.
Tests use local Widgets rather than network or device services. The standalone
suite also enforces production dependency boundaries; the Starter suite rejects
both package-internal imports and relative source imports into the package. App and
Playground integration tests remain in the Starter's test directory.
