import SwiftUI
import GoogleSignInSwift
import Combine

struct ContentView: View {
    @State private var isLoggin: Bool = false
    private let container: DIContainer

    private var userBinding: Binding<Bool> {
        $isLoggin.dispatched(to: container.appState, \.userData.isLoggedIn)
    }

    init(container: DIContainer) {
        self.container = container
    }

    var body: some View {
        Group {
            ZStack {
                VStack {
                    if isLoggin {
                        HomeView().inject(container)
                    } else {
                        TestView().inject(container)
                    }
                }
            }
        }
        .onReceive(loginStatusUpdate) {isLoggin = $0}
    }
}

extension ContentView {
    fileprivate var loginStatusUpdate: AnyPublisher<Bool, Never> {
        container.appState.updates(for: \.userData.isLoggedIn)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(container: .preview)
    }
}
