# Admin9 Design System v1.0 Source and Evidence Ledger

This ledger separates external requirements, framework capability, Admin9 product decisions, static design evidence, and implementation-stage Unknowns. An external link does not by itself prove the current App implementation. Runtime and device claims remain Unknown until the gate named in the normative module passes.

| Evidence class | Official source | Used for | Admin9 interpretation |
| --- | --- | --- | --- |
| Flutter SDK baseline | [Flutter 3.44.1 API](https://api.flutter.dev/) and repository `flutter --version` evidence | available Material, Cupertino, `TextScaler`, `MediaQuery`, navigation, focus, and Semantics APIs | the declaration probe proves consumer shapes compile on the pinned SDK; it does not prove a runtime implementation |
| Flutter adaptive guidance | [Adaptive and responsive design](https://docs.flutter.dev/ui/adaptive-responsive) and [Cupertino widget catalog](https://docs.flutter.dev/ui/widgets/cupertino) | one semantic product with platform-natural controls and responsive composition | Core owns interactive platform selection; Business may compose only the documented layout primitives |
| Flutter text scaling | [`TextScaler`](https://api.flutter.dev/flutter/painting/TextScaler-class.html) | nonlinear system scaling | App `1.00/1.12/1.24` factors multiply the system-resolved result and never impose a total cap |
| Flutter accessibility | [Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility) | Semantics, contrast, text scaling, focus, and assistive-technology verification | automated semantics/layout prove deterministic contracts; one TalkBack/VoiceOver representative flow proves actual reader output; unexecuted Switch sampling stays P2 backlog |
| Material 3 | [Material Design 3](https://m3.material.io/) and [Flutter Material library](https://api.flutter.dev/flutter/material/material-library.html) | Android component structure, state, navigation, selection, feedback, and 48dp interaction baseline | Admin9 freezes the exact Android mapping in Platform Adaptation; selected treatment remains component-specific |
| Apple platform guidance | [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) and [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility) | iOS navigation, grouped lists, disclosure, switches, readable content, platform gestures, and 44pt interaction baseline | Admin9 uses Cupertino structures and preserves edge-back; platform behavior does not permit weaker contrast or semantics |
| Android system behavior | [Predictive back](https://docs.flutter.dev/release/breaking-changes/android-predictive-back) and [edge-to-edge](https://docs.flutter.dev/release/breaking-changes/default-systemuimode-edge-to-edge) | Android back integration and target-SDK system-bar behavior | application-state automation is separate from API 34+/36 system-gesture and edge-to-edge device evidence |
| WCAG 2.2 | [Contrast minimum](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) and [non-text contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html) | 4.5:1 ordinary text and 3:1 large text/critical non-text boundaries | frozen palette pairs are mathematically reproducible; composites and rendered/device output are later gates |
| Admin9 product baseline | [Experience baseline](../../product/admin9-app-experience-baseline.md) and [Phase 0C evidence](../../design/phase-0c/admin9-phase-0c-gate-1-review.md) | restrained productivity direction, information hierarchy, truthful backend-free states, and reference tasks | these are product decisions and calibration inputs, not claims that Material or Apple mandates the visual style |
| Admin9 static evidence | [Visual calibration](admin9-design-system-v1-visual-calibration.md) and generated boards | repeated candidate values, exact App `1.24`, platform structure, and static bounds annotations | design references are not App, simulator, device, Semantics, focus, or gesture evidence |

When official guidance and an Admin9 preference conflict, the fixed order is safety/accessibility, platform system behavior, business semantic consistency, Design System consistency, then Brand preference. SDK upgrades trigger the review in `DS-UPG-001`; changed external defaults never silently rewrite v1.0.

v1.0.2 does not claim WCAG conformance or full assistive-technology
certification. WCAG sources define measurable contrast targets used by the
system; Phase 6 evidence establishes only the documented minimum usable
representative-flow baseline. The [Phase 6 report](../../architecture/admin9-ui-phase-6-acceptance-report.md)
owns current Pass/Unknown/Backlog status.
