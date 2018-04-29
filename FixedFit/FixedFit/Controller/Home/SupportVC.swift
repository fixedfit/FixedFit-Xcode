//
//  SupportVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/6/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit
class SupportVC: UIViewController{
    
    //Initial variable for setting the title and mode
    var viewTitle:String!
    var mode:String!
    
    //Variable that limits the number of spaces between messages
    static let messageSpacing = 3
    static let faqQandASpacing = 2
    
    //Reference to the text view
    @IBOutlet weak var MainTextView: UITextView!
    
    //Initial variable to hold the subclass to the MainSupportFramework for accessing of variables for present information to the user
    var selectedClass: MainSupportFramework?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MainTextView.isEditable = false
        
        //Set the font
        self.MainTextView.font = UIFont.systemFont(ofSize:18, weight: UIFont.Weight.semibold)
        
        if(mode == FirebaseSupportTitleAndMode.tutorial){
            self.viewTitle = self.viewTitle + " tutorial"
            
        }
        self.navigationItem.title = viewTitle
        
        //Display the messages and/or images to the user
        if selectedClass != nil{
            displayClassInformation()
        } else {
            
            //show user that the information could not load and remove the view from user's sight
            presentInfoVC(message: "Error: No Class Object associated with this section.")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //This function will iterate through the list of messages and/or images to be displayed to the user
    func displayClassInformation(){
        
        //Obtain the list of images and messages from the class
        let images = selectedClass?.images
        let messages = selectedClass?.messages
        
        //Initial variable to hold the answers of the help center
        var answers: [String]?
        
        //Boolean variable to determine if the process to iterate through the messages array are correct
        var condition = false
        
        //Variable to hold the error message to the user
        var errorMsg:String!
        
        //Perform error checking to ensure that iteration is performed correctly
        if (messages != nil && images != nil){
            if ((images?.count)! == (messages?.count)!) && (images?.count)! > 0{
                condition = true
            } else if(images?.count != messages?.count){
                condition = false
                errorMsg = "Error: This selection requires images and messages to be displayed.\nBut the number of elements between them are not equal."
            } else {
                condition = false
                errorMsg = "Error: Either images or messages has 0 elements.\n Both need to have at least one element each."
            }
        } else if(messages != nil){
            if (messages?.count)! > 0{
                condition = true
            } else {
                condition = false
                errorMsg = "This selection requires messages but there are none set."
            }
        } else if(images != nil){
            if (images?.count)! > 0{
                condition = true
            } else {
                condition = false
                errorMsg = "This selection requires images but there are none set."
            }
        } else {
            condition = false
            errorMsg = "No message and image data set in class object for this section."
        }
        
        //Determine if the HelpCenter FAQ has the correct number of answers corresponding to the number of questions
        if mode == FirebaseSupportTitleAndMode.helpCenter && condition{
            if let helpCenterVC = selectedClass as? HelpCenter_FAQ{
                if(helpCenterVC.answers == nil){
                    condition = false
                    errorMsg = "In the class object for the help center, the answers varible is not set."
                } else if helpCenterVC.answers?.count != messages?.count{
                    condition = false
                    errorMsg = "In the class object for the help center, the number of answers does not equal the number of questions."
                } else {
                    answers = helpCenterVC.answers
                }
            }
        }
        
        if (!condition){
            
            //Present message
            presentInfoVC(message: errorMsg)
            
            //remove the view from user's sight
            self.navigationController?.popViewController(animated: true)
            
        } else {
            
            //Call function to write data into View controller
            presentInformation(images: images, messages: messages, answers: answers)
            
        }
    }
    

    
    //Function to write data into the VC
    func presentInformation(images: [UIImage]?, messages: [String]?, answers: [String]?){
        
        //Disable scrolling to ensure messages are visible from the beginning whent he user sees them
        self.MainTextView.isScrollEnabled = false
        
        //Initialize a count to keep track of the amount of messages we are iterating through
        var counter = 0
        var totalCount: Int!
        
        //Obtain the total length of the arrays
        if images == nil{
            totalCount = (messages?.count)!
        } else {
            totalCount = (images?.count)!
        }
        
        //Display the information to the SupportVC
        while(counter < totalCount){
            
            //Insert message into MainTextView
            self.MainTextView.text = self.MainTextView.text! + "\((counter + 1)). " + messages![counter]
            
            //Insert the spacing between the question and answer and insert answer
            if self.mode == FirebaseSupportTitleAndMode.helpCenter{
                self.MainTextView.text = self.MainTextView.text! + String(repeating: "\n", count: SupportVC.faqQandASpacing)
                self.MainTextView.text = self.MainTextView.text! + answers![counter]
            }
            
            //This subsection will print out the linefeed between each message specified by the messageSpacing variable
            self.MainTextView.text = self.MainTextView.text! + String(repeating: "\n", count: SupportVC.messageSpacing)
            
            //Increment the counter
            counter += 1
        }
        
        //Enable scrolling again so the user can see all of the messages
         self.MainTextView.isScrollEnabled = true
        
    }
    
    //Function used to present an information vc when the category could not be added
    private func presentInfoVC(message: String){
        let buttonDataRight = ButtonData(title: "OK", color: .fixedFitBlue, action: nil)
        let secondInformationVC = InformationVC(message: message, image: UIImage(named: "error diagram"), leftButtonData: nil, rightButtonData: buttonDataRight)
        
        self.present(secondInformationVC, animated: true, completion:nil)
    }
    
    
}
