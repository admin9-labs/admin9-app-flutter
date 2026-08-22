# Admin9 UI Unification Stage Gates

Status: G1 revised gate contract
Scope: Demo-first evaluation, implementation, and real-device handoff

The confirmed product principle is the authority for every gate:

> 统一品牌外观、统一业务体验、保留系统交互差异。

## Functional owners

| Responsibility | Owner | Required evidence |
| --- | --- | --- |
| Scope, implementation, and local remediation | Main implementation task | Fixed commit, diff, commands, and evidence manifest |
| Product and brand review | Independent product/UI reviewer | Go/Revise/Block with evidence locations |
| Architecture, dependency, and `App*` boundary | Independent Flutter architecture reviewer | Go/Revise/Block plus boundary results |
| Test, accessibility, state, and delivery risk | Independent QA/accessibility reviewer | Go/Revise/Block plus missing-runtime limits |
| Final brand direction and Android/iOS real-device experience | User/product approver | Explicit acceptance after using both device builds |

The implementation task may repair G1-G3 Revise findings without asking the
user. Only the user can approve final visual direction and real-device unity.

## Severity and release rules

### P0: blocks the current stage immediately

- violates the confirmed product principle or still reads as two products;
- changes business information, action order, state meaning, recovery, route
  tree, or feature-owned state to make a UI candidate fit;
- leaks a candidate Theme, Controller, Router, state model, enum, callback,
  style, context extension, or package type through `App*`;
- moves permissions, sharing, system pickers, keyboard/autofill, safe-area, or
  accessibility service ownership into a visible component implementation;
- breaks build, navigation/back, keyboard/autofill, focus recovery, safe area,
  or a critical accessibility path;
- has unknown/incompatible license or asset obligations, a blocking advisory,
  or cannot be removed without business-code changes.

### P1: must be zero before the next stage

- major brand hierarchy or component-family drift between platforms;
- missing required light/dark, large/long text, focus, disabled, loading,
  empty, error, destructive, or retry evidence;
- incorrect semantics, announcement content/count/timing, focus movement,
  contrast, dynamic text, hit region, or reduced-motion behavior;
- non-reproducible reference/Golden evidence, material performance regression,
  or an unowned upgrade/maintenance/exit obligation.

P2/P3 findings are recorded with an owner and follow-up stage. They cannot be
used to hide a P0/P1 or to claim broader runtime/device proof.

## Fixed-reference protocol

One comparison round has exactly one reference commit and one generated asset
manifest. The control, first-party candidate, and every package candidate use
the same data, copy, states, viewport matrix, commands, and acceptance rules.
Changing generator source, SVG, PNG, required labels, or manifest invalidates
the previous round; every comparison object reruns before a decision.

The existing non-Golden tests are an old-contract regression baseline. They
are never counted as brand-unity or Flutter Golden evidence.

## G1: decision and evidence baseline

Entry: confirmed principle and current real-device observation.

Exit requires:

1. decision baseline, ownership matrix, four paired scenarios, exact state
   coverage, and this gate contract in one fixed commit;
2. generated SVG/PNG assets, current manifest, required-state verification,
   normalized paired-structure verification, and manual crop/overlap review;
3. candidate boundary policy plus positive and exact negative fixtures;
4. accessibility announcement and capability/service ownership contracts;
5. static analysis, existing non-Golden regression, document/asset/boundary
   checks, and an explicit statement that Flutter Golden was not run if absent;
6. three independent reviews of the same commit with no open P0/P1 and all
   three returning Go.

## G2: bounded candidate POC and recommendation

Resource budget:

- comparison objects are the current control, one first-party candidate, one
  primary package candidate, and at most one backup package;
- the backup receives code only when the primary is eliminated or a named
  evidence gap cannot otherwise be resolved;
- POC code stays inside Design System adapters/components, a removable POC
  harness, focused tests, and evaluation evidence;
- no feature flow, business model, router, app state, Starter migration,
  release version, or production dependency adoption is part of the POC.

Entry requires G1 Go. Before package code, record exact version, transitive
dependencies, license/NOTICE/font/assets, source and release activity,
advisories, Flutter compatibility, native plugins, component coverage,
theming, accessibility, testability, performance plan, upgrade cost, and exit
cost. A blocking unknown eliminates the package.

Exit requires same-scenario evidence, the candidate-boundary gate, focused
Widget/Golden/performance evidence, and an actual removal drill: remove the
candidate dependency and adapter, make no business-code or route changes, then
pass analyze, existing non-Golden regression, and all boundary gates. The
recommendation must explain why first-party, third-party, or mixed has the
lowest total evidence-backed cost. Three independent reviewers must return Go.

## G3: Demo implementation and local delivery evidence

Entry requires G2 Go. Implement only the recommended route in the Demo.

Exit requires static analysis, focused and full non-Golden tests, controlled
Flutter Golden results for approved per-platform rendering, required viewport
and text-state coverage, local Android/iOS runnable build checks, screenshots
clearly labelled as simulator/local evidence, and no open P0/P1. Three
independent reviewers inspect one fixed commit and must return Go.

## Real-device handoff and stop condition

After G3 Go, prepare Android/iOS device packages and a shared checklist for
brand recognition, business flow/state/feedback, back/keyboard/autofill,
permissions/share/pickers, safe areas, TalkBack/VoiceOver, and recovery.

The unattended task stops here. Starter migration, versioning, release, push,
and publication remain blocked until the user explicitly accepts both real
devices as the same Admin9 product with natural platform interaction.
