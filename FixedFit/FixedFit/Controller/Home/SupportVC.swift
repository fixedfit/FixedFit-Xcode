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
    var mode:String!
    
    //Reference to the text view
    @IBOutlet weak var MainTextView: UITextView!
    @IBOutlet weak var TutorialChildView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MainTextView.isEditable = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if(mode == FirebaseSupportTitleAndMode.tutorial){
            self.viewTitle = self.viewTitle + " tutorial"
            self.TutorialChildView.isHidden = false
        } else if(mode == FirebaseSupportTitleAndMode.helpCenter){
            self.TutorialChildView.isHidden = true
        }
        
        
        self.navigationItem.title = viewTitle
    }
    
}
