import SwiftUI
import WebKit

@main
struct XinXuApp: App {
    var body: some Scene {
        WindowGroup {
            XinXuWebView()
                .ignoresSafeArea()
        }
    }
}

private struct XinXuWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 200 / 255, green: 232 / 255, blue: 255 / 255, alpha: 1)
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        if let page = Bundle.main.url(forResource: "薪序-薪资管理", withExtension: "html"),
           let resources = Bundle.main.resourceURL {
            webView.loadFileURL(page, allowingReadAccessTo: resources)
        } else {
            webView.loadHTMLString(
                "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><p style=\"font:16px -apple-system;text-align:center;margin-top:30vh\">找不到薪序页面资源</p>",
                baseURL: nil
            )
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
