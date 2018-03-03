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

    //label for the user name and user bios
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var UserNameBios: UILabel!
    
    //References to the buttons followers and following for updating the text field
    @IBOutlet weak var Followers: UIButton!
    @IBOutlet weak var Following: UIButton!
    
    
    //MARK: Update profile page once view is loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.UserNameLabel.text = "Firebase"
        self.UserNameBios.text = "Bios"
    }
    @IBAction func tappedEditProfile(_ sender: UIButton) {
        
        //Move to the edit view controller
        performSegue(withIdentifier: "EditTransition", sender: <#T##Any?#>)
        
    }
    //Functions to the buttons involved in the profile section
    @IBAction func FollowersButton(_ sender: Any) {
    }
    @IBAction func FollowingButton(_ sender: UIButton) {
    }
    
    
    //MARK: When User is modifiying data in the firebase realtime database that impacts the profile page, it must update the profile page to reflect that change. Include fields like number of followers and number of following. along with there lists, etc.
    
    
    //MARK: place in settings button
    //@IBAction func tappedLogout(_ sender: Any) {
    //    firebaseManager.logout { _ in }
    //}
}
