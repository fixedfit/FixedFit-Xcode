//
//  AccountRecoveryVC.swift
//  FixedFit
//
//  Created by Mario Buenrostro on 4/25/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

protocol RecoverSelectionDelegate{
    func recoverSelection(recover: String, cancel: Bool)
}
class AccountRecoveryVC: UIViewController {

    //References to objects in the AccountRecoveryVC
    @IBOutlet weak var RecoverySelectionView: UIView!
    @IBOutlet weak var RecoverEmailButton: UIButton!
    @IBOutlet weak var RecoverPasswordButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var RecoveryLabel: UILabel!
    
    //Initial button data
    var button: ButtonData?
    
    //Initial delegate
    var delegate: RecoverSelectionDelegate!
    
    //Initialize title varible for users to see
    var titleMsg: String!
    
    //Initializers
    init(title: String, buttonData: ButtonData){
        super.init(nibName: "AccountRecoveryVC", bundle:nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
        
        //Assign the button data
        self.button = buttonData
        self.titleMsg = title
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Fix color titles and colors
        self.RecoverEmailButton.setTitle("Recover Email Address", for: .normal)
        self.RecoverPasswordButton.setTitle("Recover Password", for: .normal)
        self.CancelButton.setTitle("Cancel", for: .normal)
        
        self.RecoverEmailButton.setTitleColor(.fixedFitPurple, for: .normal)
        self.RecoverPasswordButton.setTitleColor(.fixedFitBlue, for: .normal)
        
        //Assign common font to the buttons
        let buttonFont = UIFont.systemFont(ofSize:18, weight: UIFont.Weight.semibold)
        
        self.RecoverEmailButton.titleLabel?.font = buttonFont
        self.RecoverPasswordButton.titleLabel?.font = buttonFont
        self.CancelButton.titleLabel?.font = buttonFont
        
        //Set label
        self.RecoveryLabel.sizeToFit()
        self.RecoveryLabel.text = self.titleMsg
    }
    
    //Actions by the buttons being pressed
    @IBAction func RecoverEmailTapped(_ sender: UIButton) {
        delegate?.recoverSelection(recover: RecoveryKeys.recoverEmail, cancel: false)
        self.dismiss(animated: true, completion: button?.action)
    }
    @IBAction func RecoverPasswordTapped(_ sender: UIButton) {
        delegate?.recoverSelection(recover: RecoveryKeys.recoverPassword, cancel: false)
        self.dismiss(animated: true, completion: button?.action)
    }
    @IBAction func CancelTapped(_ sender: UIButton) {
        delegate?.recoverSelection(recover: "", cancel: true)
        self.dismiss(animated: true, completion: button?.action)
    }
    
}
