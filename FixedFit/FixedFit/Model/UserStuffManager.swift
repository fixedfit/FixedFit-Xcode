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
    var uid = ""
    var firstName = ""
    var lastName = ""
    var username = ""
    var bio = ""
    var publicProfile = true
    var previousPhotoURL = ""
    var photo: UIImage?
    var following: [String] = []
    var followers: [String] = []
    var blocked: [String] = []
    var likes: [Outfit] = []

    init() {}

    init(firstName: String, lastName: String, username: String, bio: String, publicProfile: Bool, previousPhotoURL: String, photo: UIImage?, uniqueID: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.bio = bio
        self.publicProfile = publicProfile
        self.previousPhotoURL = previousPhotoURL
        self.photo = photo
        self.uid = uniqueID

        //Set the display name with the first and last name of the user
        let firebaseManager = FirebaseManager.shared
        firebaseManager.displayNameModification(name: (self.firstName + " " + self.lastName))

    }

    init?(json: [String: Any]) {
        if let firstName = json[FirebaseKeys.firstName.rawValue] as? String,
            let lastName = json[FirebaseKeys.lastName.rawValue] as? String,
            let username = json[FirebaseKeys.username.rawValue] as? String,
            let bio = json[FirebaseKeys.bio.rawValue] as? String,
            let publicProfile = json[FirebaseKeys.publicProfile.rawValue] as? Bool,
            let previousPhotoURL = json[FirebaseKeys.profileImageURL.rawValue] as? String,
            let uniqueID = json[FirebaseKeys.uniqueID.rawValue] as? String {
            self.firstName = firstName
            self.lastName = lastName
            self.username = username
            self.bio = bio
            self.publicProfile = publicProfile
            self.previousPhotoURL = previousPhotoURL
            self.uid = uniqueID

            if let followers = json[FirebaseKeys.followers.rawValue] as? [String] {
                self.followers = followers
            }

            if let following = json[FirebaseKeys.following.rawValue] as? [String] {
                self.following = following
            }

            if let blocked = json[FirebaseKeys.blocked.rawValue] as? [String] {
                self.blocked = blocked
            }

            //Set the display name with the first and last name of the user
            let firebaseManager = FirebaseManager.shared
            firebaseManager.displayNameModification(name: (firstName + " " + lastName))


        } else {
            return nil
        }
    }
}

struct Event {
    var date: Date
    var outfit: Outfit
    var name: String?

    init(date: Date, outfit: Outfit, name: String?) {
        self.date = date
        self.outfit = outfit
        self.name = name
    }
}

