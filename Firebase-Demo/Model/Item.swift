//
//  Item.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

struct Item {
    let name: String
    let price: Double
    let id: String // document id 
    let listedDate: Date
    let sellerName: String
    let sellerId: String 
    let categoryName: String
    let imageURL: String
}

extension Item {
    init(_ dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? "no item name"
        self.price = dictionary["price"] as? Double ?? 0.0
        self.id = dictionary["id"] as? String ?? "no id"
        self.listedDate = dictionary["listedDate"] as? Date ?? Date()
        self.sellerName = dictionary["sellerName"] as? String ?? "no Seller name"
        self.sellerId = dictionary["sellerId"]  as? String ?? "no seller id"
        self.categoryName = dictionary["categoryName"] as? String ?? "no category"
        self.imageURL = dictionary["imageURL"] as? String ?? "no image"
    }
}
