---
name: admin9-flutter-app
description: Use when initializing, implementing, reviewing, or extending this repository or a derived Flutter App, including Forui UI and CLI work, Riverpod state, AutoRoute routing, Feature/data boundaries, dependency adoption, and verification. Do not use for unrelated generic Flutter projects.
---

# Admin9 Flutter App

Use this Skill as an execution guide. It does not replace repository authority
or expand user authorization.

## Read Authority First

Resolve the active Git root and read its current local authority before acting:

- [Repository Working Agreements](../../../AGENTS.md)
- [Application Architecture](../../../docs/architecture.md)
- [UI System](../../../docs/ui.md)
- [Upstream Starter](../../../docs/starter.md) for bundled Showroom work

A derived project may replace upstream scope, identities, routes, or evidence;
its repository-local documents take precedence.

## Execution Decision Tree

1. Read `pubspec.yaml` and `pubspec.lock`. Match Forui work to the resolved
   version; the current checked-in snapshot is `references/0.26.0/`.
2. Inventory the real consumer and public API axes before choosing a layer,
   dependency, generator, route, or component. Do not infer generic size,
   color, state, or variant controls that the API does not provide.
3. For UI ownership, follow [UI Ownership](../../../docs/ui.md#ui-ownership-model):
   use `F*` directly when it satisfies the requirement, create an `A*` API only
   for a stable observable Admin9 difference, and keep Feature-only UI with its
   Feature.
4. For Examples work, follow the
   [Showroom contract](../../../docs/ui.md#showroom-playground-contract) and the
   [Starter registry](../../../docs/starter.md#current-playground-registry).
   Group related official capabilities into a coherent Playground; do not create
   one shallow route per capability or count an `F*` type occurrence as coverage.
5. Keep Playground preview, configuration, interaction feedback, and reset
   widgets inside Examples. Do not promote them to `shared/ui/` or build a
   generic dynamic component renderer.
6. For AGrid or another approved Admin9 API, verify a real consumer, documented
   difference, Forui Theme/style integration, accessibility and directionality,
   tests, and the dependency boundary. The current scope uses official `FTabs`
   and does not create `ATabs` or a tabs experiment.
7. For routing, state, persistence, localization, dependencies, generators, and
   native work, use the boundaries in [Architecture](../../../docs/architecture.md)
   rather than duplicating them here. Never hand-edit generated router source.
8. Check authorization separately for builds, simulators, signing,
   installation, and physical devices. Source implementation does not authorize
   those actions.

Do not create empty layers, placeholder APIs, mechanically renamed Forui
primitives, compatibility code for superseded implementations, or speculative
Features and dependencies.

## Version-Matched Forui Lookup

1. Read the compact index first: `references/0.26.0/llms.txt`.
2. Prefer the matching official single-page documentation when live access and
   version context are available.
3. For offline or cross-page questions, search narrow terms in
   `references/0.26.0/llms-full.txt`; do not load the full file by default.
4. Read [snapshot metadata](references/0.26.0/source.json) when provenance,
   capture time, constraints, or hashes matter.
5. If documentation and resolved package source disagree, inspect the package
   source and report the mismatch instead of guessing.

Useful commands:

```shell
rg -n -i "button|FButton" .agents/skills/admin9-flutter-app/references/0.26.0/llms.txt
rg -n -i "FButton|button style|button variant" .agents/skills/admin9-flutter-app/references/0.26.0/llms-full.txt
sed -n '<start>,<end>p' .agents/skills/admin9-flutter-app/references/0.26.0/llms-full.txt
```

## Verification Checklist

- Confirm the resolved Forui version and version-bound snapshot.
- For Showroom work, verify all 72 official capability IDs once, the many-to-one
  Playground registry, required axes, coverage modes, and focused evidence.
- For every `direct` claim, verify a realistic scenario, configuration-driven
  preview, observable interaction feedback, reset, Chinese UI text, responsive
  layout, accessibility, and focused tests.
- Verify every registered Playground Page, typed route, translation namespace,
  and test; reject orphan routes, old generated routes, and untracked pages.
- Verify `shared/ui/` does not depend on Examples, AutoRoute, App routing, or a
  business Feature, and that Playground-only UI remains Examples-owned.
- Run focused tests and the repository source gates, Markdown local-link check,
  and `git diff --check`.
- On a clean checkout, run `dart run build_runner build`, then require
  `git diff --exit-code` and an empty
  `git status --porcelain --untracked-files=all` result.
- Treat Android/iOS builds, platform delivery, simulator behavior, signing,
  installation, and physical-device acceptance as `Unknown` unless that exact
  scope was authorized and executed against the current source.

When removing Examples in a derived project, follow the
[removal contract](../../../docs/starter.md#examples-removal-contract) without
deleting independent Admin9 UI such as AGrid or the Settings Feature.
