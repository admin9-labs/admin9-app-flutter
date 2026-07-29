# Components

## 1. Shared contract rules

All components belong to Core, accept semantic data, and expose controlled state unless explicitly stated. They do not read ViewModels, entities, repositories, services, session, permissions, or business copy. `Key` is supported through normal Widget construction. Feature tests locate behavior by stable keys, visible text, semantics, and result state; only Design System tests assert Material/Cupertino implementation types.

Feature composition receives semantic values only through the read-only `AppDesignTokens` contract and `AppDesignScope`. The Core-owned lookup mechanism is frozen by the Phase 0D implementation probe and exported from `lib/admin9_ui.dart`; v1.0.1 does not falsely specify a static abstract Dart method. The facade exposes Admin9 semantic values, not `ThemeData`, `CupertinoThemeData`, mutable styles, component internals, or arbitrary raw-value escape hatches.

<a id="ds-cmp-001"></a>

The v1.0 consumer shapes live in the non-exported [contract probe](../../tool/design_system/design_system_contract_probe.dart). Its abstract Widgets deliberately avoid fake runtime bodies. `flutter analyze tool/design_system/design_system_contract_probe.dart` proves Flutter 3.44.1/Dart 3.12.1 can express every frozen name, constructor parameter, generic bound, nullability, `Key`, callback, controlled-state owner, enum, and immutable value object. It does not prove that a consumer can instantiate a runtime Widget.

v1.0.1 fixes the implementation boundary without changing those shapes: Phase 0D makes the value objects, controller interfaces, immutable token lookup scope, Brand entry, Gallery registry seam, and import boundary real. The [implementation probe](../../tool/design_system/design_system_implementation_probe.dart) instantiates those non-visual mechanisms through `lib/admin9_ui.dart`. Each concrete visual Widget replaces its abstract declaration only in its assigned Phase 1-4 and is exported in that same change, with constructor parity and instantiation evidence. Phase 0D does not manufacture a presentation Widget to satisfy an early gate.

### 1.1 Public export matrix

| Public from `lib/admin9_ui.dart` when owning phase completes | Core-internal presentation type | Rule |
| --- | --- | --- |
| concrete `AppPage`, `AppBottomNavigation`, `AppButton`, `AppTextField`, `AppSelect`, `AppSegmentedControl`, `AppSingleChoiceList`, `AppSwitch`, `AppListTile`, `AppSection`, `AppNotice`, `AppProgressIndicator` | platform implementation classes | consumers instantiate only the public semantic Widget |
| `AppInteractionController`, `AppInteractionControllerOf`, `AppInteractionHost`, `AppActionMenuItem<T>` | `AppDialog`, `AppActionMenu<T>` presentation Widgets | Phase 0D provides the non-visual lookup host; Phase 4 installs the real controller; Business invokes controller methods and awaits results |
| `AppFeedbackController`, `AppFeedbackRequest`, `AppFeedbackHost` | `AppFeedback` app-root presentation Widget | Phase 0D provides the non-visual lookup host; Phase 2 installs the real presenter/controller; Business only submits/dismisses requests through it |
| `AppPageAction`, `AppNavigationDestination`, `AppSelectOption<T>`, `AppChoice<T>`, enums and `AppDesignTokens` read-only facade | platform icon/token resolvers | values contain no raw Material/Cupertino types |

The component names `AppDialog`, `AppActionMenu`, and `AppFeedback` remain normative Core capabilities even though their presentation Widgets are internal. There is one Business entry for each behavior, never a controller/Widget choice.

## 2. Component matrix

