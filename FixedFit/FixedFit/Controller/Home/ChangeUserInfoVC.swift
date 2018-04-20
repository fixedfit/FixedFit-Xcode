//
//  ChangeUserInfoVC.swift
//  FixedFit
//
//  Created by Mario Buenrostro on 4/9/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit
protocol UserInfoDelegate{
    func saveUserInfo(userInfo:String)
}
class ChangeUserInfoVC: UIViewController, UITextFieldDelegate {

    var delegate: UserInfoDelegate?
    var button: ButtonData!
    
    //references to object in certain classes
    @IBOutlet weak var ChangeInfoView: UIView!
    @IBOutlet weak var titleMessage: UILabel!
    @IBOutlet weak var presentChangingInfo: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    
    //Variable used to obtain the mode in which this VC will operate as efficient as it can
    var userInfoUpdateMode: String!
    
    init(buttonAction:ButtonData, changingInfoMode: String){
        super.init(nibName: "ChangeUserInfoVC", bundle:nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
        
        //Store the passed in information
        self.userInfoUpdateMode = changingInfoMode
        self.button = buttonAction
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Change the colors of the UIButtons and the fonts
        saveButton.setTitleColor(.fixedFitPurple, for: .normal)
        discardButton.setTitleColor(.fixedFitBlue, for: .normal)
        
        //Change the font of the text
        let buttonFont = UIFont.systemFont(ofSize:18, weight: UIFont.Weight.semibold)
        
        saveButton.titleLabel?.font = buttonFont
        discardButton.titleLabel?.font = buttonFont
        
        self.textField.delegate = self
        
        //Assign the fields of each label
        if(userInfoUpdateMode == SettingKeys.emailUpdate.rawValue){
            titleMessage.text = "Changing Email:\n"
            presentChangingInfo.text = "New Email:"
            textField.isSecureTextEntry = false
        } else if(userInfoUpdateMode == SettingKeys.passwordUpdate.rawValue){
            titleMessage.text = "Changing Password:\n"
            presentChangingInfo.text = "New Password:"
            textField.isSecureTextEntry = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func discardInfo(_ sender: UIButton) {
        self.dismiss(animated: true, completion: button?.action)
    }
    
    @IBAction func savedInfo(_ sender: UIButton) {
        delegate?.saveUserInfo(userInfo: self.textField.text!)
        self.dismiss(animated: true, completion: button?.action)
    }
    
    //Functions used to dismiss the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        super.view.endEditing
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
