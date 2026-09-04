---
name: admin9-flutter-app
description: Use when initializing, implementing, reviewing, or extending an Admin9 Flutter Starter repository or derived App, including Forui UI, Riverpod state, AutoRoute routing, Feature/data boundaries, dependency adoption, and verification. Read product scope from the active repository; do not use for unrelated Flutter projects.
---

# Admin9 Flutter App

Use this Skill as an execution guide. It does not replace repository authority
or expand user authorization.

Keep this Skill reusable across the Starter and derived Apps. Product names,
Pages, routes, platform identifiers, Feature inventories, exclusions, and
acceptance snapshots belong to the active repository's authority and source,
not to this Skill.

## Read Authority First

Resolve the active Git root and read its current local authority before acting:

- [Repository Working Agreements](../../../AGENTS.md)
- `docs/architecture.md`, when present
- `docs/ui.md`, when present
- `docs/product.md`, when present
- `docs/starter.md`, when present and relevant to the task

Then inspect the current source, tests, `pubspec.yaml`, and `pubspec.lock`.
Repository-local authority and actual consumers take precedence over upstream
examples and historical evidence.

## Impeccable Coordination

This Skill may be combined with an installed `impeccable` Skill on the same UI
task. Establish the repository's technical, component, ownership, version, and
acceptance boundaries here first; then route general design review, visual
critique, copy clarity, and experience refinement to Impeccable within those
boundaries, including its `audit`, `critique`, `polish`, `clarify`, `harden`,
or `adapt` playbooks.

Impeccable must not introduce a second Theme, token, typography, icon, routing,
or state-management system, and it does not expand authorization for files,
dependencies, platform builds, simulators, physical devices, or releases. For
Flutter-native review, use its native source-review references rather than its
Web detector. Do not install or enable its optional automatic Hook unless both
the active repository and the user explicitly authorize it. When guidance
conflicts, the active repository and this Skill take precedence. Missing
Impeccable-specific root artifacts does not authorize creating or relocating
repository product or design authority.

## Execution Decision Tree

1. Resolve the actual Flutter and package versions from `pubspec.yaml` and
   `pubspec.lock`; do not infer them from this Skill.
2. Inventory the real consumer and public API axes before choosing a layer,
   dependency, generator, route, or component. Do not infer generic size,
   color, state, or variant controls that the API does not provide.
3. Follow the active repository's UI ownership rules. Use `F*` directly when it
   satisfies the requirement, create an `A*` API only for a stable observable
   Admin9 difference, and keep Feature-only UI with its Feature.
4. Keep shared UI limited to stable App-wide or Admin9 responsibilities with
   real consumers, documentation, tests, and the active Forui Theme contract.
5. Keep Feature UI and state with the owning Feature. Add Data or Domain layers
   only when a real source or business rule gives them a concrete responsibility.
6. Use generated typed AutoRoute routes where the repository has adopted
   AutoRoute. Route Pages may navigate; reusable leaf Widgets receive semantic
   callbacks. Never hand-edit generated source.
7. For routing, state, persistence, localization, dependencies, generators, and
   native work, use `docs/architecture.md` when present; otherwise follow the
   active repository's established boundaries. Do not duplicate product
   decisions here.
8. Check authorization separately for builds, simulators, signing,
   installation, physical devices, publishing, and release operations. Source
   implementation does not authorize those actions.

Do not create empty layers, placeholder APIs, mechanically renamed Forui
primitives, compatibility code for superseded implementations, or speculative
Features and dependencies.

## Version-Matched Forui Lookup

After resolving the Forui version, look for a matching
`references/<version>/llms.txt` snapshot. Prefer matching official documentation
when live version context is available. For offline or cross-page questions,
search narrow terms in `llms-full.txt` rather than loading it in full. Read the
matching `source.json` when provenance or capture constraints matter. If the
documentation and resolved package source disagree, inspect the package source
and report the mismatch instead of guessing.

## Verification Checklist

- Confirm resolved dependency versions and use only matching reference material.
- Verify affected ownership, public APIs, generated routes, translations,
  responsive layout, accessibility, and interaction behavior in proportion to
  the change.
- Run focused tests plus the current repository's source gates, Markdown link
  check, and `git diff --check`.
- On a clean checkout, run `dart run build_runner build`, then require
  `git diff --exit-code` and an empty
  `git status --porcelain --untracked-files=all` result.
- Treat Android/iOS builds, platform delivery, simulator behavior, signing,
  installation, and physical-device acceptance as `Unknown` unless that exact
  scope was authorized and executed against the current source.
