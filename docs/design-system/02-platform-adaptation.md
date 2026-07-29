# Platform Adaptation

## 1. Ownership and host

<a id="ds-plt-001"></a>

Core owns every visible interactive platform choice. Feature code MUST NOT call `Platform.isIOS`, select Material/Cupertino controls, change route builders, or import platform implementation files. Business pages MAY use non-interactive Flutter layout and content primitives: `Widget`, `Text`, `Image`, `Row`, `Column`, `Stack`, `Wrap`, `Flex`, `Expanded`, `Flexible`, `Padding`, `Align`, `Center`, `SizedBox`, `ColoredBox`, `ClipOval`, `ConstrainedBox`, `LayoutBuilder`, `MediaQuery`, `SafeArea`, `SingleChildScrollView`, `ListView`, `CustomScrollView`, `Sliver*`, `Form`, `FocusTraversalGroup`, and `Semantics`. The single read-only content exception is `package:flutter/material.dart show SelectableText`, used only to preserve native text selection for long legal/reference copy; it is not an action, field, picker, or styling escape. Interactive commands, fields, selections, feedback, dialogs, sheets, lists, page bars, and navigation go through `App*` APIs.

The root remains one `MaterialApp` for Navigator, localization, and theme infrastructure. This host choice does not authorize Material visual controls on iOS. The same semantic tokens derive `ThemeData` and `CupertinoThemeData`.

## 2. Unique mapping

| Semantic role | Android implementation | iOS implementation | Fixed behavior |
| --- | --- | --- | --- |
| app root | `MaterialApp`, Material 3 | shared `MaterialApp` host + Cupertino theme bridge | one route tree and localization source |
| route | `MaterialPageRoute`, default Android builder | `MaterialPageRoute`, default Cupertino builder | no custom no-transition builder |
| shell | `Scaffold + IndexedStack + NavigationBar` | `CupertinoPageScaffold + IndexedStack + CupertinoTabBar` | Shell owns index, pages, and lifecycle |
| page/bar | `Scaffold + AppBar` | `CupertinoPageScaffold + CupertinoNavigationBar` | root no back; child back names parent |
| primary button | `FilledButton` | `CupertinoButton.filled` | one primary action region |
| secondary button | `OutlinedButton` | `CupertinoButton.tinted` | no elevation |
| tertiary button | `TextButton` | `CupertinoButton` | low-priority command |
| destructive button | error-role `FilledButton` | destructive `CupertinoButton` | irreversible action requires confirmation |
| text/password field | `TextFormField` | external label/error + `FormField<String>` bridging `CupertinoTextField` | persistent label, adjacent error, controlled focus |
| compact field select | `DropdownMenuFormField<T>` | modal `CupertinoPicker` with Cancel/Done | 2-20 non-search choices; not settings |
| peer-mode segment | `SegmentedButton<T>` | `CupertinoSlidingSegmentedControl<T>` | 2-5 short, equal modes; not theme/font |
| settings single choice | `RadioGroup<T> + RadioListTile<T>` | pushed checkmark list with selected trait | immediate selection, user returns manually |
| boolean | `Switch` | `CupertinoSwitch` | controlled App preference; system/effective status separate |
| list row | `ListTile` | `CupertinoListTile` | Core owns disclosure and pressed feedback |
| section | unframed column, header/footer, row dividers | `CupertinoListSection.insetGrouped` | no decorative or nested cards |
| dialog | `AlertDialog` | `CupertinoAlertDialog` | information 1 action; confirm 2 actions |
| action menu | `showModalBottomSheet<T>` | `showCupertinoModalPopup<T>` containing `CupertinoActionSheet` | 2-6 commands; Cancel/dismiss returns null; never a field picker |
| inline notice | semantic inline container | semantic inline container | icon + tone label + message + optional action |
| feedback | transient `SnackBar`; persistent `MaterialBanner` | top status `OverlayEntry` | one app-global owner; not a toast |
| loading | `AppProgressKind.circular` -> `CircularProgressIndicator`; `.linear` -> `LinearProgressIndicator` | indeterminate -> `CupertinoActivityIndicator`; determinate -> Core semantic linear bar | readable label; determinate value 0...1 |
| page action icon | Material icon mapped from `AppIconRole` | Cupertino icon mapped from `AppIconRole` | tooltip/name and platform hit minimum |

`AppSelect` and `AppSegmentedControl` have frozen v1 contracts but no approved current consumer. Settings MUST use `AppSingleChoiceList<T>`. `AppActionMenu` is the only 2-6 command sheet; it MUST NOT select field or settings values. `AppProgressIndicator` uses Material circular/linear indicators on Android; iOS uses `CupertinoActivityIndicator` for indeterminate work and a Core semantic determinate bar for known progress.

### 2.1 Authoritative icon mapping

