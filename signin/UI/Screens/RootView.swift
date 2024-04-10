import SwiftUI
import Combine

struct RootView: View {
    private let container: DIContainer

    private var cancellables = Set<AnyCancellable>()

    init(container: DIContainer) {
        self.container = container
    }

    var body: some View {
        ContentView(container: container)
    }
}
