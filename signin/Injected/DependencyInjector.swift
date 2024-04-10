import Foundation
import SwiftUI
import Combine

struct DIContainer: EnvironmentKey {

    let appState: Store<AppState>
    let interactors: Interactors

    init(appState: Store<AppState>, interactors: Interactors) {
        self.appState = appState
        self.interactors = interactors
    }

    init(appState: AppState, interactors: Interactors) {
        self.init(appState: Store<AppState>(appState), interactors: interactors)
    }

    static var defaultValue: Self { Self.default }

    private static let `default` = Self(appState: AppState(), interactors: .stub)

}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}

#if DEBUG
extension DIContainer {
    static var preview: Self {
        .init(appState: .init(AppState.preview), interactors: .stub)
    }
}
#endif

extension View {
    func inject(_ appState: AppState,
                _ interactors: Interactors) -> some View {
        let container = DIContainer(appState: .init(appState),
                                    interactors: interactors)
        return inject(container)
    }

    func inject(_ container: DIContainer) -> some View {
        return self
            .modifier(RootViewAppearance())
            .environment(\.injected, container)
    }
}
