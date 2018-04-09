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

struct UserInfo {
    var firstName = ""
    var lastName = ""
    var username = ""
    var bio = ""
    var publicProfile = true
    var pushNotificationsEnabled = true
    var photo: UIImage?
}

class UserStuffManager {
    static let shared = UserStuffManager()

    var userInfo = UserInfo()
    var closet = Closet()

    let firebaseManager = FirebaseManager.shared

    func fetchUserInfo(completion: @escaping (Error?) -> Void) {
        firebaseManager.fetchUserInfo { [weak self] (userInfo, error) in
            if let error = error {
                completion(error)
            } else if let userInfo = userInfo,
                let firstName = userInfo[FirebaseKeys.firstName.rawValue] as? String,
                let lastName = userInfo[FirebaseKeys.lastName.rawValue] as? String,
                let username = userInfo[FirebaseKeys.username.rawValue] as? String,
                let bio = userInfo[FirebaseKeys.bio.rawValue] as? String,
                let publicProfile = userInfo[FirebaseKeys.publicProfile.rawValue] as? Bool {
                
                self?.userInfo.firstName = firstName
                self?.userInfo.lastName = lastName
                self?.userInfo.username = username
                self?.userInfo.bio = bio
                self?.userInfo.publicProfile = publicProfile

                completion(nil)
            }
        }
    }

    func fetchCloset(completion: @escaping (Error?) -> Void) {
        firebaseManager.fetchCloset { [weak self] (closet, error) in
            guard let strongSelf = self else { return }

            if let error = error {
                completion(error)
            } else if let closet = closet {
                strongSelf.closet.items = strongSelf.parseClosetItems(foundCloset: closet)
                strongSelf.closet.filters = strongSelf.parseFilters(foundCloset: closet)
                strongSelf.closet.outfits = strongSelf.parseOutfits(foundCloset: closet)
                completion(nil)
            }
        }
    }
    
    func updateUserInfo(_ userInfo: UserInfo, completion: @escaping (Error?) -> Void) {
        self.userInfo = userInfo
        firebaseManager.updateUserInfo(userInfo) { (error) in
            if let error = error {
                // Show the user something
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

    func togglePublicProfile() {
        userInfo.publicProfile = !userInfo.publicProfile
        firebaseManager.updateUserInfo(userInfo) { _ in }
    }

    func togglePushNotificationsEnabled() {
        userInfo.pushNotificationsEnabled = !userInfo.pushNotificationsEnabled
        firebaseManager.updateUserInfo(userInfo) { _ in }
    }

    func checkUsername(username: String, completion: @escaping (Bool?)->Void){
        // Check if firebase already contains the user name
        // If true, the completion function will contain the parameter as a boolean value
        firebaseManager.checkUsername(username) { (error) in
            if let _ = error {
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    // MARK: Helper methods

    func parseClosetItems(foundCloset: [String: Any]) -> [ClosetItem] {
        var closetItems: [ClosetItem] = []

        if let foundClosetItems = foundCloset[FirebaseKeys.items.rawValue] as? [String: [String:Any]] {
            for foundClosetItemInfo in foundClosetItems {
                if let url = foundClosetItemInfo.value[FirebaseKeys.url.rawValue] as? String,
                    let category = foundClosetItemInfo.value[FirebaseKeys.category.rawValue] as? String {

                    let uniqueID = foundClosetItemInfo.value[FirebaseKeys.uniqueID.rawValue] as? String
                    let subcategory = foundClosetItemInfo.value[FirebaseKeys.subcategory.rawValue] as? String
                    let categorySubcategory = CategorySubcategory(category: category, subcategory: subcategory)
                    let createdClosetItem = ClosetItem(categorySubcategory: categorySubcategory, storagePath: url, uniqueID: uniqueID!)

                    closetItems.append(createdClosetItem)
                    closet.categorySubcategoryStore.addCategory(category: category)

                    if subcategory != nil {
                        closet.categorySubcategoryStore.addSubcategory(category: category, subcategory: subcategory!)
                    }
                }
            }
        }

        return closetItems
    }

    func parseFilters(foundCloset: [String: Any]) -> [String: String] {
        if let filters = foundCloset[FirebaseKeys.filters.rawValue] as? [String: String] {
            return filters
        } else {
            return [:]
        }
    }

    func parseOutfits(foundCloset: [String: Any]) -> [Outfit] {
        var foundOutfits: [Outfit] = []

        if let outfits = foundCloset[FirebaseKeys.outfits.rawValue] as? [String: [String: Any]] {
            for key in outfits.keys {
                var outfit = Outfit(uniqueID: key, items: [])
                var outfitInfo = outfits[key]

                if let items = outfitInfo?[FirebaseKeys.items.rawValue] as? [[String: String]] {
                    for closetItem in items {
                        if let url = closetItem[FirebaseKeys.url.rawValue],
                            let category = closetItem[FirebaseKeys.category.rawValue],
                            let uniqueID = closetItem[FirebaseKeys.uniqueID.rawValue] {
                            let categorySubcategory = CategorySubcategory(category: category, subcategory: closetItem[FirebaseKeys.subcategory.rawValue])
                            let closetItem = ClosetItem(categorySubcategory: categorySubcategory, storagePath: url, uniqueID: uniqueID)

                            outfit.items.append(closetItem)
                        }
                    }

                }

                foundOutfits.append(outfit)
            }
        }

        print(foundOutfits.count)

        return foundOutfits
    }
}
