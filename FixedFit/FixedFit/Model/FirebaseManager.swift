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
    case unableToRetrieveData
    case unableToUploadCloset
    case unableToFetchUserInformation

    var localizedDescription: String {
        switch self {
        case .usernameInUse: return "Username in use"
        case .unableToSignOut: return "Unable to signout"
        case .unableToRetrieveData: return "Unable to retrieve data"
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

enum FirebaseKeys: String {
    // User
    case users = "users"
    case firstName = "firstName"
    case lastName = "lastName"
    case username = "username"
    // Closet
    case closet = "closet"
    case items = "items"
    case category = "category"
    case subcategory = "subcategory"
    case uniqueID = "uniqueID"
    case url = "url"
    case categories = "categories"
    // Filters
    case filters = "filters"
    // Outfits
    case outfits = "outfits"
}

//structs for UserFinder title and mode
struct FirebaseUserFinderTitle{
    static let blocked = "Blocked Users"
    static let search = "Search for Users"
    static let follower = "Followers"
    static let following = "Following"
}
struct FirebaseUserFinderMode{
    static let blocked = "blocked"
    static let search = "search"
    static let follower = "follower"
    static let following = "following"
}

//struct for Support title and mode combined
struct FirebaseSupportVCTitleAndMode{
    static let helpCenter = "Help Center(FAQ)"
    static let contactUs = "Contact Us"
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
            completion?(user, error)
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

                        self?.ref.child(.users).child(user.uid).setValue(firstLoginData)
                    }

                    completion(user, error)
                }
            }
        }
    }

    func checkUsername(_ newUsername: String, completion: @escaping (Error?) -> Void) {
        ref.child(.users).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }

            if let allUsersInfo = snapshot.value as? [String: [String: Any]] {
                if strongSelf.checkUsername(newUsername, in: allUsersInfo) {
                    completion(nil)
                } else {
                    completion(FirebaseError.usernameInUse)
                }
            } else {
                completion(FirebaseError.unableToRetrieveData)
            }
        }, withCancel: {(_) in
            completion(FirebaseError.unableToRetrieveData)
        })
    }

    func logout(completion: (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            notificationCenter.post(name: .authStatusChanged, object: nil)
            completion(nil)
        } catch {
            print(FirebaseError.unableToSignOut.localizedDescription)
            completion(FirebaseError.unableToSignOut)
        }
    }
    
    // MARK: - Fetch methods

    func fetchUserInfo(completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let currentUser = currentUser else { return }

        ref.child(.users).child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userInfo = snapshot.value as? [String: Any] {
                completion(userInfo, nil)
            }
        }) { (error) in
            print(error.localizedDescription)
            completion(nil, error)
        }
    }

    func fetchCloset(completion: @escaping ([String: Any]?, Error?) -> Void) {
        func fetchCloset(username: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
            ref.child(username).child(.closet).observeSingleEvent(of: .value, with: { (snapshot) in
                if let closetItems = snapshot.value as? [String: Any] {
                    completion(closetItems, nil)
                } else {
                    completion([:], nil)
                }
            }) { (error) in
                completion(nil, error)
            }
        }

        guard let _ = currentUser else { return }

        if userStuffManager.username.isEmpty == true {
            fetchUserInfo { (userInfo, error) in
                if let username = userInfo?[FirebaseKeys.username.rawValue] as? String {
                    fetchCloset(username: username, completion: completion)
                } else {
                    completion(nil, FirebaseError.unableToRetrieveData)
                }
            }
        } else {
            fetchCloset(username: userStuffManager.username, completion: completion)
        }
    }

    func fetchImage(storageURL: String, completion: @escaping (UIImage?, Error?) -> Void) {
        storageRef.child(storageURL).getData(maxSize: 3 * 1024 * 1024) { (data, error) in
            if let data = data,
                let image = UIImage(data: data) {
                completion(image, nil)
            } else {
                print(error?.localizedDescription ?? "")
                completion(nil, error)
            }
        }
    }

    // MARK: - Upload methods

    func uploadClosetItems(_ itemCategoriesDict: [UIImage: CategorySubcategory], completion: @escaping (Error?) -> Void) {
        guard let _ = currentUser else { return }

        var itemInfos: [[String: Any]] = []
        var itemCategories: [String] = []

        for (index, itemCategoryDict) in itemCategoriesDict.enumerated() {
            let itemImage = itemCategoryDict.key
            let itemCategoryInfo = itemCategoryDict.value
            let category = itemCategoryInfo.category!
            let imageUniqueID = uniqueID()
            let newItemStoragePath = storageImageURLReference(uniqueID: imageUniqueID) ?? ""

            // Save images to storage
            if let resizedImage = itemImage.resized(toWidth: 700), let imageData = UIImagePNGRepresentation(resizedImage) {
                // Use the index to see if im saving the last image in the dictionary, because then I call the completion method
                if index + 1 == itemCategoriesDict.count {
                    saveItemImage(path: newItemStoragePath, imageData: imageData, completion: { (error) in
                        if let error = error {
                            print(error.localizedDescription)
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

            // Save closet item info to database
            var itemDict = [FirebaseKeys.category.rawValue: category, FirebaseKeys.url.rawValue: newItemStoragePath, FirebaseKeys.uniqueID.rawValue: imageUniqueID]

            if let subcategory = itemCategoryInfo.subcategory {
                itemDict[FirebaseKeys.subcategory.rawValue] = subcategory
            }

            itemInfos.append(itemDict)
            itemCategories.append(category)
        }

        saveClosetItems(newItems: itemInfos)
        saveNewCategories(categories: itemCategories)
    }

    private func saveItemImage(path: String, imageData: Data, completion: ((Error?) -> Void)?) {
        storageRef.child(path).putData(imageData, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                completion?(error)
            } else {
                completion?(nil)
            }
        })
    }

    private func saveClosetItems(newItems: [[String: Any]]) {
        newItems.forEach({ (newItemInfo) in
            let itemUniqueID = newItemInfo[FirebaseKeys.uniqueID.rawValue] as? String

            ref.child(userStuffManager.username).child(.closet).child(.items).child(itemUniqueID ?? "").setValue(newItemInfo)
        })
    }

    private func saveNewCategories(categories: [String]) {
        ref.child(userStuffManager.username).child(.closet).child(.categories).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }

            if var foundCategories = snapshot.value as? [String] {
                for category in categories {
                    if !foundCategories.contains(category) {
                        foundCategories.append(category)
                    }
                }

                strongSelf.ref.child(strongSelf.userStuffManager.username).child(.closet).child(.categories).setValue(foundCategories)
            } else {
                strongSelf.ref.child(strongSelf.userStuffManager.username).child(.closet).child(.categories).setValue(categories)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    func saveSubcategoryFilter(subcategoryFilter: String, category: String) {
        ref.child(userStuffManager.username).child(.closet).child(.filters).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }

            if var filtersDict = snapshot.value as? [String: String] {
                filtersDict[category] = subcategoryFilter
                strongSelf.ref.child(strongSelf.userStuffManager.username).child(.closet).child(.filters).setValue(filtersDict)
            } else {
                strongSelf.ref.child(strongSelf.userStuffManager.username).child(.closet).child(.filters).setValue([category: subcategoryFilter])
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    func saveOutfit(outfitItems: [ClosetItem], completion: @escaping (Error?) -> Void) {
        var outfitItemsInfos: [[String: String]] = []
        let outfitUniqueID = uniqueID()

        outfitItems.forEach { (closetItem) in
            let closetItemInfo = [FirebaseKeys.uniqueID.rawValue: closetItem.uniqueID]

            outfitItemsInfos.append(closetItemInfo)
        }
        
        ref.child(userStuffManager.username).child(.closet).child(.outfits).child(outfitUniqueID).child(.items).setValue(outfitItemsInfos) { (error, _) in
            if let error = error {
                print(error.localizedDescription)
            }

            completion(error)
        }
    }

    //Function needed for reauthentication of user
    //User should already be prompted with email/username and password
    func reautheticateUser(currentUserEmail: String, currentUserPassword: String) -> Int{
        guard let user = currentUser else {return 0}
        var credential: AuthCredential
        var returnVal:Int!

        // Determine if either user input and password is filled correctly
        if(currentUserEmail == "" || currentUserPassword == ""){
            returnVal = -1
        } else if(currentUserEmail != user.email){
            returnVal = -2
        }

        //Accept sing-in credentials
        credential = EmailAuthProvider.credential(withEmail: currentUserEmail, password: currentUserPassword)

        //Attempt to reauthenticate user
        user.reauthenticate(with: credential) { (error) in
            if error != nil {
                // An error happened.
                print("reauthentication failed")
                returnVal = 0
            } else {
                // User re-authenticated.
                print("User re-authenticated")
                returnVal = 1
            }
        }

        return returnVal

    }


    //Function used to modify user's email, password, and manage deletion of user account
    //When function returns 1, it means that the particular operation was a success.
    func manageUserAccount(commandString: String, updateString: String) -> Int?{
        guard let user = currentUser else {return 0}

        //Integer value used to represent error codes for calling funciton
        var returnVal:Int!

        if(commandString == "change email" && updateString != ""){

            //update email
            user.updateEmail(to: updateString) { (error) in
                if error != nil{
                    //An error occured
                    print("Failed to update email")
                    returnVal = 0
                } else {
                    //Email successfully updated
                    returnVal = 1
                }
            }

        } else if(commandString == "change password" && updateString != ""){

            //update password
            user.updatePassword(to: updateString) { (error) in
                if error != nil{
                    //An error occured
                    print("Failed to update email")
                    returnVal = 0
                } else {
                    //Password successfully updated
                    returnVal = 1
                }
            }

        } else if(commandString == "delete account"){

            //delete user's account
            user.delete { (error) in
                if error != nil{
                    //An error occured
                    print("Failed to update email")
                    returnVal = 0
                } else {
                    //Account Deleted
                    returnVal = 1
                    self.notificationCenter.post(name: .authStatusChanged, object: nil)
                }
            }

        } else {
            //No other user modification needed so it will just be ignored and return
            returnVal = 0
        }
        return returnVal
    }

    // MARK: - Helper methods

    private func createfirstLoginData(user: User, signUpInfo: SignUpInfo) -> [String: Any] {
        return [FirebaseKeys.username.rawValue: signUpInfo.username, FirebaseKeys.firstName.rawValue: signUpInfo.firstName, FirebaseKeys.lastName.rawValue: signUpInfo.lastName]
    }

    private func checkUsername(_ username: String, in allUsersInfo: [String: [String: Any]]) -> Bool {
        for (_ , userInfo) in allUsersInfo {
            if let takenUsername = userInfo[FirebaseKeys.username.rawValue] as? String {
                if takenUsername == username {
                    return false
                }
            }
        }

        return true
    }

    private func uniqueID() -> String {
        let fullRandomIDReference = ref.childByAutoId().description()
        let uniqueID = fullRandomIDReference.replacingOccurrences(of: "https://testfixedfit.firebaseio.com/", with: "")

        return uniqueID
    }

    func storageImageURLReference(uniqueID: String? = nil) -> String? {
        guard let _ = currentUser else { return nil }

        if let uniqueID = uniqueID {
            let fullStorageReference = storageRef.child(userStuffManager.username).child(.closet).child(uniqueID).description
            let referenceNeeded = fullStorageReference.replacingOccurrences(of: "gs://testfixedfit.appspot.com/", with: "")

            return referenceNeeded
        } else {
            let fullStorageReference = storageRef.child(userStuffManager.username).child(.closet).child(self.uniqueID()).description
            let referenceNeeded = fullStorageReference.replacingOccurrences(of: "gs://testfixedfit.appspot.com/", with: "")

            return referenceNeeded
        }
    }
}
