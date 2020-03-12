//
//  DatabaseService.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class DatabaseService {
    
    static let itemsCollection = "items" // collection - convention: collection name is lower cased
    static let userCollection = "users"
    static let commentCollection = "comments" // sub-collection on an item document
    static let favoritesCollection = "favorites" //  sub-collection on a user document
    
    // Review - firebase heiarchy works like this
    // top level
    // collection -> document -> collection -> document -> .....
    // lets get a reference to the firebase firestore database
    
    private let db = Firestore.firestore() // top level of our database
    
    public func createItem(name: String, price: Double, category: Category, displayName: String, completion: @escaping (Result<String, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        
        // generate a document
        
        let documentRef = db.collection(DatabaseService.itemsCollection).document() // returns a document reference with an auto generated id for items collections
        
        // create a document in our items collection
        
        /*
         struct Item {
         let name: String
         let price: Double
         let id: String // document id
         let listedDate: Date
         let sellerName: String
         let sellerId: String
         let categoryName: String
         }
         
         */
        
        db.collection(DatabaseService.itemsCollection).document(documentRef.documentID).setData(["name": name, "price": price, "id": documentRef.documentID, "listedDate": Timestamp(date: Date()), "sellerName": displayName, "sellerId": user.uid, "categoryName": category.name ]) { (error) in
            if let error = error {
                completion (.failure(error))
                print("error creating item: \(error)")
            } else {
                completion (.success(documentRef.documentID))
                print("item was created: \(documentRef.documentID)")
            }
        }
    }
    
    public func createDatabaseUser(authDataResult: AuthDataResult, completion: @escaping (Result<Bool, Error>)-> ()) {
        
        
        // within the user collection a document is created with the collection
        
        guard let email = authDataResult.user.email else {
            return
        }
        db.collection(DatabaseService.userCollection).document(authDataResult.user.uid).setData(["email": email, "createdDate": Timestamp(date: Date()), "userid": authDataResult.user.uid]) { error in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
            
        }
    }
    
    public func updateDatabaseUser(displayName: String, photoUrl: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        // document id is the same as the user id
        
        guard let user = Auth.auth().currentUser else { return }
        
        db.collection(DatabaseService.userCollection).document(user.uid).updateData(["photoUrl": photoUrl, "displayName": displayName]) { (error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
            
            
        }
    }
    
    public func delete(item: Item, completion: @escaping (Result<Bool, Error>) -> ()){
        db.collection(DatabaseService.itemsCollection).document(item.id).delete() { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
            
        }
    }
    
    public func postComment(item: Item, comment: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser, let displayname = user.displayName else {
            print("missing user data")
            return }
        let docRef = db.collection(DatabaseService.itemsCollection).document(item.id).collection(DatabaseService.commentCollection).document()
        // using document from above to write to its contents to firebase
        db.collection(DatabaseService.itemsCollection).document(item.id).collection(DatabaseService.commentCollection).document(docRef.documentID).setData(["text": comment, "commentDate": Timestamp(date: Date()), "itemName": item.name, "itemId": item.id, "sellerName": item.sellerName, "commentedBy": displayname]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
            
        }
    }
    
    public func addToFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user =  Auth.auth().currentUser else { return}
        
        db.collection(DatabaseService.userCollection).document(user.uid).collection(DatabaseService.favoritesCollection).document(item.id).setData(["itemName": item.name, "price": item.price, "imageURL": item.imageURL, "favoritedDate": Timestamp(date: Date()), "itemId": item.id, "sellerName": item.sellerName, "sellerId": item.sellerId]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func removeFromFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return}
        db.collection(DatabaseService.userCollection).document(user.uid).collection(DatabaseService.favoritesCollection).document(item.id).delete { (error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
            
        }
        
    }
    
    public func isItemInFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        guard let user = Auth.auth().currentUser else { return}
        
        // in firebase we use the "where" keyword to query the collection for a spe
        // addSnapshotListener: attach a listener to a collection when any changes happen changes are returned, continues to listen to changes to a colelction
        // get documents - fetches documents/document ONLY once - most apps use this and manually updates with a refresh controller.
        
        db.collection(DatabaseService.userCollection).document(user.uid).collection(DatabaseService.favoritesCollection).whereField("itemId", isEqualTo: item.id).getDocuments { (snapshot, error) in
            // whats behind the word snapshot -- firebase uses the word snap shot to represent the current state of the data
            
            if let error = error {
                 completion(.failure(error))
                
            } else if let snapshot = snapshot {
                if snapshot.documents.count > 0 {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            }
        }
    }
    
    public func fetchUsersItems(userId: String, completion: @escaping (Result<[Item], Error>) -> ()) {
       
        // filter items collection by user id
        // for cases of "sellerId" create a constant file and refer to them names from it rather than spelling it out
        // e.g. Constant.sellerId which would be equal to and return"sellerId"
        db.collection(DatabaseService.itemsCollection).whereField("sellerId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let items = snapshot.documents.map { Item($0.data()) }
                completion(.success(items))
            
        }
        
    }
}

}
