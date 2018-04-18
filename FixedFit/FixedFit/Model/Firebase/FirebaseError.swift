//
//  FirebaseError.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 4/8/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation

enum FirebaseError: Error {
    case usernameInUse
    case unableToSignOut
    case unableToRetrieveData
    case unableToUploadCloset
    case unableTofetchUserInfo

    var localizedDescription: String {
        switch self {
        case .usernameInUse: return "Username in use"
        case .unableToSignOut: return "Unable to signout"
        case .unableToRetrieveData: return "Unable to retrieve data"
        case .unableToUploadCloset: return "Unable to upload closet"
        case .unableTofetchUserInfo: return "Unable to fetch user information"
        }
    }
}