extension Event {
    init?(json: [String: Any]) {
        if let dateFrom1970 = json[FirebaseKeys.date.rawValue] as? Int,
            let outfitInfo = json[FirebaseKeys.outfit.rawValue] as? [String: Any],
            let outfitUniqueID = outfitInfo[FirebaseKeys.uniqueID.rawValue] as? String,
            let isPublic = outfitInfo[FirebaseKeys.isPublic.rawValue] as? Bool {
            self.date = Date(timeIntervalSince1970: Double(dateFrom1970))

            if let eventName = json[FirebaseKeys.eventName.rawValue] as? String {
                self.name = eventName
            }

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

            let outfit = Outfit(uniqueID: outfitUniqueID, items: outfitClosetItems, isPublic: isPublic, userID: "", username: "")
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
                let publicProfile = userInfo[FirebaseKeys.publicProfile.rawValue] as? Bool,
                let uid = userInfo[FirebaseKeys.uniqueID.rawValue] as? String{

                self?.userInfo.firstName = firstName
                self?.userInfo.lastName = lastName
                self?.userInfo.username = username
                self?.userInfo.publicProfile = publicProfile
                self?.userInfo.uid = uid

                if let followers = userInfo[FirebaseKeys.followers.rawValue] as? [String] {
                    self?.userInfo.followers = followers
                } else {
                    self?.userInfo.followers.removeAll()
                }

                if let following = userInfo[FirebaseKeys.following.rawValue] as? [String] {
                    self?.userInfo.following = following
                } else {
                    self?.userInfo.following.removeAll()
                }

                if let blocked = userInfo[FirebaseKeys.blocked.rawValue] as? [String] {
                    self?.userInfo.blocked = blocked
                } else {
                    self?.userInfo.blocked.removeAll()
                }

                if let likes = userInfo[FirebaseKeys.likes.rawValue] as? [[String:Any]] {
                    var foundOutfits: [Outfit] = []

                    for outfit in likes {
                        var createOutfit = Outfit(uniqueID: "", items: [], isPublic: false, userID: "", username: "")

                        if let isFavorited = outfit[FirebaseKeys.isFavorited.rawValue] as? Bool,
                            let isPublic = outfit[FirebaseKeys.isPublic.rawValue] as? Bool,
                            let userID = outfit[FirebaseKeys.userID.rawValue] as? String,
                            let uniqueID = outfit[FirebaseKeys.uniqueID.rawValue] as? String,
                            let username = outfit[FirebaseKeys.username.rawValue] as? String {
                            createOutfit.isFavorited = isFavorited
                            createOutfit.isPublic = isPublic
                            createOutfit.userID = userID
                            createOutfit.uniqueID = uniqueID
                            createOutfit.username = username
                        }

                        if let items = outfit[FirebaseKeys.items.rawValue] as? [[String: String]] {
                            for closetItem in items {
                                if let url = closetItem[FirebaseKeys.url.rawValue],
                                    let category = closetItem[FirebaseKeys.category.rawValue],
                                    let uniqueID = closetItem[FirebaseKeys.uniqueID.rawValue] {
                                    let categorySubcategory = CategorySubcategory(category: category, subcategory: closetItem[FirebaseKeys.subcategory.rawValue])
                                    let closetItem = ClosetItem(categorySubcategory: categorySubcategory, storagePath: url, uniqueID: uniqueID)

                                    createOutfit.items.append(closetItem)
                                }
                            }

                        }

                        foundOutfits.append(createOutfit)
                    }

                    self?.userInfo.likes = foundOutfits

                } else {
                    self?.userInfo.likes.removeAll()
                }


                //Determine if bio is empty, if so then just make it say "No Bio Set"
                if bio.isEmpty {
                    self?.userInfo.bio = "No Bio Set"
                } else {
                    self?.userInfo.bio = bio
                }
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
                print("So it is a closet then")
                strongSelf.closet.items = strongSelf.parseClosetItems(foundCloset: closet)
                strongSelf.closet.filters = strongSelf.parseFilters(foundCloset: closet)
                strongSelf.closet.outfits = strongSelf.parseOutfits(foundCloset: closet)
                completion(nil)
            } else {
                print("Bro this should delete everything!")
                strongSelf.closet.items.removeAll()
                strongSelf.closet.filters.removeAll()
                strongSelf.closet.outfits.removeAll()
                strongSelf.closet.categorySubcategoryStore.resetEverything()
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

    //Function to add user both locally and on firebase
    func addUserToList(listMode: String, uid: String){

        //If the current user chooses to follow another user
        //Then add the currentUser's uid to the other user's followers list
        //And add the other user's uid to your following list
        if(listMode == FirebaseUserFinderMode.following){

            self.userInfo.following.append(uid)
            firebaseManager.followUser(usernameUniqueID: uid){ (error) in

                if error != nil{
                    print("Internal error: Users has not been added as a followers")
                }
            }

        //Add user to Blocked Users list
        } else if(listMode == FirebaseUserFinderMode.blocked){

            self.userInfo.blocked.append(uid)
            firebaseManager.blockUser(usernameUniqueID: uid){ (error) in
                if error != nil{
                    print("Internal error: this user has not been added to the blocked user's list")
                }
            }
        }
    }

    //Function to remove user both locally and on firebase
    func removeUserFromList(listMode: String, uid: String){

        //If the current user chooses to unfollow another user
        //Then remove the currentUser's uid from the other user's followers list
        //And remove the other user's uid from your following list
        if(listMode == FirebaseUserFinderMode.following){

            if let index = self.userInfo.following.index(where: {$0 == uid}){
                self.userInfo.following.remove(at: index)
            }

            firebaseManager.unfollowUser(usernameUniqueID: uid){ (error) in
                if error != nil{
                    print("Internal error: this user has not been removed from the user's followers list")
                }
            }

        //Remove user from Blocked Users list
        } else if(listMode == FirebaseUserFinderMode.blocked){

            if let index = self.userInfo.blocked.index(where: {$0 == uid}){
                self.userInfo.blocked.remove(at: index)
            }

            firebaseManager.unblockUser(usernameUniqueID: uid){ (error) in
                if error != nil{
                    print("Internal error: this user has not been removed from the blocked user's list")
                }
            }
        }
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
                var outfit = Outfit(uniqueID: key, items: [], isPublic: false, userID: "", username: "")
                var outfitInfo = outfits[key]

                if let isFavorited = outfitInfo?[FirebaseKeys.isFavorited.rawValue] as? Bool,
                    let isPublic = outfitInfo?[FirebaseKeys.isPublic.rawValue] as? Bool,
                    let userID = outfitInfo?[FirebaseKeys.userID.rawValue] as? String,
                    let username = outfitInfo?[FirebaseKeys.username.rawValue] as? String {
                    outfit.isFavorited = isFavorited
                    outfit.isPublic = isPublic
                    outfit.userID = userID
                    outfit.username = username
                }

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
