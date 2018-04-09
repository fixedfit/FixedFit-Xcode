//
//  EditorVC.swift
//  FixedFit
//
//  Created by Mario Buenrostro on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit

class EditorVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    // Reference for editing photo
    @IBOutlet weak var editingPhoto: UIImageView!
    // Button for current view status of profile
    @IBOutlet weak var currentStatus: UIButton!
    // TextFields for name, username, and bios
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!

    // Initial variable to hold data when view is loaded. to be able to restore data if user improperly entered a field and decided to return back to the previous view.
    var previousFirstName: String!
    var previousLastName: String!
    var previousUsername: String!
    var previousBio: String?
    var previousPublicProfile: Bool!
    weak var previousPhoto: UIImage?

    var imagePicker = UIImagePickerController()

    let userStuffManager = UserStuffManager.shared
    
    // Update current view with relevant information regarding the user's profile
    override func viewDidLoad() {
        super.viewDidLoad()
        //Assign the local variables with the corresponding Image and text
        self.usernameTextField.delegate = self
        self.bioTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        
        //Add UITapGesture to the UIImage
        let tappedPhotoGesture = UITapGestureRecognizer(target:self, action: #selector(EditorVC.tappedPhoto))
        tappedPhotoGesture.delegate = self
        editingPhoto.isUserInteractionEnabled = true
        editingPhoto.addGestureRecognizer(tappedPhotoGesture)
        
        //Initialize image field of EditingPhoto to nil to identify this view being presented by the profileVC
        if userStuffManager.userInfo.photo != nil {
             editingPhoto.image = userStuffManager.userInfo.photo
        }
    }
    
    //Allow UIImageView to have touch gesture - this will allow you to perform action when clicking the photo
    @objc func tappedPhoto(sender: UITapGestureRecognizer?){
        
        //Initialize variable used to determine where the users would like to retrieve the photo for the user profile
        var selectionStatus: String!
        
        //Present PhotoSelector ViewController to ask user how they want to edit user photo
        selectionStatus = "Libray"//debug purposes
        
        if(selectionStatus == "Libray"){
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = false
            }
        } else if(selectionStatus == "Camera"){
        
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
            }
        
        } else {
            //If users select the default profile image to be displayed on their profile, then just assigned it and return
            editingPhoto.image = UIImage(named: "defaultProfile")
            return
        }
        
        self.present(imagePicker, animated: true, completion: nil)
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]){
        // Need to unwrap info's value entry when retrieving image since it is wrapped in a optional
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            editingPhoto.contentMode = .scaleAspectFit
            editingPhoto.image = image
        }

        self.dismiss(animated: true, completion: nil)
    }
 
    
    override func viewWillAppear(_ animated: Bool) {
        // Load up image of user and text fields from previous user stats for user modification
        usernameTextField.text = userStuffManager.userInfo.username
        bioTextField.text = userStuffManager.userInfo.bio
        firstNameTextField.text = userStuffManager.userInfo.firstName
        lastNameTextField.text = userStuffManager.userInfo.lastName
        
        // Store previous values into temporary variables for fast exit
        previousUsername = usernameTextField.text!
        previousBio = bioTextField.text!
        previousFirstName = firstNameTextField.text!
        previousLastName = lastNameTextField.text!
        previousPublicProfile = userStuffManager.userInfo.publicProfile

        if self.editingPhoto.image == nil {
            self.previousPhoto = userStuffManager.userInfo.photo
            self.editingPhoto.contentMode = UIViewContentMode.scaleAspectFit
            self.editingPhoto.image = userStuffManager.userInfo.photo
        }
        
        // Update current viewing status from firebase field into the button field
        if userStuffManager.userInfo.publicProfile {
            currentStatus.setTitle("Public", for: .normal)
        } else {
            currentStatus.setTitle("Private", for: .normal)
        }
    }
    
    // Hide keyboard when users touch outside the text boxes
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    // Hide keyboard when users touch the done button on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Resign the Text Field from being the first responder
        usernameTextField.resignFirstResponder()
        bioTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        
        return true
    }
    
    // Change the current view status for profile
    @IBAction func changeStatus(_ sender: UIButton) {
        // Determine if the status was public or private before the switching of the view status
        if userStuffManager.userInfo.publicProfile {
            currentStatus.setTitle("Private", for: .normal)
            userStuffManager.togglePublicProfile()
        } else {
            currentStatus.setTitle("Public", for: .normal)
            // Update switch of view status to public
            userStuffManager.togglePublicProfile()
        }
    }
    
    // Perform any last minute error checks and Exit editor view if needed
    @IBAction func exitEditor(_ sender: UIBarButtonItem) {
        // Initialize dispatch group to ensure that the error messages are accurate
        let dispatch = DispatchGroup()
        
        // Error message used to be concatenated to let the user know what to do
        var errorMsg = "Error Status:\n"
        
        // Store original error message to confirm if any errors were found
        let oldErrorMsg = errorMsg
        
        // Initialize character limiter for text fields
        let nameCharacterLimiter = 35
        let bioCharacterLimiter = 150
        
        //Initialize button message to empty
        var leftMessage = ""
        var rightMessage = ""
        var leftButton:ButtonData!
        var rightButton:ButtonData!
        
        // If there was no changes, then just return without asking the user to save or not
        if firstNameTextField.text! == previousFirstName && lastNameTextField.text! == previousLastName && bioTextField.text! == previousBio && usernameTextField.text! == previousUsername && editingPhoto.image == previousPhoto && userStuffManager.userInfo.publicProfile == previousPublicProfile {
            self.dismiss(animated: true, completion: nil)
            return
        }

        // Perform error checking
        // Determine if UserName crietria is satisfied
        if usernameTextField.text! != previousUsername {
            if usernameTextField.text!.isEmpty {
                errorMsg = errorMsg + "User Name Field is empty.\n"
            //Check if username has too many characters
            } else if usernameTextField.text!.count > nameCharacterLimiter {
                errorMsg = errorMsg + "User Name has exceeded the character limit of \(nameCharacterLimiter)"
            //Check if user name already exists in list of users in firebase
            } else {
                dispatch.enter()
                userStuffManager.checkUsername(username: self.usernameTextField.text!) { (takenUserName) in
                    if takenUserName == true {
                        errorMsg = errorMsg + "User Name already exists.\n"
                    }

                    dispatch.leave()
                }
            }
        }
        
        //Make main wait for checkusername closure to be executed
        dispatch.notify(queue: .main){
            //Determine if First name crietria is satisfied
            if(self.firstNameTextField.text! != self.previousFirstName){
                if(self.firstNameTextField.text!.isEmpty){
                    errorMsg = errorMsg + "First Name Field is empty.\n"
                
                } else if(( (self.firstNameTextField.text!.count) > nameCharacterLimiter)){
                    errorMsg = errorMsg + "User Name has exceeded the character limit of \(nameCharacterLimiter)"
                }
            }
        
            //Determine if Last name crietria is satisfied
            if(self.lastNameTextField.text! != self.previousLastName){
                if(self.lastNameTextField.text!.isEmpty){
                    errorMsg = errorMsg + "Last Name Field is empty.\n"
                
                } else if(( (self.lastNameTextField.text!.count) > nameCharacterLimiter)){
                    errorMsg = errorMsg + "User Name has exceeded the character limit of \(nameCharacterLimiter)"
                }
            }
        
            //Determine if bio crietria is satisfied
            if(self.bioTextField.text! != self.previousBio){
                if(self.bioTextField.text!.isEmpty){
                    self.bioTextField.text = "No Bio Set"
                
                } else if(( (self.bioTextField.text!.count) > bioCharacterLimiter)){
                    errorMsg = errorMsg + "User Name has exceeded the character limit of \(bioCharacterLimiter)"
                }
            }
        
            //if the error message is the same, then changes are successful so update them
            if(oldErrorMsg == errorMsg) {
                leftMessage = "make more changes"
                rightMessage = "save changes"
                errorMsg = "Would you like to save changes?\n"
                
                //Update previous user information with the new content
                let updatedUserInfo = UserInfo(firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, username: self.usernameTextField.text!, bio: self.bioTextField.text!, publicProfile: self.previousPublicProfile, pushNotificationsEnabled: true, photo: self.editingPhoto.image)
                self.userStuffManager.updateUserInfo(updatedUserInfo, completion: { _ in })
            } else {
                leftMessage = "fix issues"
                rightMessage = "discard changes"
                errorMsg = errorMsg + "Would you like to discard changes and go to profile?"
            }
        
            //Set button messages
            leftButton = ButtonData(title: leftMessage, color: .fixedFitPurple, action: nil)
            rightButton = ButtonData(title: rightMessage, color: .fixedFitBlue){
                
                //Assign nil to EditingPhoto image field to identify that updating was successful and prepare next editing session when being presented by profileVC next time
                self.editingPhoto.image = nil
                
                self.dismiss(animated: true, completion: nil)

            }
        
            //Generate the informationVC and present it to the user
            let informationVC = InformationVC(message: errorMsg, image: #imageLiteral(resourceName: "question"), leftButtonData: leftButton, rightButtonData: rightButton)
        
            self.present(informationVC, animated: true, completion: nil)
        }
    }
    
}