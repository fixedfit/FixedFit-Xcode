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
                                  bio: "",
                                  pushNotificationsEnabled: true
        ) 

        if validInput(signUpInfo) {
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
        } else {
            showLoginError("Make sure all text fields are filled")
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
