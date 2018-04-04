//
//  ReauthenticateVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 4/3/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

protocol ReauthenticationDelegate {
    func didPressDone(email: String, password: String)
}

class ReauthenticateVC: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    var delegate: ReauthenticationDelegate?

    init() {
        super.init(nibName: "ReauthenticateVC", bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressDone(_ sender: Any) {
        delegate?.didPressDone(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
    }
}
