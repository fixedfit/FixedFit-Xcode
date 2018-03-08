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
    UIImagePickerControllerDelegate{

    //MARK: Button for current view status of profile
    @IBOutlet weak var CurrentViewStatus: UIButton!
    
    //MARK: TextFields for name, username, and bios
    @IBOutlet weak var UserNameTextField: UITextField!
    @IBOutlet weak var UserBiosTextField: UITextView!
    @IBOutlet weak var UserFirstNameField: UITextField!
    @IBOutlet weak var UserLastNameField: UITextField!
    
    //MARK: Initial variable to hold data when view is loaded. to be able to restore data if user improperly entered a field and decided to return back to the previous view.
    var PreviousUserName: String!
    var PreviousUserBios: String!
    var PreviousUserFirstName: String!
    var PreviousUserLastName: String!
    weak var PreviousUserPhoto: UIImage!
    
    
    //MARK: Update current view with relevant information regarding the user's profile
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign the local variables with the corresponding Image and text
        self.UserNameTextField.delegate = self
        self.UserBiosTextField.delegate = self
        self.UserFirstNameField.delegate = self
        self.UserLastNameField.delegate = self
        
        //Temporarily store the previous texts and user photo from fiebase before any changes are made
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Load up image of user and text fields from data base
        
        //update current viewing status from firebase field into the button field
        if true{
            self.CurrentViewStatus.setTitle("Public", for: <#T##UIControlState#>)
        } else {
            self.CurrentViewStatus.setTitle("Private", for: <#T##UIControlState#>)
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
        UserBiosTextField.resignFirstResponder()
        UserFirstNameField.resignFirstResponder()
        UserLastNameField.resignFirstResponder()
        
        //Perform any error checks in this section
        
        //Otherwise, store the newly updated information into firebase
        
        return true
    }
    
    //Change the current view status for profile
    @IBAction func changeStatus(_ sender: UIButton) {
    
        //Determine if the status was public or private before the switching of the view status
        if true{
            self.CurrentViewStatus.setTitle("Private", for: <#T##UIControlState#>)
            
            //Update switch of view status to private in data base
            
        } else {
            self.CurrentViewStatus.setTitle("Public", for: <#T##UIControlState#>)
            
            //Update switch of view status to private in data base
            
        }
    
    }
    
    
    
}
