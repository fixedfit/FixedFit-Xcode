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
        self.SendEmailButton.setTitle("Send Email", for: .normal)
        self.SendEmailButton.setTitleColor(.fixedFitBlue, for: .normal)
        self.SendEmailButton.titleLabel?.font = buttonFont
        
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
}
