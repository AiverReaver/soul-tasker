#!/usr/bin/env bash
# Builds a release app and installs it on a real iPhone with devicectl, which
# is steadier over Wi-Fi than `flutter run`. Each failure prints its fix.
#   tool/deploy_iphone.sh [--demo] [--check] [--device <udid>]
#   --demo   build lib/main_demo.dart (seeded data) instead of lib/main.dart
#   --check  run the preflight only
set -euo pipefail

app="$(cd "$(dirname "$0")/.." && pwd)"
bundle="com.hearthrise.app"
target="lib/main.dart"
check_only=0
udid=""
while [ $# -gt 0 ]; do
  case "$1" in
    --demo) target="lib/main_demo.dart" ;;
    --check) check_only=1 ;;
    --device) udid="$2"; shift ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
  shift
done

fail() { printf '\n✗ %s\n  Fix: %s\n' "$1" "$2" >&2; exit 1; }
ok() { printf '✓ %s\n' "$1"; }

# 1. Signing: a development certificate and the project's team.
security find-identity -v -p codesigning | grep -q "Apple Development" ||
  fail "No Apple Development certificate in the keychain." \
    "open ios/Runner.xcworkspace, Xcode > Settings > Accounts, sign in, then Runner target > Signing & Capabilities > pick the team."
team="$(grep -m1 -o 'DEVELOPMENT_TEAM = [A-Z0-9]*' "$app/ios/Runner.xcodeproj/project.pbxproj" | awk '{print $3}')"
[ -n "$team" ] || fail "No DEVELOPMENT_TEAM in the Xcode project." \
  "Runner target > Signing & Capabilities > Team, then save."
ok "signing: Apple Development certificate, team $team"

# 2. The phone: paired, Developer Mode on.
json="$(mktemp)"
trap 'rm -f "$json"' EXIT
xcrun devicectl list devices --json-output "$json" >/dev/null 2>&1 ||
  fail "devicectl could not list devices." "Install Xcode 15+ and run: sudo xcode-select -s /Applications/Xcode.app"
want="$udid"
read -r udid name pairing devmode transport < <(python3 -I - "$json" "$udid" <<'PY'
import json, sys
devices = json.load(open(sys.argv[1]))["result"]["devices"]
want = sys.argv[2]
for d in devices:
    hw, dp, cp = d["hardwareProperties"], d["deviceProperties"], d["connectionProperties"]
    if hw.get("reality") != "physical" or hw.get("platform") != "iOS":
        continue
    if want and hw.get("udid") != want:
        continue
    print(hw.get("udid"), dp.get("name", "?").replace(" ", "_"), cp.get("pairingState"),
          dp.get("developerModeStatus"), cp.get("transportType"))
    break
else:
    print("- - - - -")
PY
)
[ "$udid" != "-" ] || fail "No iPhone found${want:+ with UDID $want}." \
  "Plug the phone in by USB, unlock it, tap Trust on the phone. Once it shows in Xcode > Window > Devices it also works over Wi-Fi."
[ "$pairing" = "paired" ] || fail "$name is not paired with this Mac." \
  "Plug in by USB, unlock the phone and tap Trust."
[ "$devmode" = "enabled" ] || fail "Developer Mode is off on $name." \
  "On the phone: Settings > Privacy & Security > Developer Mode > On, then restart it."
ok "device: ${name//_/ } ($udid) over $transport"
[ "$transport" = "wired" ] || echo "  note: over Wi-Fi. Keep the phone unlocked and on the same network; plug in by USB if install stalls."

[ "$check_only" = 0 ] || exit 0

# 3. Build, install, launch.
cd "$app"
echo "→ flutter build ios --release -t $target"
flutter build ios --release -t "$target" ||
  fail "Release build failed." \
    "Read the Xcode error above. 'status code 255' over Wi-Fi: open ios/Runner.xcworkspace, Product > Build once so Xcode prepares the device, then rerun."
echo "→ installing on ${name//_/ }"
xcrun devicectl device install app --device "$udid" build/ios/iphoneos/Runner.app ||
  fail "Install failed." \
    "Unlock the phone. If it says the developer is untrusted: Settings > General > VPN & Device Management > Apple Development > Trust. Over Wi-Fi, try USB."
echo "→ launching $bundle"
xcrun devicectl device process launch --device "$udid" "$bundle" >/dev/null ||
  fail "Installed, but launch failed." \
    "Unlock the phone and open Hearthrise by hand. First launch may need: Settings > General > VPN & Device Management > Trust."
ok "Hearthrise running on ${name//_/ } ($target)"
