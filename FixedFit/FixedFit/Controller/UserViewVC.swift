//
//  UserViewVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/7/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

/*
 Assumptions of UserFinder operations for UserView to interpret status of user properly
 1-UserFinder searching operation does not pull any user profiles that are blocked by the currentUser or the other users.
 2-UserFinder mode's should determine the operation of the UserFinder search and should reflect the search criteria established from the mode.
    -searching through followers should only pull results of users that are following the currentUser.
    -searching through users you are following should only pull results of users that you are following.
    -search for users from the feed should be able to pull any User's profile given main criteria 1 is not broken.
 */

import UIKit

struct LeftButtonLabels{
    static let following = "Following"
    static let blocked = "Blocked"
    static let search = "Follow"
}
struct RightButtonLabels{
    static let following = "Unfollow"
    static let blocked = "Unblock"
    static let search = "Block"
}

class UserViewVC: UIViewController, UIGestureRecognizerDelegate{
    
    //Variable used to present the title, which is the username, the mode and the other user's profile status
    var uid: String!
    var mode: String!
    var profileStatus:Bool!
    
    //Varible for handler
    var userNameHandle: UInt = 0
    var userStatusHandle: UInt = 0
    
    @IBOutlet weak var UserChildVCView: UIView!
    @IBOutlet weak var LeftButton: UIButton!
    @IBOutlet weak var RightButton: UIButton!
    @IBOutlet weak var PrivateStatusMessage: UILabel!
    @IBOutlet weak var UserViewChildVCView: UIView!
    
    
    //Initialize boolean variable to control what mode is being active
    //Note, when selectionStatus = true - current user has either followed or blocked the user
    //      when selectionStatus = false - current user is either searching for general users, looking at followers, or has deselected a button to not be a follower or unblock another user
    var selectionStatus:Bool!
    
    let firebaseManager = FirebaseManager.shared
    let userStuffManager = UserStuffManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide or show the UserChildVC and the PrivateStatusMessage
        if profileStatus{
            self.PrivateStatusMessage.isHidden = true
            self.UserChildVCView.isHidden = false
        } else {
            self.PrivateStatusMessage.isHidden = false
            self.UserChildVCView.isHidden = true
        }
        
        //set up font for the buttons
        let buttonFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
        self.LeftButton.titleLabel?.font = buttonFont
        self.RightButton.titleLabel?.font = buttonFont
        
        ////Set titles for buttons initially
        //Note, UserFinder must display users of the table view cells corresponding to what mode it is in and whether they have performed an action once they go back and changed the state of the user(either blocked, following, etc.)
        if(self.mode == FirebaseUserFinderMode.following){
            
            self.selectionStatus = true
            self.LeftButton.isUserInteractionEnabled = false
            
        } else if(self.mode == FirebaseUserFinderMode.blocked){
            
            self.selectionStatus = true
            self.LeftButton.isUserInteractionEnabled = false
            
        //If other cases returned false then there is a need to find out the relationship the selected user and the current user has
        //to set the buttons correctly
        } else {
            
            self.selectionStatus = false
            
        }
        
        //Determine mode to display button layout
        self.changeStatus(mode: self.mode, selectionStatus: self.selectionStatus)
        
