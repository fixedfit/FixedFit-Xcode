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
    
    //Variable that limits the number of spaces between messages
    static let messageSpacing = 3
    static let faqQandASpacing = 2
    
    //Reference to the text view
    @IBOutlet weak var MainTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MainTextView.isEditable = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if(mode == FirebaseSupportTitleAndMode.tutorial){
            self.viewTitle = self.viewTitle + " tutorial"

        } else if(mode == FirebaseSupportTitleAndMode.helpCenter){

        }
        
        
        self.navigationItem.title = viewTitle
    }
    
}
