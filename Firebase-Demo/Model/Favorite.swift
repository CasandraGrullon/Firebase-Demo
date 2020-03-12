//
//  Favorite.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/12/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import Firebase

struct Favorite {
    let itemName: String
    let price: String
    let itemURL: String
    let favoritedDate: Timestamp
    let seller: String
    let sellerId: String
}
extension Favorite {
        init(_ dictionary: [String: Any]) {
        self.itemName = dictionary["itemName"] as? String ?? "no item name"
        self.price = dictionary["price"] as? String ?? "no price"
        self.itemURL = dictionary["itemURL"] as? String ?? "no item url"
        self.favoritedDate = dictionary["favoritedDate"] as? Timestamp ?? Timestamp(date: Date())
        self.seller = dictionary["seller"] as? String ?? "no seller name"
        self.sellerId = dictionary["sellerId"] as? String ?? "no seller id"
    }
}
