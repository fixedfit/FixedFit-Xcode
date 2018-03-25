//
//  NotificationName+Extension.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 2/20/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation

struct NotificationUserInfo {
    static let newFilterSubcategory = "newFilterSubcategory"
}

extension Notification.Name {
    static let authStatusChanged = Notification.Name(rawValue: "authStatusChanged")
    static let changeTabs = Notification.Name(rawValue: "changeTabs")
    static let categoriesUpdated = Notification.Name(rawValue: "categoriesUpdated")
    static let filtersUpdated = Notification.Name(rawValue: "filtersUpdated")
}
