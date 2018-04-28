//
//  ContactUsVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/23/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit
import MessageUI

class ContactUsVC: UIViewController, MFMailComposeViewControllerDelegate {

    //Initial variable for setting the title
    var viewTitle:String!
    
    //Variable used to determine when the keyboard will or will not be presented
    private let notificationCenter = NotificationCenter.default
    
    //Initialize variable to hold the original view's orgin y coordinate value
    private var y_origin_position: CGFloat!
    
    //Initialize keyboard variable to determine whether the keyboard is being displayed
    private var keyboardPresented: Bool!
    
    //Initialize the variable to hold the target email address
    static let toRecipients = ["fixedfits@gmail.com"]
    var userUID:String!
    
    private let firebaseManager = FirebaseManager.shared
    
    //References to the label, subject text field, and the body text view
    @IBOutlet weak var UsersEmailLabel: UILabel!
    @IBOutlet weak var SubjectLine: UITextField!
    @IBOutlet weak var MessageBody: UITextView!
    @IBOutlet weak var SendEmailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.viewTitle
        
        let buttonFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        self.SendEmailButton.setTitle("Create Email", for: .normal)
        self.SendEmailButton.setTitleColor(.fixedFitBlue, for: .normal)
        self.SendEmailButton.titleLabel?.font = buttonFont
        
        //Set the keyboardPresented and exiting variables to false initially
        self.keyboardPresented = false
        
        //Preserve the original origin
        self.y_origin_position = self.view.frame.origin.y
        
        //Add observers when ever the user wishes to edit a text field
        self.notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Obtain the user's uid and their email
        if let contactInfo = firebaseManager.fetchContactUsInfo(){
            
            //Obtain the indices of the uid and the email in the string
            let uidIndex = 0
            let emailIndex = 1
            
            self.userUID = contactInfo[uidIndex]
            self.UsersEmailLabel.text = contactInfo[emailIndex]
            
        } else {
            
            //Could not load user's email and uid
            self.presentInfoVC(message: "Unable to load User Contact Info", imageName: "error diagram")
            
        }
    }
    
    //Function used to present an information vc when the category could not be added
    private func presentInfoVC(message: String, imageName: String){
        let buttonDataRight = ButtonData(title: "OK", color: .fixedFitBlue, action: nil)
        let secondInformationVC = InformationVC(message: message, image: UIImage(named: imageName), leftButtonData: nil, rightButtonData: buttonDataRight)
        
        self.present(secondInformationVC, animated: true, completion:nil)
    }
    
    @IBAction func SendEmailTapped(_ sender: UIButton) {
        var Subject = "From user \(self.userUID): "
        Subject += self.SubjectLine.text!
        
        let Body = self.MessageBody.text!
        
        //Initialize a MFMailComposeViewController
        let mailVC: MFMailComposeViewController = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        
        //set the subject, body, and recipients
        mailVC.setSubject(Subject)
        mailVC.setPreferredSendingEmailAddress(self.UsersEmailLabel.text!)
        mailVC.setMessageBody(Body, isHTML: false)
        mailVC.setToRecipients(ContactUsVC.toRecipients)
        
        if(MFMailComposeViewController.canSendMail()){
            self.present(mailVC, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        //Initialize message and imageName for user to see returning status
        var message: String!
        var imageName: String!
        
        //Determine which case has occured within the MailComposeViewController
        switch result{
            case MFMailComposeResult.cancelled:
                NSLog("Mail Cancelled")
                message = ""
                imageName = ""
            case MFMailComposeResult.saved:
                NSLog("Mail Saved")
                message = "Mail Saved"
                imageName = "greycheckmark"
            
                //Clear out the text fields
                self.SubjectLine.text = ""
                self.MessageBody.text = ""
            case MFMailComposeResult.sent:
                NSLog("Mail Sent")
                message = "Mail Sent"
                imageName = "bluecheckmark"
            case MFMailComposeResult.failed:
                NSLog("Mail sent Failure: %@",[error?.localizedDescription])
                message = "Mail Failed"
                imageName = "error diagram"
        }
        
        //Dismiss the MailComposeViewController
        self.dismiss(animated: true){
            if(!(message.isEmpty) && !(imageName.isEmpty)){
                self.presentInfoVC(message: message, imageName: imageName)
            }
        }
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
        
        //Move the text fields into proper position by a fixed amount of half of the size of the view
        if(self.keyboardPresented){
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y += 0
            }
            
        } else {
            self.view.frame.origin.y = self.y_origin_position
        }
        
        UIView.animate(withDuration: 0.0) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}
