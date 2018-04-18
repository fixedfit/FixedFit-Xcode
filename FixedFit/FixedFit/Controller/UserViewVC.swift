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
    var viewTitle: String!
    var mode: String!
    
    //References to objects in view controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = viewTitle
    }
}
