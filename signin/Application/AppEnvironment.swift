import Foundation
import Combine

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        let interactors = configuredInteractors(appState: appState)
        let diContainer = DIContainer(appState: appState, interactors: interactors)
        return AppEnvironment(container: diContainer)
    }

    private static func configuredInteractors(appState: Store<AppState>
    ) -> Interactors {
        let productService = ProductService(appState: appState, productRepository: ProductRepository())
        let authService = AuthService(appState: appState)
        let cartService = CartService(appState: appState)

        return .init(productService: productService, cartService: cartService, authService: authService)
    }
}
