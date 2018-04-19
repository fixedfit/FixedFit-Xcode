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
    
    override func viewDidLoad() {
        
        //Fetch the selected user's information from firebase
        
        //Obtain the user name for the current selected user
        var viewTitle = "Username"
        super.viewDidLoad()
        self.navigationItem.title = viewTitle
        setupView()
    }
    
    func setupView(){
        
    }
}
