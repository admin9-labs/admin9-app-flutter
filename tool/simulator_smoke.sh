#!/bin/bash

set -u
set -o pipefail

ANDROID_AVD="Admin9_API_34"
IOS_UDID="C10E0968-4695-4C02-BC55-8C322531239A"
IOS_RUNTIME="com.apple.CoreSimulator.SimRuntime.iOS-26-5"
BUNDLE_ID="com.admin9.app.foundation"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$ROOT" ]]; then
  printf 'RESULT=Unknown\nfailure_call=git rev-parse --show-toplevel\n'
  exit 30
fi
cd "$ROOT" || exit 30

ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Library/Android/sdk}}"
ADB="$ANDROID_SDK_ROOT/platform-tools/adb"
EMULATOR="$ANDROID_SDK_ROOT/emulator/emulator"
FLUTTER="$(command -v flutter 2>/dev/null || true)"
FLUTTER_REAL="$(perl -MCwd=abs_path -e 'print abs_path(shift)' "$FLUTTER" 2>/dev/null || true)"
FLUTTER_ROOT="$(cd "$(dirname "$FLUTTER_REAL")/.." 2>/dev/null && pwd -P || true)"
SOURCE_SHA="$(git rev-parse HEAD)"
SOURCE_TREE="$(git rev-parse HEAD^{tree})"
RESULT_FILE="/dev/null"
COMMANDS_LOG="/dev/null"
BLOCKS=0
UNKNOWNS=0

usage() {
  cat <<'EOF'
Usage:
  tool/simulator_smoke.sh preflight
  tool/simulator_smoke.sh run [--rounds N] [--evidence-dir PATH]
EOF
}

command_string() {
  printf '%q ' "$@"
}

fail() {
  local category="$1" stage="$2" invocation="$3" log_path="$4" code=30
  [[ "$category" == "App Fail" ]] && code=10
  [[ "$category" == "Infrastructure Block" ]] && code=20
  {
    printf 'RESULT=%s\nstage=%s\nsource_sha=%s\n' "$category" "$stage" "$SOURCE_SHA"
    printf 'failure_call=%s\nfailure_log=%s\n' "$invocation" "$log_path"
  } | tee "$RESULT_FILE"
  exit "$code"
}

run_step() {
  local category="$1" stage="$2" log_path="$3" status invocation
  shift 3
  invocation="$(command_string "$@")"
  printf '$ %s\n' "$invocation" >>"$COMMANDS_LOG"
  "$@" 2>&1 | tee "$log_path"
  status="${PIPESTATUS[0]}"
  [[ "$status" -eq 0 ]] || fail "$category" "$stage" "$invocation" "$log_path"
}

ok() {
  printf 'PASS %-28s %s\n' "$1" "$2"
}

blocked() {
  BLOCKS=$((BLOCKS + 1))
  printf 'INFRASTRUCTURE_BLOCK %-12s %s\n' "$1" "$2"
}

unknown() {
  UNKNOWNS=$((UNKNOWNS + 1))
  printf 'UNKNOWN %-25s %s\n' "$1" "$2"
}

probe_write() {
  local label="$1" target="$2" parent probe
  parent="$target"
  [[ -d "$parent" ]] || parent="$(dirname "$parent")"
  probe="$parent/.admin9-simulator-smoke-probe.$$"
  if [[ -d "$parent" ]] && (umask 077 && : >"$probe") 2>/dev/null; then
    rm -f "$probe"
    ok "$label" "transient write probe removed: $parent"
  else
    rm -f "$probe" 2>/dev/null || true
    blocked "$label" "cannot write required cache path: $parent"
  fi
}

android_serial() {
  local serial state ignored name
  while read -r serial state ignored; do
    [[ "$serial" == emulator-* && "$state" == device ]] || continue
    name="$($ADB -s "$serial" shell getprop ro.boot.qemu.avd_name 2>/dev/null | tr -d '\r')"
    if [[ "$name" == "$ANDROID_AVD" ]]; then
      printf '%s\n' "$serial"
      return 0
    fi
  done < <("$ADB" devices -l 2>/dev/null | tail -n +2)
  return 1
}

