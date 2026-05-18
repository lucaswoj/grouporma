import SwiftUI
import UIKit

@main
struct RiskApp: App {
    @State private var store = PersistentStore()

    init() {
        let proxy = UIPageControl.appearance()
        proxy.currentPageIndicatorTintColor = UIColor.label
        proxy.pageIndicatorTintColor = UIColor.tertiaryLabel
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
