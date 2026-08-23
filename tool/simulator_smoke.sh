#!/bin/bash
set -u
set -o pipefail
ANDROID_AVD="Admin9_API_34"
IOS_UDID="C10E0968-4695-4C02-BC55-8C322531239A"
IOS_RUNTIME="com.apple.CoreSimulator.SimRuntime.iOS-26-5"
BUNDLE_ID="com.admin9.app.foundation"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$ROOT" ]] || {
  printf 'RESULT=Unknown\nfailure_call=git rev-parse --show-toplevel\n'
  exit 30
}
cd "$ROOT" || exit 30
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Library/Android/sdk}}"
ADB="$ANDROID_SDK_ROOT/platform-tools/adb"
EMULATOR="$ANDROID_SDK_ROOT/emulator/emulator"
FLUTTER="$(command -v flutter 2>/dev/null || true)"
FLUTTER_REAL="$(perl -MCwd=abs_path -e 'print abs_path(shift)' "$FLUTTER" 2>/dev/null || true)"
FLUTTER_ROOT="$(cd "$(dirname "$FLUTTER_REAL")/.." 2>/dev/null && pwd -P || true)"
SOURCE_SHA="$(git rev-parse HEAD)"
RESULT_FILE="/dev/null"
BLOCKS=0
UNKNOWNS=0
usage() {
  printf '%s\n' 'tool/simulator_smoke.sh preflight' \
    'tool/simulator_smoke.sh run [--rounds N] [--evidence-dir PATH]'
}
cmdline() {
  printf '%q ' "$@"
}
fail() {
  local category="$1" stage="$2" call="$3" log="$4" code=30
  [[ "$category" == "App Fail" ]] && code=10
  [[ "$category" == "Infrastructure Block" ]] && code=20
  {
    printf 'RESULT=%s\nstage=%s\nsource_sha=%s\n' "$category" "$stage" "$SOURCE_SHA"
    printf 'failure_call=%s\nfailure_log=%s\n' "$call" "$log"
  } | tee "$RESULT_FILE"
  exit "$code"
}
step() {
  local category="$1" stage="$2" log="$3" status call
  shift 3
  call="$(cmdline "$@")"
  {
    printf '$ %s\n' "$call"
    "$@"
  } 2>&1 | tee "$log"
  status="${PIPESTATUS[0]}"
  [[ "$status" -eq 0 ]] || fail "$category" "$stage" "$call" "$log"
}
pass() { printf 'PASS %-28s %s\n' "$1" "$2"; }
block() {
  BLOCKS=$((BLOCKS + 1))
  printf 'INFRASTRUCTURE_BLOCK %-12s %s\n' "$1" "$2"
}
unknown() {
  UNKNOWNS=$((UNKNOWNS + 1))
  printf 'UNKNOWN %-25s %s\n' "$1" "$2"
}
probe_write() {
  local target="$1" parent probe
  parent="$target"
  [[ -d "$parent" ]] || parent="$(dirname "$parent")"
  probe="$parent/.admin9-simulator-smoke-probe.$$"
  if [[ -d "$parent" ]] && (umask 077 && : >"$probe") 2>/dev/null; then
    rm -f "$probe"
    pass cache_write "$parent"
  else
    rm -f "$probe" 2>/dev/null || true
    block cache_write "cannot write $parent"
  fi
}
android_serial() {
  local serial state ignored name
  while read -r serial state ignored; do
    [[ "$serial" == emulator-* && "$state" == device ]] || continue
    name="$($ADB -s "$serial" shell getprop ro.boot.qemu.avd_name 2>/dev/null | tr -d '\r')"
    [[ "$name" == "$ANDROID_AVD" ]] && {
      printf '%s\n' "$serial"
      return 0
    }
  done < <("$ADB" devices -l 2>/dev/null | tail -n +2)
  return 1
}
preflight() {
  local output value ios_line runtime serial
  BLOCKS=0
  UNKNOWNS=0
  printf 'source_sha=%s\ntask_identity=uid:%s user:%s\n' \
    "$SOURCE_SHA" "$(id -u)" "$(id -un)"
  git diff --quiet && git diff --cached --quiet &&
    pass git_tracked_tree "clean" || unknown git_tracked_tree "changes are not represented by HEAD"
  for feature in hw.optional.neon hw.optional.arm.FEAT_AES; do
    value="$(/usr/sbin/sysctl -n "$feature" 2>&1)"
    [[ "$?" -eq 0 && "$value" == 1 ]] && pass "$feature" "$value" ||
      block "$feature" "call: /usr/sbin/sysctl -n $feature; output: $value"
  done
  output="$([[ -x "$ADB" ]] && "$ADB" devices -l 2>&1)"
  [[ $? -eq 0 ]] && lsof -nP -iTCP:5037 -sTCP:LISTEN >/dev/null 2>&1 &&
    pass adb_5037 "$ADB; devices query and listener passed" ||
    block adb_5037 "call: $ADB devices -l; output: $output"
  output="$([[ -x "$EMULATOR" ]] && "$EMULATOR" -list-avds 2>&1)"
  grep -Fxq "$ANDROID_AVD" <<<"$output" &&
    pass android_avd "$ANDROID_AVD; $("$EMULATOR" -version 2>&1 | sed -n '1p')" ||
    block android_avd "call: $EMULATOR -list-avds; missing $ANDROID_AVD"
  grep -Fqx 'image.sysdir.1=system-images/android-34/google_apis/arm64-v8a/' \
    "$HOME/.android/avd/$ANDROID_AVD.avd/config.ini" 2>/dev/null &&
    pass android_image "Google APIs arm64 API 34" ||
    block android_image "unexpected original AVD config"
  output="$(xcrun simctl list devices available 2>&1)"
  ios_line="$(grep -F "$IOS_UDID" <<<"$output" || true)"
  [[ -n "$ios_line" ]] && pass core_simulator "$ios_line" ||
    block core_simulator "call: xcrun simctl list devices available; output: $output"
  runtime="$(plutil -extract runtime raw \
    "$HOME/Library/Developer/CoreSimulator/Devices/$IOS_UDID/device.plist" 2>&1)"
  [[ "$runtime" == "$IOS_RUNTIME" ]] && pass ios_runtime "$runtime" ||
    block ios_runtime "expected $IOS_RUNTIME; output: $runtime"
  [[ -x "$FLUTTER" ]] && pass flutter "$FLUTTER" || block flutter "not executable"
  output="$(xcodebuild -version 2>&1)"
  [[ $? -eq 0 ]] && pass xcode "$(tr '\n' ' ' <<<"$output")" ||
    block xcode "call: xcodebuild -version; output: $output"
  for cache in "$FLUTTER_ROOT/bin/cache" "$HOME/.pub-cache" "$HOME/.gradle" \
    "$HOME/Library/Developer/Xcode/DerivedData" "$HOME/Library/Developer/CoreSimulator" "$ROOT/build"; do
    probe_write "$cache"
  done

  serial="$(android_serial || true)"
  [[ -n "$serial" ]] && pass android_target "$ANDROID_AVD booted as $serial" ||
    pass android_target "$ANDROID_AVD shutdown"
  [[ -n "$ios_line" ]] && pass ios_target "$ios_line"
  [[ "$BLOCKS" -eq 0 ]] || {
    printf 'RESULT=Infrastructure Block\n'
    return 20
  }
  [[ "$UNKNOWNS" -eq 0 ]] || {
    printf 'RESULT=Unknown\n'
    return 30
  }
  printf 'RESULT=Pass\n'
}
start_devices() {
  local session_dir="$1" serial boot
  serial="$(android_serial || true)"
  if [[ -z "$serial" ]]; then
    printf '$ %s\n' "$(cmdline "$EMULATOR" -avd "$ANDROID_AVD" -no-snapshot-load -no-boot-anim -gpu host)" \
      >"$session_dir/android-emulator.log"
    "$EMULATOR" -avd "$ANDROID_AVD" -no-snapshot-load -no-boot-anim -gpu host \
      >>"$session_dir/android-emulator.log" 2>&1 &
    for _ in $(seq 1 180); do
      serial="$(android_serial || true)"
      boot=""
      [[ -n "$serial" ]] && boot="$($ADB -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
      [[ "$boot" == 1 ]] && break
      sleep 1
    done
  fi
  [[ -n "$serial" && "${boot:-1}" == 1 ]] || fail "Infrastructure Block" android_boot \
    "$(cmdline "$EMULATOR" -avd "$ANDROID_AVD" -no-snapshot-load -no-boot-anim -gpu host)" \
    "$session_dir/android-emulator.log"
  if ! xcrun simctl list devices booted | grep -Fq "$IOS_UDID"; then
    step "Infrastructure Block" ios_boot "$session_dir/ios-boot.log" xcrun simctl boot "$IOS_UDID"
  fi
  step "Infrastructure Block" ios_bootstatus "$session_dir/ios-bootstatus.log" \
    xcrun simctl bootstatus "$IOS_UDID" -b
  printf '%s\n' "$serial" >"$session_dir/android-serial.txt"
}
run_round() {
  local round="$1" serial="$2" dir="$3" apk ios_app installed_app pid
  apk="$ROOT/build/app/outputs/flutter-apk/app-release.apk"
  ios_app="$ROOT/build/ios/iphonesimulator/Runner.app"
  mkdir -p "$dir"
  RESULT_FILE="$dir/result.txt"
  [[ "$(git rev-parse HEAD)" == "$SOURCE_SHA" ]] && git diff --quiet && git diff --cached --quiet ||
    fail Unknown source_provenance "git rev-parse HEAD; git diff --quiet" "$dir/result.txt"
  step "Infrastructure Block" pub_get "$dir/pub-get.log" "$FLUTTER" pub get
  step "App Fail" android_build "$dir/android-build.log" "$FLUTTER" build apk --release
  step "App Fail" ios_build "$dir/ios-build.log" "$FLUTTER" build ios --simulator --debug
  [[ -f "$apk" && -d "$ios_app" ]] || fail "App Fail" artifacts \
    "test -f $apk; test -d $ios_app" "$dir/build-sha256.txt"
  step "Infrastructure Block" android_install "$dir/android-install.log" "$ADB" -s "$serial" install -r "$apk"
  step "Infrastructure Block" ios_install "$dir/ios-install.log" xcrun simctl install "$IOS_UDID" "$ios_app"
  step "App Fail" android_cold_launch "$dir/android-launch.log" "$ADB" -s "$serial" shell \
    am start -W -S -n "$BUNDLE_ID/.MainActivity"
  sleep 3
  pid="$($ADB -s "$serial" shell pidof "$BUNDLE_ID" 2>/dev/null | tr -d '\r')"
  [[ -n "$pid" ]] || fail "App Fail" android_process \
    "$(cmdline "$ADB" -s "$serial" shell pidof "$BUNDLE_ID")" "$dir/android-launch.log"
  xcrun simctl terminate "$IOS_UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  step "App Fail" ios_cold_launch "$dir/ios-launch.log" xcrun simctl launch \
    --terminate-running-process "$IOS_UDID" "$BUNDLE_ID"
  sleep 3
  printf '$ %s\n' "$(cmdline "$ADB" -s "$serial" exec-out screencap -p)" >"$dir/android-screenshot.log"
  "$ADB" -s "$serial" exec-out screencap -p >"$dir/android-cold-launch.png" 2>>"$dir/android-screenshot.log" ||
    fail "Infrastructure Block" android_screenshot \
      "$(cmdline "$ADB" -s "$serial" exec-out screencap -p)" "$dir/android-screenshot.log"
  printf '$ %s\n' "$(cmdline xcrun simctl io "$IOS_UDID" screenshot "$dir/ios-cold-launch.png")" >"$dir/ios-screenshot.log"
  xcrun simctl io "$IOS_UDID" screenshot "$dir/ios-cold-launch.png" >>"$dir/ios-screenshot.log" 2>&1 ||
    fail "Infrastructure Block" ios_screenshot \
      "$(cmdline xcrun simctl io "$IOS_UDID" screenshot "$dir/ios-cold-launch.png")" "$dir/ios-screenshot.log"
  "$ADB" -s "$serial" logcat -d --pid="$pid" -t 300 >"$dir/android-app.log" 2>&1 || true
  xcrun simctl spawn "$IOS_UDID" log show --style compact --last 2m \
    --predicate 'process == "Runner"' >"$dir/ios-app.log" 2>&1 || true
  installed_app="$(xcrun simctl get_app_container "$IOS_UDID" "$BUNDLE_ID" app 2>/dev/null || true)"
  {
    printf 'round=%s\nsource_sha=%s\n' "$round" "$SOURCE_SHA"
    "$ADB" -s "$serial" shell getprop ro.boot.qemu.avd_name
    "$ADB" -s "$serial" shell getprop ro.build.version.sdk
    "$ADB" -s "$serial" shell settings get secure navigation_mode
    "$ADB" -s "$serial" shell wm size
    printf 'android_package='
    "$ADB" -s "$serial" shell pm path "$BUNDLE_ID"
    "$ADB" -s "$serial" shell dumpsys package "$BUNDLE_ID" | sed -n -E '/versionCode=|versionName=/p'
    for variable in SIMULATOR_DEVICE_NAME SIMULATOR_RUNTIME_VERSION SIMULATOR_MODEL_IDENTIFIER \
      SIMULATOR_MAINSCREEN_SCALE SIMULATOR_MAINSCREEN_WIDTH SIMULATOR_MAINSCREEN_HEIGHT; do
      printf '%s=' "$variable"
      xcrun simctl getenv "$IOS_UDID" "$variable"
    done
    printf 'ios_installed_app=%s\n' "$installed_app"
    printf 'ios_bundle='
    /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$installed_app/Info.plist"
    shasum -a 256 "$apk" "$ios_app/Runner" "$ios_app/Frameworks/App.framework/App" \
      "$installed_app/Runner" "$installed_app/Frameworks/App.framework/App"
  } >"$dir/device-and-build.txt" 2>&1
  grep -q '^android_package=package:' "$dir/device-and-build.txt" &&
    grep -Fqx "ios_bundle=$BUNDLE_ID" "$dir/device-and-build.txt" || fail "Infrastructure Block" install_identity \
    "pm path; simctl get_app_container" "$dir/device-and-build.txt"
  step "App Fail" android_smoke "$dir/android-smoke.log" "$FLUTTER" test \
    integration_test/simulator_smoke_test.dart -d "$serial" -r expanded
  step "App Fail" ios_smoke "$dir/ios-smoke.log" "$FLUTTER" test \
    integration_test/simulator_smoke_test.dart -d "$IOS_UDID" -r expanded
  shasum -a 256 "$dir"/*.png "$dir"/*-smoke.log >"$dir/evidence-sha256.txt"
  printf 'RESULT=Pass\nround=%s\nsource_sha=%s\ncompleted_at=%s\n' \
    "$round" "$SOURCE_SHA" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" | tee "$RESULT_FILE"
}
run_all() {
  local rounds="$1" evidence="$2" session lock status serial round
  session="$evidence/$SOURCE_SHA"
  lock="${TMPDIR:-/tmp}/admin9-simulator-smoke-$UID.lock"
  mkdir -p "$session"
  RESULT_FILE="$session/result.txt"
  mkdir "$lock" 2>/dev/null || fail "Infrastructure Block" lock "mkdir $lock" "$RESULT_FILE"
  trap "rmdir '$lock' 2>/dev/null || true" EXIT INT TERM
  preflight 2>&1 | tee "$session/preflight.log"
  status="${PIPESTATUS[0]}"
  [[ "$status" -eq 0 ]] || {
    [[ "$status" -eq 20 ]] && fail "Infrastructure Block" preflight "tool/simulator_smoke.sh preflight" "$session/preflight.log"
    fail Unknown preflight "tool/simulator_smoke.sh preflight" "$session/preflight.log"
  }
  start_devices "$session"
  serial="$(cat "$session/android-serial.txt")"
  for round in $(seq 1 "$rounds"); do run_round "$round" "$serial" "$session/round-$round"; done
  printf 'RESULT=Pass\nsource_sha=%s\nrounds=%s\nevidence=%s\n' \
    "$SOURCE_SHA" "$rounds" "$session" | tee "$RESULT_FILE"
}

case "${1:-}" in
  preflight) preflight ;;
  run)
    shift
    rounds=1
    evidence="$ROOT/build/simulator-smoke"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --rounds)
          rounds="${2:-}"
          shift 2
          ;;
        --evidence-dir)
          evidence="${2:-}"
          shift 2
          ;;
        *)
          usage
          exit 30
          ;;
      esac
    done
    [[ "$rounds" =~ ^[1-9][0-9]*$ ]] || {
      printf 'RESULT=Unknown\nfailure_call=invalid --rounds\n'
      exit 30
    }
    [[ "$evidence" == /* ]] || evidence="$ROOT/$evidence"
    run_all "$rounds" "$evidence"
    ;;
  *)
    usage
    exit 30
    ;;
esac
