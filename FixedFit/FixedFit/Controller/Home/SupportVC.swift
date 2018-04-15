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
    
    //Initial variable for setting the title
    var viewTitle:String!
    
    //Variable used to determine options on ViewController
    var supportMode:String!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = viewTitle
        
        //Determine support mode to display certain text
        if(viewTitle == FirebaseSupportVCTitleAndMode.helpCenter){
            supportMode = "FAQ"
        } else if(viewTitle == FirebaseSupportVCTitleAndMode.contactUs){
            supportMode = "Contacts"
        } else if(viewTitle == FirebaseSupportVCTitleAndMode.tutorial){
            supportMode = "Tutorials"
        }
        
    }
    
}
