import Foundation
import SwiftUI
import Combine

struct AppState: Equatable {
    var userData = UserStatusModel(givenName: "", isLoggedIn: false, userEmail: "", profilePicUrl: "")
    var products: [ProductModel] = []
    var cart: [ProductModel] = []
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    return lhs.userData == rhs.userData && lhs.products == rhs.products && lhs.cart == rhs.cart
}

#if DEBUG
extension AppState {
    static var preview: AppState {
        var state = AppState()
        return state
    }
}
#endif
