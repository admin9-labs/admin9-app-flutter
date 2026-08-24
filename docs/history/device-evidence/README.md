# Historical Device Evidence

This directory retains the minimum raw evidence needed to explain historical
delivery decisions and rejected claims. It is not current Admin9 App Starter
acceptance. Current source must be rebuilt and re-exercised before any device
result is claimed; see [Delivery](../../delivery/README.md).

## Retained Collections

| Collection | Original result | Boundary |
| --- | --- | --- |
| `simulator-smoke/` | Android and iOS each completed two fixed-source build/install/cold-launch/minimal-smoke rounds: `Pass` | bounded historical simulator result; not full interaction, physical device, reader, real IME, or brand approval |
| `ios-simulator/` | 13 iOS-only interactive observations were recorded | no equivalent Android interactive set; no dual-platform result inferred |
| `foundation/` | selected Foundation delivery, gesture, reader, IME, safe-area, and defect evidence | bound only to the source/artifacts named in each record; not current Starter evidence |

The retained Foundation set includes:

- [final candidate provenance](foundation/foundation-final-candidate-provenance.md)
  and its source manifest;
- [Android final install identity](foundation/physical-android-api30-v102-final-provenance.md),
  [TalkBack transcript](foundation/physical-android-api30-talkback-transcript.md),
  and [real IME transcript](foundation/physical-android-api30-real-ime-transcript.md);
- [iPhone delivery provenance](foundation/physical-iphone-v102-provenance.md)
  and [human acceptance transcript](foundation/physical-iphone-v102-human-acceptance.md),
  including the distinct install/launch/process records used by the fixed
  live-region and final selected-state checks;
- Android API 34/API 36 human-mouse predictive-back records and API 36
  edge-to-edge/cutout/IME records with their referenced media;
- the interrupted three-button smoke (`not a pass`), its later clean pass, and
  the post-fix light/dark system-bar evidence; and
- the Switch Access root-scan screenshot/XML retained as `Unknown`, not Pass.

## Removed Collections

The current tree no longer carries initial discovery screenshots, calibration
wireframes duplicated by current visual references, superseded gesture runs,
ordinary package/build/install logs, repeated intermediate device screenshots,
or the earlier non-hardened simulator-smoke archive. They had no runtime or CI
consumer and were replaced by current Goldens/generated references, the later
fixed-source evidence above, or an explicit historical status in
[History](../../HISTORY.md). Exact deleted bytes remain available in Git
history; no Tag was moved or recreated.

## Integrity

`SHA256SUMS` covers every retained file below this directory except the manifest
itself. Verify it from the repository root:

```bash
shasum -c docs/history/device-evidence/SHA256SUMS
```

When intentionally changing the retained set, regenerate the manifest from the
repository root and review every add/delete before committing:

```bash
find docs/history/device-evidence -type f ! -name SHA256SUMS -print0 \
  | sort -z \
  | xargs -0 shasum -a 256 \
  > docs/history/device-evidence/SHA256SUMS
```
