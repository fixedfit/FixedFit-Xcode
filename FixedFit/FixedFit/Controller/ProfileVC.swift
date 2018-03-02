//
//  ProfileVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 2/20/18.
//  Edited by Mario Buenrostro on 3/2/2018.
//
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    let firebaseManager = FirebaseManager.shared

    //UserNameLabel
    @IBOutlet weak var UserNameLabel: UILabel!
    
    //MARK: Update profile page once view is loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.UserNameLabel.text = "Firebase"
    }
    
    //MARK: When User is modifiying data in the firebase realtime database that impacts the profile page, it must update the profile page to reflect that change.
    

    @IBAction func tappedLogout(_ sender: Any) {
        firebaseManager.logout { _ in }
    }
}
