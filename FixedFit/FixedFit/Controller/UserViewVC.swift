//
//  UserViewVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/7/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class UserViewVC: UIViewController, UIGestureRecognizerDelegate{
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
    @IBOutlet weak var FollowersView: UIView!
    @IBOutlet weak var FollowingView: UIView!
    
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
        
        //Set every scale to make the text fit
        self.BioLabel.numberOfLines = 0
        self.BioLabel.adjustsFontSizeToFitWidth = true
        self.FirstNameLabel.adjustsFontSizeToFitWidth = true
        self.LastNameLabel.adjustsFontSizeToFitWidth = true
        self.FollowingCounter.adjustsFontSizeToFitWidth = true
        self.FollowersCounter.adjustsFontSizeToFitWidth = true
        
        //Give UITapGesture to the Following and Follower views
        let followingTap = UITapGestureRecognizer(target:self, action: #selector(UserViewVC.tappedFollowing))
        followingTap.delegate = self
        let followersTap = UITapGestureRecognizer(target:self, action: #selector(UserViewVC.tappedFollowers))
        followersTap.delegate = self
        
        self.FollowingView.isUserInteractionEnabled = true
        self.FollowersView.isUserInteractionEnabled = true
        self.FollowingView.addGestureRecognizer(followingTap)
        self.FollowersView.addGestureRecognizer(followersTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {

        ////Fetch the selected user's information from firebase by using the observers
        self.userNameHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.username.rawValue).observe(.value, with: {(snapshot) in
            
            //retrieve the User's username
            if let username = snapshot.value as? String {
            
                //set the User's username
                self.navigationItem.title = username
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
                self.LastNameLabel.text = lastname
            }
        })
        
        self.bioHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.bio.rawValue).observe(.value, with: {(snapshot) in
            
            //retrieve the User's bio
            if let bio = snapshot.value as? String {
            
                //set the User's bio
                self.BioLabel.text = bio
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
            
            //Scale image to aspect fit
            self.UserImage.contentMode = UIViewContentMode.scaleAspectFit
            
            //retrieve the User's profile photo
            if let photoURL = snapshot.value as? String {
                
                self.UserImage.image = UIImage(named: "defaultProfile")
            }
        })
    }
    
    //Functions to the buttons involved in the UserView section
    //Execute with transitional view animations
    //perform action when following and followers button are clicked
    @objc func tappedFollowing(sender: UITapGestureRecognizer){
        guard let vc = PushViews.executeTransition(vcName: PushViewKeys.userfinderVC, storyboardName: PushViewKeys.userfinder, newString:FirebaseUserFinderTitle.following, newMode:FirebaseUserFinderMode.following) else {return}
        
        //Check if the View Controller is of a certain View Controller type
        if let vc = vc as? UserFinderVC{
            
            //Push View Controller onto Navigation Stack
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let vc = vc as? InformationVC{
            self.present(vc, animated: true, completion: nil)
        }
    }
    @objc func tappedFollowers(sender: UITapGestureRecognizer){
        guard let vc = PushViews.executeTransition(vcName: PushViewKeys.userfinderVC, storyboardName: PushViewKeys.userfinder, newString:FirebaseUserFinderTitle.follower, newMode:FirebaseUserFinderMode.follower) else {return}
        
        //Check if the View Controller is of a certain View Controller type
        if let vc = vc as? UserFinderVC{
            
            //Push View Controller onto Navigation Stack
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let vc = vc as? InformationVC{
            self.present(vc, animated: true, completion: nil)
        }
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
