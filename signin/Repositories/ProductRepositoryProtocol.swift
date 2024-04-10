import Foundation

protocol ProductRepositoryProtocol {
    func fetchProducts(completion: @escaping (Result<[ProductModel], Error>) -> Void)
}
