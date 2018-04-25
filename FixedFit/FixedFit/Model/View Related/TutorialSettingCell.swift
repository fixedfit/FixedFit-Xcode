//
//  TutorialSettingCell.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/25/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class TutorialSettingCell: UITableViewCell {

    static let identifier = "TutorialSettingCell"
    
    //Reference to the labels of the tutorials cells
    @IBOutlet weak var TutorialLabel: UILabel!
    
    func configure(tutorial: String){
        TutorialLabel.adjustsFontSizeToFitWidth = true
        TutorialLabel.text = tutorial
        
    }

}
