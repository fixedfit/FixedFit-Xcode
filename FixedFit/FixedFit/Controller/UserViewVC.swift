//
//  UserViewVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/7/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class UserViewVC: UIViewController {
    //Variable used to present the title, which is the username
    var uid: String!
    var mode: String!
    
    //References to objects in view controller
    @IBOutlet weak var FirstNameLabel: UILabel!
    @IBOutlet weak var LastNameLabel: UILabel!
    @IBOutlet weak var BioLabel: UILabel!
    @IBOutlet weak var FollowersCounter: UILabel!
    @IBOutlet weak var FollowingCounter: UILabel!
    @IBOutlet weak var UserImage: UIImageView!
    
    let firebaseManager = FirebaseManager.shared
    
    //Handlers for the removal of the observers
    var userNameHandle: UInt = 0
    var firstNameHandle: UInt = 0
    var lastNameHandle: UInt = 0
    var bioHandle: UInt = 0
    var followersHandle: UInt = 0
    var followingHandle: UInt = 0
    var profileImageHandle: UInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ////Fetch the selected user's information from firebase by using the observers
        self.userNameHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.username.rawValue).observe(.value, with: {(snapshot) in
            
            //retrieve the User's username
            if let username = snapshot.value as? String {
            
                //set the User's username
                self.FirstNameLabel.text = username
            }
        })
        
        self.firstNameHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.firstName.rawValue).observe(.value, with: {(snapshot) in
            
            //retrieve the User's first name
            if let firstname = snapshot.value as? String {
            
                //set the User's first name
                self.FirstNameLabel.text = firstname
            }
        })
        
        self.lastNameHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.lastName.rawValue).observe(.value, with: {(snapshot) in
            
            //retrieve the User's last name
            if let lastname = snapshot.value as? String {
                
                //set the User's last name
                self.FirstNameLabel.text = lastname
            }
        })
        
        self.bioHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.bio.rawValue).observe(.value, with: {(snapshot) in
            
            //retrieve the User's bio
            if let bio = snapshot.value as? String {
            
                //set the User's bio
                self.FirstNameLabel.text = bio
            }
        })
        
        
        self.followingHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.followingCount.rawValue).observe(.value, with: {(snapshot) in
            
            //Assign variable with the snapshot value
            if let followingCounter = snapshot.value as? Int {
            
                //Update button titles/view counters for following Counter
                self.FollowingCounter.text = "\(followingCounter)"
            }
        })
        
        //Observer used to observe when a user is added or delete from the followers lists of the current user
        self.followersHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.followersCount.rawValue).observe(.value, with: {(snapshot) in
            
            //Assign variable with the snapshot value
            if let followersCounter = snapshot.value as? Int {
            
                //Update button titles/view counters for follower's Counter
                self.FollowersCounter.text = "\(followersCounter)"
            }
        })
        
        //Observer used to observe when a user has modified their profile image
        self.profileImageHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.profilePhoto.rawValue).observe(.value, with: {(snapshot) in
            
            //retrieve the User's profile photo
            if let photoURL = snapshot.value as? String {
                print(photoURL)
                self.UserImage.image = UIImage(named: "defaultProfile")
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        //Remove the observers for this view
        firebaseManager.ref.removeObserver(withHandle: self.userNameHandle)
        firebaseManager.ref.removeObserver(withHandle: self.firstNameHandle)
        firebaseManager.ref.removeObserver(withHandle: self.lastNameHandle)
        firebaseManager.ref.removeObserver(withHandle: self.bioHandle)
        firebaseManager.ref.removeObserver(withHandle: self.followersHandle)
        firebaseManager.ref.removeObserver(withHandle: self.followingHandle)
        firebaseManager.ref.removeObserver(withHandle: self.profileImageHandle)
    }
}
