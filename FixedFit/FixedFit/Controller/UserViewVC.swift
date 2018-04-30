//
//  UserViewVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/7/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class UserViewVC: UIViewController, UIGestureRecognizerDelegate{
    //Variable used to present the title, which is the username
    var uid: String!
    var mode: String!
    
    //Varible for handler
    var userNameHandle: UInt = 0
    
    @IBOutlet weak var UserChildVCView: UIView!
    @IBOutlet weak var LeftButton: UIButton!
    @IBOutlet weak var RightButton: UIButton!
    
    
    let firebaseManager = FirebaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up font for the buttons
        let buttonFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        self.LeftButton.titleLabel?.font = buttonFont
        self.RightButton.titleLabel?.font = buttonFont
    }
    
    override func viewWillAppear(_ animated: Bool) {

        ////Fetch the selected user's information from firebase by using the observers
        self.userNameHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.uid).child(FirebaseKeys.username.rawValue).observe(.value, with: {(snapshot) in
            
            //retrieve the User's username
            if let username = snapshot.value as? String {
                
                //set the User's username
                self.navigationItem.title = username
            }
        })
        
        //set up buttons for viewing

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UserProfileInfoVC {
            vc.uid = self.uid
            vc.currentUserCheck = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        //Remove the observers for this view
        firebaseManager.ref.removeObserver(withHandle: self.userNameHandle)
    }
}
