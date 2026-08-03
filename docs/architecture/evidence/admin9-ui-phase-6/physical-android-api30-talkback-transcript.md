# Xiaomi API 30 TalkBack transcript

> **Historical evidence:** This file preserves phase- and date-bound evidence.
> It is not a current Admin9 App Starter specification, compatibility promise,
> or rule for independent forks.

Date: 2026-07-30

## Environment

- Device: Xiaomi M2007J22C
- Serial: `r8ovcmxwberwtoau`
- OS: Android 11 / API 30
- Accessibility service:
  `com.google.android.marvin.talkback/.TalkBackService`
- App: release `com.admin9.app.foundation`
- Human observer: device owner
- Evidence boundary: the quoted spoken output below was reported by the human
  observer. Screenshots and Android accessibility-node facts are supporting
  evidence; they are not substituted for spoken output.

## Confirmed observations

| Flow point | Human-reported spoken output | Supporting observation | Result |
| --- | --- | --- | --- |
| Home, Mine tab before activation | “我的，第 2 个标签，共 2 个，按钮” | Focus on the unselected Mine destination | Pass |
| Mine tab after activation | “我的，第 2 个标签，共 2 个，已选中” | Mine page visible and destination selected | Pass |
| Mine page traversal | “我的” | Focus returned from bottom navigation to page title | Pass |
| Guest identity summary | “游客身份，游客，当前没有用户会话” | One atomic identity-summary node | Pass |
| Login primary action | “登录，按钮” | Complete green focus bounds on Login | Pass |
| Register secondary action | “注册，按钮，点按两次即可激活” | Focus followed Login in visual order | Pass |
| Settings row in Mine list | “设置，按钮，第 4 个，共 5 个，点按两次即可激活” | Complete row focus bounds | Pass |
| Enter Settings | “设置，返回，按钮，你已离开列表” | Settings page visible; focus on Back | Pass |
| Back on Settings | “设置，返回，按钮，点按两次即可激活” | Back remained actionable | Pass |
| Theme row | “主题，浅色，点按两次即可激活” | Row exposed current value | Pass |
| Enter Theme choice | “主题，返回，按钮，你已离开按钮” | Theme choice page visible | Pass |
| Theme page title | “主题” | Title follows Back in traversal | Pass |
| System theme option | “未选中，跟随系统” | Android node is an unchecked `RadioButton` | Pass |
| Light theme option | “浅色，已选中，单项，点按两次可切换” | Android node is a checked `RadioButton` | Pass |
| Return to Settings | “主题，按钮，浅色” | Focus restored to Theme row with current value | Pass |
| Grayscale before activation | “未选中，灰度，开关” | Android node is an unchecked `Switch` | Pass |

## Separate representative input result

- The human real-IME Next/Done sample subsequently passed and is recorded in
  `physical-android-api30-real-ime-transcript.md`. Widget/integration tests own
  all other form-state and focus cases.
- Switch Access, remaining setting switches, Dialog/Notice/AppFeedback
  repetition, password-manager and external-keyboard sampling are P2 backlog.
  They are not claimed as passed and do not duplicate the representative
  TalkBack flow unless a real consumer or defect raises their risk.

The real-IME result is not inferred from this TalkBack transcript; it is bound
to its separate human transcript and screenshots.

## Current release clean-session observations

Artifact SHA-256:
`d6765958320a271272fe68437113e4db9e35537e348de884f3009d1f456f1326`

| Flow point | Human-reported spoken output | Supporting observation | Result |
| --- | --- | --- | --- |
| Privacy gate body | “Admin9 需要在您同意……” | Current release was hash-bound, cleared, cold-launched, and the privacy body held TalkBack focus | Pass |
| User agreement link | “用户协议，按钮，点按两次即可激活” | Focus moved once from the body to the first legal link | Pass |
| Privacy policy link | “隐私政策，按钮，点按两次即可激活……” | Focus moved once from User agreement to the second legal link | Pass |
| Accept privacy action | “同意并继续，按钮，点按两次即可激活” | Focus moved once from Privacy policy to the primary action | Pass |
| Activate privacy action | No spoken output after activation | Screenshot confirms the same-route subtree changed to Home; no TalkBack focus highlight was visible | P1 confirmed; fixed in source, device retest pending |
| Home title after first right swipe | “Admin9” | The first reachable Home node was the page title | Pass; supports the P1 diagnosis above |
| Home empty state | “暂无内容” | Empty-state content followed the title | Pass |
| Home destination | “已选中，首页，第 1 个标签，共 2 个，按钮……” | Selected Home destination followed page content | Pass |
| Mine destination before activation | “我的，第 2 个标签……” | Unselected Mine destination followed Home | Pass |
| Mine destination after activation | “我的，第 2 个标签，共 2 个，已选中” | Destination activated and selected state was spoken | Pass |
| Mine title and guest identity | “我的”, then “游客，身份游客，当前没有用户会话……” | Reading order restarted at title, then the atomic identity summary | Pass |
| Login and Register actions | “登录，按钮，第 2 个，共 5 个……”, then “注册，按钮，点按 2 次即可……” | Both guest actions were reachable and Register activated | Pass |
| Enter Register | “注册，返回，按钮，你已离开列表……”, then “注册” | Child-page Back preceded the title | Pass |
| Register field order | Account, new password, its visibility button, confirmation, its visibility button, submit | The observer confirmed each expected label/role in order | Pass |
| Password visibility activation | Only the TalkBack activation sound; no immediate state speech | Screenshot confirmed the icon changed and focus stayed on the button | P2 backlog; state remains discoverable |
| Password visibility after refocus | “隐藏密码，按钮” | Moving away and back exposed the changed semantic label | Pass for state/name/focus; no immediate-announcement claim |
| Empty Register submit | Account field and “请输入手机号或邮箱”, plus IME information | Focus moved to the first error and the error was spoken | Pass |

## Final privacy-announcement artifact retest

Artifact SHA-256:
`fc43800cd9cd0553ef3b708a0b646f37b520e980b9bdfaba43c618e837b134aa`

The release APK was rebuilt, installed, pulled back from the API 30 Xiaomi with
the same SHA-256, cleared and cold-launched while TalkBack remained enabled. The
observer focused `同意并继续`, activated it once, and reported the immediate
spoken output `已进入首页` without any exploratory swipe. Result: **Pass**.
The prior P1 silent transition is closed on the final Android artifact.

The Android UI hierarchy reader was invoked once after the first account-field
observation. On this Xiaomi build it restarted/interfered with the accessibility
session and reset focus to Back. Evidence after that point was restarted from
Back and confirmed again by the human observer; no continuity across the reset
is claimed. `uiautomator dump` is prohibited for the remainder of physical
screen-reader sessions. Ordinary screenshots may support visible facts only.

The silent privacy transition was classified P1 because a reader user could not
confirm that consent succeeded without an exploratory gesture. Source sends one
supported post-frame `已进入首页` announcement only for the
not-accepted to accepted transition, with automated positive, cold-launch
negative and final physical-artifact evidence. Password visibility is P2
because activation retains focus and the changed state is correctly exposed on
refocus; it remains backlog unless user evidence shows that this prevents task
completion.
