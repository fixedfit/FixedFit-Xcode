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
    
    var localizedDescription: String{
        switch self {
        case .invalidStoryboardName: return "Invalid Storyboard Name"
        case .invalidVCName: return "Invalid View Controller Name"
        }
    }
}
enum SettingKeys: String{
    case deletion = "delete account"
    case emailUpdate = "change email"
    case passwordUpdate = "change password"
    case newCategory = "add category"
}
class SettingsVC: UIViewController, UIGestureRecognizerDelegate, ReauthenticationDelegate, UserInfoDelegate{
    
    let firebaseManager = FirebaseManager.shared
    let usermanager = UserStuffManager.shared
    
    //Variables used to obtain the email and password for reauthentication
    var userEmail:String!
    var userPassword:String!
    
    //Variable used to hold the value to be used to update user info
    var userInfo:String!
    
    //Variable used to determine if the view controller has been cancelled
    //Initialize it to false to check whenever it was cancelled
    var cancelled = false
    
    //Initialize dispatch group to wait for the ReauthenticationVC nib file to be finish presented
    let dispatch = DispatchGroup()
    
    //View references for tap gestures for particular actions
    @IBOutlet weak var CategoryView: UIView!
    @IBOutlet weak var BlockUserView: UIView!
    @IBOutlet weak var ChangeEmailView: UIView!
    @IBOutlet weak var ChangePasswordView: UIView!
    @IBOutlet weak var TutorialView: UIView!
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
        
