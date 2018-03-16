//
//  UserStuffManager.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation

class UserStuffManager {
    static let shared = UserStuffManager()

    var firstName = ""
    var lastName = ""
    var username = ""

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
                    let category = newClosetItem[FirebaseKeys.category] as? String,
                    let subcategory = newClosetItem[FirebaseKeys.subcategory] as? String {
                    let categorySubcategory = CategorySubcategory(category: category, subcategory: subcategory)
                    let createdClosetItem = ClosetItem(categorySubcategory: categorySubcategory, storagePath: url)

                    createdClosetItems.append(createdClosetItem)
                    self.closet.categorySubcategoryStore.addCategory(category: category)
                    self.closet.categorySubcategoryStore.addSubcategory(category: category, subcategory: subcategory)
                }
            }

            self.closet.items = createdClosetItems
        } else if let newClosetCategories = closet[FirebaseKeys.categories] as? [String] {
            for newClosetCategory in newClosetCategories {
                self.closet.categorySubcategoryStore.addCategory(category: newClosetCategory)
            }
        }
    }
}
