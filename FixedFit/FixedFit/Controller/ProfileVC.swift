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

class ProfileVC: UIViewController {
    let firebaseManager = FirebaseManager.shared

    //MARK: Default string messages for buttons and names
    var FollowersMessage = "Follwers"
    var FollowingMessage = "Following"
    var imageName = "profile"
    
    //MARK: Initialize integer counters to count the number of followers and followings the user currently has.
    var FollowersCounter = 0
    var FollowingCounter = 0
    
    //label for the user's first and last name, user's bio, and viewing status
    @IBOutlet weak var UserFirstName: UILabel!
    @IBOutlet weak var UserLastName: UILabel!
    
    @IBOutlet weak var UserNameBios: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    
    //References to the buttons followers and following for updating the text field
    @IBOutlet weak var FollowersButton: UIButton!
    @IBOutlet weak var FollowingButton: UIButton!
    
    //Reference to the UIImageVIew
    @IBOutlet weak var UserProfileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Update profile page once view appears.
    override func viewDidAppear(_ animated: Bool) {
        //Update the title of the navigation bar with the user name of the user
        self.navigationItem.title = "Future UserName"
        
        //Update labels of profile if user has edited them
        self.UserFirstName.text = "Hello"
        self.UserLastName.text = "World"
        self.UserNameBios.text = "Bio"
        
        //If the user has signed up, default viewing status would be set to public and update/create status in firebase if it does not exist
        if(self.StatusLabel.text == "Status"){
            self.StatusLabel.text = "Public"
            
            //Add public view status into firebase as a string entry where (key = status, value = (String)Status)
            
        } else {
            
            //Update status field for user from the firebase field
            print("placeholder")
        }
        
        ////Load the User's profile photo into the UIImageView
        //if there is picture already set for the user's profile, then retrieve the photo from firebase, otherwise it will place the default image for the user
        
        //Only obtain a single photo under the term: "userphoto" as a parameter which will be used to determine what to look for
        
        //Generate a UIImage from the user's photo
        //ContentMode is used to scale images
        UserProfileImage.contentMode = UIViewContentMode.scaleAspectFit
        let image = UIImage(named: imageName)
        UserProfileImage.image = image
        
        ////Update Followers and Following Counters from firebase
        
        ////Update button titles
        self.FollowersButton.setTitle("\(FollowersCounter)\n" + FollowersMessage, for: UIControlState.normal)
        self.FollowingButton.setTitle("\(FollowingCounter)\n" + FollowersMessage, for: UIControlState.normal)
        
    }
    
    //Transition to the editor view controller
    @IBAction func tappedEditProfile(_ sender: UIButton) {
        performSegue(withIdentifier: "EditTransition", sender: self)
    }
    
    //Functions to the buttons involved in the profile section
    //Execute with transitional view animations
    @IBAction func FollowersButton(_ sender: Any) {
    }
    @IBAction func FollowingButton(_ sender: UIButton) {
    }
    
    
    //MARK: When other Users are modifiying data in the firebase realtime database that impacts the profile page, it must update the profile page to reflect that change. Including fields like number of followers and number of following. along with there lists, etc. When the current users are in this view controller. RealTime Interactions can be tracked when other users are in feed and follow the current user.
    
}
