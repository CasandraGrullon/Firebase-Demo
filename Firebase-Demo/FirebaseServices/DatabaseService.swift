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
    
    //firebasefirestore looks like : collection -> document -> collection -> document ...etc
    
    static let itemsCollection = "items"
    static let usersCollection = "users"
    static let commentsColletion = "comments" //subcollection for items document
    static let favoritesCollection = "favorites"
    
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
    
    public func createDatabaseUser(authDataResult: AuthDataResult, completion: @escaping (Result<Bool, Error>) -> () ) {
        
        guard let email = authDataResult.user.email else {
            return
        }
        
        //giving the document id the user's id
        db.collection(DatabaseService.usersCollection).document(authDataResult.user.uid).setData(["email": email, "createdDate": Timestamp(date: Date()), "userId": authDataResult.user.uid]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    public func updateDatabaseUser(displayName: String, photoURL: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        db.collection(DatabaseService.usersCollection).document(user.uid).updateData(["displayName": displayName, "photoURL": photoURL]) { (error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
        
        
    }
    
    public func deleteItem(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        db.collection(DatabaseService.itemsCollection).document(item.itemId).delete { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    //creating a subcollection in items collection
    public func postComment(item: Item, comment: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser,
            let displayName = user.displayName else {
                print("missing user data")
            return
        }
        //we are adding onto our items collection
        let docRef = db.collection(DatabaseService.itemsCollection).document(item.itemId).collection(DatabaseService.commentsColletion).document()
        db.collection(DatabaseService.itemsCollection).document(item.itemId).collection(DatabaseService.commentsColletion).document(docRef.documentID).setData(["commentText": comment, "createdDate": Timestamp(date: Date()), "itemName": item.itemName, "itemId": item.itemId, "sellerName": item.sellerName, "commentedBy": displayName]) { (error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }

    public func addToFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser else { return }
        db.collection(DatabaseService.usersCollection).document(user.uid).collection(DatabaseService.favoritesCollection).document(item.itemId).setData(["itemName": item.itemName, "price": item.price, "imageURL": item.imageURL, "favoritedDate": Timestamp(date: Date()), "itemId": item.itemId, "seller": item.sellerName, "sellerId": item.sellerId]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
        
    }
    
    public func removeFromFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> () ) {
        guard let user = Auth.auth().currentUser else { return }
        db.collection(DatabaseService.usersCollection).document(user.uid).collection(DatabaseService.favoritesCollection).document(item.itemId).delete { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func isItemInFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> () ) {
        
        guard let user = Auth.auth().currentUser else { return }
        
        //whereField --> allows us to see if an item was already favorited
        //addSnapshotListener --> continues to listen for changes to a collection
        //getDocuments --> fetches documents ONLY ONCE!!!
        db.collection(DatabaseService.usersCollection).document(user.uid).collection(DatabaseService.favoritesCollection).whereField("itemId", isEqualTo: item.itemId).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let count = snapshot.documents.count //do we have documents??
                if count > 0 { //documents do exist ----> item was already favorited
                    completion(.success(true))
                } else { //documents do not exist ----> item hasn't been favorited before
                    completion(.success(false))
                }
            }
        }
        
    }
    public func fetchUserItems(userId: String, completion: @escaping (Result<[Item], Error>) -> () ) {
        //wherefield will filter the items on the database by those that match the user id
        db.collection(DatabaseService.itemsCollection).whereField(Constants.sellerId, isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let items = snapshot.documents.map {Item ($0.data())}
                completion(.success(items.sorted(by: {$0.listedDate.seconds > $1.listedDate.seconds})))
            }
        }
    }
    
    public func fetchFavorites(completion: @escaping(Result<[Favorite], Error>) -> ()) {
        //accessing the users collection -> document: userId -> favorites collection -> get documents
        guard let user = Auth.auth().currentUser else { return }
        db.collection(DatabaseService.usersCollection).document(user.uid).collection(DatabaseService.favoritesCollection).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot { //query snapshot is the data in our firebase storage
                let favorites = snapshot.documents.compactMap {Favorite ($0.data())} //because favorite has a failable initializer (init?() returns Favorite?), we need to use compactMap to remove all optional values
                completion(.success(favorites.sorted(by: {$0.favoritedDate.seconds > $1.favoritedDate.seconds})))
            }
        }
    }
}
