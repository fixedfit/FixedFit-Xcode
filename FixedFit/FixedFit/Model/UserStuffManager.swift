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
                self?.fetchTags()

                if let completion = completion {
                    completion(nil)
                }
            }
        }
    }

    func fetchTags() {
        let firebaseManager = FirebaseManager.shared

        firebaseManager.fetchTags(for: username) { [weak self] (foundTags, error) in
            guard let strongSelf = self else { return }

            if let _ = error {
                print("Problem fetching tags")
            } else if let foundTags = foundTags {
                strongSelf.closet.setTags(tags: strongSelf.closet.allTags.union(foundTags))
            }
        }
    }

    func updateCloset(closet: [String: Any]) {
        if let newClosetItems = closet[FirebaseKeys.items] as? [[String:Any]] {
            var createdClosetItems: [ClosetItem] = []

            for newClosetItem in newClosetItems {
                if let url = newClosetItem[FirebaseKeys.url] as? String,
                    let tag = newClosetItem[FirebaseKeys.tag] as? String {
                    let createdClosetItem = ClosetItem(storagePath: url, tag: tag)
                    createdClosetItems.append(createdClosetItem)
                }
            }

            self.closet.items = createdClosetItems
        } else if let newClosetTags = closet[FirebaseKeys.tags] as? [String] {
            self.closet.setTags(tags: Set(newClosetTags))
        }
    }
}
