//
//  UserViewVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/7/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class UserViewVC: UIViewController {
    //Variable used to present the title, which is the username
    var uid: String!
    var mode: String!
    var userInformation: UserInfo!
    
    //References to objects in view controller
    @IBOutlet weak var FirstNameLabel: UILabel!
    @IBOutlet weak var LastNameLabel: UILabel!
    @IBOutlet weak var BioLabel: UILabel!
    @IBOutlet weak var FollowersCounter: UILabel!
    @IBOutlet weak var FollowingCounter: UILabel!
    
    let firebaseManager = FirebaseManager.shared
    
    //Handles for the removal of the observers
    var followingHandle: UInt = 0
    var followersHandle: UInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Fetch the selected user's information from firebase and store it into userInformation
        
        
        //Set up view
        setupView()
        
        //Add observer for modifing the Followers and Following Counters
        self.followingHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.userInformation.uid).child(FirebaseKeys.followingCount.rawValue).observe(.value, with: {(snapshot) in
            
            //Assign variable with the snapshot value
            let followingCounter = snapshot.value as? Int
            
            //Update button titles/view counters for following Counter
            self.FollowingCounter.text = "\(followingCounter!)"
            
        })
        
        //Observer used to observe when a user is added or delete from the followers lists of the current user
        self.followersHandle = self.firebaseManager.ref.child(FirebaseKeys.users.rawValue).child(self.userInformation.uid).child(FirebaseKeys.followersCount.rawValue).observe(.value, with: {(snapshot) in
            
            //Assign variable with the snapshot value
            let followersCounter = snapshot.value as? Int
            
            //Update button titles/view counters for follower's Counter
            self.FollowersCounter.text = "\(followersCounter!)"

        })
    }
    
    //Function that sets up the labels
    func setupView(){
        
        //Assign each label with the corresponding entry
        self.FirstNameLabel.text = self.userInformation.firstName
        self.LastNameLabel.text = self.userInformation.lastName
        self.BioLabel.text = self.userInformation.bio
        self.navigationItem.title = self.userInformation.username
        
        //Obtain the image of the user
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        //Remove the observers for this view
        self.firebaseManager.ref.removeObserver(withHandle: self.followingHandle)
        self.firebaseManager.ref.removeObserver(withHandle: self.followersHandle)
        
    }
}
