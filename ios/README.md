# 薪序 iOS 模拟器预览

此目录提供一个用于界面预览的轻量 iOS WebView 外壳。页面仍由现有 HTML/CSS/JavaScript 提供，收入和设置数据不会被写入仓库。

## 云端模拟器构建

GitHub Actions 在 macOS 运行机上使用 XcodeGen 生成 Xcode 工程，编译 iOS Simulator 版本、启动可用的 iPhone 模拟器，并把屏幕截图作为 Actions artifact 上传。

- 工作流：`.github/workflows/ios-simulator.yml`
- 手动运行：GitHub 仓库的 Actions → iOS Simulator Preview → Run workflow
- 结果：打开该次运行，在 Artifacts 下载 `xin-xu-ios-simulator-preview`

## 当前范围

这是用于模拟器预览的原型外壳，不是 App Store 发布包。要正式发布，还需要完善原生容器体验、数据迁移/同步、隐私说明、图标和 Apple 签名配置。网页当前依赖浏览器本地存储；WKWebView 的数据空间独立于 Safari。
