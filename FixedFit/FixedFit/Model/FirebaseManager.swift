//
//  FirebaseManager.swift
//  GoalSetter
//
//  Created by Amanuel Ketebo on 9/3/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

enum FirebaseLogoutError: String {
    case unableToSignOut = "Unable to signout"
}

class FirebaseManager {
    static let shared = FirebaseManager()

    private var ref: DatabaseReference {
        return Database.database().reference()
    }
    
    private var storageRef: StorageReference {
        return Storage.storage().reference()
    }

    private var currentUser: User? {
        return Auth.auth().currentUser
    }

    let notificationCenter = NotificationCenter.default

    // MARK: - Auth methods
    func login(nshi: String, password: String, completion: ((User?, Error?) -> Void)?) {
        Auth.auth().signIn(withEmail: nshi, password: password) { (user, error) in
            guard let completion = completion else { return }
            completion(user, error)
        }
    }

    func logout(completion: (FirebaseLogoutError?) -> Void) {
        do {
            try Auth.auth().signOut()
            print("SIGNED OUT!")
            notificationCenter.post(name: .authStatusChanged, object: nil)
            completion(nil)
        } catch {
            print("Errro!")
            completion(FirebaseLogoutError.unableToSignOut)
        }
    }
}
