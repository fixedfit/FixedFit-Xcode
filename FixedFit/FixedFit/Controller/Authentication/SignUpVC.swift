//
//  LoginVC.swift
//  MyUNLV
//
//  Created by Amanuel Ketebo on 10/23/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import FirebaseAuth
import SafariServices

enum UserInfoCheckerKeys: Int{
    case username_has_whitespsace = 0
    case firstname_of_user_invalid_structure = -1
    case lastname_of_user_invalid_structure = -2
}

class SignUpVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var welcomeMessageLabel: UILabel!
    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var stackViewVerticalConstraint: NSLayoutConstraint!

    var keyboardShowing = false

    private let firebaseManager = FirebaseManager.shared
    private let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)

        setupViews()
    }

    private func setupViews() {
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        errorMessageLabel.alpha = 0
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }

    @IBAction func touchedSignUp() {
        let signUpInfo = SignUpInfo(firstName: firstNameTextField.text ?? "",
                                  lastName: lastNameTextField.text ?? "",
                                  email: emailTextField.text ?? "",
                                  username: usernameTextField.text ?? "",
                                  password: passwordTextField.text ?? "",
                                  publicProfile: true,
                                  bio: ""
        )
        
        let validInputBool = validInput(signUpInfo)
        let validNamesInt = validNames(signUpInfo)

        if validInputBool && validNamesInt == 1{
            firebaseManager.signUp(signUpInfo, completion: { [weak self] (_, error) in
                if let firebaseError = error as? FirebaseError {
                    self?.showLoginError(firebaseError.localizedDescription)
                } else if let firebaseError = error, let authError = AuthErrorCode(rawValue: firebaseError._code) {
                    self?.showLoginError(authError.localizedDescription)
                } else {
                    self?.dismissKeyboard()
                    self?.notificationCenter.post(name: .authStatusChanged, object: nil)
                }
            })
        } else if(!validInputBool){
            showLoginError("Make sure all text fields are filled")
        } else if(validNamesInt == UserInfoCheckerKeys.username_has_whitespsace.rawValue){
            showLoginError("Username has white spaces")
        } else if(validNamesInt == UserInfoCheckerKeys.firstname_of_user_invalid_structure.rawValue){
            showLoginError("First name should have letters and whitespaces")
        } else if(validNamesInt == UserInfoCheckerKeys.lastname_of_user_invalid_structure.rawValue){
            showLoginError("Last name should have letters and whitespaces")
        }

    }

    // MARK: - Helper methods
    private func validInput(_ signUpInfo: SignUpInfo) -> Bool {
        if signUpInfo.firstName.isEmpty || signUpInfo.lastName.isEmpty || signUpInfo.email.isEmpty || signUpInfo.username.isEmpty || signUpInfo.password.isEmpty {
            return false
        } else {
            return true
        }
    }
    private func validNames(_ signUpInfo: SignUpInfo) -> Int{
        
        //Return code used to determine if names satifiy criteria
        var returnCode = 1
        
        //If the user name has any whitespace
        if(signUpInfo.username.contains(" ")){
            returnCode = UserInfoCheckerKeys.username_has_whitespsace.rawValue
        } else {
            
            //Determine if the first and last names have the correct structure
            if(returnCode == 1){
                for (_, char) in signUpInfo.firstName.enumerated(){
                    if(!(char == " " || (char >= "A" && char <= "Z") || (char >= "a" && char <= "z"))){
                        returnCode = UserInfoCheckerKeys.firstname_of_user_invalid_structure.rawValue
                        break
                    }
                }
            }
            
            if(returnCode == 1){
                for (_, char) in signUpInfo.lastName.enumerated(){
                    if(!(char == " " || (char >= "A" && char <= "Z") || (char >= "a" && char <= "z"))){
                        returnCode = UserInfoCheckerKeys.lastname_of_user_invalid_structure.rawValue
                        break
                    }
                }
            }
        }
        
        return returnCode
        
    }

    private func showLoginError(_ message: String) {
        errorMessageLabel.text = message
        errorMessageLabel.alpha = 0
        errorMessageLabel.fadeIn(duration: 0.3)
    }

    private func hideLoginError() {
        errorMessageLabel.text = ""
        errorMessageLabel.fadeOut(duration: 0.1)
    }

    @objc private func keyboardWillShow(_ notification: NSNotification) {
        keyboardShowing = true
        adjustTextFieldPlacement()
    }

    @objc private func keyboardWillHide(_ notificaiton: NSNotification) {
        keyboardShowing = false
        adjustTextFieldPlacement()
    }

    private func adjustTextFieldPlacement() {
        let newAlpha: CGFloat!
        let newVerticalConstant: CGFloat!

        if keyboardShowing {
            newAlpha = 0
            newVerticalConstant = -75
        } else {
            newAlpha = 1
            newVerticalConstant = 0
        }

        stackViewVerticalConstraint.constant = newVerticalConstant

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.welcomeMessageLabel.alpha = newAlpha
            self?.view.layoutIfNeeded()
        }
    }

    @objc private func dismissKeyboard() {
        print("Dismissing keyboard!")
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func touchedAlreadyHaveAccount() {
        dismiss(animated: true, completion: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension SignUpVC {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
