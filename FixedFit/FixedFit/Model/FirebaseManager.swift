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

enum FirebaseError: Error {
    case usernameInUse
    case unableToSignOut

    var localizedDescription: String {
        switch self {
        case .usernameInUse: return "Username in use"
        case .unableToSignOut: return "Unable to signout"
        }
    }
}

struct SignUpInfo {
    let firstName: String
    let lastName: String
    let email: String
    let username: String
    let password: String

    init(firstName: String, lastName: String, email: String, username: String, password: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.username = username
        self.password = password
    }
}

struct FirebaseKeys {
    static let users = "users"
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let username = "username"
    static let closet = "closet"
    static let items = "items"
    static let tag = "tag"
    static let url = "url"
    static let tags = "tags"
}

class FirebaseManager {
    static let shared = FirebaseManager()

    var ref: DatabaseReference {
        return Database.database().reference()
    }
    var storageRef: StorageReference {
        return Storage.storage().reference()
    }
    private var currentUser: User? {
        return Auth.auth().currentUser
    }

    let userStuffManager = UserStuffManager.shared
    let notificationCenter = NotificationCenter.default

    // MARK: - Auth methods

    func login(email: String, password: String, completion: AuthResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard let completion = completion else { return }

            completion(user, error)
        }
    }

    func signUp(_ signUpInfo: SignUpInfo, completion: @escaping AuthResultCallback) {
        checkUsername(signUpInfo.username) { [weak self] (firebaseError) in
            if firebaseError != nil {
                completion(nil, FirebaseError.usernameInUse)
            } else {
                Auth.auth().createUser(withEmail: signUpInfo.email, password: signUpInfo.password) { [weak self] (user, error) in
                    if let user = user {
                        let firstLoginData = self?.createfirstLoginData(user: user, signUpInfo: signUpInfo)

                        self?.ref.child(FirebaseKeys.users).child(user.uid).setValue(firstLoginData)
                    }

                    completion(user, error)
                }
            }
        }
    }

    func checkUsername(_ newUsername: String, completion: @escaping (FirebaseError?) -> Void) {
        ref.child(FirebaseKeys.users).observeSingleEvent(of: .value, with: { (snapshot) in
            if let allUsersInfo = snapshot.value as? [String: [String: Any]] {
                var goodNewUsername = true

                for (_, userInfo) in allUsersInfo {
                    if let takenUsername = userInfo[FirebaseKeys.username] as? String {
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

    func logout(completion: (FirebaseError?) -> Void) {
        do {
            try Auth.auth().signOut()
            notificationCenter.post(name: .authStatusChanged, object: nil)
            completion(nil)
        } catch {
            completion(FirebaseError.unableToSignOut)
        }
    }
    
    // MARK: - Fetch methods

    func fetchUserInfo(completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let currentUser = currentUser else { return }

        ref.child(FirebaseKeys.users).child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userInfo = snapshot.value as? [String: Any] {
                completion(userInfo, nil)
            }
        }) { (error) in
            completion(nil, error)
        }
    }

    func fetchCloset(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        guard let _ = currentUser else { return }
        
        ref.child(userStuffManager.username).child(FirebaseKeys.closet).child(FirebaseKeys.items).observeSingleEvent(of: .value, with: { (snapshot) in
            if let closetItems = snapshot.value as? [[String: Any]] {
                completion(closetItems, nil)
            }
        }) { (error) in
            completion(nil, error)
        }
    }

    func fetchTags(for username: String, completion: @escaping (Set<String>?, Error?) -> Void) {
        guard let _ = currentUser else { return }

        ref.child(userStuffManager.username).child(FirebaseKeys.closet).child(FirebaseKeys.tags).observeSingleEvent(of: .value, with: { (snasphot) in
            if let foundTags = snasphot.value as? [String] {
                completion(Set(foundTags), nil)
            } else {
                completion(Set<String>(), nil)
            }
        }) { (error) in
            completion(nil, error)
        }
    }

    // MARK: - Upload methods

    func uploadClosetItems(_ itemTagsDict: [UIImage: String]) {
        guard let _ = currentUser else { return }

        var itemInfos: [[String: Any]] = []
        var itemTags: [String] = []

        for itemTagDict in itemTagsDict {
            let itemImage = itemTagDict.key
            let itemTag = itemTagDict.value
            let newItemStoragePath = storageImageURLReference() ?? ""

            if let resizedImage = itemImage.resized(toWidth: 700), let imageData = UIImagePNGRepresentation(resizedImage) {
                saveItemImage(path: newItemStoragePath, imageData: imageData)
            }

            itemInfos.append([FirebaseKeys.tag: itemTag, FirebaseKeys.url: newItemStoragePath])
            itemTags.append(itemTag)
        }

        saveClosetItems(newItems: itemInfos)
        saveNewTags(tags: itemTags)
    }

    private func saveItemImage(path: String, imageData: Data) {
        storageRef.child(path).putData(imageData, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }

    private func saveClosetItems(newItems: [[String: Any]]) {
        ref.child(userStuffManager.username).child(FirebaseKeys.closet).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }

            if var closetArray = snapshot.value as? [[String: Any]] {
                closetArray.append(contentsOf: newItems)
                strongSelf.ref.child(strongSelf.userStuffManager.username).child(FirebaseKeys.closet).child(FirebaseKeys.items).setValue(closetArray)
            } else {
                strongSelf.ref.child(strongSelf.userStuffManager.username).child(FirebaseKeys.closet).child(FirebaseKeys.items).setValue(newItems)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    private func saveNewTags(tags: [String]) {
        ref.child(userStuffManager.username).child(FirebaseKeys.tags).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }

            if var foundTags = snapshot.value as? [String] {
                for tag in tags {
                    if !foundTags.contains(tag) {
                        foundTags.append(tag)
                    }
                }

                strongSelf.ref.child(strongSelf.userStuffManager.username).child(FirebaseKeys.closet).child(FirebaseKeys.tags).setValue(foundTags)
            } else {
                strongSelf.ref.child(strongSelf.userStuffManager.username).child(FirebaseKeys.closet).child(FirebaseKeys.tags).setValue(tags)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    // MARK: - Helper methods

    private func createfirstLoginData(user: User, signUpInfo: SignUpInfo) -> [String: Any] {
        return [FirebaseKeys.username: signUpInfo.username, FirebaseKeys.firstName: signUpInfo.firstName, FirebaseKeys.lastName: signUpInfo.lastName]
    }

    private func uniqueID() -> String {
        let fullRandomIDReference = ref.childByAutoId().description()
        let uniqueID = fullRandomIDReference.replacingOccurrences(of: "https://testfixedfit.firebaseio.com/", with: "")

        return uniqueID
    }

    func storageImageURLReference(uniqueID: String? = nil) -> String? {
        guard let _ = currentUser else { return nil }

        if let uniqueID = uniqueID {
            let fullStorageReference = storageRef.child(userStuffManager.username).child(FirebaseKeys.closet).child(uniqueID).description
            let referenceNeeded = fullStorageReference.replacingOccurrences(of: "gs://testfixedfit.appspot.com/", with: "")

            return referenceNeeded
        } else {
            let fullStorageReference = storageRef.child(userStuffManager.username).child(FirebaseKeys.closet).child(self.uniqueID()).description
            let referenceNeeded = fullStorageReference.replacingOccurrences(of: "gs://testfixedfit.appspot.com/", with: "")

            return referenceNeeded
        }
    }
}
