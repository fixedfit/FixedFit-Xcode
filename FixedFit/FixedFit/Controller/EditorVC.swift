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

    //MARK: Labels for name, user, and bios
    @IBOutlet weak var UserFirstName: UILabel!
    @IBOutlet weak var UserLastName: UILabel!
    @IBOutlet weak var UserNameEditorLabel: UILabel!
    @IBOutlet weak var UserTextField: UITextField!
    @IBOutlet weak var UserBiosTextField: UITextView!
    
    //MARK: Initial variable to hold data when view is loaded. to be able to restore data if user improperly entered a field and decided to return back to the previous view.
    var UserPreviousUserText: String!
    var UserPreviousUserBios: String!
    weak var UserPreviousUserPhoto: UIImageView!
    
    
    //MARK: Update current view with relevant information regarding the user's profile
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load up image of user and text fields from data base
        
        
        //Assign the local variables with the corresponding Image and text
        self.UserTextField.delegate = self
        self.UserBiosTextField.delegate = self
        
    }
    
    //Hide keyboard when users touch outside the text boxes
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Hide keyboard when users touch the done button on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Resign the Text Field from being the first responder
        UserTextField.resignFirstResponder()
        UserBiosTextField.resignFirstResponder()
        
        //Perform any error checks in this section
        
        return true
    }
    
}
