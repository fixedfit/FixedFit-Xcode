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
    var PreviousUserName: String!
    var PreviousUserBio: String?
    var PreviousUserFirstName: String!
    var PreviousUserLastName: String!
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
        
        //Store the previous user stats
        self.PreviousUserName = usermanager.username
        self.PreviousUserBio = ""
        self.PreviousUserFirstName = usermanager.firstName
        self.PreviousUserLastName = usermanager.lastName
        
        //Load up image of user and text fields from previous user stats for user modification
        self.UserNameTextField.text = PreviousUserName
        self.UserBioTextField.text = PreviousUserBio
        self.UserFirstNameField.text = PreviousUserFirstName
        self.UserLastNameField.text = PreviousUserLastName
        
        
        //Initialize a weak reference to a variable called "Image" to hold the UIImage reference
        weak var Image:UIImage?
        
        //Determine if the user has already set up a photo or if it needs to use the default profile pic
        if true{
            Image = UIImage(named:"defaultProfile")
        } else {
            print("data from firebase")
        }
        
        
        //Add the image onto the UIImaveView and scale it
        let image = Image
        EditingPhoto.contentMode = UIViewContentMode.scaleAspectFit
        EditingPhoto.image = image
        
        //Store the reference of the UIImage that appear before it gets overwritten
        PreviousUserPhoto = image
        
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
        if true{
            self.CurrentViewStatus.setTitle("Private", for: [])
            
            //Update switch of view status to private in data base
            
        } else {
            self.CurrentViewStatus.setTitle("Public", for: [])
            
            //Update switch of view status to private in data base
            
        }
    
    }
    
    //perform any last minute error checks and Exit editor view if needed
    @IBAction func ExitEditor(_ sender: UIBarButtonItem) {
        
        //Error message used to be concatenated to let the user know what to do
        var errorMsg = "Error Status:\n"
        
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
        
        //Use informationVC object to select decision
        self.dismiss(animated: true, completion: nil)
        
        //debug message
        print(errorMsg)
       
        
    }
    

    
}