preflight() {
  local value output ios_line runtime serial
  BLOCKS=0
  UNKNOWNS=0
  printf 'source_sha=%s\nsource_tree=%s\ntask_identity=uid:%s user:%s\n' \
    "$SOURCE_SHA" "$SOURCE_TREE" "$(id -u)" "$(id -un)"

  if git diff --quiet && git diff --cached --quiet; then
    ok git_tracked_tree "clean at $SOURCE_SHA"
  else
    unknown git_tracked_tree "tracked changes are not represented by HEAD"
  fi

  for feature in hw.optional.neon hw.optional.arm.FEAT_AES; do
    value="$(/usr/sbin/sysctl -n "$feature" 2>&1)"
    if [[ "$?" -eq 0 && "$value" == 1 ]]; then
      ok "$feature" "$value"
    else
      blocked "$feature" "call: /usr/sbin/sysctl -n $feature; output: $value"
    fi
  done

  if [[ -x "$ADB" ]]; then
    output="$("$ADB" devices -l 2>&1)"
    if [[ "$?" -eq 0 ]] && lsof -nP -iTCP:5037 -sTCP:LISTEN >/dev/null 2>&1; then
      ok adb_5037 "$ADB; devices query and localhost listener passed"
    else
      blocked adb_5037 "call: $ADB devices -l; output: $output"
    fi
  else
    blocked adb_binary "not executable: $ADB"
  fi

  if [[ -x "$EMULATOR" ]]; then
    output="$("$EMULATOR" -list-avds 2>&1)"
    if grep -Fxq "$ANDROID_AVD" <<<"$output"; then
      ok android_avd "$ANDROID_AVD; $("$EMULATOR" -version 2>&1 | sed -n '1p')"
    else
      blocked android_avd "call: $EMULATOR -list-avds; missing $ANDROID_AVD"
    fi
  else
    blocked emulator_binary "not executable: $EMULATOR"
  fi

  if grep -Fqx 'image.sysdir.1=system-images/android-34/google_apis/arm64-v8a/' \
    "$HOME/.android/avd/$ANDROID_AVD.avd/config.ini" 2>/dev/null; then
    ok android_image "Google APIs arm64 API 34 original AVD"
  else
    blocked android_image "unexpected $HOME/.android/avd/$ANDROID_AVD.avd/config.ini"
  fi

  output="$(xcrun simctl list devices available 2>&1)"
  ios_line="$(grep -F "$IOS_UDID" <<<"$output" || true)"
  if [[ -n "$ios_line" ]]; then
    ok core_simulator "simctl connected; $ios_line"
  else
    blocked core_simulator "call: xcrun simctl list devices available; output: $output"
  fi
  runtime="$(plutil -extract runtime raw \
    "$HOME/Library/Developer/CoreSimulator/Devices/$IOS_UDID/device.plist" 2>&1)"
  if [[ "$runtime" == "$IOS_RUNTIME" ]]; then
    ok ios_runtime "$runtime"
  else
    blocked ios_runtime "fixed device runtime is $runtime, expected $IOS_RUNTIME"
  fi

  if [[ -x "$FLUTTER" ]]; then
    ok flutter_binary "$FLUTTER; $($FLUTTER --version 2>/dev/null | sed -n '1p')"
  else
    blocked flutter_binary "flutter is not executable"
  fi
  if output="$(xcodebuild -version 2>&1)"; then
    ok xcode_toolchain "$(tr '\n' ' ' <<<"$output")"
  else
    blocked xcode_toolchain "call: xcodebuild -version; output: $output"
  fi

  probe_write flutter_cache "$FLUTTER_ROOT/bin/cache"
  probe_write pub_cache "$HOME/.pub-cache"
  probe_write gradle_cache "$HOME/.gradle"
  probe_write xcode_derived_data "$HOME/Library/Developer/Xcode/DerivedData"
  probe_write core_simulator_cache "$HOME/Library/Developer/CoreSimulator"
  probe_write repository_build "$ROOT/build"

  serial="$(android_serial || true)"
  [[ -n "$serial" ]] && ok android_target_state "$ANDROID_AVD booted as $serial" ||
    ok android_target_state "$ANDROID_AVD available and shutdown"
  [[ -n "$ios_line" ]] && ok ios_target_state "$ios_line"

  if [[ "$BLOCKS" -gt 0 ]]; then
    printf 'RESULT=Infrastructure Block\n'
    return 20
  fi
  if [[ "$UNKNOWNS" -gt 0 ]]; then
    printf 'RESULT=Unknown\n'
    return 30
  fi
  printf 'RESULT=Pass\n'
}

wait_for_android() {
  local serial boot
  for _ in $(seq 1 180); do
    serial="$(android_serial || true)"
    boot=""
    [[ -n "$serial" ]] &&
      boot="$($ADB -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
    if [[ -n "$serial" && "$boot" == 1 ]]; then
      printf '%s\n' "$serial"
      return 0
    fi
    sleep 1
  done
  return 1
}

