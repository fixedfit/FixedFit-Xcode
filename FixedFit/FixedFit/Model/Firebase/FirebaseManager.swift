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
    static let tutorial = "Tutorials"
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
    var databaseURL = "https://testfixedfit3.firebaseio.com/"
    var storageURL = "gs://testfixedfit3.appspot.com"

    let notificationCenter = NotificationCenter.default

    // MARK: - Auth methods

    func login(email: String, password: String, completion: @escaping AuthResultCallback) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
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
                    print(FirebaseError.usernameInUse.localizedDescription)
                    completion(FirebaseError.usernameInUse)
                }
            } else {
                completion(nil)
            }
        }, withCancel: {(_) in
            print(FirebaseError.unableToRetrieveData.localizedDescription)
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
        guard let user = currentUser else { return }

        ref.child(.users).child(user.uid).child(.closet).observeSingleEvent(of: .value, with: { (snapshot) in
            if let closetItems = snapshot.value as? [String: Any] {
                completion(closetItems, nil)
            } else {
                completion([:], nil)
            }
        }) { (error) in
            print(error.localizedDescription)
            completion(nil, error)
        }
    }

    func fetchEvents(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        guard let user = currentUser else { return }

        ref.child(.users).child(user.uid).child(.events).observeSingleEvent(of: .value, with: { (snapshot) in
            if let eventsInfos = snapshot.value as? [[String: Any]] {
                completion(eventsInfos, nil)
            }
        }) { (error) in
            completion(nil, error)
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

    func fetchUsers(nameStartingWith: String, completion: @escaping ([UserInfo]?, Error?) -> Void) {
        guard let _ = currentUser else { return}

        ref.child(.users).queryOrdered(byChild: FirebaseKeys.username.rawValue).queryStarting(atValue: nameStartingWith)
            .queryEnding(atValue: nameStartingWith + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
                var usersInfos: [UserInfo] = []

                if let data = snapshot.value as? [String: Any] {
                    for userData in data.values {
                        if let json = userData as? [String: Any],
                            let userInfo = UserInfo(json: json) {
                            usersInfos.append(userInfo)
                        }
                    }
                }

                completion(usersInfos, nil)
            }) { (error) in
                print(error.localizedDescription)
                completion(nil, error)
        }
    }

    // MARK: - Upload methods

    func updateUserInfo(_ userInfo: UserInfo, completion: @escaping (Error?) -> Void) {
        guard let user = currentUser else { return }
        
        ////upload photo's url onto firebase storage by first checking if one already exists
        //Generate path for new image
        let imageUniqueID = uniqueID()
        let imagePath = storageProfilePhotoURLReference(uniqueID: imageUniqueID) ?? ""

        //Delete the previous user's photo if already stored
        if(!(userInfo.previousPhotoURL.isEmpty)){

            let photoRef = storageRef.child(userInfo.previousPhotoURL)
            //delete the user's profile photo
            photoRef.delete{ error in
                if error != nil{
                    //Error in deletion
                    print("Could not delete user profile image")
                } else {
                    //User storage deleted
                    print("Successfully deleted user profile image")
                }
            }
        }
        
        //Update the new user's photo into firebase
        if let resizedImage = userInfo.photo!.resized(toWidth: 100), let imageData = UIImagePNGRepresentation(resizedImage) {
            
            saveItemImage(path: imagePath, imageData: imageData, completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    completion(error)
                } else {
                    completion(nil)
                }
            })
        }
        print("Updating", userInfo.publicProfile)
        let userInfoDict = [FirebaseKeys.firstName.rawValue: userInfo.firstName,
                            FirebaseKeys.lastName.rawValue: userInfo.lastName,
                            FirebaseKeys.username.rawValue: userInfo.username,
                            FirebaseKeys.bio.rawValue: userInfo.bio,
                            FirebaseKeys.publicProfile.rawValue: userInfo.publicProfile,
                            FirebaseKeys.profileImageURL.rawValue: imagePath
            ] as [String : Any]

        ref.child(.users).child(user.uid).updateChildValues(userInfoDict) { (error, _) in
            if let error = error {
                print(error.localizedDescription)
                completion(error)
            }
        }
    }

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
            if let resizedImage = itemImage.resized(toWidth: 100), let imageData = UIImagePNGRepresentation(resizedImage) {
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
        guard let user = currentUser else { return }

        newItems.forEach({ (newItemInfo) in
            let itemUniqueID = newItemInfo[FirebaseKeys.uniqueID.rawValue] as? String

            ref.child(.users).child(user.uid).child(.closet).child(.items).child(itemUniqueID ?? "").setValue(newItemInfo)
        })
    }

    private func saveNewCategories(categories: [String]) {
        guard let user = currentUser else { return }

        ref.child(.users).child(user.uid).child(.closet).child(.categories).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }

            if var foundCategories = snapshot.value as? [String] {
                for category in categories {
                    if !foundCategories.contains(category) {
                        foundCategories.append(category)
                    }
                }

                strongSelf.ref.child(.users).child(user.uid).child(.closet).child(.categories).setValue(foundCategories)
            } else {
                strongSelf.ref.child(.users).child(user.uid).child(.closet).child(.categories).setValue(categories)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    func saveSubcategoryFilter(subcategoryFilter: String, category: String) {
        guard let user = currentUser else { return }

        ref.child(.users).child(user.uid).child(.closet).child(.filters).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }

            if var filtersDict = snapshot.value as? [String: String] {
                filtersDict[category] = subcategoryFilter
                strongSelf.ref.child(.users).child(user.uid).child(.closet).child(.filters).setValue(filtersDict)
            } else {
                strongSelf.ref.child(.users).child(user.uid).child(.closet).child(.filters).setValue([category: subcategoryFilter])
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    func saveOutfit(outfitItems: [ClosetItem], completion: @escaping (_ uniqueID: String?, _ error: Error?) -> Void) {
        guard let user = currentUser else { return }

        var newOutfit: [String: Any] = [:]
        var outfitItemsInfos: [[String: String]] = []
        let outfitUniqueID = uniqueID()

        outfitItems.forEach { (closetItem) in
            var closetItemInfo = [FirebaseKeys.uniqueID.rawValue: closetItem.uniqueID,
                                  FirebaseKeys.url.rawValue: closetItem.storagePath]

            if let category = closetItem.categorySubcategory.category {
                closetItemInfo[FirebaseKeys.category.rawValue] = category
            }

            if let subcategory = closetItem.categorySubcategory.subcategory {
                closetItemInfo[FirebaseKeys.subcategory.rawValue] = subcategory
            }


            outfitItemsInfos.append(closetItemInfo)
        }

        newOutfit[FirebaseKeys.items.rawValue] = outfitItemsInfos
        newOutfit[FirebaseKeys.uniqueID.rawValue] = outfitUniqueID
        ref.child(.users).child(user.uid).child(.closet).child(.outfits).child(outfitUniqueID).setValue(newOutfit) { (error, _) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
            } else {
                completion(outfitUniqueID, nil)
            }
        }
    }

    func saveEvent(date: Date, eventName: String, outfit: Outfit, completion: @escaping (Error?) -> Void) {
        guard let user = currentUser else { return }

        ref.child(.users).child(user.uid).child(.events).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }

            var eventDict: [String: Any] = [FirebaseKeys.date.rawValue: date.timeIntervalSince1970]
            var outfitDict: [String: Any] = [FirebaseKeys.uniqueID.rawValue: outfit.uniqueID]
            var outfitItemsInfos: [[String: String]] = []

            outfit.items.forEach { (closetItem) in
                var closetItemInfo = [FirebaseKeys.uniqueID.rawValue: closetItem.uniqueID,
                                      FirebaseKeys.url.rawValue: closetItem.storagePath]

                if let category = closetItem.categorySubcategory.category {
                    closetItemInfo[FirebaseKeys.category.rawValue] = category
                }

                if let subcategory = closetItem.categorySubcategory.subcategory {
                    closetItemInfo[FirebaseKeys.subcategory.rawValue] = subcategory
                }

                outfitItemsInfos.append(closetItemInfo)
            }

            outfitDict[FirebaseKeys.items.rawValue] = outfitItemsInfos
            eventDict[FirebaseKeys.outfit.rawValue] = outfitDict
            eventDict[FirebaseKeys.eventName.rawValue] = eventName

            if var events = snapshot.value as? [[String: Any]] {
                // Already have stuff stored
                events.append(eventDict)
                strongSelf.ref.child(.users).child(user.uid).child(.events).setValue(events, withCompletionBlock: { (error, _) in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                })
            } else {
                strongSelf.ref.child(.users).child(user.uid).child(.events).setValue([eventDict], withCompletionBlock: { (error, _) in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                })
            }
        }) { (error) in
            completion(error)
            print(error.localizedDescription)
        }
    }

    //Function needed for reauthentication of user
    //User should already be prompted with email/username and password
    func reautheticateUser(currentUserEmail: String, currentUserPassword: String, completion: @escaping (Int?)->Void){
        guard let user = currentUser else {return}
        var credential: AuthCredential
        var terminate = false

        // Determine if either user input and password is filled correctly
        if(currentUserEmail == "" || currentUserPassword == ""){
            completion(-1)
            terminate = true
        } else if(currentUserEmail != user.email){
            completion(-2)
            terminate = true
        }

        if(terminate == false){
            //Accept sing-in credentials
            credential = EmailAuthProvider.credential(withEmail: currentUserEmail, password: currentUserPassword)
            
            //Attempt to reauthenticate user
            user.reauthenticate(with: credential) { (error) in
                if error != nil {
                    // An error happened.
                    print("reauthentication failed")
                    completion(0)
                } else {
                    // User re-authenticated.
                    print("User re-authenticated")
                    completion(1)
                }
            }
        }
    }


    //Function used to modify user's email, password, and manage deletion of user account
    //When function returns 1, it means that the particular operation was a success.
    func manageUserAccount(commandString: String, updateString: String, completion: ((Error?) -> Void)?){
        guard let user = currentUser else {return}

        if(commandString == "change email" && updateString != ""){

            //update email
            user.updateEmail(to: updateString) { (error) in
                if error != nil{
                    //An error occured
                    print("Failed to update email")
                    completion?(error)
                } else {
                    //Email successfully updated
                    completion?(nil)
                }
            }

        } else if(commandString == "change password" && updateString != ""){

            //update password
            user.updatePassword(to: updateString) { (error) in
                if error != nil{
                    //An error occured
                    print("Failed to update password")
                    completion?(error)
                } else {
                    //Password successfully updated
                    completion?(nil)
                }
            }

        } else if(commandString == "delete account"){
            deleteAccount(user:user)
        }
    }

    // MARK: - Helper methods

    private func createfirstLoginData(user: User, signUpInfo: SignUpInfo) -> [String: Any] {
        return [
            FirebaseKeys.firstName.rawValue: signUpInfo.firstName,
            FirebaseKeys.lastName.rawValue: signUpInfo.lastName,
            FirebaseKeys.username.rawValue: signUpInfo.username,
            FirebaseKeys.publicProfile.rawValue: signUpInfo.publicProfile,
            FirebaseKeys.bio.rawValue: signUpInfo.bio,
            FirebaseKeys.profileImageURL.rawValue: ""
        ]
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
        let uniqueID = fullRandomIDReference.replacingOccurrences(of: databaseURL, with: "")

        return uniqueID
    }

    func storageImageURLReference(uniqueID: String? = nil) -> String? {
        guard let user = currentUser else { return nil }

        if let uniqueID = uniqueID {
            let fullStorageReference = storageRef.child(user.uid).child(.closet).child(uniqueID).description
            let referenceNeeded = fullStorageReference.replacingOccurrences(of: storageURL, with: "")

            return referenceNeeded
        } else {
            let fullStorageReference = storageRef.child(user.uid).child(.closet).child(self.uniqueID()).description
            let referenceNeeded = fullStorageReference.replacingOccurrences(of: storageURL, with: "")

            return referenceNeeded
        }
    }
    func storageProfilePhotoURLReference(uniqueID: String? = nil) -> String? {
        guard let user = currentUser else { return nil }
        
        if let uniqueID = uniqueID {
            let fullStorageReference = storageRef.child(user.uid).child(.profilePhoto).child(uniqueID).description
            let referenceNeeded = fullStorageReference.replacingOccurrences(of: storageURL, with: "")
            
            return referenceNeeded
        } else {
            let fullStorageReference = storageRef.child(user.uid).child(.profilePhoto).child(self.uniqueID()).description
            let referenceNeeded = fullStorageReference.replacingOccurrences(of: storageURL, with: "")
            
            return referenceNeeded
        }
    }
    
    private func deleteAccount(user: User){

        //Obtain the current users unique ID
        let uid = user.uid
        
        //Use dispatch to ensure that the deletion of the database and storage happen first before deleting the authentication
        let dispatch = DispatchGroup()
        
        dispatch.enter()
        ////delete user's storage
        deleteStorageAndDatabase(user: user){
            
            ////delete user's data base account
            self.ref.child(FirebaseKeys.users.rawValue).child("\(uid)").observe(.value, with:{(snapshot)in
                if snapshot.value != nil{
                    self.ref.child(FirebaseKeys.users.rawValue).child("\(uid)").removeValue()
                }
            })
            dispatch.leave()
        }
        
        dispatch.notify(queue: .main){
            //delete user's account
            user.delete { (error) in
                if error == nil{
                    //Account Deleted
                    self.notificationCenter.post(name: .authStatusChanged, object: nil)
                } else {
                    //An error occured
                    print("Failed to delete account")
                 }
             }
        }
    }
    
    private func deleteStorageAndDatabase(user: User, completion: @escaping ()->Void){
        
        //Obtain the current users unique ID
        let uid = user.uid

        //Initialize a dispatch for concurrent execution of firebase functions before performing completion
        let dispatch = DispatchGroup()
        
        ////Iterate through the database to delete the references of the clothes and profile photo
        
        dispatch.enter()
        //Delete the profilePhoto if the user has set one
        self.ref.child(FirebaseKeys.users.rawValue).child("\(uid)").child(FirebaseKeys.profileImageURL.rawValue).observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let path = snapshot.value as? String{
                self.storageRef.child(path).delete{ (error) in
                    if error == nil{
                        //Profile photo deleted
                        print("Successfully deleted profile photo")
                        
                    } else {
                        //An error occured
                        print("Failed to delete profile photo")
                    }
                }
            }
            dispatch.leave()
        })
        
        dispatch.enter()
        //Delete the clothes in the closet and then delete the user photo
        self.ref.child(FirebaseKeys.users.rawValue).child("\(uid)").child(FirebaseKeys.closet.rawValue).child(FirebaseKeys.items.rawValue).observeSingleEvent(of: .value, with:{(snapshot) in
            
            if let data = snapshot.value! as? [String: [String: Any]]{
                for (_, val) in data{
                    if let url = val[FirebaseKeys.url.rawValue] as? String{
                        self.storageRef.child(url).delete{ (error) in
                            if error == nil{
                                //Profile photo deleted
                                print("Successfully deleted profile photo")
                                
                            } else {
                                //An error occured
                                print("Failed to delete profile photo")
                            }
                        }
                    }
                }
            }
            dispatch.leave()
        })
        
        //Call completion handler to finish deleting the data base
        dispatch.notify(queue: .main){
            completion()
        }
    }
}
