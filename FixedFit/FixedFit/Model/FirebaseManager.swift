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

enum FirebaseError: Error {
    case usernameInUse

    var localizedDescription: String {
        switch self {
        case .usernameInUse: return "Username in use"
        }
    }
}

enum DatabaseError: Error {
    case fetchingError
    case parsingError
    case noPlayersListener
    case invalidGameKey
    case missingUID
    case usernameInUse
    case couldNotLogout

    var localizedDescription: String {
        switch self {
        case .usernameInUse: return "Username in use"
        case .couldNotLogout: return "Could not logout"
        default: return ""
        }
    }
}

struct Nodes {
    static let users = ref.child("users")
}

fileprivate let ref = Database.database().reference()

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private var storageRef: StorageReference {
        return Storage.storage().reference()
    }

    private var currentUser: User? {
        return Auth.auth().currentUser
    }

    struct Nodes {
        static let users = ref.child("users")
    }

    let notificationCenter = NotificationCenter.default

    // MARK: - Auth methods
    func login(email: String, password: String, completion: AuthResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard let completion = completion else { return }
            completion(user, error)
        }
    }

    func signUp(firstName: String, lastName: String, email: String, username: String, password: String, completion: @escaping AuthResultCallback) {
        checkUsername(username) { (firebaseError) in
            if firebaseError != nil {

                completion(nil, FirebaseError.usernameInUse)
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
                    if let user = user {
                        let firstLoginData = self?.createfirstLoginData(user: user, username: username)
                        Nodes.users.child("\(user.uid)").setValue(firstLoginData)
                        
                        // following method is to add extra user details
                        //ref.child("users").child(user.uid).setValue(["Email": email, "Firstname": firstName, "Lastname": lastName])
                    }

                    completion(user, error)
                }

            }
        }
    }

    func checkUsername(_ newUsername: String, completion: @escaping (FirebaseError?) -> Void) {
        Nodes.users.observeSingleEvent(of: .value, with: {(snapshot) in
            if let allUsersInfo = snapshot.value as? [String: [String: Any]] {
                var goodNewUsername = true

                for (_, userInfo) in allUsersInfo {
                    if let takenUsername = userInfo["username"] as? String {
                        if takenUsername == newUsername {
                            goodNewUsername = false
                        }
                    }
                }

                if goodNewUsername {
                    completion(nil)
                } else {
                    completion(.usernameInUse)
                }

            } else {
                completion(nil)
            }
        })
    }

    func logout(completion: (FirebaseLogoutError?) -> Void) {
        do {
            try Auth.auth().signOut()
            notificationCenter.post(name: .authStatusChanged, object: nil)
            completion(nil)
        } catch {
            completion(FirebaseLogoutError.unableToSignOut)
        }
    }

    private func createfirstLoginData(user: User, username: String) -> [String: Any] {
        return ["username": username]
    }
}
