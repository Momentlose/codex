# 牛马费 iOS 端

原生壳 + 内置网页。App 启动后用 `WKWebView` 加载打包进 Bundle 的
`薪序-薪资管理.html`，不联网、不需要服务器，数据存在 App 自己的
WebKit 本地存储里。

## 目录

```
ios/
├── XinXu/
│   ├── App.swift       # SwiftUI 入口
│   ├── WebView.swift   # WKWebView 封装
│   └── Info.plist      # Bundle 配置
├── build.sh            # 编译 + 安装到模拟器
└── build/              # 产物（已 gitignore）
```

## 构建并运行

```bash
cd ios
./build.sh                 # 默认装到 iPhone 14 Pro 模拟器
./build.sh <模拟器 UDID>    # 指定设备
SKIP_INSTALL=1 ./build.sh   # 只编译，不安装
```

脚本会：拷贝网页资源 → `swiftc` 编译 → ad-hoc 签名 → 安装 → 启动。

需要先有模拟器：

```bash
xcrun simctl list devicetypes | grep "iPhone 14 Pro"
xcrun simctl create "iPhone 14 Pro" \
  com.apple.CoreSimulator.SimDeviceType.iPhone-14-Pro \
  com.apple.CoreSimulator.SimRuntime.iOS-27-2
```

## 设计说明

- **整屏铺满**：`ContentView` 用 `ignoresSafeArea(.all)`，让背景渐变延伸到状态栏和底部；
  安全区由网页自己的 `env(safe-area-inset-*)` 处理（页面 meta 已带 `viewport-fit=cover`）。
- **禁用自动内边距**：`contentInsetAdjustmentBehavior = .never`，否则 WKWebView 会再套一层安全区，
  导致页面上下各多出一条空白。
- **本地资源**：`loadFileURL(_:allowingReadAccessTo:)`，读取范围限制在 Bundle 根目录。
- **数据持久化**：file:// 来源在 WKWebView 下可以正常使用 localStorage 与 IndexedDB
  （已验证 `Library/WebKit/<bundle-id>/WebsiteData` 下生成了持久化数据）。

## 已知限制

- 这是**原生壳方案**，界面仍由网页渲染，不是 SwiftUI 重写。
- 编译器只产出模拟器架构（`arm64-apple-ios-simulator`）。装到真机需要：
  1. 一个 Xcode 工程（终端构建不生成 `.xcodeproj`）；
  2. Apple ID 签名 Team；
  3. `xcodebuild -destination 'generic/platform=iOS'` 并签名。
- `导出 Excel` 走的是浏览器下载逻辑，WKWebView 里需要额外实现下载代理才能保存文件。
