//
//  Comment.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import Firebase // timestamp

struct Comment {
    let commentDate: Timestamp
    let commentedBy: String
    let itemId: String
    let itemName: String
    let sellerName: String
    let text: String
    
}

extension Comment {
    init(_ dictionary: [String: Any]) {
        self.commentDate = dictionary["commentDate"] as? Timestamp ?? Timestamp(date: Date())
        self.commentedBy = dictionary["commentedBy"] as? String ?? "no commented by name"
        self.itemId = dictionary["itemId"] as? String ?? "no item id"
        self.itemName = dictionary["itemName"] as? String ?? "no item name"
        self.sellerName = dictionary["sellerName"] as? String ?? "no seller name"
        self.text = dictionary["text"] as? String ?? "no comment text"
    }
}
