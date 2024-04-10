import Foundation
import Combine

class ProductService: ProductServiceProtocol {
    let appState: Store<AppState>
    let productRepository: ProductRepositoryProtocol

    init(appState: Store<AppState>, productRepository: ProductRepositoryProtocol) {
        self.appState = appState
        self.productRepository = productRepository
    }

    func fetchProducts() {
        productRepository.fetchProducts { result in
            switch result {
            case .success(let products):
                // Update appState with fetched products
                self.appState.bulkUpdate { state in
                    state.products = products
                }
            case .failure(let error):
                print("Failed to fetch products: \(error)")
                // Handle error if needed
            }
        }
    }
}

struct StubProductServiceImpl: ProductServiceProtocol {
    func fetchProducts() -> Void {}
}
