# Admin9 Phase 6 manual device acceptance checklist

Status: Complete - Phase 6 representative P0/P1 gates pass

Date: 2026-07-31

This checklist applies risk-tiered Phase 6 acceptance. Automated tests and code
review own component states, focus requests, Semantics, validation, responsive
layouts, tokens, platform mapping and business boundaries. Human review owns
only facts those mechanisms cannot prove: actual reader output, system gestures,
real IME behavior, safe areas and release installation/cold launch. One
representative flow per capability and platform is sufficient; pages do not
repeat equivalent controls.

P0/P1 items below are release blockers. P2/P3 samples remain named backlog and
are not claimed as passed, but do not block this Foundation until a real business
consumer, observed failure or user report raises their severity. ADB and
screenshots may support visible facts but do not replace the named human
observation. `uiautomator dump` is prohibited during physical reader sessions
because it interfered with Xiaomi TalkBack.

For every session record the reviewer, date/time, device model, OS/API, App
artifact SHA-256, navigation mode, system text/accessibility settings, expected
result, actual result, and a timestamped human transcript, screenshot or
recording name. A contemporaneous device-owner transcript is valid for spoken
output and gesture outcome when it identifies the device, artifact, scenario,
expected result and actual result; it MUST NOT be rewritten as media evidence.
Mark an unavailable or unobserved item `Unknown`; never infer `Pass`.

## Android representative physical pass (P0/P1)

Status: **Pass** on Xiaomi API 30 through an explicit composite evidence chain,
not a claim that every observation ran continuously on one artifact. The
representative TalkBack traversal is bound to `d676595...`; the privacy P1
announcement retest and install/pull hash are bound to
`fc43800cd9cd0553ef3b708a0b646f37b520e980b9bdfaba43c618e837b134aa`;
the real-IME result has its own transcript and screenshots. Reader-sensitive
source deltas are additive and covered by focused plus full-suite Semantics and
focus regressions before the final release artifact is build/install bound.
No machine result is described as spoken output. Item 6 is closed by the
approved API 36 emulator lane; Android 14+ physical hardware remains separately
Unknown.

Required device: the available reviewed physical Android target. Android 14+
hardware remains separately `Unknown` when unavailable; API-specific system
behavior uses the required API 34/API 36 emulator lane.

1. Install the reviewed release APK and record its SHA-256 against the local
   artifact. Cold launch from a cleared App state and accept the privacy gate.
2. Complete Home -> Mine -> Settings. Exercise one single-choice row, one
   switch, and App font; force-stop/cold-launch and confirm persistence.
3. Smoke Light, Dark and one large-text setting. Confirm the representative
   page endpoints, bars and primary actions are not cropped or obscured.
4. **Pass, 2026-07-31.** With the real Xiaomi keyboard, Account -> Next moved
   focus to New password, and Done/submit dismissed the keyboard while retaining
   input and showing only the truthful unavailable-service boundary. Evidence:
   `physical-android-api30-real-ime-transcript.md` and its two indexed PNGs.
5. Run one continuous TalkBack representative flow: privacy gate -> Home/Mine
   navigation -> one Settings choice and switch -> Register first error,
   password visibility state and Back. Actual name, role, state, value and
   reading order must permit completion. Equivalent Dialog, Notice and feedback
   states remain automation-owned unless this pass exposes a mismatch.
6. Inspect one gesture-navigation and one three-button representative page for
   safe areas, system-bar contrast, bottom navigation and IME resizing. Restore
   temporary system/App values and record them.

P2 backlog: Switch Access repetition, password-manager save prompts, external
keyboard traversal, every-page 200% repetition, every Dialog/Notice state and
actionable-feedback replacement under TalkBack. They become blockers only when
an observed defect or adopted business flow raises them to P0/P1.

## Android predictive back

Status: **Pass** on `Admin9_API_34` and `Admin9_API_36` using genuine macOS
mouse drags in the native Emulator windows. See
`android-api34-predictive-back-human-mouse.md` and
`android-api36-predictive-back-human-mouse.md`. System-input prechecks and
rejected low-frame-rate recordings are not used as substitutes.

Required targets: API 34 and API 36 gesture-navigation emulator or device.

For each API, open a child page containing route-local state and make one
continuous screen recording that shows:

1. gesture start from the system edge;
2. visible predictive progress while the finger remains down;
3. cancellation by reversing before release, leaving the same page and state;
4. a second gesture completed through release, returning exactly one route;
5. the destination Tab and state remain correct with no duplicate pop.

The record must name the AVD/device, API, build, navigation mode, recording
file, reviewer, and actual result for all five observations. Ordinary Back,
`Navigator.pop`, `handlePopRoute`, and integration-test application state are
not substitutes.

## Physical iPhone representative pass (P0/P1)

Required device: current available iPhone with the reviewed signed release.

Status: **Pass** on Qiyue iPhone, iPhone 17 Pro Max, iOS 26.5.2. The
signed artifact, process binding and human observations are recorded in
`phase6-final-candidate-provenance.md` and
`physical-iphone-v102-human-acceptance.md`.

1. **Pass.** Current-candidate executable provenance, strict
   signature verification, install, unlocked cold launch and process-path
   binding are recorded in `phase6-final-candidate-provenance.md`.
2. **Pass.** One VoiceOver representative flow covered privacy, primary
   navigation, a Settings single choice/switch, Register first error, password
   state and Back. The post-fix single choice announced selected state.
3. **Pass.** The real iOS keyboard `Next` advanced focus and `Done` submitted;
   an empty account correctly returned focus to the first invalid field and
   valid local input retained the truthful unavailable-service result.
4. **Pass.** Human left-edge gestures covered cancellation with state retained
   and completion with one route popped.
5. **Pass.** App Extra Large content and the representative safe-area endpoint
   retained reachable primary actions; temporary VoiceOver use was ended.

P2 backlog: Switch Control repetition, password-manager and external-keyboard
sampling, every-page Bold Text/Increase Contrast/Reduce Motion repetition, and
all Dialog/Notice/AppFeedback variants under VoiceOver.

## Exit record

Phase 6 can be `Go` when every P0/P1 row above is `Pass`, each human-only claim
has the specified evidence, the automated suite is rerun against the same
accepted source tree, independent Android/iOS/accessibility reviews have no
open P0/P1, and every P2/P3 remainder has an owner and trigger in backlog. A
backlog item is never relabeled `Pass` merely because it is non-blocking.

Exit result: **Go.** Every representative P0/P1 row is `Pass`. Android 14+
physical hardware remains a separately named non-blocking `Unknown`; the P2/P3
items above remain owned backlog. The accepted claim is a minimum usable
accessibility baseline on representative Android/iOS flows, not WCAG or full
assistive-technology certification.
