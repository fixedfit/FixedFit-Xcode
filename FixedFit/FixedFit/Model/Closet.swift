//
//  Closet.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/12/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation

struct CategorySubcategory {
    var category: String?
    var subcategory: String?

    func allFieldsSet() -> Bool {
        if category != nil && subcategory != nil {
            return true
        } else {
            return false
        }
    }
}

struct ClosetItem {
    var categorySubcategory: CategorySubcategory
    var storagePath: String
    var uniqueID: String

    init(categorySubcategory: CategorySubcategory, storagePath: String, uniqueID: String) {
        self.storagePath = storagePath
        self.categorySubcategory = categorySubcategory
        self.uniqueID = uniqueID
    }
}

class Closet {
    var items: [ClosetItem] = []
    var categorySubcategoryStore = CategorySubcategoryStore()
    var filters: [String: String] = [:]

    func imageStoragePath(for category: String) -> String? {
        for item in items {
            if item.categorySubcategory.category == category {
                return item.storagePath
            }
        }

        return nil
    }

    func filterForCategory(category: String) -> String {
        if let filter = filters[category] {
            return filter
        } else {
            return "show all"
        }
    }

    func closetItems(matching category: String) -> [ClosetItem] {
        return items.filter { return $0.categorySubcategory.category ?? "" == category ? true : false }
    }
}

func ==(_ a: CategorySubcategory, _ b: CategorySubcategory) -> Bool {
    guard let aCategory = a.category, let aSubcategory = a.subcategory,
        let bCategory = b.category, let bSubcategory = b.subcategory else {
            return false
    }

    if aCategory == bCategory && aSubcategory == bSubcategory {
        return true
    } else {
        return false
    }
}
