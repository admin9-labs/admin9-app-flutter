# Visual References

These generated Android/iOS boards are current design-review inputs. They are
not App, simulator, device, Golden, focus, gesture, animation, or reader output.
Production behavior remains authoritative in source and tests.

## Scenarios

| Scenario | Shared evidence |
| --- | --- |
| authentication | field order, validation, long errors, primary action, and unavailable-service state |
| account and navigation | page hierarchy, navigation selection, signed-in rows, empty/error meaning, and recovery |
| settings | section/list/switch hierarchy, selected values, effective-state explanation, and persistence recovery |
| dialog and feedback | command order, disabled/destructive/cancel meaning, loading, empty/error, feedback, and retry |

The boards use identical data, copy, states, and information hierarchy across
platforms. Explicit platform annotations describe system-owned behavior such as
keyboard, back gesture, safe area, and accessibility delivery. Pixel equality
is not required; business meaning and visible Admin9 structure are.

Generated outputs are under `evidence/visual-references/`; source and checks are
under `evidence/sources/`. The manifest records dimensions, required labels,
hashes, and the explicitly allowed platform annotations.

```bash
node --check docs/design-system/evidence/sources/generate_visual_references.mjs
node --check docs/design-system/evidence/sources/verify_visual_references.mjs
node docs/design-system/evidence/sources/verify_visual_references.mjs \
  docs/design-system/evidence/visual-references
```

Changing generator source, an SVG/PNG, required state, or the manifest requires
regeneration, verification, visual crop/overlap review, and directly affected
production/Golden review. Static boards never upgrade an unexecuted device item
from `Unknown` or `Pending`.
