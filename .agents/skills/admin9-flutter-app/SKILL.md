---
name: admin9-flutter-app
description: Use when initializing, implementing, reviewing, or extending this repository or a derived Flutter App, including Forui UI and CLI work, Riverpod state, AutoRoute routing, Feature/data boundaries, dependency adoption, and verification. Do not use for unrelated generic Flutter projects.
---

# Admin9 Flutter App

Use this Skill as the execution guide for this repository and projects derived
from it. It does not replace repository authority or expand user authorization.

## Read Repository Authority First

Resolve the active Git root and read its local authorities before changing code:

- [Repository Working Agreements](../../../AGENTS.md)
- [Application Architecture](../../../docs/architecture.md)
- [UI System](../../../docs/ui.md)

The active repository documents override this Skill. A derived project may have
changed product scope, dependencies, identities, or validation rules; never
assume the upstream Starter remains current there.

## Route The Task

- **Forui UI, theme, component, style, snippet, or CLI work:** read the relevant
  UI rules, then use the version-matched Forui lookup below.
- **Feature, Riverpod, Repository, Service, Model, Domain, or shared code:** read
  the corresponding architecture sections and create only responsibilities with
  an approved consumer.
- **Page, AutoRoute, Guard, nested Tab Router, or deep-link work:** follow the
  routing architecture, require an approved consumer or Starter example for each
  optional routing capability, and keep navigation out of Riverpod Notifiers and
  data or Domain code.
- **New dependency or generator:** check whether it is a frozen baseline or a
  candidate. A candidate entry is advice, not implementation authority; require
  its trigger, an approved Feature, and fresh compatibility, maintenance,
  licensing, and platform review.
- **Validation, build, simulator, signing, installation, or device work:** follow
  the repository authorization boundary. Builds and device actions are not
  implied by ordinary source implementation.

Keep edits scoped to the request. Do not create empty layers, placeholder APIs,
parallel Forui primitives, speculative Features, or compatibility code for
superseded implementations.

When a task affects the upstream repository's bundled example, also read
[Upstream Starter](../../../docs/starter.md). Do not project that example's
Features, routes, platform scope, or acceptance matrix onto a derived project.
For a derived project, its repository-local authority and Starter reference
document take precedence.

## Use The Selected Stack At Its Boundary

- Forui owns visible product UI, theme, and base components. Compose `F*`
  widgets directly; add App-owned UI only for a stable pattern, business meaning,
  or confirmed Forui gap.
- Riverpod owns presentation state and dependency wiring. Keep feature providers
  with their Feature; keep Widget-local input, focus, scrolling, and animation
  state in the Widget.
- AutoRoute owns typed routes, nested navigation, Guards, and deep-link route
  construction. Use generated Route objects and never hand-edit generated router
  files. Typed route generation is baseline; nested Tab Routers, Guards,
  Observers, and deep links still require a consumer.
- EasyLocalization owns App copy. `FLocalizations.delegate` owns Forui component
  copy and is appended exactly once to the App localization delegates.
- Services and Repositories own external and persistence boundaries. Models,
  Preferences, Services, Repositories, and Domain code remain independent of UI,
  Riverpod, AutoRoute, and `BuildContext`.

These bullets orient work; the repository documents contain the complete and
current rules.

For AutoRoute work, use `auto_route: ^11.1.0`,
`auto_route_generator: ^10.6.0`, and `build_runner: ^2.16.0`. Follow the
repository's adaptive RouteType, import boundary, navigation-state terminology,
and generation-drift gate; do not carry forward the old direct
`analyzer: 10.1.0` constraint.

## Match The Version First

1. Read `pubspec.yaml` and `pubspec.lock` before relying on a snapshot.
2. If Forui is not resolved yet, use the target baseline in `AGENTS.md` only as
   initialization intent and verify it after dependency resolution.
3. Use the reference directory matching the resolved Forui version. The current
   snapshot is `references/0.26.0/`.
4. Read [snapshot metadata](references/0.26.0/source.json) when provenance,
   freshness, Flutter/Dart constraints, or exact hashes matter.
5. If the resolved version differs, use official version-matched sources or add
   a new snapshot only with user authorization. Never overwrite an older
   versioned snapshot.

The Forui website is live and unversioned. This snapshot records the site while
0.26.0 was the current pub.dev release; its hashes bind the captured content,
not future website state.

## Look Up Documentation Progressively

1. Read [the compact index](references/0.26.0/llms.txt) to discover relevant
   page titles, terms, and official single-page URLs.
2. Prefer the relevant official single page for routine work when live access is
   available and its package version context still matches the project.
3. For offline work, cross-page questions, or suspected omissions, search
   `references/0.26.0/llms-full.txt` with `rg` and read only narrow ranges around
   matches.
4. Never load or print the entire `llms-full.txt` by default. Broaden the search
   only when narrower terms fail.

Useful lookup shapes:

```shell
rg -n -i "button|FButton" .agents/skills/admin9-flutter-app/references/0.26.0/llms.txt
rg -n -i "FButton|button style|button variant" .agents/skills/admin9-flutter-app/references/0.26.0/llms-full.txt
sed -n '<start>,<end>p' .agents/skills/admin9-flutter-app/references/0.26.0/llms-full.txt
```

Use exact widget, class, CLI command, or concept names where possible. When
documentation and package source disagree, inspect the resolved package source
and report the mismatch instead of guessing.

For implementation or review, cite the relevant official page or narrow snapshot
section for non-obvious Forui claims. When documentation and resolved package
source disagree, inspect the source and report the mismatch instead of guessing.

## Verify The Result

Run focused tests for changed behavior plus the applicable repository source
gates. Check generated output, local links, naming, dependency direction, and
`git diff --check`. UI acceptance uses only evidence from the new source.

On a clean CI checkout, regenerate AutoRoute output with
`dart run build_runner build`, then require both `git diff --exit-code` and an
empty status with
`test -z "$(git status --porcelain --untracked-files=all)"`.

Do not claim Android/iOS builds, deep-link delivery, simulator behavior,
signing, installation, or physical-device acceptance unless that exact scope was
authorized and executed.
