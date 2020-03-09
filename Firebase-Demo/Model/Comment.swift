//
//  Comment.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/9/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

struct Comment {
    let username: String
    let userId: String
    let itemId: String
    let comment: String
    let datePosted: Date
}
extension Comment {
    init(_ dictionary: [String: Any]) {
        self.username = dictionary["username"] as? String ?? "no username"
        self.userId = dictionary["price"] as? String ?? "no user id"
        self.itemId = dictionary["itemID"] as? String ?? "no item id"
        self.comment = dictionary["comment"] as? String ?? "no comment"
        self.datePosted = dictionary["datePosted"] as? Date ?? Date()
    }
}
