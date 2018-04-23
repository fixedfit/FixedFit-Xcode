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
enum ProfileOutfitKeys: String{
    case all = "all"
    case publicOutfits = "public"
    case privateOutfits = "private"
    case cancel = "cancel"
}
class ProfileVC: UIViewController, UIGestureRecognizerDelegate, OutfitSelectorDelegate {
    enum CurrentDisplay {
        case outfit
        case likes
        case favorite
    }

    let firebaseManager = FirebaseManager.shared
    let userStuffManager = UserStuffManager.shared

    //MARK: Initialize integer counters to count the number of followers and followings the user currently has.
    var FollowersCounter = 0
    var FollowingCounter = 0
    
    //MARK: varible used to determine if the outfit selection was already being presented or if it is not being presented
    var outfitDisplayed: Bool!
    var outfitdisplayingStatus: String!

    var outfitsVC: OutfitsVC!
    var selectedOutfit: Outfit!

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

        //Set Initial state of outfitDisplayed when the profile view is loaded
        self.outfitDisplayed = false
        
        //Adjust texts in labels to fit the width of the label
        self.UserBio.numberOfLines = 0
        self.UserBio.adjustsFontSizeToFitWidth = true
        self.UserFirstName.adjustsFontSizeToFitWidth = true
        self.UserLastName.adjustsFontSizeToFitWidth = true
        self.FollowingCount.adjustsFontSizeToFitWidth = true
        self.FollowersCount.adjustsFontSizeToFitWidth = true
        
        //Give UITapGesture to the Following and Follower views
        let followingTap = UITapGestureRecognizer(target:self, action: #selector(ProfileVC.tappedFollowing))
        followingTap.delegate = self
        let followersTap = UITapGestureRecognizer(target:self, action: #selector(ProfileVC.tappedFollowers))
        followersTap.delegate = self

        FollowingButton.isUserInteractionEnabled = true
        FollowersButton.isUserInteractionEnabled = true
        FollowingButton.addGestureRecognizer(followingTap)
        FollowersButton.addGestureRecognizer(followersTap)

        let outfitsVC = UIStoryboard.outfitsVC as! OutfitsVC
        childVCView.addSubview(outfitsVC.view)
        outfitsVC.view.fillSuperView()
        self.outfitsVC = outfitsVC
        outfitsVC.outfits = userStuffManager.closet.outfits
        self.addChildViewController(outfitsVC)
    }

    //MARK: Update profile page once view appears.
    override func viewWillAppear(_ animated: Bool) {
        outfitsVC.viewWillAppear(true)

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
        self.FollowingCount.text = String(userStuffManager.userInfo.following.count)
        self.FollowersCount.text = String(userStuffManager.userInfo.followers.count)

        ////Load the User's profile photo into the UIImageView
        //if there is picture already set for the user's profile, then retrieve the photo from firebase, otherwise it will place the default image for the user

        Image = userStuffManager.userInfo.photo
        //Generate a UIImage from the user's photo
        //ContentMode is used to scale images
        UserProfileImage.contentMode = UIViewContentMode.scaleAspectFit
        let image = Image
        UserProfileImage.image = image
        
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
        
        //Initialize outfit displaying status
        self.outfitdisplayingStatus = ""
        
        //Initialize a DispatchGroup to notify main to execute the viewing of the specific outfits
        let dispatch = DispatchGroup()
        
        //Determine if the button for the outfit Displaying is already selected
        if(outfitDisplayed == true){
            
            dispatch.enter()
            //Generate the button and the outfitSelecitonVC to show the nibfile's view to the user
            let button = ButtonData(title: "", color: UIColor()){
                dispatch.leave()
            }
            
            let outfitSelectorVC = OutfitSelectionVC(button: button)
            outfitSelectorVC.delegate = self
            self.present(outfitSelectorVC, animated: true, completion: nil)
        }
        
        //Make main execute this section strictly after the OutfitSelectionVC has been dismissed
        //This section will perform the displaying of certain outfits, either all outfits, public outfits, or private outfits
        dispatch.notify(queue: .main){
            print("Tapped outfits")
        }
        
        //If the outfit button is was tapped, then make the boolean value of the outfitDisplayed variable to true
        self.outfitDisplayed = true
        
    }

    @IBAction func tappedLiked(_ sender: UITapGestureRecognizer) {
        
        //If the liked button is was tapped, then make the boolean value of the outfitDisplayed variable to false
        self.outfitDisplayed = false
        
        //Display only the outfits of other user's that the current user liked
        
        
        print("Tapped liked")
    }

    @IBAction func tappedFavorited(_ sender: UITapGestureRecognizer) {

        //If the liked button is was tapped, then make the boolean value of the outfitDisplayed variable to false
        self.outfitDisplayed = false
        
        //Display only the outfits that belongs to the current user that they liked
        
        
        print("Tapped favorited")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let outfitItemsVC = segue.destination as? OutfitItemsVC {
            outfitItemsVC.outfit = selectedOutfit
        }
    }

    //Implement the function of the OutfitSelectionVC
    func displaySelection(selection:String){
        self.outfitdisplayingStatus = selection
    }

    //MARK: When other Users are modifiying data in the firebase realtime database that impacts the profile page, it must update the profile page to reflect that change. Including fields like number of followers and number of following. along with there lists, etc. When the current users are in this view controller. RealTime Interactions can be tracked when other users are in feed and follow the current user.

}
