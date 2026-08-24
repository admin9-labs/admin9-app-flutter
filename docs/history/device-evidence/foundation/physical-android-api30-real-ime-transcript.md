# Xiaomi API 30 real IME transcript

> **Historical evidence:** This file preserves phase- and date-bound evidence.
> It is not a current Admin9 App Starter specification, compatibility promise,
> or rule for independent forks.

- Date: 2026-07-31 (Asia/Shanghai)
- Device: Xiaomi M2007J22C
- ADB serial: `r8ovcmxwberwtoau`
- OS: Android 11 / API 30
- Artifact: final Phase 6 release APK bound by
  `physical-android-api30-final-release-provenance.txt`
- Scope: one representative real-keyboard Next action and one Done/submit
  action. This is physical-device human evidence, not an automated IME claim.

## Observation

1. The Account field was focused with the installed Xiaomi keyboard visible.
   The keyboard exposed a blue `下一步` action.
2. The human tester activated `下一步` once and reported that the blue focus
   border moved from Account to `新密码`. Result: **Pass**.
3. The agent filled non-sensitive test values, and the human tester focused
   `确认新密码` and activated the keyboard Done action once.
4. The keyboard dismissed, all entered values remained, and the page displayed
   `服务尚未接入，当前操作不会提交或保存。` Result: **Pass**.

This closes the Android representative real-IME P1 gate: Next moves focus in
visual order, Done submits once, and the backend-free product boundary remains
truthful. It does not certify every installed IME, autofill/password managers,
external keyboards, or all forms; those remain tracked P2 sampling work under
Design System v1.0.2.

## Assets

| Asset | Meaning | SHA-256 |
| --- | --- | --- |
| `physical-android-api30-real-ime-next-ready.png` | Real keyboard with the blue Next action before the human activation | `a20447be132486c6065f431470e7bcbde387e3ddd9fb54c4cecfbaa551888ee9` |
| `physical-android-api30-real-ime-done-result.png` | Post-Done form with preserved values and the truthful service-unavailable notice | `87ae9443f594714d2435219013848bd2ba11e0e28daec7c90c236feec961db48` |
