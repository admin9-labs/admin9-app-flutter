# Physical iPhone v1.0.2 human acceptance

Recorded: 2026-07-31

Reviewer: device owner, reporting contemporaneously in the active Codex task.
Evidence identifier: this timestamped transcript, ending with the explicit
attestation `全通过`. Source task ID:
`019faba2-dda7-77c1-8fbc-d19566adbabb`. The exact wall-clock time of each
observation was not captured and remains `Unknown`; the task sequence and date
are preserved. No screenshot, audio or video is claimed for these human
observations.

## Bound artifact and environment

- Device: Qiyue iPhone, iPhone 17 Pro Max
- Runtime: iOS 26.5.2 (23F84)
- UDID: `00008150-000268290C44401C`
- CoreDevice ID: `44C6E299-C645-56DD-8A6F-6E03EE2B631E`
- Bundle: `com.admin9.app.foundation`
- Signed Runner SHA-256:
  `89fc6f98e42089afa592e3f3ba0515fe2935e5744de83dbdd475372bf03db209`
- Installation URL:
  `file:///private/var/containers/Bundle/Application/BCEF21D2-ECFC-4AB5-B5C0-68317ABB5470/Runner.app/`
- Running process: PID `27173`, executable under the same installation URL
- Signature Team: `J25XZRW743`
- Raw install, launch and process records: `physical-iphone-v102-install.*`,
  `physical-iphone-v102-launch.*`, and
  `physical-iphone-v102-final-processes.*`

This is a human-observation record. Screenshots, Semantics tests and process
records support identity and deterministic behavior but are not substituted
for the VoiceOver, software-keyboard or system-gesture observations below.

## Representative VoiceOver flow

The approved composite flow combines the detailed observations made during the
same physical-iPhone session with the final post-fix selected-state retest:

| Step | Expected | Actual human observation |
| --- | --- | --- |
| Privacy gate | Title/body and legal/consent actions are discoverable; consent enters Home | VoiceOver exposed `Admin9`, the consent explanation, `用户协议` and `隐私政策` as buttons, then `同意并继续`; after the one-time transition fix the entry announcement was heard and Home became operable |
| Primary navigation | Home and Mine expose tab position and selected state | VoiceOver exposed `首页` as the first of two tabs and `我的` as the second of two; the active destination was announced selected |
| Mine identity/actions | Guest identity and valid actions are discoverable | VoiceOver exposed the guest identity/current no-session boundary plus Login, Register and Settings actions; no fabricated signed-in identity appeared |
| Settings choice | Theme row, current value, options and selected state are discoverable | VoiceOver exposed Theme and its current value; before the final fix it spoke only `浅色`, which was rejected. On the final signed rebuild the device owner confirmed the selected option announced its label, role and selected state |
| Settings switch | Label, switch role and current state are discoverable and operable | The representative switch exposed its label and `打开` state; activation remained operable and focus did not become trapped |
| Registration | Field names, password state, first error and Back are discoverable | VoiceOver exposed the `手机号或邮箱` edit field, password visibility control and Back. Empty submission announced/focused `请输入手机号或邮箱`; the user could return without losing the route |
| Truthful boundary | Valid local input never creates a fake session or success | The unavailable-service boundary remained the only post-validation result; no session or success tone was fabricated |

The final selected-state retest was performed after rebuilding, signing,
installing and launching Runner SHA-256
`89fc6f98e42089afa592e3f3ba0515fe2935e5744de83dbdd475372bf03db209`.

The device owner completed the agreed risk-tiered representative flow and
reported all five final checks as passing:

| Gate | Expected | Actual |
| --- | --- | --- |
| VoiceOver single choice | The selected option exposes its label, radio/button role and selected state | Pass after the explicit iOS `AppSingleChoiceList` Semantics fix and signed rebuild |
| VoiceOver off and representative flow | Privacy, primary navigation, one Settings item, Register first error and Back remain operable; VoiceOver can be turned off afterward | Pass; the detailed flow above completed and VoiceOver was then turned off |
| iOS edge-back cancel | On the Theme child page, a short left-edge drag preserves the page and selected value | Pass; the device owner remained on the child page with state retained |
| iOS edge-back complete | From the same Theme child-page scenario, a completed left-edge drag pops exactly one route to Settings | Pass; one route was removed and Settings remained operable |
| Extra Large and safe area | With App Extra Large on the Settings/registration representative endpoints, content can scroll to its final action without status-bar or home-indicator obstruction | Pass; the device owner reached the endpoint and primary action with no crop, overlap or blocked safe-area control |

The same session also established the real iOS software-keyboard sample:

- `Next` was announced by the real iOS keyboard and moved focus from account to
  the new-password field, then to confirmation.
- `Done` submitted the form. With the account field empty, validation correctly
  returned focus to the account field and announced its error instead of
  fabricating success. The page remained scrollable above the keyboard; no
  primary field or submit path became unreachable.
- With valid local input, the flow retained the truthful service-unavailable
  boundary; no session or backend result was invented.

Earlier in the session, password visibility retained focus and changed its
semantic label from `显示密码` to `隐藏密码`. Activation did not immediately
announce the new label; refocusing exposed it. This remains tracked P2 backlog
because the state is discoverable and the task remains completable.

## Claim boundary

This closes the iOS P0/P1 representative device gates for Phase 6. Together
with the automated Semantics, focus, responsive and business-truth contracts,
it establishes only Admin9's minimum usable accessibility baseline on a
representative iOS flow. It is not WCAG conformance, full accessibility
certification, or evidence for Switch Control, external keyboards, password
managers, every page, or every feedback variant.