| Component | Purpose and semantic input | State owner and platform mapping | Content, semantics, and responsive rules |
| --- | --- | --- | --- |
| `AppPage` / `AppPageAction` | page title, body, required `navigationMode`, semantic actions, child-only `parentLabel` | Core maps Scaffold/AppBar or Cupertino page/navigation bar; caller owns page state | root forbids back/parentLabel; child requires non-empty parentLabel; action has name/tooltip; no business route logic |
| `AppBottomNavigation` / `AppNavigationDestination` | 2-5 top-level labels and icon roles, selected index | Shell owns index/pages/lifecycle; NavigationBar or CupertinoTabBar | selected trait/value announced; preserves tabs; no page construction or independent Navigator |
| `AppButton` | label, primary/secondary/tertiary/destructive, enabled/loading, optional icon role | caller owns task idempotency/loading transition; Core disables dispatch while loading/disabled | one pointer/keyboard activation dispatches one callback; label grows/wraps; loading keeps action location; button/input need not be equal height |
| `AppTextField` | controller, label, focus, validation/error, input action/type, autofill, obscure toggle | feature owns text/focus/validation; Core owns password visibility presentation | persistent label; adjacent error; first-error focus; named toggle; no fixed height |
| `AppSelect<T>` | label, nullable controlled value, 2-20 options, non-null `AppValueChanged<T>` callback | caller owns committed value; dropdown form field or Cupertino modal picker | null means not selected; Cancel/dismiss never calls back; Done commits one non-null value once; every close restores trigger focus; not search, settings, action menu, or multi-select |
| `AppSegmentedControl<T>` | 2-5 short, equal peer modes and controlled value | caller owns value; SegmentedButton or sliding segmented control | no long labels; not navigation, theme, font size, filters needing many values, or primary action |
| `AppSingleChoiceList<T>` | title, controlled current value, labelled choices | caller owns value; Material radio list or iOS checkmark list | selection immediate; selected trait/text; user returns manually; settings choice only in v1 |
| `AppSwitch` | label association, controlled boolean, enabled/change callback | caller owns App preference; Switch or CupertinoSwitch | switch and row form one semantic action, never double-trigger; system/effective status remains nearby page content |
| `AppListTile` | title, subtitle, optional icon role, read-only current value, selected/enabled/onTap/disclosure | caller owns its single row action; ListTile or CupertinoListTile | Core renders the value/disclosure; values move below labels under pressure; no arbitrary trailing Widget escape |
| `AppSection` | optional title/footer and child rows | page owns child order; unframed Android group or inset-grouped iOS section | no nested cards; header/footer are associated; does not define business grouping |
| `AppNotice` | tone, title/message, optional paired action label/callback | feature chooses state and copy; Core presents inline container | icon + explicit tone/status; action remains reachable; not transient feedback or a success decision engine |
| `AppFeedback` | `AppFeedbackRequest` message/tone/optional paired action submitted through `AppFeedbackController` | app-root single owner; SnackBar/Banner or iOS top overlay | fixed lifecycle in platform module; live region; close/action; replacement; no caller duration or `BuildContext` input |
| `AppDialog` | information/confirmation/destructive request submitted through `AppInteractionController` | caller awaits `void`/boolean result; AlertDialog or CupertinoAlertDialog | focus trapped and restored; cancel precedes confirm; destructive named and not color-only; no public presentation Widget or `BuildContext` input |
| `AppIconRole` | cross-platform semantic role, selected/unselected state where relevant | Core maps Material/Cupertino glyph | decorative instances excluded; actionable instances named; raw `IconData` not public |
| `AppActionMenu<T>` / `AppActionMenuItem<T>` | optional title, 2-6 labelled command values, Cancel, optional semantic icon/destructive state | caller awaits `AppInteractionController.showActionMenu<T>` and owns the business effect; Material modal bottom sheet or CupertinoActionSheet | not a field picker; disabled/destructive states explicit; dismiss returns `null`; one invocation returns at most one non-null selection |
| `AppProgressIndicator` | required readable label, circular/linear kind, optional determinate value in `0...1` | caller owns task/progress value; Circular/LinearProgressIndicator or CupertinoActivityIndicator/semantic determinate bar | indeterminate never invents percentage; determinate announces bounded progress; reduced motion retains state comprehension |

## 3. Variants and states

Every Gallery entry MUST show enabled, pressed, focused, disabled, selected/toggled where applicable, loading, error, long Chinese label, Standard/Large/Extra Large, light, dark, and high-contrast intent. `AppActionMenu` additionally shows normal, disabled, destructive, cancellation, and 6-item overflow-safe states. `AppProgressIndicator` additionally shows circular/linear, indeterminate, 0%, 45%, 100%, reduced-motion, and labelled semantics. Error, unavailable, destructive, selected, disabled, and loading each include non-color information.

`AppTone` is the single shared status enum for `AppNotice` and `AppFeedback`: `info`, `success`, `warning`, `error`. No parallel notice-only tone enum exists.

