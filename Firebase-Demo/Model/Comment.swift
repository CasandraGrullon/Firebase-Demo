//
//  Comment.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/9/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import Firebase

struct Comment {
    let commentText: String
    let commentedBy: String
    let createdDate: Timestamp
    let commenterPhoto: String
    let itemId: String
    let itemName: String
    let sellerName: String
}
extension Comment {
    init(_ dictionary: [String: Any]) {
        self.commentText = dictionary["commentText"] as? String ?? "no comment text"
        self.commentedBy = dictionary["commentedBy"] as? String ?? "no commenter name"
        self.createdDate = dictionary["createdDate"] as? Timestamp ?? Timestamp(date: Date())
        self.commenterPhoto = dictionary["commenterPhoto"] as? String ?? "no photo url"
        self.itemId = dictionary["itemId"] as? String ?? "no item id"
        self.itemName = dictionary["itemName"] as? String ?? "no item name"
        self.sellerName = dictionary["sellerName"] as? String ?? "no seller name"
    }
}
