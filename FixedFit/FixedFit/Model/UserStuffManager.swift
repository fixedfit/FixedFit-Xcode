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

    private let defaultTags = ["hat", "top", "bottom", "shoe"]
    private var userCreatedTags: [String] = []

    init() {}

    var tags: [String] {
        return defaultTags + userCreatedTags
    }

    func addNewTag(_ tag: String) {
        userCreatedTags.append(tag)
    }
}
