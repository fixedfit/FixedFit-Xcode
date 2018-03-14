//
//  Closet.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/12/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation

struct ClosetItem {
    var storagePath: String
    var category: String

    init(storagePath: String, category: String) {
        self.storagePath = storagePath
        self.category = category
    }
}

class Closet {
    var items: [ClosetItem] = []
    private var categories: Set<String> = []
    var temporaryCategories: Set<String> = []

    var allCategories: Set<String> {
        return categories.union(temporaryCategories)
    }

    func addNewCategory(_ category: String) {
        temporaryCategories.insert(category)
    }

    func setCategories(categories: Set<String>) {
        self.categories = categories
    }

    func removeTemporaryCategories(insertToUserCategories: Bool) {
        if insertToUserCategories {
            categories = categories.union(temporaryCategories)
        } else {
            temporaryCategories.removeAll()
        }
    }

    func imageStoragePath(for category: String) -> String? {
        for item in items {
            if item.category == category {
                return item.storagePath
            }
        }

        return nil
    }

    func closetItems(matching category: String) -> [ClosetItem] {
        return items.filter { return $0.category == category ? true : false }
    }
}
