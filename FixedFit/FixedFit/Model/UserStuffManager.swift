//
//  UserStuffManager.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct UserInfo {
    var firstName = ""
    var lastName = ""
    var username = ""
    var bio = ""
    var publicProfile = true
    var previousPhotoURL = ""
    var photo: UIImage?
}

struct Event {
    var date: Date
    var outfit: Outfit
    var name: String

    init(date: Date, outfit: Outfit, name: String) {
        self.date = date
        self.outfit = outfit
        self.name = name
    }
}

extension Event {
    init?(json: [String: Any]) {
        if let eventName = json[FirebaseKeys.eventName.rawValue] as? String,
            let dateFrom1970 = json[FirebaseKeys.date.rawValue] as? Int,
            let outfitInfo = json[FirebaseKeys.outfit.rawValue] as? [String: Any],
            let outfitUniqueID = outfitInfo[FirebaseKeys.uniqueID.rawValue] as? String {
            self.date = Date(timeIntervalSince1970: Double(dateFrom1970))
            self.name = eventName

            var outfitClosetItems = [ClosetItem]()

            if let closetItems = outfitInfo[FirebaseKeys.items.rawValue] as? [[String: Any]] {
                for closetItem in closetItems {
                    if let url = closetItem[FirebaseKeys.url.rawValue] as? String,
                        let category = closetItem[FirebaseKeys.category.rawValue] as? String {

                        let uniqueID = closetItem[FirebaseKeys.uniqueID.rawValue] as? String
                        let subcategory = closetItem[FirebaseKeys.subcategory.rawValue] as? String
                        let categorySubcategory = CategorySubcategory(category: category, subcategory: subcategory)
                        let createdClosetItem = ClosetItem(categorySubcategory: categorySubcategory, storagePath: url, uniqueID: uniqueID!)

                        outfitClosetItems.append(createdClosetItem)
                    }
                }
            }

            let outfit = Outfit(uniqueID: outfitUniqueID, items: outfitClosetItems)
            self.outfit = outfit
        } else  {
            return nil
        }
    }
}

class UserStuffManager {
    static let shared = UserStuffManager()

    var userInfo = UserInfo()
    var closet = Closet()
    var events: [Event] = []

    let firebaseManager = FirebaseManager.shared

    func fetchUserInfo(completion: @escaping (Error?) -> Void) {
        firebaseManager.fetchUserInfo { [weak self] (userInfo, error) in
            if let error = error {
                completion(error)
            } else if let userInfo = userInfo,
                let firstName = userInfo[FirebaseKeys.firstName.rawValue] as? String,
                let lastName = userInfo[FirebaseKeys.lastName.rawValue] as? String,
                let username = userInfo[FirebaseKeys.username.rawValue] as? String,
                let bio = userInfo[FirebaseKeys.bio.rawValue] as? String,
                let publicProfile = userInfo[FirebaseKeys.publicProfile.rawValue] as? Bool {
                
                self?.userInfo.firstName = firstName
                self?.userInfo.lastName = lastName
                self?.userInfo.username = username
                self?.userInfo.bio = bio
                self?.userInfo.publicProfile = publicProfile

                completion(nil)
            }
            
            //Fetch user photo
            if let userInfo = userInfo, let userphotoURL = userInfo[FirebaseKeys.profileImageURL.rawValue] as? String, !(userphotoURL.isEmpty){

                //fetch User image
                self?.firebaseManager.fetchImage(storageURL: userphotoURL, completion: { (image, error) in
                    if let error = error{
                        print(error.localizedDescription)
                        self?.userInfo.photo = UIImage(named: "defaultProfile")
                        self?.userInfo.previousPhotoURL = ""
                    } else {
                        self?.userInfo.photo = image
                        self?.userInfo.previousPhotoURL = userphotoURL
                    }
                })
                completion(nil)
            } else {
                self?.userInfo.photo = UIImage(named: "defaultProfile")
                self?.userInfo.previousPhotoURL = ""
                completion(nil)
            }
        }
    }

