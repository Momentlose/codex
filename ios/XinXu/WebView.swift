import SwiftUI
import WebKit
import UIKit

/// 用内置网页渲染「牛马费」主界面。
/// 页面自身通过 env(safe-area-inset-*) 处理安全区，所以这里让 WebView 铺满整屏。
struct WebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.bounces = true
        webView.allowsBackForwardNavigationGestures = false
        webView.navigationDelegate = context.coordinator

        if let url = Bundle.main.url(forResource: "薪序-薪资管理", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            webView.loadHTMLString("<h1 style=\"font-family:-apple-system\">缺少内置页面</h1>", baseURL: nil)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    /// 页面加载完成后强制回到顶部。
    /// WebKit 会按会话恢复上一次的滚动位置，导致重新打开时顶部标题栏被顶出屏幕。
    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.scrollView.setContentOffset(.zero, animated: false)
            webView.evaluateJavaScript("window.scrollTo(0, 0); void 0;", completionHandler: nil)
        }
    }
}
