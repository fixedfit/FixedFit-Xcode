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
    case unableToUploadCloset
    case unableToFetchUserInformation

    var localizedDescription: String {
        switch self {
        case .usernameInUse: return "Username in use"
        case .unableToSignOut: return "Unable to signout"
        case .unableToUploadCloset: return "Unable to upload closet"
        case .unableToFetchUserInformation: return "Unable to fetch user information"
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
    static let category = "category"
    static let uniqueID = "uniqueID"
    static let url = "url"
    static let categories = "categories"
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

    func fetchCloset(completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let _ = currentUser else { return }

        if userStuffManager.username.isEmpty {
            userStuffManager.fetchUserInformation(completion: { [weak self] (error) in
                guard let strongSelf = self else { return }

                if let _ = error {
                    completion(nil, FirebaseError.unableToFetchUserInformation)
                } else {
                    strongSelf.ref.child(strongSelf.userStuffManager.username).child(FirebaseKeys.closet).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let closetItems = snapshot.value as? [String: Any] {
                            completion(closetItems, nil)
                        } else {
                            completion([:], nil)
                        }
                    }) { (error) in
                        completion(nil, error)
                    }
                }
            })
        } else {
            ref.child(userStuffManager.username).child(FirebaseKeys.closet).observeSingleEvent(of: .value, with: { (snapshot) in
                if let closetItems = snapshot.value as? [String: Any] {
                    completion(closetItems, nil)
                } else {
                    completion([:], nil)
                }
            }) { (error) in
                completion(nil, error)
            }
        }
    }

    func fetchCategories(for username: String, completion: @escaping (Set<String>?, Error?) -> Void) {
        guard let _ = currentUser else { return }

        ref.child(userStuffManager.username).child(FirebaseKeys.closet).child(FirebaseKeys.categories).observeSingleEvent(of: .value, with: { (snasphot) in
            if let foundcategories = snasphot.value as? [String] {
                completion(Set(foundcategories), nil)
            } else {
                completion(Set<String>(), nil)
            }
        }) { (error) in
            completion(nil, error)
        }
    }

    func fetchImage(storageURL: String, completion: @escaping (UIImage?, Error?) -> Void) {
        storageRef.child(storageURL).getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let data = data,
                let image = UIImage(data: data) {
                completion(image, nil)
            } else {
                completion(nil, error)
            }
        }
    }

    // MARK: - Upload methods

    func uploadClosetItems(_ itemCategoriesDict: [UIImage: String], completion: @escaping (Error?) -> Void) {
        guard let _ = currentUser else { return }

        var itemInfos: [[String: Any]] = []
        var itemCategories: [String] = []

        for (index, itemcategoryDict) in itemCategoriesDict.enumerated() {
            let itemImage = itemcategoryDict.key
            let itemcategory = itemcategoryDict.value
            let imageUniqueID = uniqueID()
            let newItemStoragePath = storageImageURLReference(uniqueID: imageUniqueID) ?? ""

            if let resizedImage = itemImage.resized(toWidth: 700), let imageData = UIImagePNGRepresentation(resizedImage) {
                if index + 1 == itemCategoriesDict.count {
                    saveItemImage(path: newItemStoragePath, imageData: imageData, completion: { (error) in
                        if let error = error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    })
                } else {
                    saveItemImage(path: newItemStoragePath, imageData: imageData, completion: nil)
                }
            } else {
                completion(FirebaseError.unableToUploadCloset)
            }

            itemInfos.append([FirebaseKeys.category: itemcategory, FirebaseKeys.url: newItemStoragePath, FirebaseKeys.uniqueID: imageUniqueID])
            itemCategories.append(itemcategory)
        }

        saveClosetItems(newItems: itemInfos)
        saveNewCategories(categories: itemCategories)
    }

    private func saveItemImage(path: String, imageData: Data, completion: ((Error?) -> Void)?) {
        storageRef.child(path).putData(imageData, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                if let completion = completion {
                    completion(error)
                }
            } else {
                if let completion = completion {
                    completion(nil)
                }
            }
        })
    }

    private func saveClosetItems(newItems: [[String: Any]]) {
        ref.child(userStuffManager.username).child(FirebaseKeys.closet).child(FirebaseKeys.items).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
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

    private func saveNewCategories(categories: [String]) {
        ref.child(userStuffManager.username).child(FirebaseKeys.closet).child(FirebaseKeys.categories).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }

            if var foundCategories = snapshot.value as? [String] {
                for category in categories {
                    if !foundCategories.contains(category) {
                        foundCategories.append(category)
                    }
                }

                strongSelf.ref.child(strongSelf.userStuffManager.username).child(FirebaseKeys.closet).child(FirebaseKeys.categories).setValue(foundCategories)
            } else {
                strongSelf.ref.child(strongSelf.userStuffManager.username).child(FirebaseKeys.closet).child(FirebaseKeys.categories).setValue(categories)
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
