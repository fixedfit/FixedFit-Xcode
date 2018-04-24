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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = viewTitle
        
    }
    
}
