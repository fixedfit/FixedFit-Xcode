//
//  ChangeUserInfoVC.swift
//  FixedFit
//
//  Created by Mario Buenrostro on 4/9/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit
protocol UserInfoDelegate{
    func saveUserInfo(userInfo:String, cancel: Bool)
}
class ChangeUserInfoVC: UIViewController, UITextFieldDelegate {

    var delegate: UserInfoDelegate?
    var button: ButtonData!
    
    //references to object in certain classes
    @IBOutlet weak var ChangeInfoView: UIView!
    @IBOutlet weak var titleMessage: UILabel!
    @IBOutlet weak var presentChangingInfo: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    
    //Variable used to obtain the mode in which this VC will operate as efficient as it can
    var userInfoUpdateMode: String!
    
    //Initialize variable to hold the original view's orgin y coordinate value
    var y_origin_position: CGFloat!
    
    //Initialize keyboard variable to determine whether the keyboard is being displayed
    var keyboardPresented: Bool!
    
    //Variable used to determine if the view is leaving for cleaner exit
    var exiting: Bool!
    
    //Variable used to determine when the keyboard will or will not be presented
    private let notificationCenter = NotificationCenter.default
    
    init(buttonAction:ButtonData, changingInfoMode: String){
        super.init(nibName: "ChangeUserInfoVC", bundle:nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
        
        //Store the passed in information
        self.userInfoUpdateMode = changingInfoMode
        self.button = buttonAction
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Change the colors of the UIButtons and the fonts
        saveButton.setTitleColor(.fixedFitPurple, for: .normal)
        discardButton.setTitleColor(.fixedFitBlue, for: .normal)
        
        //Change the font of the text
        let buttonFont = UIFont.systemFont(ofSize:18, weight: UIFont.Weight.semibold)
        
        saveButton.titleLabel?.font = buttonFont
        discardButton.titleLabel?.font = buttonFont
        
        self.textField.delegate = self
        
        //Assign the fields of each label
        if(userInfoUpdateMode == SettingKeys.emailUpdate.rawValue){
            titleMessage.text = "Changing Email:\n"
            presentChangingInfo.text = "New Email:"
            textField.isSecureTextEntry = false
        } else if(userInfoUpdateMode == SettingKeys.passwordUpdate.rawValue){
            titleMessage.text = "Changing Password:\n"
            presentChangingInfo.text = "New Password:"
            textField.isSecureTextEntry = true
        } else if(userInfoUpdateMode == SettingKeys.newCategory.rawValue){
            titleMessage.text = "Adding new Category\n"
            presentChangingInfo.text = "New Category:"
            textField.isSecureTextEntry = false
        }
        
        //Set the keyboardPresented and exiting variables to false initially
        self.keyboardPresented = false
        self.exiting = false
        
        //Preserve the original origin
        self.y_origin_position = self.view.frame.origin.y
        
        //Add observers when ever the user wishes to edit a text field
        self.notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
    }

    //Functions used to show and hide the keyboard whenever the user selects the text field
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        self.keyboardPresented = true
        adjustTextFieldPlacement(notification: notification)
    }
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        self.keyboardPresented = false
        adjustTextFieldPlacement(notification: notification)
    }
    private func adjustTextFieldPlacement(notification: NSNotification) {
        
        //Determine if the reauthenticationVC is being dismissed or if the user is choosing to dismiss the keyboard
        if(self.exiting == true){
            return
        }
        
        //Move the text fields into proper position by a fixed amount of half of the size of the view
        if(self.keyboardPresented){
            self.view.frame.origin.y -= ((self.ChangeInfoView.frame.size.height)/2)
        } else {
            self.view.frame.origin.y = self.y_origin_position
        }
        
        UIView.animate(withDuration: 0.0) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func discardInfo(_ sender: UIButton) {
        //Dismiss the view and keyboard if needed
        self.exiting = true
        dismisskeyBoard()
        delegate?.saveUserInfo(userInfo: "", cancel: true)
        self.dismiss(animated: true, completion: button?.action)
    }
    
    @IBAction func savedInfo(_ sender: UIButton) {
        //Dismiss the view and keyboard if needed
        self.exiting = true
        dismisskeyBoard()
        delegate?.saveUserInfo(userInfo: self.textField.text!, cancel: false)
        self.dismiss(animated: true, completion: button?.action)
    }
    
    //Functions used to dismiss the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        super.view.endEditing
        //dismisskeyBoard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismisskeyBoard()
        return true
    }
    
    private func dismisskeyBoard(){
        self.textField.resignFirstResponder()
    }
}
