import SwiftUI

@main
struct MainApp: App {
    let environment = AppEnvironment.bootstrap()

    var body: some Scene {
        WindowGroup {
            RootView(container: environment.container)
        }
    }
}
