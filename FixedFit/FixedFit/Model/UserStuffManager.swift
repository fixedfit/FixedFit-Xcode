//
//  UserStuffManager.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UserStuffManager {
    static let shared = UserStuffManager()

    var ref: DatabaseReference {
        return Database.database().reference()
    }
    var storageRef: StorageReference {
        return Storage.storage().reference()
    }
    private var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    var firstName = ""
    var lastName = ""
    var username = ""
    var userbio = ""
    var userstatus = "Public"
    var userPushNotification = "On"
    var userphoto:UIImage? = nil

    var closet = Closet()

    func fetchUserInformation(completion: ((Error?) -> Void)? = nil) {
        let firebaseManager = FirebaseManager.shared

        firebaseManager.fetchUserInfo { [weak self] (userInfo, error) in
            if let error = error {
                print(error.localizedDescription)
                if let completion = completion {
                    completion(error)
                }
            } else if let userInfo = userInfo, let username = userInfo[FirebaseKeys.username] as? String,
                let firstName = userInfo[FirebaseKeys.firstName] as? String, let lastName = userInfo[FirebaseKeys.lastName] as? String, let userbio = userInfo[FirebaseKeys.bio] as? String {
                self?.firstName = firstName
                self?.lastName = lastName
                self?.username = username
                self?.userbio = userbio
                
                if let completion = completion {
                    completion(nil)
                }
            }
        }
    }

    func updateCloset(closet: [String: Any]) {
        if let newClosetItems = closet[FirebaseKeys.items] as? [[String:Any]] {
            var createdClosetItems: [ClosetItem] = []

            for newClosetItem in newClosetItems {
                if let url = newClosetItem[FirebaseKeys.url] as? String,
                    let category = newClosetItem[FirebaseKeys.category] as? String {
                    let subcategory = newClosetItem[FirebaseKeys.subcategory] as? String
                    let categorySubcategory = CategorySubcategory(category: category, subcategory: subcategory)
                    let createdClosetItem = ClosetItem(categorySubcategory: categorySubcategory, storagePath: url)

                    createdClosetItems.append(createdClosetItem)
                    self.closet.categorySubcategoryStore.addCategory(category: category)

                    if subcategory != nil {
                        self.closet.categorySubcategoryStore.addSubcategory(category: category, subcategory: subcategory!)
                    }
                }
            }

            self.closet.items = createdClosetItems
        }

        if let filters = closet[FirebaseKeys.filters] as? [String: String] {
            self.closet.filters = filters
        }
    }
    
    func updateUserInfo(firstname: String, lastname: String, bio: String, name_of_user: String,status: String,
                        photo: UIImage? = nil){
        
        //let firebaseManager = FirebaseManager.shared
        
        //Update user first & last name in firebase
        self.ref.child("users").child((currentUser?.uid)!).updateChildValues(["firstName" : firstname])
        self.ref.child("users").child((currentUser?.uid)!).updateChildValues(["lastName" : lastname])
        
        //Save current bio into firebase
        self.ref.child("users").child((currentUser?.uid)!).updateChildValues(["bio" : bio])
        
        //Save current username into firebase
        self.ref.child("users").child((currentUser?.uid)!).updateChildValues(["username" : name_of_user])
        
        //Save current userstatus into firebase
        self.ref.child("users").child((currentUser?.uid)!).updateChildValues(["status" : status])
        

        
    }
    
    //Function used to modify user's status
    func toggleUserStatus(newStatus: String){
        self.userstatus = newStatus
    }
    
    func toggelUserPushNotification(newStatus: String){
        self.userPushNotification = newStatus
    }
    
    //Function used to check if user name already exist by calling firebase checkUsername()
    func checkUsername(username: String, completed: @escaping (Bool?)->Void){
        
        //Check if firebase already contains the user name
        //if true, the completion function will contain the parameter as a boolean value
        let firebaseManager = FirebaseManager.shared
        
        //Check username
        firebaseManager.checkUsername(username) {(firebaseError) in
            if firebaseError != nil {
                completed(true)
            } else {
                completed(false)
            }
        }
    }
}
