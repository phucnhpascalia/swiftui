import Foundation
import Alamofire

class WidgetsJSManager {
    static let shared = WidgetsJSManager()

    private(set) var contentTW: String?
    private(set) var contentIG: String?

    public func load(link: String, type: String) {
        AF.request(link).responseString { response in
            switch response.result {
            case .success(let data):
                switch type {
                case "tw":
                    self.contentTW = data
                case "ig":
                    self.contentIG = data
                default:
                    break
                }

            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
