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
fileprivate let storageRef = Storage.storage().reference()

class FirebaseManager {
    static let shared = FirebaseManager()

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

    func signUp(email: String, username: String, password: String, completion: @escaping AuthResultCallback) {
        checkUsername(username) { (firebaseError) in
            if firebaseError != nil {

                completion(nil, FirebaseError.usernameInUse)
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
                    if let user = user {
                        let firstLoginData = self?.createfirstLoginData(user: user, username: username)
                        Nodes.users.child("\(user.uid)").setValue(firstLoginData)
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

    // MARK: Upload methods
    func upload(imageInfos: [UIImage: String]) {
        guard let currentUser = currentUser else { return }

        var firebaseData: [[String: Any]] = []

        for imageInfo in imageInfos {
            let image = imageInfo.key
            let tag = imageInfo.value
            let fullUniquePhotoID = ref.childByAutoId().description()
            let uniquePhotoID = fullUniquePhotoID.replacingOccurrences(of: "https://testfixedfit.firebaseio.com/", with: "")
            let photoURL = currentUser.uid + "/" + "closetPhotos" + "/" + uniquePhotoID

            firebaseData.append(["url": photoURL, "tag": tag])

            if let resizedImage = image.resized(toWidth: 700),
                let imageData = UIImagePNGRepresentation(resizedImage) {
                storageRef.child(photoURL).putData(imageData, metadata: nil)
            } else {
                print("Bro not good!")
            }
        }

        ref.child(currentUser.uid).child("closet").observeSingleEvent(of: .value) { (snapshot) in
            if var clothes = snapshot.value as? [[String: Any]] {
                clothes.append(contentsOf: firebaseData)
                ref.child(currentUser.uid).child("closet").setValue(clothes)
            } else {
                ref.child(currentUser.uid).child("closet").setValue(firebaseData)
            }
        }
    }
}
