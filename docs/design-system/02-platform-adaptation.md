# Platform Adaptation

> Scope: normative terms in this module apply only to implementations and
> contributions proposed for inclusion in the upstream Admin9 App Starter
> repository. They do not govern independent forks.

## 1. Ownership And Host

<a id="ds-plt-001"></a>

Core owns every visible interactive platform choice. Feature code MUST NOT call
`Platform.isIOS`, select Material/Cupertino controls, change route builders, or
import platform implementation files. Business pages MAY use the non-
interactive Flutter declarations allowed by the import-boundary gate. Commands,
fields, selections, feedback, dialogs, sheets, lists, page bars, and navigation
go through `App*` APIs.

The root remains one `MaterialApp` for Navigator, localization, theming, and
system integration. This is infrastructure, not permission for Feature code to
select a visual component family.

## 2. Visible Unity And System Differences

Brand-owned controls use one first-party Admin9 structure on both platforms.
Platform differences are allowed only where the operating system owns the
interaction:

| Responsibility | Shared Admin9 contract | Platform-owned behavior retained |
| --- | --- | --- |
| App host and routes | one host, route tree, route names, destinations, and results | default Android/iOS transition and back dispatch |
| page and shell | one title hierarchy, surface language, action order, and bottom navigation | status/navigation/home-indicator safe areas and system bars |
| buttons and fields | one variant, label, validation, state, loading, and recovery language | keyboard layout, IME actions, autofill/password-manager UI |
| settings and lists | one row, section, value, selected, switch, and disclosure language | operating-system accessibility focus and input mechanics |
| dialogs, menus, notices, and feedback | one action order, destructive meaning, state message, and recovery | system dismissal/back delivery and accessibility scheduling |
| progress and icons | one semantic role and branded glyph family | necessary system busy behavior and rasterization differences |

The current production component code uses the shared first-party mapping.
Material/Cupertino types may remain inside Core for host, theme, route, or future
system-owned behavior, but their types, themes, controllers, resources, and
callbacks MUST NOT leak through `lib/admin9_ui.dart` or into Feature code.

### 2.1 Authoritative Icon Mapping

`AppIconRole` maps to one current branded glyph family on Android and iOS:

| `AppIconRole` | Glyph |
| --- | --- |
| `back` | `Icons.arrow_back` |
| `close` | `Icons.close` |
| `chevronForward` | `Icons.chevron_right` |
| `home` / `homeSelected` | `Icons.home_outlined` / `Icons.home` |
| `account` / `accountSelected` | `Icons.person_outline` / `Icons.person` |
| `settings` | `Icons.settings_outlined` |
| `search` | `Icons.search` |
| `info` | `Icons.info_outline` |
| `warning` | `Icons.warning_amber_outlined` |
| `success` | `Icons.check_circle_outline` |
| `error` | `Icons.error_outline` |
| `visibility` / `visibilityOff` | `Icons.visibility` / `Icons.visibility_off` |
| `more` | `Icons.more_horiz` |

Business never receives raw `IconData` and cannot substitute a platform glyph.

## 3. Navigation And Back

<a id="ds-nav-001"></a>

Root tabs never show back. Child pages preserve the platform default page-
transition builder. Android remains compatible with predictive back; iOS
preserves the left-edge gesture. A cancelled gesture keeps route-local form and
scroll state; a completed gesture pops once. Dialog, sheet, and picker dismissal
resolves before a page pop. Reduced motion does not replace system navigation.

Automation verifies application state before and after pop. It cannot prove
gesture start, progress, cancellation, or completion on the operating system.
Those results require contemporaneous device evidence.

## 4. Edge-To-Edge And Safe Areas

Android target SDK edge-to-edge is a system constraint, not a product option.
Background may extend behind system bars; interactive content is protected by
page bars, navigation, `SafeArea`, and `MediaQuery.viewPadding`. System-bar
foreground brightness follows the backing surface.

Top bars own the top safe area. Child bodies own bottom protection; Shell tabs
rely on their bottom navigation and do not add duplicate padding. Sheets and
pickers own their bottom safe area. iOS content respects the home indicator.

## 5. Keyboard, IME, And Autofill

Android keeps manifest `adjustResize`; page scaffolds resize for the keyboard.
Task forms remain scrollable. `viewInsets.bottom` is IME occlusion and
`viewPadding` is a persistent system region; they are not interchangeable.

Focus, visual, and semantics order match. `next` advances; `done` validates or
submits. The first error receives focus and one announcement. Password
visibility is a separately named control. Business supplies input type, action,
and autofill hints; Core preserves them without inventing a network result.

## 6. Feedback Lifecycle

`persistent = action exists OR MediaQuery.accessibleNavigationOf(context)`.

- Non-persistent info/success closes after 3 seconds; warning/error after 5.
- Persistent feedback exposes Close and, when applicable, one action.
- Action dispatches once, then closes; a new message replaces the old message.
- A new message is announced once without stealing focus.
- Close and action have distinct names and at least 48 logical-pixel bounds.

Widget tests verify lifecycle, semantics, focus, and geometry. They do not prove
TalkBack or VoiceOver delivery.

## 7. Evidence Boundary

Current automated coverage protects visible structure, route/application state,
keyboard metadata, semantics, responsive layout, and safe-area ownership. The
fixed-source repeated simulator smoke is historical bounded `Pass` evidence.
Current physical-device, real IME/password-manager, TalkBack/VoiceOver,
predictive/edge-back gesture, and final brand results remain exactly as recorded
in [Delivery](../delivery/README.md).