        //Set message and properties of PrivateMessageStatus label
        self.PrivateStatusMessage.text = "User's profile is private"
        self.PrivateStatusMessage.isUserInteractionEnabled = false
        self.PrivateStatusMessage.adjustsFontSizeToFitWidth = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        ////Fetch the selected user's information from firebase by using the observers
        //Add observers for both username and userstatus
        addUserNameObservers()
        addUserStatusObserver()
    }
    
    //Function to update the status of the user and the buttons if the user has selected a button or loaded the view
    //Note, when user selected a button, the current mode of the user before it was pressed is passed into the function
    func changeStatus(mode: String, selectionStatus: Bool){
        
        if(mode == ""){
            print("Internal error: Mode has not been defined with the button layout, status representation, and scheme")
            return
        }
        
        //If user selected to follow user or is already currently following when loading UserViewVC
        if(mode == FirebaseUserFinderMode.following && selectionStatus == true){
            
            changeButtonStatus(changeStatus: FirebaseUserFinderMode.following)
            
            //Obtain the array of string that contains the list of users you are following
            let followingArray = self.userStuffManager.userInfo.following
            
            //Check to see if this selected user in the following list of the current user
            //If they are not in there then add the user, otherwise just ignore it since this moment in time is when the UserViewVC is loaded into memory
            if(!followingArray.contains(self.uid)){
                self.addUserToList(modeList: mode, uid: self.uid)
            }
            
        //If user selected to block user or is already currently in the blocking state when loading UserViewVC
        } else if(mode == FirebaseUserFinderMode.blocked && selectionStatus == true){
            
            changeButtonStatus(changeStatus: FirebaseUserFinderMode.blocked)
            
            //Obtain the array of string that contains the list of users you have blocked
            let blockedArray = self.userStuffManager.userInfo.blocked
            
            //Check to see if this selected user in the following list of the current user
            //If they are not in there then add them
            if(!blockedArray.contains(self.uid)){
                self.addUserToList(modeList: mode, uid: self.uid)
            }
            
        //If other cases returned false then there is a need to find out the relationship that selected user to the current user hasto set the buttons correctly
        //If the user has deselected a status of blocking or following another user, then it will go into this else statement.
        } else {
            
            //Since the search or follower mode is set, we need to distingush what relationship the other user has with the current user
            //The if section deals with only changing the display of the buttons
            if(mode == FirebaseUserFinderMode.search || mode == FirebaseUserFinderMode.follower){
                
                //Obtain the array of string that contains the list of users you are following
                let followingArray = self.userStuffManager.userInfo.following
                
                //Search through following list otherwise default button scheme to search button scheme
                //If they are in there then update the buttons
                if(followingArray.contains(self.uid)){
                    changeButtonStatus(changeStatus: FirebaseUserFinderMode.following)
                    self.LeftButton.isUserInteractionEnabled = false
                } else {
                    changeButtonStatus(changeStatus: FirebaseUserFinderMode.search)
                }
                
            //If an option has been deselected, then remove user from the corresponding mode's list
            } else if(!selectionStatus){
                changeButtonStatus(changeStatus: FirebaseUserFinderMode.search)
                self.removeUserFromList(modeList: mode, uid: self.uid)
            }
        }
    }
    
    //Function used to make changes to the button's title and colors based on the action that the buttons performed
    func changeButtonStatus(changeStatus: String){
        
        let buttonFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.LeftButton.titleLabel?.font = buttonFont
        self.RightButton.titleLabel?.font = buttonFont
        
        //Following button scheme
        if(changeStatus == FirebaseUserFinderMode.following){
            
            self.LeftButton.setTitle(LeftButtonLabels.following, for: .normal)
            self.RightButton.setTitle(RightButtonLabels.following, for: .normal)
            
        //Blocked button scheme
        } else if(changeStatus == FirebaseUserFinderMode.blocked){
            
            self.LeftButton.setTitle(LeftButtonLabels.blocked, for: .normal)
            self.RightButton.setTitle(RightButtonLabels.blocked, for: .normal)
            
        //Search button scheme
        } else if(changeStatus == FirebaseUserFinderMode.search){
            
            self.LeftButton.setTitle(LeftButtonLabels.search, for: .normal)
            self.RightButton.setTitle(RightButtonLabels.search, for: .normal)
            
        }
    }
    
    //Function to add user to list pertaining to the parameter that is passed
    func addUserToList(modeList: String, uid: String){
        self.userStuffManager.addUserToList(listMode: modeList, uid: uid)
    }
    
    //Function to remove user to list pertaining to the parameter that is passed
    func removeUserFromList(modeList: String, uid: String){
        self.userStuffManager.removeUserFromList(listMode: modeList, uid: uid)
    }
    
    //Actions from the buttons on what each should do when they are pressed
    @IBAction func LeftButtonTapped(_ sender: UIButton) {
        
        //If selectionStatus condition is true, then it means that the user is selecting to follow someone
        if !self.selectionStatus {
            self.LeftButton.isUserInteractionEnabled = false
            self.selectionStatus = true
        }
        
        if(self.LeftButton.isUserInteractionEnabled == false){
            //Determine which mode should be passed to changeStatus function by tapping the right button
            changeStatus(mode:retrieveModeFromButtonTapped(buttonSwitch: true), selectionStatus: selectionStatus)
        }
    }
    @IBAction func RightButtonTapped(_ sender: UIButton) {
        
        if self.selectionStatus {
            self.selectionStatus = false
            self.LeftButton.isUserInteractionEnabled = true
        } else {
            self.selectionStatus = true
            self.LeftButton.isUserInteractionEnabled = false
        }
        
        //Determine which mode should be passed to changeStatus function by tapping the right button
        changeStatus(mode: retrieveModeFromButtonTapped(buttonSwitch: false), selectionStatus: selectionStatus)
    }
    
    func retrieveModeFromButtonTapped(buttonSwitch: Bool)->String{
        
        //If button swift is true, the the user clicked on the left button. Otherwise, the user clicked on the right button
        if(buttonSwitch){
            switch self.LeftButton.titleLabel?.text!{
            case LeftButtonLabels.search: return FirebaseUserFinderMode.following
            case LeftButtonLabels.following: return FirebaseUserFinderMode.following
            case LeftButtonLabels.blocked: return FirebaseUserFinderMode.blocked
            default: return ""
            }
        } else {
            switch self.RightButton.titleLabel?.text!{
            case RightButtonLabels.search: return FirebaseUserFinderMode.blocked
            case RightButtonLabels.following: return FirebaseUserFinderMode.following
            case RightButtonLabels.blocked: return FirebaseUserFinderMode.blocked
            default: return ""
            }
        }
        
        return ""
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UserProfileInfoVC {
            vc.uid = self.uid
            vc.currentUserCheck = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        //Remove the observers for this view
        firebaseManager.ref.removeObserver(withHandle: self.userNameHandle)
        firebaseManager.ref.removeObserver(withHandle: self.userStatusHandle)
        
        //Reset observers
        self.userNameHandle = 0
        self.userStatusHandle = 0
    }
    
    //Add observers to pull information quickly from both viewDidLoad and viewWillAppear
    func addUserNameObservers(){
        ////Fetch the selected user's information from firebase by using the observers
        self.userNameHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.username.rawValue).observe(.value, with: {(snapshot) in
            
            //retrieve the User's username
            if let username = snapshot.value as? String {
                
                //set the User's username
                self.navigationItem.title = username
            }
        })
    }
    func addUserStatusObserver(){
        self.userStatusHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.publicProfile).observe(.value, with: {(snapshot) in
            if let userStatus = snapshot.value as? Bool{
                
                //Hide or display the PrivateStatusMessage label and vice versa on the outfits of this user if the current user is not a follower of the other user
                //If true, then user's profile is public
                //If false, then user's profile is private
                if userStatus{
                    self.PrivateStatusMessage.isHidden = true
                    self.UserChildVCView.isHidden = false
                } else {
                    self.PrivateStatusMessage.isHidden = false
                    self.UserChildVCView.isHidden = true
                }
            }
        })
    }
}
