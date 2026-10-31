#!/usr/bin/env bash
# 构建「牛马费」iOS 模拟器 App，并安装到指定模拟器
# 用法: ./build.sh [模拟器 UDID]
set -euo pipefail

IOS_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$IOS_DIR/.." && pwd)"
BUILD="$IOS_DIR/build"
APP="$BUILD/牛马费.app"
UDID="${1:-8ADE95B1-8751-458C-A8AC-7C34750A74F9}"
BUNDLE_ID="com.momentlose.xinxu"

echo "· 清理"
rm -rf "$BUILD"
mkdir -p "$APP"

echo "· 拷贝网页资源"
for f in "薪序-薪资管理.html" cloud-sync.js manifest.webmanifest service-worker.js icon-180.png icon-512.png; do
  cp "$REPO/$f" "$APP/"
done
cp "$REPO/icon-180.png" "$APP/AppIcon.png"
cp "$REPO/icon-180.png" "$APP/AppIcon60x60@2x.png"
cp "$REPO/icon-512.png" "$APP/AppIcon60x60@3x.png"

echo "· 生成 Info.plist"
cp "$IOS_DIR/XinXu/Info.plist" "$APP/Info.plist"

echo "· 编译 Swift"
SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
mkdir -p "$BUILD/tmp" "$BUILD/ModuleCache" "$BUILD/ClangCache"
export TMPDIR="$BUILD/tmp"
xcrun --sdk iphonesimulator swiftc \
  -sdk "$SDK" \
  -target arm64-apple-ios17.0-simulator \
  -parse-as-library -O \
  -module-cache-path "$BUILD/ModuleCache" \
  -Xcc -fmodules-cache-path="$BUILD/ClangCache" \
  -o "$APP/XinXu" \
  "$IOS_DIR/XinXu/App.swift" "$IOS_DIR/XinXu/WebView.swift" \
  -framework SwiftUI -framework WebKit -framework UIKit

echo "· 签名"
codesign --force --sign - --timestamp=none "$APP" 2>&1 | tail -2
echo "· 产物: $APP"

if [ "${SKIP_INSTALL:-0}" = "1" ]; then
  exit 0
fi

echo "· 启动模拟器 $UDID"
xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1 || sleep 5

echo "· 安装"
xcrun simctl uninstall "$UDID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl install "$UDID" "$APP"

echo "· 启动"
xcrun simctl launch "$UDID" "$BUNDLE_ID"
