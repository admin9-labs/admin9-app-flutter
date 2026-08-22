# Admin9 UI Ownership Matrix

Status: G1 working matrix
Scope: current Demo and its removable comparison POCs

“Unified” below means one Admin9 visible contract, not cross-platform pixel
identity. “Platform” means native system behavior is preserved behind `App*`.

| Surface or capability | Current implementation | Owner | Target contract | Allowed platform difference | Evidence gate |
| --- | --- | --- | --- | --- | --- |
| Semantic color | Shared tokens | Brand | One Admin9 role set in light/dark/high contrast | OS color rendering | Contrast calculation, paired review, device review |
| Type hierarchy | Different Android/iOS metrics | Brand | Same semantic hierarchy and emphasis | System font shaping and accessibility scaling | Structure assertions, long Chinese, Bold Text, max text |
| Spacing and shape | Part shared; Cupertino groups differ | Brand | One restrained rhythm and surface language | Hit-region minimum | Paired reference and bounds checks |
| Icon language | Full Material/Cupertino glyph swap | Brand | One coherent Admin9 icon family for business UI | System-owned picker/share/permission glyphs | Paired review and semantic labels |
| Page content layout | Shared feature structure | Brand | Same information order and page composition | Safe-area insets | 320/360/390/600, landscape, device |
| Page bar | Material/Cupertino split | Mixed | Shared Admin9 bar appearance and actions | Back glyph/gesture and route transition may adapt | Back tests plus paired/device review |
| Bottom navigation | NavigationBar/CupertinoTabBar split | Mixed | Shared Admin9 destinations, labels, selection, geometry intent | Safe area and OS feedback mechanics | State preservation, hit bounds, paired review |
| Primary/secondary/destructive button | Filled/Outlined versus CupertinoButton | Brand | One visible family and state model | 48dp/44pt hit minimum and system focus mechanics | Widget states, semantics, paired review |
| Text/password field | TextFormField versus CupertinoTextField | Brand | One label, border, error, focus, disabled, and loading language | Keyboard, caret, selection, autofill, password manager | Widget/IME/autofill/device |
| List row and section | ListTile versus Cupertino grouped list | Brand | One scan rhythm, dividers, value/disclosure treatment | OS focus/accessibility mechanics | Long text, selected/disabled, paired review |
| Switch | Switch/CupertinoSwitch | Mixed | Shared label/state hierarchy; visible style chosen by evidence | Native semantics, haptic/accessibility behavior | Widget semantics and dual-device review |
| Single choice | Radio list versus checkmark list | Mixed | Same choices, selected meaning, and return behavior | System focus/selection feedback | Task test, selected semantics, dual-device review |
| Menu/action sheet | Material bottom sheet versus Cupertino action sheet | Mixed | Same command order, danger, disabled, cancel, and brand framing | Dismiss gesture and safe-area mechanics | Widget behavior, paired overlay, device dismissal |
| Business dialog | AlertDialog/CupertinoAlertDialog | Mixed | Same Admin9 hierarchy, copy, actions, and danger meaning | OS modal focus and dismissal mechanics | Widget semantics, focus restoration, paired/device review |
| Date/time/system picker | No approved consumer | System or mixed | Use system picker when the choice is system-domain; brand shell only when business-domain | Native picker UI | Scenario-specific decision and device test |
| Inline notice | Shared semantic container | Brand | One tone hierarchy and recovery action model | Reader announcement mechanics | Contrast, semantics, long/error states |
| Transient feedback | Snackbar/banner versus iOS overlay | Brand for visible result; system for announcement | One placement and Admin9 visual contract unless device evidence requires variation | OS live-region behavior and safe area | Replacement/timing tests and device reader |
| Loading/empty/error | Partial platform indicator split | Brand | Same content hierarchy, state meaning, and recovery path | Native system activity signal only if visually subordinate | State matrix, reduced motion, paired review |
| Route tree and navigation state | One route tree | Product/architecture | Retain one route tree and feature-owned state | Native transition and back gesture | Navigation tests and Android/iOS gesture tests |
| Keyboard and IME | Platform supplied | System | Preserve resize, next/done, selection, and input | Keyboard visuals and IME affordances | Real IME, landscape, external keyboard |
| Autofill/password manager | Platform supplied | System | Preserve hints and credential flow | Native overlays | Android/iOS device test |
| Permissions/share | Platform supplied | System | OS owns prompts and share UI; Admin9 owns surrounding explanation/result | Full native UI | Device scenario test |
| Safe areas/system bars | Platform supplied with App shell | System | Content never obscured; brand surface can extend appropriately | Insets and system-bar mechanics | Cutout/home indicator, edge-to-edge, 3-button/gesture |
| Accessibility services | Shared semantics plus OS | System behavior; brand content | Same names, roles, values, order, errors, and recovery | TalkBack/VoiceOver/Switch behavior | Widget semantics and device matrix |

## Current priority

The first implementation comparison targets the most visible brand-owned and
mixed surfaces: page bar, bottom navigation, button, field, list/section,
switch, dialog/menu, feedback, and loading/error states. System-owned
capabilities remain regression gates and are not visually redesigned.
