//
//  AuthenticationSession.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 2/28/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseAuth //https://firebase.google.com/docs/auth?authuser=0

class AuthenticationSession {
    // firebase deals with pw encryption
    public func createNewUser(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>)-> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if let error = error {
                completion(.failure(error))
            } else if let authDataResult = authDataResult {
                completion(.success(authDataResult))
            }
        }
        
    }
    
    public func signExisitingUser(email: String, password: String,  completion: @escaping (Result<AuthDataResult, Error>)-> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if let error = error {
                completion(.failure(error))
            } else if let authDataResult = authDataResult {
                completion(.success(authDataResult))
            }
        }
    }
    
    
}
