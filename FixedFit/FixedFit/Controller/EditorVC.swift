//
//  EditorVC.swift
//  FixedFit
//
//  Created by Mario Buenrostro on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class EditorVC: UIViewController, UITextFieldDelegate,
    UITextViewDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UIGestureRecognizerDelegate{
    
    let usermanager = UserStuffManager.shared
    
    //MARK: Reference for editing photo
    @IBOutlet weak var EditingPhoto: UIImageView!
    
    //MARK: Button for current view status of profile
    @IBOutlet weak var CurrentViewStatus: UIButton!
    
    //MARK: TextFields for name, username, and bios
    @IBOutlet weak var UserNameTextField: UITextField!

    @IBOutlet weak var UserBioTextField: UITextField!
    @IBOutlet weak var UserFirstNameField: UITextField!
    @IBOutlet weak var UserLastNameField: UITextField!

    
    
    //MARK: Initial variable to hold data when view is loaded. to be able to restore data if user improperly entered a field and decided to return back to the previous view.
    var PreviousUserName: String!
    var PreviousUserBio: String?
    var PreviousUserFirstName: String!
    var PreviousUserLastName: String!
    weak var PreviousUserPhoto: UIImage?
//    var PreviousUserFirstName = ""
//    var PreviousUserLastName = ""
//    var PreviousUserName = ""
//    var PreviousUserBio = ""
    var PreviousUserStatus = ""
    
    // Firebase Database Reference
    var ref: DatabaseReference {
        return Database.database().reference()
    }
    
    //MARK: Update current view with relevant information regarding the user's profile
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign the local variables with the corresponding Image and text
        self.UserNameTextField.delegate = self
        self.UserBioTextField.delegate = self
        self.UserFirstNameField.delegate = self
        self.UserLastNameField.delegate = self
        
        self.navigationItem.title = "Edit Profile"
        
        //Add UITapGesture to the UIImage
        let tapped = UITapGestureRecognizer(target:self, action: #selector(EditorVC.tappedPhoto))
        tapped.delegate = self
        EditingPhoto.isUserInteractionEnabled = true
        EditingPhoto.addGestureRecognizer(tapped)
    }
    
    //Allow UIImageView to have touch gesture - this will allow you to perform action when clicking the photo
    @objc func tappedPhoto(sender: UITapGestureRecognizer?){
        
        print("switch photos")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Load up image of user and text fields from previous user stats for user modification
        self.UserNameTextField.text = usermanager.username
        self.UserBioTextField.text = ""
        self.UserFirstNameField.text = usermanager.firstName
        self.UserLastNameField.text = usermanager.lastName
        
        //store previous values into temporary variables for fast exit
        PreviousUserName = self.UserNameTextField.text!
        PreviousUserBio = self.UserBioTextField.text!
        PreviousUserFirstName = self.UserFirstNameField.text!
        PreviousUserLastName = self.UserLastNameField.text!
        PreviousUserStatus = usermanager.userstatus
        
        //Determine if the user has already set up a photo or if it needs to use the default profile pic
        if usermanager.userphoto == nil{
            self.PreviousUserPhoto = UIImage(named:"defaultProfile")
        } else {
            print("data from firebase")
        }
        
        //Add the image onto the UIImaveView and scale it
        let image = self.PreviousUserPhoto
        EditingPhoto.contentMode = UIViewContentMode.scaleAspectFit
        EditingPhoto.image = image
        
        //update current viewing status from firebase field into the button field
        if (usermanager.userstatus == "Public"){
            self.CurrentViewStatus.setTitle("Public", for: [])
        } else {
            self.CurrentViewStatus.setTitle("Private", for: [])
        }
        
    }
    
    //Hide keyboard when users touch outside the text boxes
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Hide keyboard when users touch the done button on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Resign the Text Field from being the first responder
        UserNameTextField.resignFirstResponder()
        UserBioTextField.resignFirstResponder()
        UserFirstNameField.resignFirstResponder()
        UserLastNameField.resignFirstResponder()
        
        return true
    }
    
    //Change the current view status for profile
    @IBAction func changeStatus(_ sender: UIButton) {
    
        //Determine if the status was public or private before the switching of the view status
        if usermanager.userstatus == "Public"{
            self.CurrentViewStatus.setTitle("Private", for: [])
            
            //Update switch of view status to private
            usermanager.toggleUserStatus(newStatus: "Private")
            
        } else {
            self.CurrentViewStatus.setTitle("Public", for: [])
            
            //Update switch of view status to public
            usermanager.toggleUserStatus(newStatus: "Public")

        }
    
    }
    
    //perform any last minute error checks and Exit editor view if needed
    @IBAction func ExitEditor(_ sender: UIBarButtonItem) {
        
        //Error message used to be concatenated to let the user know what to do
        var errorMsg = "Error Status:\n"
        
        //store original error message to confirm if any errors were found
        let oldErrorMsg = errorMsg
        
        //Initialize button message to empty
        var leftMessage = ""
        var rightMessage = ""
        var leftButton:ButtonData!
        var rightButton:ButtonData!
        
        //if there was no changes, then just return without asking the user to save or not
        if((self.UserFirstNameField.text == PreviousUserFirstName) && (self.UserLastNameField.text == PreviousUserLastName) && (self.UserBioTextField.text == PreviousUserBio) && (self.UserNameTextField.text == PreviousUserName) && /*(EditingPhoto.image != PreviousUserPhoto) &&*/ (usermanager.userstatus == PreviousUserStatus)){
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        //Perform error checking
        //Determine if UserName crietria is satisfied

        if (UserNameTextField.text!.isEmpty){
            errorMsg += "User Name Field is empty.\n"
        } else if( (UserNameTextField.text!.count) > 35){
            
        //Check if user name already exists
        } else {
        
        // Check if user name already exists
            let newUsername = UserNameTextField.text!

                ref.child(FirebaseKeys.users).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let allUsersInfo = snapshot.value as? [String: [String: Any]] {
                        var goodNewUsername = true
                        
                        for (_, userInfo) in allUsersInfo {
                            if let takenUsername = userInfo[FirebaseKeys.username] as? String {
                                if takenUsername == newUsername {
                                    goodNewUsername = false
                                }
                            }
                        }

                        if (!goodNewUsername) {
                            print("User Name already exists.\n")
                        }
                        else{
                            //save new username
                        }

                    }
                })

        }
        
        if(UserFirstNameField.text!.isEmpty){
            errorMsg += "First Name Field is empty.\n"
        } else if(( (UserFirstNameField.text!.count) > 35)){
            errorMsg = errorMsg + "max character limit reached.\n"
            //print("max character limit reached")
        } else {
            //set new
        }
        
        if(UserLastNameField.text!.isEmpty){
            errorMsg = errorMsg + "Last Name Field is empty.\n"
        } else if(( (UserLastNameField.text!.count) > 35)){
            errorMsg = errorMsg + "max character limit reached.\n"
            //print("max character limit reached")
        }
        
        if(UserBioTextField.text!.isEmpty){
            errorMsg = errorMsg + "No Bio Set.\n"
            UserBioTextField.text = "No Bio Set."
            
        } else if(( (UserBioTextField.text!.count) > 100)){
            print("max character limit reached")
            errorMsg = errorMsg + "max character limit reached.\n"
        }
        
        //if the error message is the same, then changes are successful
        if(oldErrorMsg == errorMsg){
            leftMessage = "make more changes"
            rightMessage = "save changes"
            errorMsg = "Would you like to save changes?"
            
            //Update previous user information with the new content
            usermanager.updateUserInfo(firstname: self.UserFirstNameField.text!, lastname: self.UserLastNameField.text!, bio: self.UserBioTextField.text!, name_of_user: self.UserNameTextField.text!, photo: EditingPhoto.image)
        } else {
            leftMessage = "fix issues"
            rightMessage = "discard changes"
            errorMsg = errorMsg + "Would you like to discard changes and go to profile?\n"
        }
        
        //Set button messages
        leftButton = ButtonData(title: leftMessage, color: .fixedFitPurple, action: nil)
        rightButton = ButtonData(title: rightMessage, color: .fixedFitBlue){
            self.dismiss(animated: true, completion: nil)
        }
        
        
        //Generate the informationVC and present it to the user
        let informationVC = InformationVC(message: errorMsg, image: #imageLiteral(resourceName: "question"), leftButtonData: leftButton, rightButtonData: rightButton)
        
        present(informationVC, animated: true, completion: nil)


        //debug message
        print(errorMsg)
        
//        //Use informationVC object to select decision
//        self.dismiss(animated: true, completion: nil)

       
        
    }
    
}
