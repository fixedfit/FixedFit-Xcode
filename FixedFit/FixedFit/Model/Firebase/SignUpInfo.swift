//
//  SignUpInfo.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 4/8/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation

struct SignUpInfo {
    let firstName: String
    let lastName: String
    let email: String
    let username: String
    let password: String
    let publicProfile: Bool
    let bio: String
    let pushNotificationsEnabled: Bool


    init(firstName: String, lastName: String, email: String, username: String, password: String, publicProfile: Bool, bio: String, pushNotificationsEnabled: Bool) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.username = username
        self.password = password
        self.publicProfile = publicProfile
        self.bio = bio
        self.pushNotificationsEnabled = pushNotificationsEnabled
    }
}
