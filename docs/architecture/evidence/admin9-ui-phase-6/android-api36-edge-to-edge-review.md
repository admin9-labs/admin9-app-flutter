# Android API 36 edge-to-edge, cutout and IME record

- Date: 2026-07-31 (Asia/Shanghai)
- AVD: `Admin9_API_36`, Android 16 / API 36
- Serial: `emulator-5554`
- Display: 1080x2400 at 420dpi
- Cutout: centered circular cutout with top safe inset 136 physical pixels
- App artifact SHA-256:
  `fc43800cd9cd0553ef3b708a0b646f37b520e980b9bdfaba43c618e837b134aa`

## Result

**Pass** on the API 36 emulator for the representative Settings/AppBar and
Register/form pages in gesture and three-button navigation modes. Status-bar
content, page title/back, bottom navigation, form controls and primary action
remain outside mandatory system regions. Three-button navigation reserves a
126-pixel bottom inset. With the software IME visible, the form resizes and the
focused account field plus remaining fields and submit action remain reachable;
the navigation buttons stay outside App content. Light/dark three-button icon
contrast is already bound by the existing release captures.

## Assets

| Asset | Meaning |
| --- | --- |
| `android-api36-edge-to-edge-gesture-settings.png` | Gesture-mode Settings page with cutout, status bar and gesture region visible |
| `android-api36-edge-to-edge-gesture-insets.txt` | Raw focused-window and status/navigation/IME inset lines for gesture mode |
| `android-api36-edge-to-edge-threebutton-register.png` | Three-button Register page before IME |
| `android-api36-edge-to-edge-threebutton-insets.txt` | Raw overlay, navigation mode and inset lines for three-button mode |
| `android-api36-edge-to-edge-threebutton-ime.png` | Three-button Register page resized with software IME visible |
| `android-api36-edge-to-edge-threebutton-ime-insets.txt` | Raw visible-IME and system-bar inset lines |
| `android-api36-display-cutout.txt` | Raw display size, density and `DisplayCutout` geometry |

These are emulator system-boundary observations, not Android 14+ physical
hardware evidence. Physical current-version hardware remains a non-blocking
Unknown and is not inferred from these files.
