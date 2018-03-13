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
    var tag: String

    init(storagePath: String, tag: String) {
        self.storagePath = storagePath
        self.tag = tag
    }
}

class Closet {
    var items: [ClosetItem] = []
    private var tags: Set<String> = []
    var temporaryTags: Set<String> = []

    var allTags: Set<String> {
        return tags.union(temporaryTags)
    }

    func addNewTag(_ tag: String) {
        temporaryTags.insert(tag)
    }

    func setTags(tags: Set<String>) {
        self.tags = tags
    }

    func removeTemporaryTags(insertToUserTags: Bool) {
        if insertToUserTags {
            tags = tags.union(temporaryTags)
        } else {
            temporaryTags.removeAll()
        }
    }

    func imageStoragePath(for tag: String) -> String? {
        for item in items {
            if item.tag == tag {
                return item.storagePath
            }
        }

        return nil
    }
}