run_round() {
  local round="$1" serial="$2" round_dir="$3" apk ios_app component pid output status installed_app
  apk="$ROOT/build/app/outputs/flutter-apk/app-release.apk"
  ios_app="$ROOT/build/ios/iphonesimulator/Runner.app"
  mkdir -p "$round_dir"
  RESULT_FILE="$round_dir/result.txt"
  COMMANDS_LOG="$round_dir/commands.log"
  : >"$COMMANDS_LOG"
  printf 'round=%s\nsource_sha=%s\nsource_tree=%s\nstarted_at=%s\n' \
    "$round" "$SOURCE_SHA" "$SOURCE_TREE" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >"$round_dir/source.txt"

  if [[ "$(git rev-parse HEAD)" != "$SOURCE_SHA" ]] ||
    ! git diff --quiet || ! git diff --cached --quiet; then
    fail Unknown source_provenance \
      "git rev-parse HEAD; git diff --quiet; git diff --cached --quiet" "$round_dir/source.txt"
  fi

  run_step "Infrastructure Block" flutter_clean "$round_dir/flutter-clean.log" "$FLUTTER" clean
  run_step "Infrastructure Block" flutter_pub_get "$round_dir/flutter-pub-get.log" "$FLUTTER" pub get
  run_step "App Fail" android_build "$round_dir/android-build.log" "$FLUTTER" build apk --release
  run_step "App Fail" ios_build "$round_dir/ios-build.log" "$FLUTTER" build ios --simulator --debug
  [[ -f "$apk" && -d "$ios_app" ]] ||
    fail "App Fail" build_artifacts "test -f $apk; test -d $ios_app" "$round_dir/build-sha256.txt"
  shasum -a 256 "$apk" "$ios_app/Runner" "$ios_app/Frameworks/App.framework/App" \
    >"$round_dir/build-sha256.txt"

  run_step "Infrastructure Block" android_install "$round_dir/android-install.log" \
    "$ADB" -s "$serial" install -r "$apk"
  run_step "Infrastructure Block" ios_install "$round_dir/ios-install.log" \
    xcrun simctl install "$IOS_UDID" "$ios_app"
  {
    "$ADB" -s "$serial" shell pm path "$BUNDLE_ID"
    "$ADB" -s "$serial" shell dumpsys package "$BUNDLE_ID" |
      sed -n -E '/versionCode=|versionName=|firstInstallTime=|lastUpdateTime=|primaryCpuAbi=/p'
  } >"$round_dir/android-install-identity.txt" 2>&1
  installed_app="$(xcrun simctl get_app_container "$IOS_UDID" "$BUNDLE_ID" app 2>/dev/null || true)"
  {
    printf 'installed_app=%s\n' "$installed_app"
    printf 'bundle_id='
    /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$installed_app/Info.plist"
    printf 'version='
    /usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$installed_app/Info.plist"
    printf 'build='
    /usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$installed_app/Info.plist"
    shasum -a 256 "$installed_app/Runner" "$installed_app/Frameworks/App.framework/App"
  } >"$round_dir/ios-install-identity.txt" 2>&1
  grep -q '^package:' "$round_dir/android-install-identity.txt" ||
    fail "Infrastructure Block" android_install_identity \
      "$(command_string "$ADB" -s "$serial" shell pm path "$BUNDLE_ID")" "$round_dir/android-install-identity.txt"
  grep -Fqx "bundle_id=$BUNDLE_ID" "$round_dir/ios-install-identity.txt" ||
    fail "Infrastructure Block" ios_install_identity \
      "$(command_string xcrun simctl get_app_container "$IOS_UDID" "$BUNDLE_ID" app)" "$round_dir/ios-install-identity.txt"

  component="$($ADB -s "$serial" shell cmd package resolve-activity --brief "$BUNDLE_ID" 2>/dev/null |
    tail -n 1 | tr -d '\r')"
  [[ -n "$component" && "$component" != No* ]] ||
    fail "App Fail" android_resolve_activity \
      "$(command_string "$ADB" -s "$serial" shell cmd package resolve-activity --brief "$BUNDLE_ID")" \
      "$round_dir/android-launch.log"
  run_step "Infrastructure Block" android_force_stop "$round_dir/android-force-stop.log" \
    "$ADB" -s "$serial" shell am force-stop "$BUNDLE_ID"
  run_step "App Fail" android_cold_launch "$round_dir/android-launch.log" \
    "$ADB" -s "$serial" shell am start -W -S -n "$component"
  sleep 3
  pid="$($ADB -s "$serial" shell pidof "$BUNDLE_ID" 2>/dev/null | tr -d '\r')"
  [[ -n "$pid" ]] || fail "App Fail" android_process \
    "$(command_string "$ADB" -s "$serial" shell pidof "$BUNDLE_ID")" "$round_dir/android-launch.log"
  printf '$ %s\n' "$(command_string "$ADB" -s "$serial" exec-out screencap -p)" >>"$COMMANDS_LOG"
  "$ADB" -s "$serial" exec-out screencap -p >"$round_dir/android-cold-launch.png" ||
    fail "Infrastructure Block" android_screenshot \
      "$(command_string "$ADB" -s "$serial" exec-out screencap -p)" "$round_dir/android-cold-launch.png"
  "$ADB" -s "$serial" logcat -d --pid="$pid" -t 300 >"$round_dir/android-app.log" 2>&1 || true

  xcrun simctl terminate "$IOS_UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  printf '$ %s\n' "$(command_string xcrun simctl launch --terminate-running-process "$IOS_UDID" "$BUNDLE_ID")" \
    >>"$COMMANDS_LOG"
  output="$(xcrun simctl launch --terminate-running-process "$IOS_UDID" "$BUNDLE_ID" 2>&1)"
  status="$?"
  printf '%s\n' "$output" | tee "$round_dir/ios-launch.log"
  [[ "$status" -eq 0 && "$output" == *": "* ]] || fail "App Fail" ios_cold_launch \
    "$(command_string xcrun simctl launch --terminate-running-process "$IOS_UDID" "$BUNDLE_ID")" \
    "$round_dir/ios-launch.log"
  sleep 3
  printf '$ %s\n' "$(command_string xcrun simctl io "$IOS_UDID" screenshot "$round_dir/ios-cold-launch.png")" \
    >>"$COMMANDS_LOG"
  xcrun simctl io "$IOS_UDID" screenshot "$round_dir/ios-cold-launch.png" >/dev/null 2>&1 ||
    fail "Infrastructure Block" ios_screenshot \
      "$(command_string xcrun simctl io "$IOS_UDID" screenshot "$round_dir/ios-cold-launch.png")" \
      "$round_dir/ios-cold-launch.png"
  xcrun simctl spawn "$IOS_UDID" log show --style compact --last 2m \
    --predicate 'process == "Runner"' >"$round_dir/ios-app.log" 2>&1 || true

  {
    printf 'avd=%s\nserial=%s\n' "$ANDROID_AVD" "$serial"
    printf 'model='
    "$ADB" -s "$serial" shell getprop ro.product.model | tr -d '\r'
    printf 'android='
    "$ADB" -s "$serial" shell getprop ro.build.version.release | tr -d '\r'
    printf 'api='
    "$ADB" -s "$serial" shell getprop ro.build.version.sdk | tr -d '\r'
    printf 'navigation_mode='
    "$ADB" -s "$serial" shell settings get secure navigation_mode | tr -d '\r'
    "$ADB" -s "$serial" shell wm size | tr -d '\r'
    "$ADB" -s "$serial" shell wm density | tr -d '\r'
  } >"$round_dir/android-device.txt" 2>&1
  {
    printf 'udid=%s\n' "$IOS_UDID"
    for variable in SIMULATOR_DEVICE_NAME SIMULATOR_RUNTIME_VERSION SIMULATOR_MODEL_IDENTIFIER \
      SIMULATOR_MAINSCREEN_SCALE SIMULATOR_MAINSCREEN_WIDTH SIMULATOR_MAINSCREEN_HEIGHT; do
      printf '%s=' "$variable"
      xcrun simctl getenv "$IOS_UDID" "$variable"
    done
  } >"$round_dir/ios-device.txt" 2>&1

  run_step "App Fail" android_smoke "$round_dir/android-smoke.log" \
    "$FLUTTER" test integration_test/simulator_smoke_test.dart -d "$serial" -r expanded
  run_step "App Fail" ios_smoke "$round_dir/ios-smoke.log" \
    "$FLUTTER" test integration_test/simulator_smoke_test.dart -d "$IOS_UDID" -r expanded
  shasum -a 256 "$round_dir/android-cold-launch.png" "$round_dir/ios-cold-launch.png" \
    "$round_dir/android-smoke.log" "$round_dir/ios-smoke.log" >"$round_dir/evidence-sha256.txt"
  {
    printf 'RESULT=Pass\nround=%s\nsource_sha=%s\nsource_tree=%s\n' \
      "$round" "$SOURCE_SHA" "$SOURCE_TREE"
    printf 'android_avd=%s\nandroid_serial=%s\n' "$ANDROID_AVD" "$serial"
    printf 'ios_udid=%s\nios_runtime=%s\ncompleted_at=%s\n' \
      "$IOS_UDID" "$IOS_RUNTIME" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  } | tee "$RESULT_FILE"
}

