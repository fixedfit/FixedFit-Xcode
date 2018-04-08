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

class SettingsVC: UIViewController, UIGestureRecognizerDelegate, ReauthenticationDelegate{
    
    let firebaseManager = FirebaseManager.shared
    let usermanager = UserStuffManager.shared
    
    //Label reference for push notification label
    @IBOutlet weak var PushStatus: UILabel!
    
    //Variables used to obtain the email and password for reauthentication
    var userEmail:String!
    var userPassword:String!
    
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
    
    //MARK: Management of Categories
    @objc func tappedCategory(_ sender: UITapGestureRecognizer){
        
        //Transition to CategoriesVC
        guard let vc = PushViews.executeTransition(vcName: "CategoriesVC", storyboardName: "Home", newTitle:"Categories", newMode:"") else {return}
        
        if let vc = vc as? CategoriesVC{
            //Push View Controller onto Navigation Stack
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let vc = vc as? InformationVC{
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: Management of blocked users
    @objc func tappedBlockUsers(_ sender: UITapGestureRecognizer){
        
        //Transition to the UserFinder storyboard where you would want to look for Blocked Users
        guard let vc = PushViews.executeTransition(vcName: "UserFinderVC", storyboardName: "UserFinder", newTitle:FirebaseUserFinderTitle.blocked, newMode:FirebaseUserFinderMode.blocked) else {return}

        if let vc = vc as? UserFinderVC{
            //Push View Controller onto Navigation Stack
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let vc = vc as? InformationVC{
            self.present(vc, animated: true, completion: nil)
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
        
        //Transition to Help Center
        guard let vc = PushViews.executeTransition(vcName: "SupportVC", storyboardName: "Home", newTitle:FirebaseSupportVCTitleAndMode.helpCenter, newMode:"") else {return}
        
        if let vc = vc as? SupportVC{
            //Push View Controller onto Navigation Stack
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let vc = vc as? InformationVC{
            self.present(vc, animated: true, completion: nil)
        }
    }
    @objc func tappedContacts(_ sender: UITapGestureRecognizer){
        
        //Transition to Contact Us
        guard let vc = PushViews.executeTransition(vcName: "SupportVC", storyboardName: "Home", newTitle:FirebaseSupportVCTitleAndMode.contactUs, newMode:"") else {return}
        
        if let vc = vc as? SupportVC{
            //Push View Controller onto Navigation Stack
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let vc = vc as? InformationVC{
            self.present(vc, animated: true, completion: nil)
        }
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
            var reauthenticationCode:Int!
            var nextMessage = ""
            
            //Initialize variables used to determine
            let email = self?.userEmail! ?? ""
            let password = self?.userPassword! ?? ""
            
            //Generate a view controller to obtain the email and password
            let reauthVC = ReauthenticateVC()
            reauthVC.delegate = self
            self?.present(reauthVC, animated: true, completion: nil)
            
            //The user must be reauthenticated in order to be able to delete the account
            reauthenticationCode = (self?.firebaseManager.reautheticateUser(currentUserEmail: email, currentUserPassword: password))!
            
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
    
    //Functions from delegates that are implemented by the SettingsVC class
    //ReauthenticationVC function:
    /*
     Function takes in two strings for the ReauthenticationVC.hib file that contains the email and password of the user
    */
    func didAcceptCredentials(email: String, password: String) {
        self.userEmail = email
        self.userPassword = password
    }
    
    //
    
}
