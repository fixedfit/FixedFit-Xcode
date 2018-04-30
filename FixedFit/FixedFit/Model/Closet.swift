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

struct Outfit {
    var uniqueID: String
    var items: [ClosetItem]
    var isFavorited = false
    var isPublic = true

    init(uniqueID: String, items: [ClosetItem], isPublic: Bool) {
        self.uniqueID = uniqueID
        self.items = items
        self.isPublic = isPublic
    }
}

class Closet {
    var items: [ClosetItem] = []
    var outfits: [Outfit] = []
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

    func updateFavorite(outfitUID: String, favorite: Bool) {
        if let index = outfits.index(where:{ $0.uniqueID == outfitUID }) {
            outfits[index].isFavorited = favorite
        }
    }

    func favoriteOutfits() -> [Outfit] {
        return outfits.filter({$0.isFavorited == true})
    }

    func publicOutfits() -> [Outfit] {
        return outfits.filter({$0.isPublic == true})
    }

    func privateOutfits() -> [Outfit] {
        return outfits.filter({$0.isPublic == false})
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
