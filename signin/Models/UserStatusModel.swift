//
//  UserStatusModel.swift
//  signin
//
//  Created by Phuc Nguyen on 04/04/2024.
//

import Foundation

struct UserStatusModel {
    var givenName: String = ""
    var isLoggedIn: Bool = false
    var userEmail: String = ""
    var profilePicUrl: String = ""

    static func == (lhs: UserStatusModel, rhs: UserStatusModel) -> Bool {
        return lhs.isLoggedIn == rhs.isLoggedIn &&
            lhs.givenName == rhs.givenName &&
            lhs.userEmail == rhs.userEmail &&
            lhs.profilePicUrl == rhs.profilePicUrl
    }
}
