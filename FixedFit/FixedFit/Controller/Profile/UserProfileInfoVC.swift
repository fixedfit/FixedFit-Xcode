//
//  UserProfileInfoVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/29/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

/*
 This class will manage the user's info in the child view controller of the profile and UserView
 */
class UserProfileInfoVC: UIViewController, UIGestureRecognizerDelegate {

    let firebaseManager = FirebaseManager.shared
    let userStuffManager = UserStuffManager.shared
    
    //Handlers for the removal of the observers
    var firstNameHandle: UInt = 0
    var lastNameHandle: UInt = 0
    var bioHandle: UInt = 0
    var followersHandle: UInt = 0
    var followingHandle: UInt = 0
    var profileImageHandle: UInt = 0
    
    //label for the user's first and last name, user's bio, and viewing status
    @IBOutlet weak var UserFirstName: UILabel!
    @IBOutlet weak var UserLastName: UILabel!
    @IBOutlet weak var UserBio: UILabel!
    
    
    //References to the buttons followers and following for updating the text field
    @IBOutlet weak var FollowingCount: UILabel!
    @IBOutlet weak var FollowersCount: UILabel!
    @IBOutlet weak var FollowingButton: UIView!
    @IBOutlet weak var FollowersButton: UIView!
    
    //Reference to the UIImageVIew
    @IBOutlet weak var UserProfileImage: UIImageView!
    
    //boolean to determine if the view is displaying the current user
    var currentUserCheck:Bool!
    
    //Variable that will contain the user's uid that we are viewing
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Adjust texts in labels to fit the width of the label
        self.UserBio.numberOfLines = 0
        self.UserBio.adjustsFontSizeToFitWidth = true
        self.UserFirstName.adjustsFontSizeToFitWidth = true
        self.UserLastName.adjustsFontSizeToFitWidth = true
        self.FollowingCount.adjustsFontSizeToFitWidth = true
        self.FollowersCount.adjustsFontSizeToFitWidth = true
        
        //Give UITapGesture to the Following and Follower views
        let followingTap = UITapGestureRecognizer(target:self, action: #selector(UserProfileInfoVC.tappedFollowing))
        followingTap.delegate = self
        let followersTap = UITapGestureRecognizer(target:self, action: #selector(UserProfileInfoVC.tappedFollowers))
        followersTap.delegate = self
        
        FollowingButton.isUserInteractionEnabled = true
        FollowersButton.isUserInteractionEnabled = true
        FollowingButton.addGestureRecognizer(followingTap)
        FollowersButton.addGestureRecognizer(followersTap)
        
        //ContentMode is used to scale images
        self.UserProfileImage.contentMode = UIViewContentMode.scaleAspectFit
        
        if(currentUserCheck){
            
            //Fetch the user's Information from the UserStuffManager
            userStuffManager.fetchUserInfo { _ in
                //Initial UIImage variable used to select the image to output to the screen
                weak var Image: UIImage!
                
                //Update labels of profile if user has edited them
                self.UserFirstName.text = self.userStuffManager.userInfo.firstName
                self.UserLastName.text = self.userStuffManager.userInfo.lastName
                self.UserBio.text = self.userStuffManager.userInfo.bio
                
                ////Load the User's profile photo into the UIImageView
                //if there is picture already set for the user's profile, then retrieve the photo from firebase, otherwise it will place the default image for the user
                Image = self.userStuffManager.userInfo.photo
                //Generate a UIImage from the user's photo
                
                let image = Image
                self.UserProfileImage.image = image
            }
        }
        
        ////Update Followers and Following Counters from firebase
        //MARK: When other Users are modifiying data in the firebase realtime database that impacts the profile page, it must update the profile page to reflect that change. Including fields like number of followers and number of following. along with there lists, etc. When the current users are in this view controller. RealTime Interactions can be tracked when other users are in feed and follow the current user.
        //Observer used to observe when a user is added or delete from the following lists of the current user
        if self.uid.isEmpty {
            self.followingHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(firebaseManager.currentUser!.uid).child(FirebaseKeys.followingCount.rawValue).observe(.value, with: {(snapshot) in

                //Assign variable with the snapshot value
                if let followingCounter = snapshot.value as? Int{

                    //Update button titles/view counters for following Counter
                    self.FollowingCount.text = "\(followingCounter)"
                }
            })
        } else {
            self.followingHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.followingCount.rawValue).observe(.value, with: {(snapshot) in

                //Assign variable with the snapshot value
                if let followingCounter = snapshot.value as? Int{

                    //Update button titles/view counters for following Counter
                    self.FollowingCount.text = "\(followingCounter)"
                }
            })
        }

        if self.uid.isEmpty {
            self.followersHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(firebaseManager.currentUser!.uid).child(FirebaseKeys.followersCount.rawValue).observe(.value, with: {(snapshot) in

                //Assign variable with the snapshot value
                if let followersCounter = snapshot.value as? Int{

                    //Update button titles/view counters for follower's Counter
                    self.FollowersCount.text = "\(followersCounter)"
                }
            })
        } else {
            self.followersHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.followersCount.rawValue).observe(.value, with: {(snapshot) in

                //Assign variable with the snapshot value
                if let followersCounter = snapshot.value as? Int{

                    //Update button titles/view counters for follower's Counter
                    self.FollowersCount.text = "\(followersCounter)"
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Determine which methodology to perform for retrival of user information
        if(!currentUserCheck){
            
            self.firstNameHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.firstName.rawValue).observe(.value, with: {(snapshot) in
                
                //retrieve the User's first name
                if let firstname = snapshot.value as? String {
                    
                    //set the User's first name
                    self.UserFirstName.text = firstname
                }
            })
            
            self.lastNameHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.lastName.rawValue).observe(.value, with: {(snapshot) in
                
                //retrieve the User's last name
                if let lastname = snapshot.value as? String {
                    
                    //set the User's last name
                    self.UserLastName.text = lastname
                }
            })
            
            self.bioHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.bio.rawValue).observe(.value, with: {(snapshot) in
                
                //retrieve the User's bio
                if let bio = snapshot.value as? String {
                    
                    //set the User's bio
                    self.UserBio.text = bio
                }
            })
            
            //Observer used to observe when a user has modified their profile image
            self.profileImageHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.profilePhoto.rawValue).observe(.value, with: {(snapshot) in
                
                //retrieve the User's profile photo
                if let photoURL = snapshot.value as? String {
                    
                    print(photoURL)
                    
                } else {
                    self.UserProfileImage.image = UIImage(named: "defaultProfile")
                }
            })
        }
    }
    
    //Functions to the buttons involved in the profile section
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
        if(!currentUserCheck){
            
            //Remove the observers for this view
            firebaseManager.ref.removeObserver(withHandle: self.firstNameHandle)
            firebaseManager.ref.removeObserver(withHandle: self.lastNameHandle)
            firebaseManager.ref.removeObserver(withHandle: self.bioHandle)
            firebaseManager.ref.removeObserver(withHandle: self.followersHandle)
            firebaseManager.ref.removeObserver(withHandle: self.followingHandle)
            firebaseManager.ref.removeObserver(withHandle: self.profileImageHandle)
        }
    }
}
