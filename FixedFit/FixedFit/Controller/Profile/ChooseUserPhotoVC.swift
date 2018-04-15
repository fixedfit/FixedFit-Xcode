//
//  ChooseUserPhotoVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/14/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit
protocol PhotoSourceDelegate{
    func didChooseOption(choice: String)
}
class ChooseUserPhotoVC: UIViewController {

    //References of button
    @IBOutlet weak var SelectView: UIView!
    
    //Initial Delegate
    var delegate: PhotoSourceDelegate?
    
    //Initial ButtonData
    
    //Initializers
    init(button: ButtonData){
        super.init(nibName: "ChooseUserPhotoVC", bundle: nil)
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

}
