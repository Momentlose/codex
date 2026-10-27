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

        let pageName = "薪序-薪资管理"
        let page = Bundle.main.url(forResource: pageName, withExtension: "html", subdirectory: "Resources")
            ?? Bundle.main.url(forResource: pageName, withExtension: "html")
        if let page, let resources = Bundle.main.resourceURL {
            webView.loadFileURL(page, allowingReadAccessTo: resources)
        } else {
            let message = """
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <body style="margin:0;min-height:100vh;display:grid;place-items:center;background:#c8e8ff;color:#20344a;font:18px -apple-system">
            <p>找不到薪序页面资源</p></body>
            """
            webView.loadHTMLString(message, baseURL: nil)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
