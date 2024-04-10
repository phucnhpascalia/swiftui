import Foundation
import Alamofire

class ProductRepository: ProductRepositoryProtocol {
    func fetchProducts(completion: @escaping (Result<[ProductModel], Error>) -> Void) {
        AF.request("https://fakestoreapi.com/products")
            .responseDecodable(of: [ProductModel].self) { response in
                switch response.result {
                case .success(let products):
                    completion(.success(products))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
