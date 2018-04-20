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
    func didAcceptCredentials(email: String, password: String)
}

class ReauthenticateVC: UIViewController, UITextFieldDelegate {

    //Initialize the delegate variable
    var delegate: ReauthenticationDelegate?
    
    //Initialize the button for a certain action to be performed when the user selected Enter button
    var buttonAction: ButtonData!
    
    //References to buttons for presenting them with a certain color
    @IBOutlet weak var EnterButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    
    //References to views
    @IBOutlet weak var reauthenticationView: UIView!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    //Initializers
    init(button:ButtonData){
        super.init(nibName: "ReauthenticateVC", bundle:nil)
        self.buttonAction = button
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Change the colors of the UIButtons and the fonts
        EnterButton.setTitleColor(.fixedFitPurple, for: .normal)
        CancelButton.setTitleColor(.fixedFitBlue, for: .normal)
        
        //Change the font of the text
        let buttonFont = UIFont.systemFont(ofSize:18, weight: UIFont.Weight.semibold)
        
        EnterButton.titleLabel?.font = buttonFont
        CancelButton.titleLabel?.font = buttonFont
        
        //Make delegate of textfields equal to itself
        EmailTextField.delegate = self
        PasswordTextField.delegate = self
        PasswordTextField.isSecureTextEntry = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Action functions used when the user selects the respective buttons
    @IBAction func pressEnter(_ sender: UIButton) {
        delegate?.didAcceptCredentials(email: EmailTextField.text!, password: PasswordTextField.text!)
        self.dismiss(animated: true, completion: self.buttonAction.action)
    }
    @IBAction func pressCancel(_ sender: UIButton) {
        //Dismiss the view
        self.dismiss(animated: true, completion: self.buttonAction.action)
    }
    
    //Functions used to dismiss the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        super.view.endEditing
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        EmailTextField.resignFirstResponder()
        PasswordTextField.resignFirstResponder()
        return true
    }
    
}
