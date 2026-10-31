import SwiftUI
import UIKit

@main
struct XinXuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().preferredColorScheme(.light)
        }
    }
}

struct ContentView: View {
    var body: some View {
        WebView()
            .ignoresSafeArea(.all)
            .background(Color(red: 0.78, green: 0.90, blue: 1.0))
    }
}
