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
    let price: Double
    let imageURL: String
    let favoritedDate: Timestamp
    let seller: String
    let sellerId: String
}
extension Favorite {
    //failable initializer
    //all properties need to exist for the object to be created
    //if something is nil, Favorite will not be created
    init?(_ dictionary: [String : Any] ) {
        guard let itemName = dictionary["itemName"] as? String,
            let price = dictionary["price"] as? Double,
            let imageURL = dictionary["imageURL"] as? String,
            let favoritedDate = dictionary["favoritedDate"] as? Timestamp,
            let seller = dictionary["seller"] as? String,
            let sellerId = dictionary["sellerId"] as? String else {
                return nil
            }
        self.itemName = itemName
        self.price = price
        self.imageURL = imageURL
        self.favoritedDate = favoritedDate
        self.seller = seller
        self.sellerId = sellerId
    }
}
