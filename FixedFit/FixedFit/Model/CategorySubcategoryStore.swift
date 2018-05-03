//
//  CategorySubcategoryStore.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/15/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation

class CategorySubcategoryStore {
    private var categories: Set<String> = [] {
        didSet {
            initializeSubcategories()
        }
    }

    private var subcategories: [String: Set<String>] = [:]

    var defaultCategories: [String] {
        return ["tops", "bottoms", "footwear", "accessories"]
    }

    var allCategories: [String] {
        var setOfAllCategories: Set<String> = []
        
        defaultCategories.forEach({ setOfAllCategories.insert($0)})
        categories.forEach({setOfAllCategories.insert($0)})

        return Array(setOfAllCategories)
    }

    var allUserCreatedCategories: [String] {
        let createdCategories = categories.subtracting(defaultCategories)
        return Array(createdCategories)
    }

    var closetCategories: [String] {
        return Array(categories)
    }

    func contains(category: String) -> Bool {
        return categories.contains(category)
    }

    func addCategory(category: String) {
        categories.insert(category)
    }
    func removeCategory(category: String){
        categories.remove(category)
    }

    func addSubcategory(category: String, subcategory: String) {
        guard categories.contains(category) else { return }

        subcategories[category]?.insert(subcategory)
    }

    func subcategories(for category: String) -> [String] {
        guard categories.contains(category) else { return [] }
        guard let foundSubcategories = subcategories[category] else { return [] }

        return Array(foundSubcategories)
    }

    private func initializeSubcategories() {
        for category in categories {
            if let _ = subcategories[category] {
                continue
            } else {
                subcategories[category] = Set<String>()
            }
        }
    }

    func resetEverything() {
        subcategories.removeAll()
        categories.removeAll()
    }
}
