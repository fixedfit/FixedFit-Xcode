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
class TutorialVC: UIViewController, UITableViewDelegate, UITableViewDataSource, RecoverSelectionDelegate {

    static let accountRecovery = "Account Recovery"
    
    //Initial variables for setting the tutorials
    var tutorialList: [String] = ["Add Clothes", "Construct Outfits", "Search for Users", "Follow a User", TutorialVC.accountRecovery]
    
    //Reference to the Table View
    @IBOutlet weak var TableView: UITableView!
    
    //Initial variable for setting the title
    var viewTitle:String!
    
    //Initialize variables for the user's selection of recovery or cancellation of the operation
    var cancelled: Bool!
    var recoverMethod: String!
    
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
            let RecoverVC = AccountRecoveryVC(buttonData: button)
            RecoverVC.delegate = self
            self.present(RecoverVC, animated: true, completion: nil)
            
            dispatch.notify(queue: .main){
                
                if(self.cancelled == false){
                    
                    //Determine if the user wants to recover their email or password
                    if(self.recoverMethod == RecoveryKeys.recoverEmail){
                        print(self.recoverMethod)
                    } else if(self.recoverMethod == RecoveryKeys.recoverPassword){
                        print(self.recoverMethod)
                    }
                }
            }
            
        } else {
            //Transition to SupportVC with desired tutorial
            guard let vc = PushViews.executeTransition(vcName: PushViewKeys.supportVC, storyboardName: PushViewKeys.home, newString: tutorialLabel + " tutorial", newMode:"") else {return}
            
            if let vc = vc as? SupportVC{
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
}