    func fetchCloset(completion: @escaping (Error?) -> Void) {
        firebaseManager.fetchCloset { [weak self] (closet, error) in
            guard let strongSelf = self else { return }

            if let error = error {
                completion(error)
            } else if let closet = closet {
                strongSelf.closet.items = strongSelf.parseClosetItems(foundCloset: closet)
                strongSelf.closet.filters = strongSelf.parseFilters(foundCloset: closet)
                strongSelf.closet.outfits = strongSelf.parseOutfits(foundCloset: closet)
                completion(nil)
            }
        }
    }

    func fetchEvents(completion: @escaping ([Event]?, Error?) -> Void) {
        firebaseManager.fetchEvents { (eventInfos, error) in
            if error != nil {
                completion(nil, error)
            } else if let eventInfos = eventInfos{
                var events = [Event]()

                for eventInfo in eventInfos {
                    if let event = Event(json: eventInfo) {
                        events.append(event)
                    }
                }

                self.events = events
                completion(events, nil)
            }
        }
    }
    
    func updateUserInfo(_ userInfo: UserInfo, completion: @escaping (Error?) -> Void) {
        self.userInfo = userInfo
        
        firebaseManager.updateUserInfo(userInfo) { (error) in
            if let error = error {
                // Show the user something
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

    func togglePublicProfile() {
        userInfo.publicProfile = !userInfo.publicProfile
    }

    func checkUsername(username: String, completion: @escaping (Bool?)->Void){
        // Check if firebase already contains the user name
        // If true, the completion function will contain the parameter as a boolean value
        firebaseManager.checkUsername(username) { (error) in
            if let _ = error {
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    // MARK: Helper methods

    func parseClosetItems(foundCloset: [String: Any]) -> [ClosetItem] {
        var closetItems: [ClosetItem] = []

        if let foundClosetItems = foundCloset[FirebaseKeys.items.rawValue] as? [String: [String:Any]] {
            for foundClosetItemInfo in foundClosetItems {
                if let url = foundClosetItemInfo.value[FirebaseKeys.url.rawValue] as? String,
                    let category = foundClosetItemInfo.value[FirebaseKeys.category.rawValue] as? String {

                    let uniqueID = foundClosetItemInfo.value[FirebaseKeys.uniqueID.rawValue] as? String
                    let subcategory = foundClosetItemInfo.value[FirebaseKeys.subcategory.rawValue] as? String
                    let categorySubcategory = CategorySubcategory(category: category, subcategory: subcategory)
                    let createdClosetItem = ClosetItem(categorySubcategory: categorySubcategory, storagePath: url, uniqueID: uniqueID!)

                    closetItems.append(createdClosetItem)
                    closet.categorySubcategoryStore.addCategory(category: category)

                    if subcategory != nil {
                        closet.categorySubcategoryStore.addSubcategory(category: category, subcategory: subcategory!)
                    }
                }
            }
        }

        return closetItems
    }

    func parseFilters(foundCloset: [String: Any]) -> [String: String] {
        if let filters = foundCloset[FirebaseKeys.filters.rawValue] as? [String: String] {
            return filters
        } else {
            return [:]
        }
    }

    func parseOutfits(foundCloset: [String: Any]) -> [Outfit] {
        var foundOutfits: [Outfit] = []

        if let outfits = foundCloset[FirebaseKeys.outfits.rawValue] as? [String: [String: Any]] {
            for key in outfits.keys {
                var outfit = Outfit(uniqueID: key, items: [])
                var outfitInfo = outfits[key]

                if let items = outfitInfo?[FirebaseKeys.items.rawValue] as? [[String: String]] {
                    for closetItem in items {
                        if let url = closetItem[FirebaseKeys.url.rawValue],
                            let category = closetItem[FirebaseKeys.category.rawValue],
                            let uniqueID = closetItem[FirebaseKeys.uniqueID.rawValue] {
                            let categorySubcategory = CategorySubcategory(category: category, subcategory: closetItem[FirebaseKeys.subcategory.rawValue])
                            let closetItem = ClosetItem(categorySubcategory: categorySubcategory, storagePath: url, uniqueID: uniqueID)

                            outfit.items.append(closetItem)
                        }
                    }

                }

                foundOutfits.append(outfit)
            }
        }

        return foundOutfits
    }
}
