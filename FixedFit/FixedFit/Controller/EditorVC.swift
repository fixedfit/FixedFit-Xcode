//
//  EditorVC.swift
//  FixedFit
//
//  Created by Mario Buenrostro on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit

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
    weak var PreviousUserPhoto: UIImage?
    
    //MARK: Update current view with relevant information regarding the user's profile
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign the local variables with the corresponding Image and text
        self.UserNameTextField.delegate = self
        self.UserBioTextField.delegate = self
        self.UserFirstNameField.delegate = self
        self.UserLastNameField.delegate = self
        
        self.navigationItem.title = "Edit Profile"
        
        //Temporarily store the previous texts and user photo from firebase before any changes are made
        
        //Add UITapGesture to the UIImage
        let tapped = UITapGestureRecognizer(target:self, action: #selector(EditorVC.tappedPhoto))
        tapped.delegate = self
        EditingPhoto.isUserInteractionEnabled = true
        EditingPhoto.addGestureRecognizer(tapped)
    }
    
    //Allow UIImageView to have touch gesture
    @objc func tappedPhoto(sender: UITapGestureRecognizer?){
        
        print("switch photos")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Load up image of user and text fields from previous user stats for user modification
        self.UserNameTextField.text = usermanager.username
        self.UserBioTextField.text = ""
        self.UserFirstNameField.text = usermanager.firstName
        self.UserLastNameField.text = usermanager.lastName
        
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
        if true{
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
        
        ////Perform error checking
        //Determine if UserName crietria is satisfied
        if UserNameTextField.text == ""{
            errorMsg = errorMsg + "User Name Field is empty.\n"
           
        
        } else if(false){
            
            print("max character limit reached")
            
        //Check if user name already exists
        } else if(false){
            
            errorMsg = errorMsg + "User Name already exists.\n"
        }
        
        if(UserFirstNameField.text == ""){
            print("user first name")
            errorMsg = errorMsg + "First Name Field is empty.\n"
            
        } else if(false){
            print("max character limit reached")
        }
        
        if(UserLastNameField.text == ""){
            errorMsg = errorMsg + "Last Name Field is empty.\n"
            
        } else if(false){
            print("max character limit reached")
        }
        
        if(UserBioTextField.text == ""){
            UserBioTextField.text = "No Bio Set."
            
        } else if(false){
            print("max character limit reached")
        }
        
        //if the error message is the same, then it was successful
        if(oldErrorMsg == errorMsg){
            leftMessage = "make more changes"
            rightMessage = "save changes"
            errorMsg = "Would you like to save changes?"
            
            //Update previous user information with the new content
            usermanager.updateUserInfo(firstname: self.UserFirstNameField.text!, lastname: self.UserLastNameField.text!, bio: self.UserBioTextField.text!, name_of_user: self.UserNameTextField.text!, photo: EditingPhoto.image)

            
        } else {
            leftMessage = "fix issues"
            rightMessage = "discard changes"
            
        }
        
        //Set button messages
        leftButton = ButtonData(title: leftMessage, color: .fixedFitPurple, action: nil)
        rightButton = ButtonData(title: rightMessage, color: .fixedFitBlue){
            self.dismiss(animated: true, completion: nil)
        }
        
        
        //Generate the informationVC and present it to the user
        let informationVC = InformationVC(message: errorMsg, image: #imageLiteral(resourceName: "question"), leftButtonData: leftButton, rightButtonData: rightButton)
        
        present(informationVC, animated: true, completion: nil)
       
        
    }
    
}