| `AppIconRole` | Android | iOS |
| --- | --- | --- |
| `back` | `Icons.arrow_back` | `CupertinoIcons.back` |
| `close` | `Icons.close` | `CupertinoIcons.clear` |
| `chevronForward` | `Icons.chevron_right` | `CupertinoIcons.chevron_forward` |
| `home` | `Icons.home_outlined` | `CupertinoIcons.house` |
| `homeSelected` | `Icons.home` | `CupertinoIcons.house_fill` |
| `account` | `Icons.person_outline` | `CupertinoIcons.person` |
| `accountSelected` | `Icons.person` | `CupertinoIcons.person_fill` |
| `settings` | `Icons.settings_outlined` | `CupertinoIcons.gear` |
| `search` | `Icons.search` | `CupertinoIcons.search` |
| `info` | `Icons.info_outline` | `CupertinoIcons.info` |
| `warning` | `Icons.warning_amber_outlined` | `CupertinoIcons.exclamationmark_triangle` |
| `success` | `Icons.check_circle_outline` | `CupertinoIcons.check_mark_circled` |
| `error` | `Icons.error_outline` | `CupertinoIcons.exclamationmark_circle` |
| `visibility` | `Icons.visibility` | `CupertinoIcons.eye` |
| `visibilityOff` | `Icons.visibility_off` | `CupertinoIcons.eye_slash` |
| `more` | `Icons.more_horiz` | `CupertinoIcons.ellipsis` |

`AppNavigationDestination` receives distinct normal and selected roles. Core resolves the complete table; Business never receives `IconData` and cannot substitute platform glyphs.

## 3. Navigation and back

<a id="ds-nav-001"></a>

Root tabs never show back. Child pages preserve the platform default page-transition builder. Android uses synchronous `PopScope` state compatible with predictive back; iOS preserves the left-edge gesture. A cancelled gesture keeps route-local form and scroll state; a completed gesture pops once. Dialog, sheet, and picker consume back/dismissal before the page. Reduced motion never replaces these builders.

Automation can verify application state before/after pop. It cannot prove Android predictive-back start/progress/cancel/complete or iOS interactive edge-back. Android API 34+ (with API 36 regression) and current iOS simulator/device manual recordings are hard gates after implementation.

## 4. Edge-to-edge and safe areas

Android target SDK 36 edge-to-edge is a system constraint, not a product option. Background may extend behind system bars; interactive content is protected by page bars, navigation, `SafeArea`, and `MediaQuery.viewPadding`. System-bar foreground brightness follows the real backing surface. Test gesture navigation, three-button navigation, display cutout, light/dark/high contrast, bottom navigation, and the scroll endpoint.

Top bars own the top safe area. Child bodies use bottom protection; Shell tabs rely on the platform bottom bar and do not add duplicate bottom padding. Sheets and pickers own their bottom safe area. iOS content respects the home indicator and does not double-inset `CupertinoTabBar`.

## 5. Keyboard, IME, and autofill

Android keeps manifest `adjustResize`; both page scaffolds resize for the keyboard. Task forms are scrollable. `viewInsets.bottom` represents IME occlusion; `viewPadding` represents persistent system regions and they are not interchangeable.

Focus, visual, and semantics order match. `next` advances to the next field; `done` validates/submits. The first error receives focus and one announcement. Password visibility is a separately named toggle with 48dp/44pt hit bounds. Autofill groups and hints are supplied by Business according to the flow (`username`, `password`, `newPassword`), while Core preserves them. Submitting locks duplicate activation but does not invent network loading.

## 6. Feedback lifecycle

`persistent = action exists OR MediaQuery.accessibleNavigationOf(context)`.

- Non-persistent info/success closes after 3 seconds; warning/error after 5 seconds.
- Persistent feedback never auto-closes. It exposes a visible close control and, when applicable, one action.
- Action activation is locked to once, invokes the callback once, then closes.
- A new message replaces the current message in the app-global scope.
- Every new message is announced once through a live region without stealing focus; replacement does not announce the old message again.
- Close and action satisfy platform hit targets and have distinct names.

The iOS overlay is anchored inside the current Navigator content below the status and navigation bars. It never covers back/title, grows for long text, preserves existing focus, and exposes reader order `message -> action -> close`; action and close hit bounds are at least 44x44pt. Widget tests verify geometry/order and device VoiceOver verifies that the platform accessibility state drives `accessibleNavigation`; until device evidence exists, that signal remains Unknown rather than being inferred from `semanticsEnabled`.

## 7. Verification status

Static visual assets verify intended structural difference only. Android/iOS device visuals, IME, autofill/password manager, TalkBack/VoiceOver/Switch Access/Control, predictive back, edge back, system-bar contrast, and runtime bounds remain Unknown until the Flutter implementation and device gates exist.