run_all() {
  local rounds="$1" evidence_dir="$2" session_dir lock_dir preflight_status serial round emulator_pid=""
  session_dir="$evidence_dir/$SOURCE_SHA"
  lock_dir="${TMPDIR:-/tmp}/admin9-simulator-smoke-$UID.lock"
  mkdir -p "$session_dir"
  RESULT_FILE="$session_dir/result.txt"
  mkdir "$lock_dir" 2>/dev/null ||
    fail "Infrastructure Block" exclusive_lock "mkdir $lock_dir" "$RESULT_FILE"
  trap "rmdir '$lock_dir' 2>/dev/null || true" EXIT INT TERM

  preflight 2>&1 | tee "$session_dir/preflight.log"
  preflight_status="${PIPESTATUS[0]}"
  [[ "$preflight_status" -eq 0 ]] || {
    [[ "$preflight_status" -eq 20 ]] &&
      fail "Infrastructure Block" preflight "tool/simulator_smoke.sh preflight" "$session_dir/preflight.log"
    fail Unknown preflight "tool/simulator_smoke.sh preflight" "$session_dir/preflight.log"
  }

  COMMANDS_LOG="$session_dir/startup-commands.log"
  : >"$COMMANDS_LOG"
  serial="$(android_serial || true)"
  if [[ -z "$serial" ]]; then
    printf '$ %s\n' "$(command_string "$EMULATOR" -avd "$ANDROID_AVD" -no-snapshot-load -no-boot-anim -gpu host)" \
      >>"$COMMANDS_LOG"
    "$EMULATOR" -avd "$ANDROID_AVD" -no-snapshot-load -no-boot-anim -gpu host \
      >"$session_dir/android-emulator.log" 2>&1 &
    emulator_pid="$!"
    serial="$(wait_for_android || true)"
    [[ -n "$serial" ]] || fail "Infrastructure Block" android_boot \
      "$(command_string "$EMULATOR" -avd "$ANDROID_AVD" -no-snapshot-load -no-boot-anim -gpu host)" \
      "$session_dir/android-emulator.log"
  fi
  printf 'emulator_pid=%s\nandroid_serial=%s\n' "$emulator_pid" "$serial" \
    >>"$session_dir/android-emulator.log"

  if ! xcrun simctl list devices booted | grep -F "$IOS_UDID" | grep -Fq '(Booted)'; then
    run_step "Infrastructure Block" ios_boot "$session_dir/ios-boot.log" xcrun simctl boot "$IOS_UDID"
  fi
  run_step "Infrastructure Block" ios_bootstatus "$session_dir/ios-bootstatus.log" \
    xcrun simctl bootstatus "$IOS_UDID" -b

  for round in $(seq 1 "$rounds"); do
    run_round "$round" "$serial" "$session_dir/round-$round"
  done
  RESULT_FILE="$session_dir/result.txt"
  {
    printf 'RESULT=Pass\nsource_sha=%s\nsource_tree=%s\nrounds=%s\n' \
      "$SOURCE_SHA" "$SOURCE_TREE" "$rounds"
    printf 'android_avd=%s\nandroid_serial=%s\nios_udid=%s\nios_runtime=%s\n' \
      "$ANDROID_AVD" "$serial" "$IOS_UDID" "$IOS_RUNTIME"
    printf 'evidence_dir=%s\n' "$session_dir"
  } | tee "$RESULT_FILE"
}

case "${1:-}" in
  preflight)
    preflight
    exit $?
    ;;
  run)
    shift
    rounds=1
    evidence_dir="$ROOT/build/simulator-smoke"
    while [[ "$#" -gt 0 ]]; do
      case "$1" in
        --rounds)
          rounds="${2:-}"
          shift 2
          ;;
        --evidence-dir)
          evidence_dir="${2:-}"
          shift 2
          ;;
        *)
          usage
          exit 30
          ;;
      esac
    done
    [[ "$rounds" =~ ^[1-9][0-9]*$ ]] || {
      printf 'RESULT=Unknown\nfailure_call=--rounds must be a positive integer\n'
      exit 30
    }
    [[ "$evidence_dir" == /* ]] || evidence_dir="$ROOT/$evidence_dir"
    run_all "$rounds" "$evidence_dir"
    ;;
  *)
    usage
    exit 30
    ;;
esac
