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
 
    @IBAction func Go(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "UserFinder", bundle:nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserViewVC") as! UserViewVC
        
        //Initialize the title of the ViewController and mode if needed
        if(self.mode != nil){
            vc.mode = self.mode
        }
        vc.viewTitle = "Username"
        
        //Push View Controller onto Navigation Stack
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
