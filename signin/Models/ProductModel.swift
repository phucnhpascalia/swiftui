//
//  Product.swift
//  signin
//
//  Created by Phuc Nguyen on 03/04/2024.
//

import Foundation

struct ProductModel: Codable, Identifiable, Equatable {
    static func == (lhs: ProductModel, rhs: ProductModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.price == rhs.price &&
            lhs.description == rhs.description &&
            lhs.category == rhs.category &&
            lhs.image == rhs.image
    }

    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: RatingModel
}
