//
//  TutorialVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/23/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit
struct RecoveryKeys{
    static let recoverEmail = "recover email"
    static let recoverPassword = "recover password"
}
class TutorialVC: UIViewController, UITableViewDelegate, UITableViewDataSource, RecoverSelectionDelegate, UserInfoDelegate {
    
    private let firebaseManager = FirebaseManager.shared

    static let accountRecovery = "Recover Credentials"
    
    //Initial variables for setting the tutorials
    var tutorialList: [String] = ["Add Clothes", "Construct Outfits","Delete Clothes", "Delete Outfits", "Search for Users", "Follow a User", "Block a User","Like a user's Photo", "Add an outfit to the calendar",TutorialVC.accountRecovery]
    
    //Reference to the Table View
    @IBOutlet weak var TableView: UITableView!
    
    //Initial variable for setting the title
    var viewTitle:String!
    
    //Initialize variables for the user's selection of recovery or cancellation of the operation
    var cancelled: Bool!
    var recoverMethod: String!
    
    //Assign email to this variable when reseting password or recovering email
    var userEmail: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.viewTitle
        
        //Set the delegates
        self.TableView.delegate = self
        self.TableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TableView Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tutorialList.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TutorialSettingCell.identifier, for: indexPath) as! TutorialSettingCell
        
        //Assign the label in the tutorialList to the cell
        cell.configure(tutorial: self.tutorialList[indexPath.row])
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Obtain the string that corresponds to this tutorial cell
        let tutorialLabel = self.tutorialList[indexPath.row]
        
        if(tutorialLabel == TutorialVC.accountRecovery){
            
            //Initialize a dispatch to wait for the nib file to retrieve the
            let dispatch = DispatchGroup()
            
            dispatch.enter()
            //Generate the AccountRecoveryVC and present it
            let button = ButtonData(title: "", color: UIColor()){
                dispatch.leave()
            }
            let RecoverVC = AccountRecoveryVC(title: "Recover Credentials", buttonData: button)
            RecoverVC.delegate = self
            self.present(RecoverVC, animated: true, completion: nil)
            
            dispatch.notify(queue: .main){
                
                if(self.cancelled == false){
                    
                    //Determine if the user wants to recover their email or password
                    if(self.recoverMethod == RecoveryKeys.recoverEmail){
                        print(self.recoverMethod)
                    } else if(self.recoverMethod == RecoveryKeys.recoverPassword){
                        
                        dispatch.enter()
                        let button = ButtonData(title: "", color: UIColor()){
                            dispatch.leave()
                        }
                        
                        let vc = ChangeUserInfoVC(buttonAction: button, changingInfoMode: RecoveryKeys.recoverPassword)
                        vc.delegate = self
                        self.present(vc, animated: true, completion: nil)
                        
                        dispatch.notify(queue: .main){
                            
                            //Obtain the current user's email for validation
                            let currentUserEmail = self.firebaseManager.retrieveEmail()
                            
                            //Initialize a ButtonData object to present information to the user
                            let button = ButtonData(title: "Ok", color: .fixedFitBlue, action: nil)
                            
                            //Initialize variable to present a message to the user
                            var message:String!

                            if(self.cancelled == false && currentUserEmail == self.userEmail!){
                                
                                //Call firebase function to reset password
                                self.firebaseManager.resetPassword(email: self.userEmail!){(error) in
                                    
                                    //Present information to the user on what the resetPassword function did
                                    var imageName = ""
                                    
                                    if error == nil {
                                        message = "An email was sent to allow you to reset your password."
                                        imageName = "bluecheckmark"
                                    } else {
                                        message = "An error has occured and a reset password email was not sent."
                                        imageName = "error diagram"
                                    }
                                    
                                    let vc = InformationVC(message: message, image: UIImage(named: imageName), leftButtonData: button, rightButtonData: nil)
                                    self.present(vc, animated: true, completion: nil)
                                    
                                } // resetPassword ending brace
                                
                            } else {
                                
                                //Determine which error it is
                                if(self.userEmail!.isEmpty){
                                    message = "Error: Email Entry is Empty"
                                } else {
                                    message = "Error: Incorrect Email"
                                }
                                
                                let vc = InformationVC(message: message, image: UIImage(named: "error diagram"), leftButtonData: button, rightButtonData: nil)
                                self.present(vc, animated: true, completion: nil)
                                
                            }//If-Else statement
                        }
                    }
                }
            }
            
        } else {
            //Transition to SupportVC with desired tutorial
            guard let vc = PushViews.executeTransition(vcName: PushViewKeys.supportVC, storyboardName: PushViewKeys.home, newString: tutorialLabel, newMode: FirebaseSupportTitleAndMode.tutorial) else {return}
            
            if let vc = vc as? SupportVC{
                
                //Instantiate the subclass of the MainSupportFramework that correspondes to the section
                //Determine which label has been selected by checking the elements of the tutorialList
                switch tutorialLabel {
                case tutorialList[0]:
                    vc.selectedClass = AddClothes()
                case tutorialList[1]:
                    vc.selectedClass = ConstructOutfits()
                case tutorialList[2]:
                    vc.selectedClass = DeleteClothes()
                case tutorialList[3]:
                    vc.selectedClass = DeleteOutfits()
                case tutorialList[4]:
                    vc.selectedClass = Search_For_Users()
                case tutorialList[5]:
                    vc.selectedClass = Follow_A_User()
                case tutorialList[6]:
                    vc.selectedClass = Block_A_User()
                case tutorialList[7]:
                    vc.selectedClass = Like_A_Users_Photo()
                case tutorialList[8]:
                    vc.selectedClass = Add_Outfit_To_Calendar()
                default:
                    vc.selectedClass = nil
                }
                
                //Push View Controller onto Navigation Stack
                self.navigationController?.pushViewController(vc, animated: true)
            } else if let vc = vc as? InformationVC{
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    //Delegate functions
    func recoverSelection(recover: String, cancel: Bool) {
        self.recoverMethod = recover
        self.cancelled = cancel
    }
    
    func saveUserInfo(userInfo:String, cancel: Bool){
        self.userEmail = userInfo
        self.cancelled = cancel
    }
}