`AppIconRole` v1 Core roles are restricted to cross-pattern navigation/actions: `back`, `close`, `chevronForward`, `home`, `homeSelected`, `account`, `accountSelected`, `settings`, `search`, `info`, `warning`, `success`, `error`, `visibility`, `visibilityOff`, and `more`. The authoritative glyph table is in [Platform adaptation](02-platform-adaptation.md#21-authoritative-icon-mapping). Settings-specific icons (`textSize`, `contrast`, `grayscale`, `reduceMotion`) remain Business until a second real shared consumer. Phase 0's proposed business-heavy icon expansion is rejected.

## 4. Page-special boundaries

The following do not become components: personal-center identity summary, guest action region, signed-in danger region, auth schema/validator/session result, settings system-versus-App explanatory row, privacy consent content, business Empty, Avatar, Tag, customer card, permissions, and domain statuses. `AppNotice` may present a state but never decides whether it is success/error/unavailable.

## 5. Test contract per component

Each implemented component requires:

1. Widget tests on Android and iOS target platforms for mapping, semantics, callbacks, disabled/loading locks, focus, and state ownership.
2. All A-L rows in [Accessibility and Quality](06-accessibility-quality.md#ds-rsp-001), including 320/360/390/600, phone landscape, Standard/Large/Extra Large, synthetic system-scale stress, and longest Chinese labels.
3. Hit-bound measurement separate from visual bounds.
4. Representative light/dark/high-contrast Goldens, never used as the sole semantic or device evidence.
5. Device acceptance for platform behavior, assistive technology, keyboard/IME, and gestures where applicable.

`AppSelect` and `AppSegmentedControl` are frozen contracts but have no approved current consumer. They remain unimplemented until a real consumer exists; their implementation change MUST include the already-frozen declaration, Gallery states, tests, and device evidence. This is an implementation trigger, not permission to choose a different API.

<a id="ds-inp-001"></a>

`AppTextField` preserves its label, keeps `forceErrorText` until Business clears it after input change, moves focus to the first invalid field after submit, and never owns validation rules or session state. Password visibility is local presentation state; text, focus, submission, and errors are Business-owned.

<a id="ds-fbk-001"></a>

`AppFeedback` has one app-root controller and one visible message. An action label and callback are both absent or both present, and a present label is non-empty. Without an action and with `MediaQuery.accessibleNavigationOf(context) == false`, info/success close after 3 seconds and warning/error after 5 seconds. With an action or `accessibleNavigation == true`, it persists until the visible Close command or action is activated. `SemanticsBinding.semanticsEnabled` is not a persistence predicate. Action dispatches once and then closes. A new request atomically replaces the old message, cancels its timer, preserves current focus, and announces only the new message once through a live region. Callers cannot set duration.

Dialog, action-menu, and feedback presentation is Core-owned through `AppInteractionController` and `AppFeedbackController`. `showInformation` returns `Future<void>`; confirmation/destructive return `Future<bool>` with every cancel, system dismiss, and permitted barrier dismiss resolving `false`; destructive barrier dismiss is disabled. `showActionMenu<T>` returns the selected value or `null` for Cancel, barrier dismiss, or system back. Presentation restores the previously focused node after dismissal. Business supplies semantic text/items and awaits results; it never presents a platform dialog or sheet directly. The non-exported declaration probe freezes these names, parameters, return types, generic bounds, and nullability; runtime lookup is frozen by the Phase 0D implementation probe.

Information dialogs have exactly one closing action and no cancel label. Confirmation and destructive dialogs have exactly one non-empty cancel label plus one non-empty confirm label; declaration assertions and Widget tests cover invalid combinations. The iOS `AppSelect` picker restores focus to its trigger after Done, Cancel, barrier dismiss, or system dismiss. Done updates the trigger's readable value before focus restoration; a reader never lands on the disposed popup.

<a id="ds-cmp-002"></a>

`AppActionMenu<T>` is only for 2-6 immediate commands. Core owns sheet presentation, cancel/dismiss semantics, focus containment, platform mapping, and single callback dispatch. Business owns labels, enabled/destructive classification, the selected value, and the resulting effect.

<a id="ds-cmp-003"></a>

`AppProgressIndicator` always has a readable label. `value == null` is indeterminate; otherwise it is finite and within `0...1`. Business owns real progress and completion; Core owns platform rendering and semantics. System Reduce Motion retains the platform-native activity indicator's necessary busy animation and readable label; only unrelated decorative/local transitions are removed. It never freezes the spinner or converts unknown progress into a percentage.

## 6. Phase 0D implementation entry

Phase 0D MUST:

- implement and export the frozen non-visual value objects, enums, controller interfaces, and `AppDesignScope` without unimplemented/placeholder `throw`, `external`, placeholder Widgets, or fake services; a missing required host fails with a named `FlutterError` as a configuration precondition;
- freeze the Core-owned token lookup and controller contract mechanism with a second implementation probe; actual dialog, action-menu, and feedback presenters remain in their owning visual phases;
- preserve every enum, generic bound, nullability, callback, value object, and controlled-state owner in the v1.0 contract probe;
- include `AppSingleChoiceList<T>`, `AppActionMenu<T>`, and `AppProgressIndicator` in the first implementation schedule;
- keep `AppSelect` and `AppSegmentedControl` specified but defer implementation until a real consumer exists;
- reduce `AppIconRole` to cross-pattern roles and prohibit raw `IconData` escapes;
- define app-global feedback owner/scope and action pairing;
- compile the declaration probe and implementation probe before Phase 0D public export;
- create a non-empty public barrel containing only real Phase 0D declarations; add each concrete Widget only when its owning phase supplies a working implementation and tests.
- expose an immutable `AppDesignTokens` facade and prove that it exposes no Material/Cupertino or mutable-style escape.
