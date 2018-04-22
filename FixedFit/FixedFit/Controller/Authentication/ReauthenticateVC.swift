//
//  ReauthenticateVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/8/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

//Make a reauthentication delegate that will be used to implement this function in other classes that utilize the delegate
protocol ReauthenticationDelegate{
    func didAcceptCredentials(email: String, password: String, cancel: Bool)
}

class ReauthenticateVC: UIViewController, UITextFieldDelegate {

    //Initialize the delegate variable
    var delegate: ReauthenticationDelegate?
    
    //Initialize the button for a certain action to be performed when the user selected Enter button
    var buttonAction: ButtonData!
    
    //Variable used to determine if the view is leaving for cleaner exit
    var exiting: Bool!
    
    //Variables used to determine if a textfield was selected
    var emailBoolean: Bool!
    var passwordBoolean: Bool!
    
    //References to buttons for presenting them with a certain color
    @IBOutlet weak var EnterButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    
    //References to views
    @IBOutlet weak var reauthenticationView: UIView!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    //Initialize variable to hold the original view's orgin y coordinate value
    var y_origin_position: CGFloat!
    
    //Initialize keyboard variable to determine whether the keyboard is being displayed
    var keyboardPresented: Bool!
    
    //Variable used to determine when the keyboard will or will not be presented
    private let notificationCenter = NotificationCenter.default
    
    //Initializers
    init(button:ButtonData){
        super.init(nibName: "ReauthenticateVC", bundle:nil)
        self.buttonAction = button
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
        
        //Unconditional set the boolean variable for the email and password to false
        self.emailBoolean = false
        self.passwordBoolean = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Change the colors of the UIButtons and the fonts
        self.EnterButton.setTitleColor(.fixedFitPurple, for: .normal)
        self.CancelButton.setTitleColor(.fixedFitBlue, for: .normal)
        
        //Change the font of the text
        let buttonFont = UIFont.systemFont(ofSize:18, weight: UIFont.Weight.semibold)
        
        self.EnterButton.titleLabel?.font = buttonFont
        self.CancelButton.titleLabel?.font = buttonFont
        
        //Make delegate of textfields equal to itself
        self.EmailTextField.delegate = self
        self.PasswordTextField.delegate = self
        self.PasswordTextField.isSecureTextEntry = true
        
        //Add observers when ever the user wishes to edit a text field
        self.notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
        //Set the keyboardPresented and exiting variables to false initially
        self.keyboardPresented = false
        self.exiting = false
        
        //Preserve the original origin
        self.y_origin_position = self.view.frame.origin.y
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Functions used to show and hide the keyboard whenever the user selects the text field
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        self.keyboardPresented = true
        
        //Determine which text field is the first responder
        if(EmailTextField.isFirstResponder){
            self.emailBoolean = true
        } else if(PasswordTextField.isFirstResponder){
            self.passwordBoolean = true
        }
        
        adjustTextFieldPlacement(notification: notification)
    }
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        self.keyboardPresented = false
        
        //Unconditional set the boolean variable for the email and password to false
        self.emailBoolean = false
        self.passwordBoolean = false
        
        adjustTextFieldPlacement(notification: notification)
    }
    private func adjustTextFieldPlacement(notification: NSNotification) {
        
        //Determine if the reauthenticationVC is being dismissed or if the user is choosing to dismiss the keyboard
        if(self.exiting == true){
           return
        }
        
        //Move the text fields into proper position by a fixed amount of half of the size of the view
        if(self.keyboardPresented && !(self.emailBoolean == true && self.passwordBoolean == true)){
            self.view.frame.origin.y -= ((reauthenticationView.frame.size.height)/2)
        } else if(self.keyboardPresented == false){
            self.view.frame.origin.y = self.y_origin_position
        }
        
        UIView.animate(withDuration: 0.0) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    //Action functions used when the user selects the respective buttons
    @IBAction func pressEnter(_ sender: UIButton) {
        //Dismiss the view and keyboard if needed
        self.exiting = true
        dismisskeyBoard()
        delegate?.didAcceptCredentials(email: EmailTextField.text!, password: PasswordTextField.text!, cancel: false)
        self.dismiss(animated: true, completion: self.buttonAction.action)
    }
    @IBAction func pressCancel(_ sender: UIButton) {
        //Dismiss the view and keyboard if needed
        self.exiting = true
        dismisskeyBoard()
        delegate?.didAcceptCredentials(email: "", password: "", cancel: true)
        self.dismiss(animated: true, completion: self.buttonAction.action)
    }
    
    //Functions used to dismiss the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        super.view.endEditing
        dismisskeyBoard()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Dismiss the keyboard by resigning the text fields from being the first responders
        dismisskeyBoard()
        
        return true
    }
    private func dismisskeyBoard(){
        self.EmailTextField.resignFirstResponder()
        self.PasswordTextField.resignFirstResponder()
    }
}
