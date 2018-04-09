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
    let userStuffManager = UserStuffManager.shared

    //MARK: Initialize integer counters to count the number of followers and followings the user currently has.
    var FollowersCounter = 0
    var FollowingCounter = 0

    var outfitVC: OutfitVC!

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

    @IBOutlet weak var childVCView: UIView!

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

        let outfitVC = UIStoryboard.outfitVC as! OutfitVC
        childVCView.addSubview(outfitVC.view)
        outfitVC.view.fillSuperView()
        self.outfitVC = outfitVC
        outfitVC.outfits = userStuffManager.closet.outfits
        self.addChildViewController(outfitVC)
    }

    //MARK: Update profile page once view appears.
    override func viewWillAppear(_ animated: Bool) {
        outfitVC.viewWillAppear(true)

        //Fetch the user's Information from the UserStuffManager
        userStuffManager.fetchUserInfo { _ in }

        //Initial UIImage variable used to select the image to output to the screen
        weak var Image: UIImage!

        //Update the title of the navigation bar with the user name of the user
        self.navigationItem.title = userStuffManager.userInfo.username

        //Update labels of profile if user has edited them
        self.UserFirstName.text = userStuffManager.userInfo.firstName
        self.UserLastName.text = userStuffManager.userInfo.lastName
        self.UserBio.text = userStuffManager.userInfo.bio

        ////Update Followers and Following Counters from firebase
        //Update button titles/view counters
        self.FollowingCount.text = String(FollowingCounter)
        self.FollowersCount.text = String(FollowersCounter)


        ////Load the User's profile photo into the UIImageView
        //if there is picture already set for the user's profile, then retrieve the photo from firebase, otherwise it will place the default image for the user

        //Only obtain a single photo under the term: "userphoto" as a parameter which will be used to determine what to look for
        if userStuffManager.userInfo.photo != nil {
            Image = userStuffManager.userInfo.photo
            //Generate a UIImage from the user's photo
            //ContentMode is used to scale images
            UserProfileImage.contentMode = UIViewContentMode.scaleAspectFit
            let image = Image
            UserProfileImage.image = image
        }
    }

    @IBAction func EditTransition(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "EditTransition", sender: self)
    }

    //Functions to the buttons involved in the profile section
    //Execute with transitional view animations
    //perform action when following and followers button are clicked
    @objc func tappedFollowing(sender: UITapGestureRecognizer){
        guard let vc = PushViews.executeTransition(vcName: "UserFinderVC", storyboardName: "UserFinder", newTitle:FirebaseUserFinderTitle.following, newMode:FirebaseUserFinderMode.following) else {return}

        //Check if the View Controller is of a certain View Controller type
        if let vc = vc as? UserFinderVC{

            //Push View Controller onto Navigation Stack
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let vc = vc as? InformationVC{
            self.present(vc, animated: true, completion: nil)
        }
    }
    @objc func tappedFollowers(sender: UITapGestureRecognizer){
        guard let vc = PushViews.executeTransition(vcName: "UserFinderVC", storyboardName: "UserFinder", newTitle:FirebaseUserFinderTitle.follower, newMode:FirebaseUserFinderMode.follower) else {return}

        //Check if the View Controller is of a certain View Controller type
        if let vc = vc as? UserFinderVC{

            //Push View Controller onto Navigation Stack
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let vc = vc as? InformationVC{
            self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func tappedOutfits(_ sender: UITapGestureRecognizer) {
        print("Tapped outfits")
    }

    @IBAction func tappedLiked(_ sender: UITapGestureRecognizer) {
        print("Tapped liked")
    }

    @IBAction func tappedFavorited(_ sender: UITapGestureRecognizer) {
        print("Tapped favorited")
    }


    //MARK: When other Users are modifiying data in the firebase realtime database that impacts the profile page, it must update the profile page to reflect that change. Including fields like number of followers and number of following. along with there lists, etc. When the current users are in this view controller. RealTime Interactions can be tracked when other users are in feed and follow the current user.

}
