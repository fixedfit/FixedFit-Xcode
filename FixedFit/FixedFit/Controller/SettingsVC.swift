//
//  SettingsVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 3/13/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit

enum SettingErrors: Error{
    case invalidStoryboardName
    case invalidVCName
}

class SettingsVC: UIViewController, UIGestureRecognizerDelegate{
    
    let firebaseManager = FirebaseManager.shared
    let usermanager = UserStuffManager.shared
    
    //Label reference for push notification label
    @IBOutlet weak var PushStatus: UILabel!
    
    //Variables used to obtain the email and password for reauthentication
    var email:String!
    var password:String!
    
    //View references for tap gestures for particular actions
    @IBOutlet weak var CategoryView: UIView!
    @IBOutlet weak var BlockUserView: UIView!
    @IBOutlet weak var ChangeEmailView: UIView!
    @IBOutlet weak var ChangePasswordView: UIView!
    @IBOutlet weak var PushNotificationView: UIView!
    @IBOutlet weak var HelpCenterView: UIView!
    @IBOutlet weak var ContactsView: UIView!
    @IBOutlet weak var LogoutView: UIView!
    @IBOutlet weak var DeleteAccountView: UIView!
    
    override func viewDidLoad() {
        
        //Assign setting title with string
        self.navigationItem.title = "Settings"
        
        ////Add tap gesture to views
        //Category
        let categoryTap = UITapGestureRecognizer(target:self, action: #selector(SettingsVC.tappedCategory))
        categoryTap.delegate = self
        CategoryView.isUserInteractionEnabled = true
        CategoryView.addGestureRecognizer(categoryTap)
        
        //Block User
        let blockUserTap = UITapGestureRecognizer(target:self, action: #selector(SettingsVC.tappedBlockUsers))
        blockUserTap.delegate = self
        BlockUserView.isUserInteractionEnabled = true
        BlockUserView.addGestureRecognizer(blockUserTap)
        
        //Change Email
        let changeEmailTap = UITapGestureRecognizer(target:self, action: #selector(SettingsVC.tappedChangeEmail))
        changeEmailTap.delegate = self
        ChangeEmailView.isUserInteractionEnabled = true
        ChangeEmailView.addGestureRecognizer(changeEmailTap)
        
        //Change Password
        let changePasswordTap = UITapGestureRecognizer(target:self, action: #selector(SettingsVC.tappedChangePassword))
        changePasswordTap.delegate = self
        ChangePasswordView.isUserInteractionEnabled = true
        ChangePasswordView.addGestureRecognizer(changePasswordTap)
        
        //Push Notifications
        let pushNotificationTap = UITapGestureRecognizer(target:self, action: #selector(SettingsVC.tappedPushNotificationView))
        pushNotificationTap.delegate = self
        PushNotificationView.isUserInteractionEnabled = true
        PushNotificationView.addGestureRecognizer(pushNotificationTap)
        
        //Help Center FAQ
        let helpcenterTap = UITapGestureRecognizer(target:self, action: #selector(SettingsVC.tappedHelpCenter))
        helpcenterTap.delegate = self
        HelpCenterView.isUserInteractionEnabled = true
        HelpCenterView.addGestureRecognizer(helpcenterTap)
        
        //Contacts
        let contactsTap = UITapGestureRecognizer(target:self, action: #selector(SettingsVC.tappedContacts))
        contactsTap.delegate = self
        ContactsView.isUserInteractionEnabled = true
        ContactsView.addGestureRecognizer(contactsTap)
        
        //Logout
        let logoutTap = UITapGestureRecognizer(target:self, action: #selector(SettingsVC.tappedLogout))
        logoutTap.delegate = self
        LogoutView.isUserInteractionEnabled = true
        LogoutView.addGestureRecognizer(logoutTap)
        
        //Delete Account
        let deleteTap = UITapGestureRecognizer(target:self, action: #selector(SettingsVC.tappedDeleteAccount))
        deleteTap.delegate = self
        DeleteAccountView.isUserInteractionEnabled = true
        DeleteAccountView.addGestureRecognizer(deleteTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //fetch user info
        usermanager.fetchUserInformation()
        
        //Change label of push notification status
        if (usermanager.userPushNotification == "On"){
            PushStatus.textColor = .fixedFitBlue
            PushStatus.text = "On"
        } else {
            PushStatus.textColor = .fixedFitPurple
            PushStatus.text = "Off"
        }
        
    }
    
    //Function used to execute transitions from a view to a new view that needs to be instantiated on the navigation
    //The Function needs:
    //(view controller name, storyboard name, title for navigation item, mode if view controller contains that variable as a member)
    func executeTransition(vcName: String, storyboardName: String, newTitle:String, newMode:String? = nil) -> UIViewController?{
        
        //Message used to monitor if cases are correct
        var errorMessage = ""
        
        if(vcName.isEmpty || storyboardName.isEmpty || newTitle.isEmpty){
            
            //Modify errorMessage vairable to produce correct error message
            errorMessage = "Error: Invalid String Parameters"
            
        } else {
            
            //Initial view controller
            var vc: UIViewController!
            let storyboard = UIStoryboard(name: storyboardName, bundle:nil)
            
            if(vcName == "UserFinderVC"){
                
                let storyboard = UIStoryboard(name: storyboardName, bundle:nil)
                vc = storyboard.instantiateInitialViewController() as! UserFinderVC
                
                if let vc = vc as? UserFinderVC{
                    //Initialize the title of the ViewController and mode if needed
                    if(newMode != nil){
                        vc.mode = newMode!
                    }
                    vc.viewTitle = newTitle
                }
                
            } else if(vcName == "SupportVC" || vcName == "UserViewVC" || vcName == "CategoriesVC"){
                
                if(vcName == "SupportVC"){
                    vc = storyboard.instantiateViewController(withIdentifier: "SupportVC")  as! SupportVC
                    
                    //Initialize the title of the ViewController
                    if let currentVC = vc as? SupportVC{
                        currentVC.viewTitle = newTitle
                    }
                    
                //For UserViewVC, the title should be the user name of the searched person
                } else if(vcName == "UserViewVC"){
                    vc = storyboard.instantiateViewController(withIdentifier: "UserViewVC") as! UserViewVC
                    
                    //Initialize the title of the ViewController
                    if let currentVC = vc as? CategoriesVC{
                        currentVC.viewTitle = newTitle
                     }
                    
                } else if(vcName == "CategoriesVC"){
                    vc = storyboard.instantiateViewController(withIdentifier: "CategoriesVC") as! CategoriesVC
                    
                    //Initialize the title of the ViewController
                    if let currentVC = vc as? CategoriesVC{
                        currentVC.viewTitle = newTitle
                    }
                }
                
            } else {
                errorMessage = "Error: Unknown view controller name"
            }
            
            //Return view controller
            return vc
        }
        
        if(!(errorMessage.isEmpty)){
            //Generate informationVC to let user know that there was an error in transition
            let rightButtonData = ButtonData(title: "Ok", color: .fixedFitBlue, action: nil)
            let informationVC = InformationVC(message: errorMessage, image: nil, leftButtonData: nil, rightButtonData: rightButtonData)
            self.present(informationVC, animated: true, completion: nil)
        }
        
        //Return nil
        return nil
    }
    
    //MARK: Management of Categories
    @objc func tappedCategory(_ sender: UITapGestureRecognizer){
        print("tapped1")
    }
    
    //MARK: Management of blocked users
    @objc func tappedBlockUsers(_ sender: UITapGestureRecognizer){
        
        //Transition to the UserFinder storyboard where you would want to look for Blocked Users
        guard let vc = executeTransition(vcName: "UserFinderVC", storyboardName: "UserFinder", newTitle:FirebaseUserFinderTitle.blocked, newMode:FirebaseUserFinderMode.blocked) else {return}

        if let vc = vc as? UserFinderVC{
            
            //Push View Controller onto Navigation Stack
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: Change user email and password
    @objc func tappedChangeEmail(_ sender: UITapGestureRecognizer){
        print("tapped5")
    }
    @objc func tappedChangePassword(_ sender: UITapGestureRecognizer){
        print("tapped6")
    }
    
    //MARK: Push Notification Settings
    @objc func tappedPushNotificationView(_ sender: UITapGestureRecognizer){
        if(PushStatus.text == "On"){
            PushStatus.textColor = .fixedFitPurple
            PushStatus.text = "Off"
            
            //Update user's push notifications in firebase
            usermanager.toggelUserPushNotification(newStatus: "Off")
            
        } else {
            PushStatus.textColor = .fixedFitBlue
            PushStatus.text = "On"
            
            //Update user's push notifications in firebase
            usermanager.toggelUserPushNotification(newStatus: "On")
        }
    }
    
    //MARK: Support - Help Center(FAQ) and Contacts
    @objc func tappedHelpCenter(_ sender: UITapGestureRecognizer){
        print("tapped7")
    }
    @objc func tappedContacts(_ sender: UITapGestureRecognizer){
        print("tapped8")
    }
    
    //MARK: log out of user account
    @objc func tappedLogout(_ sender: UITapGestureRecognizer) {
        
        let message = "Are you sure you want to logout?"
        let rightButtonData = ButtonData(title: "Yes, I'm Sure", color: .fixedFitPurple) { [weak self] in
            self?.firebaseManager.logout { _ in }
        }
        let leftButtonData = ButtonData(title: "Nevermind", color: .fixedFitBlue, action: nil)
        let informationVC = InformationVC(message: message, image: #imageLiteral(resourceName: "question"), leftButtonData: leftButtonData, rightButtonData: rightButtonData)
        
        present(informationVC, animated: true, completion: nil)
        
    }

    //MARK: Delete Account
    @objc func tappedDeleteAccount(_ sender: UITapGestureRecognizer){
        
        let message = "Are you sure you want to delete your account?"
        let rightButtonData = ButtonData(title: "Yes, delete account", color: .fixedFitPurple) { [weak self] in
            
            ////call firebase function to perform deletion operation.
            //Initialize variables used to determine if deletion is successful
            var reauthenticationCode = 0
            var nextMessage = ""
            
            //Generate a view controller to obtain the email and password
            
            
            //The user must be reauthenticated in order to be able to delete the account
            //reauthenticationCode = (self?.firebaseManager.reautheticateUser(currentUserEmail: email, currentUserPassword: password))!
            
            if(reauthenticationCode == 0){
                nextMessage = "Reauthentication Failed"
                
            } else if(reauthenticationCode == -1){
                nextMessage = "Error: Empty Email or Password Entry"
            } else if(reauthenticationCode == -2){
                nextMessage = "Error: Incorrect Email"
            } else {
                //Delete the account
                //(self?.firebaseManager.manageUserAccount(commandString: "delete account", updateString: ""))!
                
                //If message is reached then deletion of account was unsuccessful.
                nextMessage = "Deletion of Account Failed"
                
            }
            
            //Determine if informationVC must be generated for error message
            if(reauthenticationCode != 1) || !(nextMessage.isEmpty){
                //Generate second informationVC and present it
                let buttonDataRight = ButtonData(title: "OK", color: .fixedFitBlue, action: nil)
                let secondInformationVC = InformationVC(message: nextMessage, image: self?.usermanager.userphoto, leftButtonData: nil, rightButtonData: buttonDataRight)
                
                self?.present(secondInformationVC, animated: true, completion: nil)
            }
        }
        let leftButtonData = ButtonData(title: "Nevermind", color: .fixedFitBlue, action: nil)
        let informationVC = InformationVC(message: message, image: #imageLiteral(resourceName: "question"), leftButtonData: leftButtonData, rightButtonData: rightButtonData)
        
        present(informationVC, animated: true, completion: nil)
    }
}
