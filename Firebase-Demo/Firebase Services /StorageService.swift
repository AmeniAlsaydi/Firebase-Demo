//
//  StorageService.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageService {
    
    // in our app we will be uploading a photo in 2 places
    // 1. profile vc
    // 2. create item VC
    
    // we will be creating 2 different buckets of folders
    // 1. UserProfilePhotos
    // 2. ItemsPhotos
    
    // our signature will be taking in a userID or an itemID
    
    // lets create a reference to the Firebase storage
    
    private let storageRef = Storage.storage().reference()
    
    //default parameters in swift allow the function to be called with either, the other will be nil
    
    // image -> resize selected image (for storage purposes) -> convert to data -> pass to firebase (uploadData)
    // get download url and attach it to photo
    
    public func uploadPhoto(userId: String? = nil, itemId: String? = nil, image: UIImage, completion: @escaping (Result <URL, Error>) -> ()) {
        // 1. convert UIimage to data because this is the object we are posting to firebase storage
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return
        } // we have image data
        
        // we need to establish which collection we will be saving the photo too
        
        // create reference
        var photoReference: StorageReference!
        
        if let userId = userId { // coming from profile VC
            photoReference = storageRef.child("UserProfilePhotos/\(userId).jpg") // similar to an append, creating a sub folder in that specific reference
        } else if let itemId = itemId {
             photoReference = storageRef.child("ItemsPhotos/\(itemId).jpg")
        }
        
        
        // configure meta data for the object being uploaded
        // meta = attributes of the data
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg" // MIME type (multimedia type)
        
        
        // add to firebase storage and download its url
        
        let _ = photoReference.putData(imageData, metadata: metadata) { (metadata, error) in
            // metadata wil have the image url from firebase
            
            if let error = error {
                completion(.failure(error))
            } else if let  _ = metadata {
                photoReference.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                    }
                }
            }
        }
        
    }
}
