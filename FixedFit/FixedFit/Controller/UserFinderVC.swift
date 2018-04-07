//
//  UserFinderVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/3/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit
class UserFinderVC: UIViewController{
    
    //Initialize variables used to finding users from multiple sources
    var mode:String!
    var viewTitle:String!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = viewTitle
    }
 
    
}
