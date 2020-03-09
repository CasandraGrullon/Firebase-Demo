//
//  DatabaseService.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

private let db = Firestore.firestore() // reference to FirebaseFirestore database

class DatabaseService {
    
    static let itemsCollection = "items"
    static let commentsColletion = "comments"
    
    public func createItem(itemName: String, price: Double, category: Category, displayName: String, dateListed: String, completion: @escaping (Result<String, Error>) -> () ) {
        guard let user = Auth.auth().currentUser else { return }
        
        // generate a document reference for our collection
        let documentRef = db.collection(DatabaseService.itemsCollection).document()
        
        //create a document for our collection .document(documentPath: string)
        
        //firebase works with dictionaries --> key, value pairings
        //keys will be property names for Item object
        db.collection(DatabaseService.itemsCollection).document(documentRef.documentID).setData([ "itemName" : itemName, "price": price, "itemID": documentRef.documentID, "listedDate": Timestamp(date: Date()), "sellerName": displayName, "sellerId": user.uid, "categoryName": category.name]) { (error) in
            
            if let error = error {
                completion(.failure(error))
                print("creating item error \(error)")
            } else {
                completion(.success(documentRef.documentID))
            }
        }
    }
    
    public func createComment(username: String, userId: String, itemId: String, comment: String, completion: @escaping (Result<String, Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser else { return }
        let documentRef = db.collection(DatabaseService.commentsColletion).document()
        
        db.collection(DatabaseService.commentsColletion).document(documentRef.documentID).setData(["username": user.displayName ?? "no user name", "userId": user.uid, "itemID": itemId, "comment": comment, "datePosted": Date()]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(documentRef.documentID))
            }
        }
    }
}
