//
//  ProfileVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 2/20/18.
//  Edited by Mario Buenrostro on 3/2/2018.
//
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController, UIGestureRecognizerDelegate {
    let firebaseManager = FirebaseManager.shared

    //Initialize default image name
    var imageName = "defaultProfile"
    
    //MARK: Initialize integer counters to count the number of followers and followings the user currently has.
    var FollowersCounter = 0
    var FollowingCounter = 0
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Give UITapGesture to the Following and Follower views
        let followingTap = UITapGestureRecognizer(target:self, action: #selector(ProfileVC.tappedFollowing))
        followingTap.delegate = self
        let followersTap = UITapGestureRecognizer(target:self, action: #selector(ProfileVC.tappedFollowers))
        followersTap.delegate = self
        
        FollowingButton.isUserInteractionEnabled = true
        FollowersButton.isUserInteractionEnabled = true
        FollowingButton.addGestureRecognizer(followingTap)
        FollowersButton.addGestureRecognizer(followersTap)
        
    }
    


    
    //MARK: Update profile page once view appears.
    override func viewWillAppear(_ animated: Bool) {
        
        weak var Image: UIImage!
        
        //Update the title of the navigation bar with the user name of the user
        self.navigationItem.title = "Future UserName"
        
        //Update labels of profile if user has edited them
        self.UserFirstName.text = "First Name"
        self.UserLastName.text = "Last name"
        self.UserBio.text = "No Bio"
        
    
        ////Update Followers and Following Counters from firebase
        
        //Update button titles/view counters
        self.FollowingCount.text = String(FollowingCounter)
        self.FollowersCount.text = String(FollowersCounter)
        
        
        ////Load the User's profile photo into the UIImageView
        //if there is picture already set for the user's profile, then retrieve the photo from firebase, otherwise it will place the default image for the user
        
        //Only obtain a single photo under the term: "userphoto" as a parameter which will be used to determine what to look for
        
        if true {
            Image = UIImage(named: imageName)
        } else {
            print("if it does exist, then just assign it.")
        }
        
        //Generate a UIImage from the user's photo
        //ContentMode is used to scale images
        UserProfileImage.contentMode = UIViewContentMode.scaleAspectFit
        let image = Image
        UserProfileImage.image = image
        
        print("profile appeared")
    }
    
    @IBAction func EditTransition(_ sender: UIBarButtonItem) {
        print("moving to editor")
        performSegue(withIdentifier: "EditTransition", sender: self)
    }
    
    
    
    
    //Functions to the buttons involved in the profile section
    //Execute with transitional view animations
    //perform action when following and followers button are clicked
    @objc func tappedFollowing(sender: UITapGestureRecognizer){
        print("following pressed")
    }
    @objc func tappedFollowers(sender: UITapGestureRecognizer){
        print("followers pressed")
    }

    
    //MARK: When other Users are modifiying data in the firebase realtime database that impacts the profile page, it must update the profile page to reflect that change. Including fields like number of followers and number of following. along with there lists, etc. When the current users are in this view controller. RealTime Interactions can be tracked when other users are in feed and follow the current user.
    
}
