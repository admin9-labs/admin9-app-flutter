# Forui 0.27.3 Upgrade Evidence

The Starter resolves Forui 0.27.3 and Forui CLI 0.27.0 in its committed lockfile.
Flutter 3.47.2 / Dart 3.13.2 remain unchanged. admin9_ui declares ^0.27.3.

The checked-in documentation snapshot remains the historically captured 0.26.0
snapshot. Its source provenance is not relabeled. The catalogue continues to
reference 72 documentation capabilities; this does not assert a newly captured
or exhaustive 0.27.3 documentation catalogue.

The installed 0.26.0 and 0.27.3 public `lib/forui.dart` export files are identical
(SHA-256 `c9ed8142efd587268b9c15b2c1c09d66b40e9ad23298a5b84273c6ce7789cd2f`). This verifies exported library
paths, not API or behavioral equivalence within them. No exported carousel or
action-grid capability was found; the Admin9 components fill those gaps.

The 0.27.3 package changelog was reviewed. 0.27 introduces focus-highlight
corrections, portal geometry/arrow APIs, tooltip changes, keyboard/semantics
improvements and form fixes. 0.27.2 corrects bottom-navigation safe-area padding;
0.27.3 changes accessible-navigation Toast dismissal. Source analysis and the
existing themed/form/navigation/feedback Widget suite must validate the upgrade.
The selection-control example removes redundant accessible names now merged
from visible labels, preventing duplicate announcements. Its tests assert the
complete name, unchecked state and disabled state. The new package tests
validate its own public contracts independently.

Do not infer native rendering, device gestures or production acceptance from
these source checks. This task excludes native builds and device/simulator smoke.
The task record binds source verification to the reviewed candidate. Required
checks include locked App dependency resolution, formatting, App/package
analysis, App/package tests, Markdown links and patch whitespace. Package CI
checks both minimum and latest compatible dependencies. Generated contracts
must also pass the clean-checkout generation-drift gate before contribution.
