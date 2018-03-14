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
                self?.fetchCategories()

                if let completion = completion {
                    completion(nil)
                }
            }
        }
    }

    func fetchCategories() {
        let firebaseManager = FirebaseManager.shared

        firebaseManager.fetchCategories(for: username) { [weak self] (foundCategories, error) in
            guard let strongSelf = self else { return }

            if let _ = error {
                print("Problem fetching categories")
            } else if let foundCategories = foundCategories {
                strongSelf.closet.setCategories(categories: strongSelf.closet.allCategories.union(foundCategories))
            }
        }
    }

    func updateCloset(closet: [String: Any]) {
        if let newClosetItems = closet[FirebaseKeys.items] as? [[String:Any]] {
            var createdClosetItems: [ClosetItem] = []
            var createdCategories: Set<String> = []

            for newClosetItem in newClosetItems {
                if let url = newClosetItem[FirebaseKeys.url] as? String,
                    let category = newClosetItem[FirebaseKeys.category] as? String {
                    let createdClosetItem = ClosetItem(storagePath: url, category: category)

                    createdClosetItems.append(createdClosetItem)
                    createdCategories.insert(category)
                }
            }

            self.closet.items = createdClosetItems
            self.closet.setCategories(categories: createdCategories)
        } else if let newClosetCategories = closet[FirebaseKeys.categories] as? [String] {
            self.closet.setCategories(categories: Set(newClosetCategories))
        }
    }
}
