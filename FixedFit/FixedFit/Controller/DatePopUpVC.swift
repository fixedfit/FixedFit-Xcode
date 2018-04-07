//
//  DatePopUpVC.swift
//  FixedFit
//
//  Created by Carlo De Los Reyes on 4/6/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class DatePopUpVC: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eventTextField: UITextField!
    @IBOutlet weak var outfitImageView: UIImageView!
    var dateString:String = "Date Label"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = dateString
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelDate_Touch(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
