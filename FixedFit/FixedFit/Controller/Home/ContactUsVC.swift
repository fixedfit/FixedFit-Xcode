//
//  ContactUsVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/23/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit
import MessageUI

class ContactUsVC: UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    //Initialize the variable to hold the target email address
    static let toRecipients = ["fixedfits@gmail.com"]
    var senderEmail:String!
    var userUID:String!
    
    private let firebaseManager = FirebaseManager.shared
    
    //References in view
    @IBOutlet weak var CreateEmailButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var UserLabel: UILabel!
    @IBOutlet weak var ContactView: UIView!
    
    init(){
        super.init(nibName: "ContactUsVC", bundle:nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        self.CreateEmailButton.setTitle("Create Email", for: .normal)
        self.CreateEmailButton.setTitleColor(.fixedFitBlue, for: .normal)
        self.CreateEmailButton.titleLabel?.font = buttonFont
        
        self.CancelButton.setTitle("Cancel", for: .normal)
        self.CancelButton.titleLabel?.font = buttonFont
        
        self.UserLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Obtain the user's uid and their email
        if let contactInfo = firebaseManager.fetchContactUsInfo(){
            
            //Obtain the indices of the uid and the email in the string
            let uidIndex = 0
            let emailIndex = 1
            
            self.userUID = contactInfo[uidIndex]
            self.senderEmail = contactInfo[emailIndex]
            self.UserLabel.text = self.senderEmail
            
        } else {
            
            //Could not load user's email and uid
            self.dismiss(animated: true){
                self.presentInfoVC(message: "Unable to load User Contact Info", imageName: "error diagram")
            }
        }
    }
    
    //Function used to present an information vc when the category could not be added
    private func presentInfoVC(message: String, imageName: String){
        let buttonDataRight = ButtonData(title: "OK", color: .fixedFitBlue, action: nil)
        let secondInformationVC = InformationVC(message: message, image: UIImage(named: imageName), leftButtonData: nil, rightButtonData: buttonDataRight)
        
        self.present(secondInformationVC, animated: true, completion:nil)
    }
    
    @IBAction func CreateEmailTapped(_ sender: UIButton) {
        let Subject = "From user \(self.userUID): <subject>"
        
        let Body = ""
        
        //Initialize a MFMailComposeViewController
        let mailVC: MFMailComposeViewController = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        
        //set the subject, body, and recipients
        mailVC.setSubject(Subject)
        mailVC.setPreferredSendingEmailAddress(senderEmail)
        mailVC.setMessageBody(Body, isHTML: false)
        mailVC.setToRecipients(ContactUsVC.toRecipients)
        
        if(MFMailComposeViewController.canSendMail()){
            self.present(mailVC, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func CancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
