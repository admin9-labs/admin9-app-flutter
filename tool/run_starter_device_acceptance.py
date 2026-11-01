#!/usr/bin/env python3
"""Run Starter integration tests with a real OS background/foreground round trip."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import threading
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('platform', choices=['android', 'ios'])
    parser.add_argument('--device', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    adb = shutil.which('adb')
    if args.platform == 'android' and adb is None:
        sdk = os.environ.get('ANDROID_SDK_ROOT') or os.environ.get('ANDROID_HOME')
        if sdk:
            candidate = Path(sdk) / 'platform-tools' / 'adb'
            if candidate.is_file():
                adb = str(candidate)
        if adb is None:
            parser.error('adb must be on PATH or in ANDROID_SDK_ROOT/ANDROID_HOME')
    command = [
        'flutter', 'drive', '--dart-define=STARTER_OS_LIFECYCLE=true',
        '--driver=test_driver/showroom_screenshot_driver.dart',
        '--target=integration_test/starter_contract_test.dart', '-d', args.device,
    ]
    env = dict(os.environ, SHOWROOM_SCREENSHOT_DIR=str(args.output.resolve()))
    errors = []
    thread = None
    with (args.output / 'run.log').open('w') as log:
        def background():
            try:
                if args.platform == 'android':
                    prefix = [adb, '-s', args.device, 'shell']
                    commands = [prefix + ['input', 'keyevent', 'KEYCODE_HOME'],
                                prefix + ['am', 'start', '-W', '-a', 'android.intent.action.MAIN',
                                          '-c', 'android.intent.category.LAUNCHER', '-f', '0x10200000',
                                          '-n', 'dev.admin9.starter/.MainActivity']]
                else:
                    prefix = ['xcrun', 'devicectl', 'device', 'process', 'launch', '--device', args.device]
                    commands = [prefix + ['com.apple.Preferences'], prefix + ['dev.admin9.starter']]
                for action in commands:
                    result = subprocess.run(action, capture_output=True, text=True, timeout=15, check=True)
                    log.write('HOST_OS_ACTION: ' + result.stdout + result.stderr)
                    log.flush()
                    time.sleep(1.5)
            except Exception as error:
                errors.append(str(error))

        process = subprocess.Popen(command, env=env, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT, text=True, bufsize=1)
        for line in process.stdout:
            log.write(line)
            log.flush()
            print(line, end='', flush=True)
            if 'STARTER_AD_READY_FOR_OS_BACKGROUND' in line and thread is None:
                thread = threading.Thread(target=background)
                thread.start()
        code = process.wait()
        if thread is not None:
            thread.join()
        result = {'exit': code, 'fired': thread is not None, 'errors': errors}
        log.write(f'HOST_RESULT {result}\n')
        print(f'HOST_RESULT {result}')
    return code or (1 if thread is None or errors else 0)


if __name__ == '__main__':
    raise SystemExit(main())
