//
//  FirebaseKeys.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 4/8/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation

enum FirebaseKeys: String {
    // User
    case users = "users"
    case firstName = "firstName"
    case lastName = "lastName"
    case username = "username"
    case bio = "bio"
    case publicProfile = "publicProfile"
    case profileImageURL = "profileImageURL"
    case profilePhoto = "profilePhoto"
    // Follow
    case followers = "followers"
    case following = "following"
    case followersCount = "followersCount"
    case followingCount = "followingCount"
    // Closet
    case closet = "closet"
    case items = "items"
    case category = "category"
    case subcategory = "subcategory"
    case uniqueID = "uniqueID"
    case url = "url"
    case categories = "categories"
    // Events
    case events = "events"
    case date = "date"
    case outfit = "outfit"
    case eventName = "eventName"
    // Filters
    case filters = "filters"
    // Outfits
    case outfits = "outfits"
    case isFavorited = "isFavorited"
}
