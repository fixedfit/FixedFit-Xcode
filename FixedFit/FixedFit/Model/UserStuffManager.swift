//
//  UserStuffManager.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit

class UserStuffManager {
    static let shared = UserStuffManager()

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
                let firstName = userInfo[FirebaseKeys.firstName] as? String, let lastName = userInfo[FirebaseKeys.lastName] as? String {
                self?.firstName = firstName
                self?.lastName = lastName
                self?.username = username

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
    
    func updateUserInfo(firstname: String, lastname: String, bio: String, name_of_user: String, photo: UIImage? = nil){
        
        let firebaseManager = FirebaseManager.shared
        
        //Update user information in firebase
        
        
        //Save current userstatus into firebase
        
    }
    
    //Function used to modify user's status
    func toggleUserStatus(newStatus: String){
        self.userstatus = newStatus
    }
    
    func checkUsername(username: String) -> Bool{
        
        //Variable used to determine if the user's selected username already exists
        var sameUserName: Bool!
        
        //Check if firebase already contains the user name
        let firebaseManager = FirebaseManager.shared
        firebaseManager.checkUsername(username) {(firebaseError) in
            if firebaseError != nil {
                sameUserName = true
            } else {
                sameUserName = false
            }
        }
        return sameUserName
    }
    
    //Function user to update the push notification status in firebase through UserStuffManager
    func toggelUserPushNotification(newStatus: String){
        
        let firebaseManager = FirebaseManager.shared
        
        //Update current UserStuffManager variables
        self.userPushNotification = newStatus
        
        //Update firebase push notification status
        
    }
}
