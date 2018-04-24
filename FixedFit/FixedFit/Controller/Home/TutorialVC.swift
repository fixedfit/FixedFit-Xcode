//
//  TutorialVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/23/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class TutorialVC: UIViewController {

    //Initial variable for setting the title
    var viewTitle:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.viewTitle
        
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
