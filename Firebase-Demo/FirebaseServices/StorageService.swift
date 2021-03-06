//
//  StorageService.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageService {
    //uploading photo to storage in two places:
    //1. ProfileViewController (profile pic)
    //2. CreateItemVC (item's photo)
    
    //storage in two "buckets":
    //1. UserProfilePictures/
    //2. ItemPhotos/
    
    //Storage steps
    //1. need reference to firebase storage
    private let storageRef = Storage.storage().reference()
    
    //default parameters in swift ex: userId: String? = nil
    public func uploadPhoto(userId: String? = nil, itemId: String? = nil, image: UIImage, completion: @escaping (Result<URL, Error>) -> ()) {
        
        //1. get an image from user
        //2. resize the image
        //3. convert image to data
        //4. upload data to storage
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        //establish which storage bucket where the photo will be saved to
        //photoReference is like jsondecoder. we can get upload and download our objects
        var photoReference: StorageReference!
        
        if let userId = userId { //coming from ProfileVC
            photoReference = storageRef.child("UserProfilePhotos/\(userId).jpg")
        } else if let itemId = itemId { //coming from CreateItemVC
            photoReference = storageRef.child("ItemsPhotos/\(itemId).jpg")
        }
        
        //configure metadata for the object being uploaded
        let metadata = StorageMetadata()
        //mim type
        metadata.contentType = "image/jpg"
        
        let _ = photoReference.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else if let _ = metadata {
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
