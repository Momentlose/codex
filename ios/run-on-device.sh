#!/usr/bin/env bash
# 签名构建并安装到已连接的真机 iPhone
# 用法: ./run-on-device.sh [TEAM_ID]
set -euo pipefail

IOS_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$IOS_DIR"

PY=/Applications/Xcode.app/Contents/Developer/usr/bin/python3

# 1. 找真机
"$PY" - <<'PY' > /tmp/dsh_device.txt
import json, subprocess, sys
out = "/tmp/dsh_devices.json"
subprocess.run(["xcrun","devicectl","list","devices","--json-output",out],
               capture_output=True)
d = json.load(open(out))
for dev in d.get("result",{}).get("devices",[]):
    hw = dev.get("hardwareProperties",{})
    conn = dev.get("connectionProperties",{})
    if hw.get("reality") == "physical" and conn.get("tunnelState") != "unavailable":
        print(dev["identifier"])
        break
PY
DEVICE="$(head -1 /tmp/dsh_device.txt)"
[ -n "$DEVICE" ] || { echo "✗ 没找到已连接的真机，先用数据线连上并点『信任』"; exit 1; }
echo "· 真机 UDID: $DEVICE"

# 2. 找 team
TEAM="${1:-}"
if [ -z "$TEAM" ]; then
  TEAM="$("$PY" - <<'PY'
import subprocess
try:
    raw = subprocess.run(["defaults","read","com.apple.dt.Xcode","IDEProvisioningTeams"],
                         capture_output=True, text=True).stdout
except Exception:
    raw = ""
import re
ids = sorted(set(re.findall(r'\b[A-Z0-9]{10}\b', raw)))
print(ids[0] if ids else "")
PY
)"
fi
if [ -z "$TEAM" ]; then
  echo "✗ 没找到签名团队。先在 Xcode → Settings → Accounts 登录 Apple ID"
  echo "  登录成功后重新运行本脚本；或手动传入: ./run-on-device.sh <TEAM_ID>"
  exit 1
fi
echo "· 签名团队: $TEAM"

# 3. 构建
echo "· 签名构建"
xcodebuild -project XinXu.xcodeproj -scheme XinXu -configuration Debug \
  -destination "id=$DEVICE" -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="$TEAM" \
  -derivedDataPath build/DerivedDevice build

APP="build/DerivedDevice/Build/Products/Debug-iphoneos/XinXu.app"
[ -d "$APP" ] || { echo "✗ 找不到产物 $APP"; exit 1; }

# 4. 安装并启动
echo "· 安装到手机"
xcrun devicectl device install app --device "$DEVICE" "$APP"
echo "· 启动"
xcrun devicectl device process launch --device "$DEVICE" com.momentlose.xinxu || true
echo "✓ 完成"