        //Tutorial
        let tutorialsTap = UITapGestureRecognizer(target:self, action: #selector(SettingsVC.tappedTutorialView))
        tutorialsTap.delegate = self
        TutorialView.isUserInteractionEnabled = true
        TutorialView.addGestureRecognizer(tutorialsTap)
        
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
    
    //Function used to present the final Information VC for errors or successes
    private func presentFinalInfoVC(message: String, imageName: String){
        //Generate second informationVC and present it
        let buttonDataRight = ButtonData(title: "OK", color: .fixedFitBlue, action: nil)
        let secondInformationVC = InformationVC(message: message, image: UIImage(named: imageName), leftButtonData: nil, rightButtonData: buttonDataRight)
        
        self.present(secondInformationVC, animated: true, completion:nil)
    }
    
    //MARK: Function used to modify account only after the reauthenticateVC has been dismissed
    private func modifyAccount(operation:String){
        
        //Initialize the cancelled variable to false
        self.cancelled = false
        
        ////call firebase function to perform parameter operation.
        //Initialize variables used to determine if parameter is successful
        var reauthenticationCode:Int!
        var nextMessage = ""
        
        //Implement dispatch to make main wait until reauthentication view controller was done
        self.dispatch.enter()
        
        //Generate a view controller to obtain the email and password
        let buttonAction = ButtonData(title: "", color: UIColor()){
            self.dispatch.leave()
        }
        let reauthVC = ReauthenticateVC(button: buttonAction)
        reauthVC.delegate = self
        self.present(reauthVC, animated: true, completion: nil)

        self.dispatch.notify(queue: .main){
            
            //Obtain the user's email and password
            let email = self.userEmail!
            let password = self.userPassword!
            
            //Determine if the user clicked cancel on the ReauthenticationVC
            if(self.cancelled == false){
            
                //Generate a InformationVC that lets the user know that they are being reauthenticated
                let ReauthenticatingVC = InformationVC(message: "Reauthenticating...", image: UIImage(named: "add"), leftButtonData: nil, rightButtonData: nil)
                self.present(ReauthenticatingVC, animated: true, completion: nil)
                
                //The user must be reauthenticated in order to be able to modify the account
                //Implement dispatch to wait for reathentication to finish
                self.dispatch.enter()
                self.firebaseManager.reautheticateUser(currentUserEmail: email, currentUserPassword: password, completion:{(value) in
                    reauthenticationCode = value
                    
                    //Dismissing ReauthenticatingVC
                    self.dismiss(animated: true){
                        self.dispatch.leave()
                    }
                })

                self.dispatch.notify(queue: .main){

                    if(reauthenticationCode != 1){
                        if(reauthenticationCode == 0){
                            nextMessage = "Reauthentication Failed"
                        } else if(reauthenticationCode == -1){
                            nextMessage = "Error: Empty Email or Password Entry"
                        } else if(reauthenticationCode == -2){
                            nextMessage = "Error: Incorrect Email"
                        }
                        
                        //Present a informationVC that lets the user know that there was an error
                        self.presentFinalInfoVC(message: nextMessage, imageName: "error diagram")
                        
                    } else if(reauthenticationCode == 1) {
                        
                        //Generate InformationVC for changing email and password cases
                        if(operation == SettingKeys.emailUpdate.rawValue || operation == SettingKeys.passwordUpdate.rawValue){
                            
                            //Initialize button action and enter block
                            self.dispatch.enter()
                            let button = ButtonData(title: "", color: UIColor()){
                                self.dispatch.leave()
                            }
                            
                            //Instantiate view controller and present it
                            let vc = ChangeUserInfoVC(buttonAction: button, changingInfoMode: operation)
                            vc.delegate = self
                            self.present(vc, animated: true, completion: nil)

                        } else {
                            self.userInfo = ""
                        }
                        
                        self.dispatch.notify(queue: .main){
                            
                            //Determine if the cancel variable is set to false
                            if(self.cancelled == false){
                            
                                ////Generate Information vc to let user know that the operation is currently being executed
                                //Initialize a temporary string to inform user of current operation
                                var operatingString: String!
                                
                                //Assign the string value with a proper message to let the user know of the progress being made
                                if(operation == SettingKeys.emailUpdate.rawValue){
                                    operatingString = "Changing Email is in Progress"
                                } else if(operation == SettingKeys.passwordUpdate.rawValue){
                                    operatingString = "Changing Password is in Progress"
                                } else if(operation == SettingKeys.deletion.rawValue){
                                    operatingString = "Deletion of Account is in Progress"
                                } else {
                                    operatingString = "unknown operation"
                                }
                                
                                //present the view controller
                                let progressVC = InformationVC(message: operatingString, image: UIImage(named: "graycheckmark"), leftButtonData: nil, rightButtonData: nil)
                                self.present(progressVC, animated: true, completion: nil)
                               
                                ////Modify the account
                                self.firebaseManager.manageUserAccount(commandString: operation, updateString: self.userInfo, completion: {(error) in
                                    
                                    //Dismiss the view controller that is mean't to display the current operation (i.e progressVC)
                                    self.dismiss(animated: true){
                                        
                                        //If message is reached then modification of account was unsuccessful.
                                        if(error != nil){
                                            if(operation == SettingKeys.deletion.rawValue){
                                                nextMessage = "Deletion of Account Failed"
                                            } else if(operation == SettingKeys.emailUpdate.rawValue){
                                                nextMessage = "Update of Email Failed"
                                            } else if(operation == SettingKeys.passwordUpdate.rawValue){
                                                nextMessage = "Update of Password Failed"
                                            } else {
                                                nextMessage = "Updating Account Operation Failed"
                                            }
                                            
                                            //Display the View controller that lets the user know that there was an error
                                            self.presentFinalInfoVC(message: nextMessage, imageName: "error diagram")
                                        } else if(operation != SettingKeys.deletion.rawValue){
                                            
                                            //Display the View controller that lets the user know that it was successful unless it is the deletion operation
                                            var message: String!
                                            if(operation == SettingKeys.emailUpdate.rawValue){
                                                message = "Updated Email Successfully"
                                            } else if(operation == SettingKeys.passwordUpdate.rawValue){
                                                message = "Updated Password Successfully"
                                            }
                                            self.presentFinalInfoVC(message: message, imageName: "bluecheckmark")
                                        }
                                    }//Dismissing of ProgressVC
                                })
                            }//If statement for determining cancel
                        } // Dispatch for managing user data
                    } // Reauthentication if-else conditions
                } // Dispatch for Reatuhentication if-else
            } // End of if statement if user selected cancel on the reauthenticationVC
        }
    }
    
    //MARK: Management of Categories
    @objc func tappedCategory(_ sender: UITapGestureRecognizer){
        
        //Transition to CategoriesVC
        guard let vc = PushViews.executeTransition(vcName: PushViewKeys.categoriesVC, storyboardName: PushViewKeys.home, newString:"Custom Categories", newMode:"") else {return}
        
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
        guard let vc = PushViews.executeTransition(vcName: PushViewKeys.userfinderVC, storyboardName: PushViewKeys.userfinder, newString:FirebaseUserFinderTitle.blocked, newMode:FirebaseUserFinderMode.blocked) else {return}

        if let vc = vc as? UserFinderVC{
            //Push View Controller onto Navigation Stack
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let vc = vc as? InformationVC{
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: Change user email and password
    @objc func tappedChangeEmail(_ sender: UITapGestureRecognizer){

        //Function called to update email
        self.modifyAccount(operation: SettingKeys.emailUpdate.rawValue)
        
    }
    @objc func tappedChangePassword(_ sender: UITapGestureRecognizer){
        
        //Function called to update password
        self.modifyAccount(operation: SettingKeys.passwordUpdate.rawValue)
        
    }
    
    //MARK: Tutorials
    @objc func tappedTutorialView(_ sender: UITapGestureRecognizer){
        
        //Transition to Help Center
        guard let vc = PushViews.executeTransition(vcName: PushViewKeys.tutorialVC, storyboardName: PushViewKeys.home, newString:FirebaseSupportTitleAndMode.tutorial) else {return}
        
        if let vc = vc as? TutorialVC{
            //Push View Controller onto Navigation Stack
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let vc = vc as? InformationVC{
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: Support - Help Center(FAQ) and Contacts
    @objc func tappedHelpCenter(_ sender: UITapGestureRecognizer){
        
        //Transition to Help Center
        guard let vc = PushViews.executeTransition(vcName: PushViewKeys.supportVC, storyboardName: PushViewKeys.home, newString:FirebaseSupportTitleAndMode.helpCenter, newMode: FirebaseSupportTitleAndMode.helpCenter) else {return}
        
        if let vc = vc as? SupportVC{
            
            //Before push the view controller onto the stack, assign the SupportVC's selectedClass variable to the corresponding help center class
            vc.selectedClass = HelpCenter_FAQ()
            
            //Push View Controller onto Navigation Stack
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let vc = vc as? InformationVC{
            self.present(vc, animated: true, completion: nil)
        }
    }
    @objc func tappedContacts(_ sender: UITapGestureRecognizer){
        
        let contactUsVC = ContactUsVC()
        self.present(contactUsVC, animated: true, completion: nil)
    
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
            
            //Call function to delete user's account
            self?.modifyAccount(operation: SettingKeys.deletion.rawValue)
            
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
    func didAcceptCredentials(email: String, password: String, cancel: Bool) {
        self.userEmail = email
        self.userPassword = password
        self.cancelled = cancel
    }
    
    //ChangeUserInfoVC function:
    /*
     Function takes one parameter from the ChangeUserInfoVC that contains the updated email or password from the user
    */
    func saveUserInfo(userInfo: String, cancel: Bool) {
        self.userInfo = userInfo
        self.cancelled = cancel
    }
    
}
