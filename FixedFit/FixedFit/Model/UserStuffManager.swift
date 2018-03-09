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

    private var userTags: Set<String> = []
    var temporaryTags: Set<String> = []

    var tags: Set<String> {
        return userTags.union(temporaryTags)
    }

    func addNewTag(_ tag: String) {
        temporaryTags.insert(tag)
    }

    func removeTemporaryTags(insertToUserTags: Bool) {
        if insertToUserTags {
            userTags = userTags.union(temporaryTags)
        } else {
            temporaryTags.removeAll()
        }
    }

    func fetchUserInformation() {
        let firebaseManager = FirebaseManager.shared

        firebaseManager.fetchUserInfo { [weak self] (userInfo, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let userInfo = userInfo, let username = userInfo[FirebaseKeys.username] as? String,
                let firstName = userInfo[FirebaseKeys.firstName] as? String, let lastName = userInfo[FirebaseKeys.lastName] as? String {
                self?.firstName = firstName
                self?.lastName = lastName
                self?.username = username
                self?.fetchTags()
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
                strongSelf.userTags = strongSelf.userTags.union(foundTags)
            }
        }
    }
}
