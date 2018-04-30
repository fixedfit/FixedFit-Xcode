//
//  RecoverEmailVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/30/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class RecoverEmailVC: UIViewController {

    //Variable to hold the current user's email address
    //Needs to be set from the class that is presenting this view
    var userEmail:String!
    
    @IBOutlet weak var UsersEmailLabel: UILabel!
    @IBOutlet weak var ButtonReference: UIButton!
    
    //Initializers
    init(email: String){
        super.init(nibName: "RecoverEmailVC", bundle:nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
        
        self.userEmail = email
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set EmailLabel properties
        let labelFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.UsersEmailLabel.adjustsFontSizeToFitWidth = true
        self.UsersEmailLabel.textColor = .fixedFitBlack
        self.UsersEmailLabel.font = labelFont
        self.UsersEmailLabel.text = self.userEmail
        
        //Set button properties
        let buttonFont = UIFont.systemFont(ofSize:18, weight: UIFont.Weight.semibold)
        self.ButtonReference.setTitle("Ok", for: .normal)
        self.ButtonReference.setTitleColor(.fixedFitBlue, for: .normal)
        self.ButtonReference.titleLabel?.font = buttonFont
    }

    @IBAction func ButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
