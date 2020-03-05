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
    // lets get a reference to thee firebase firestore database
    
    private let db = Firestore.firestore() // top level of our database
    
    public func createItem(name: String, price: Double, category: Category, displayName: String, completion: @escaping (Result<String, Error>) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        
        // generate a document
        
        let documentRef = db.collection(DatabaseService.itemsCollection).document() // returns a document reference with an auto generated id
        
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
}
