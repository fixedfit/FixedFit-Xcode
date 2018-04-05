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
    
    //Function used to check if user name already exist by calling firebase checkUsername()
    func checkUsername(username: String) -> Bool{
        
        //Initial variable used to return boolean value
        var takenUserName:Bool?
        
        //Use dispatch group to wait for checkUsername to finish executing before returning
        let myGroup = DispatchGroup()
        
        //Check if firebase already contains the user name
        //if true, the completion function will contain the parameter as a boolean value
        let firebaseManager = FirebaseManager.shared
        myGroup.enter()
        
        //Check username
        firebaseManager.checkUsername(username) {(firebaseError) in
            if firebaseError != nil {
                takenUserName = true
            } else {
                takenUserName = false
            }
        }
        myGroup.leave()
        myGroup.wait()
        
        //debug
        if(takenUserName == nil){
            print("bool is nil")
        } else {
            print(takenUserName!)
        }

        return false//takenUserName!
    }
}
