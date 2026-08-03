# Admin9 Design System v1.0 Normative Rule Register

This is the current rule index for implementations and contributions proposed
to the upstream Admin9 App Starter repository. It does not govern independent
forks.

Stable IDs are never reused. Each active ID links to exactly one explicit HTML anchor in the normative module. Upstream verification records MUST cite the ID, not only a heading or prose fragment. Run `dart run tool/design_system/verify_rule_links.dart` to check ID uniqueness, target files, anchors, and test-gate links.

| Rule | Layer/platform | Frozen default and override boundary | Machine/test association |
| --- | --- | --- | --- |
| [DS-GOV-001](../README.md#ds-gov-001) | Core/both | this directory is the only authority; change only by versioned DS review | rule-link verifier; acceptance report |
| [DS-CLR-001](../01-foundations.md#ds-clr-001) | Core+Brand/both | semantic palette; Brand only verified primary/secondary pairs | visual calibration contrast table; Golden/device later |
| [DS-TYP-001](../01-foundations.md#ds-typ-001) | Core/both | system font; App `1.00/1.12/1.24`; no total cap | visual generator; matrix E/F/J/K/L; device max text |
| [DS-SPC-001](../01-foundations.md#ds-spc-001) | Core+Brand/both | spacing scale and 6/8 radii; Brand radius +/-2 only | visual generator; responsive Widget rows A-L |
| [DS-MOT-001](../01-foundations.md#ds-mot-001) | Core/both | local motion tokens; platform route builders retained | Widget transition assertion; device gestures |
| [DS-TOK-001](../01-foundations.md#ds-tok-001) | Core/both | immutable semantic facade; no raw Material/Cupertino styles | declaration and future import-boundary probes |
| [DS-PLT-001](../02-platform-adaptation.md#ds-plt-001) | Core/both | unique Android/iOS mapping; no feature platform branch | target-platform Widget tests; device matrix |
| [DS-NAV-001](../02-platform-adaptation.md#ds-nav-001) | Core/both | one host, Shell owns tabs, default route builders | navigation integration; edge/predictive device gates |
| [DS-CMP-001](../03-components.md#ds-cmp-001) | Core/both | frozen controlled `App*` declarations and state ownership | `tool/design_system/design_system_contract_probe.dart` |
| [DS-INP-001](../03-components.md#ds-inp-001) | Core+Business/both | persistent labels, local errors, ordered focus/autofill | matrix A-L; IME/reader device gate |
| [DS-FBK-001](../03-components.md#ds-fbk-001) | Core/both | 3s/5s transient or action/accessibility persistent | lifecycle Widget matrix and reader walkthrough |
| [DS-CMP-002](../03-components.md#ds-cmp-002) | Core/both | `AppActionMenu<T>` is 2-6 commands, not selection | declaration probe; Gallery menu states; sheet device gate |
| [DS-CMP-003](../03-components.md#ds-cmp-003) | Core/both | labelled determinate/indeterminate progress | declaration probe; semantics/Golden/reduced-motion tests |
| [DS-PAT-001](../04-page-patterns.md#ds-pat-001) | Core+Business/both | page patterns, not templates, schemas, or DSL | reference flows, responsive fixtures, device tasks |
| [DS-SHR-001](../05-upstream-contribution-boundaries.md#ds-shr-001) | Business then Core/both | upstream feature -> `lib/ui/shared/` -> evidence-based Core proposal | upstream consumer inventory and Design System review |
| [DS-ACC-001](../06-accessibility-quality.md#ds-acc-001) | Core/Android | 48dp, WCAG 4.5/3, system text and assistive-tech semantics | automated geometry/semantics plus one TalkBack/system/IME P0/P1 representative flow; P2 backlog table |
| [DS-ACC-002](../06-accessibility-quality.md#ds-acc-002) | Core/iOS | 44pt, WCAG 4.5/3, Dynamic Type and assistive-tech semantics | automated geometry/semantics plus one VoiceOver/system/IME P0/P1 representative flow; P2 backlog table |
| [DS-RSP-001](../06-accessibility-quality.md#ds-rsp-001) | Core/both | canonical automated rows A-L | exact matrix coverage report; device actual-width record |
| [DS-GAL-001](../06-accessibility-quality.md#ds-gal-001) | Core/both | Gallery debug/profile only; release absent | AST route test, profile reachability, release build/device denial |
| [DS-UPG-001](../06-accessibility-quality.md#ds-upg-001) | upstream/both | SDK behavior and Design System gates must be revalidated | upstream upgrade checklist and tests |
