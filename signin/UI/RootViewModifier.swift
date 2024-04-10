import SwiftUI
import Combine

// MARK: - RootViewAppearance

struct RootViewAppearance: ViewModifier {
    @Environment(\.injected) private var injected: DIContainer
    @State private var isActive: Bool = false

    func body(content: Content) -> some View {
        content
            .ignoresSafeArea()
    }
}
