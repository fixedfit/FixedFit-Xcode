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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
