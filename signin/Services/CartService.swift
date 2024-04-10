import Foundation
import Combine

class CartService: CartServiceProtocol {
    let appState: Store<AppState>

    init(appState: Store<AppState>) {
        self.appState = appState
    }

    func addToCart(product: ProductModel) {
        self.appState.bulkUpdate { state in
            state.cart.append(product)
        }
    }
}

struct StubCartServiceImpl: CartServiceProtocol {
    func addToCart(product: ProductModel) -> Void {
    }
}
