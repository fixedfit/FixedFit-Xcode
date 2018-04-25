//
//  CategorySettingCell.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/24/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class CategorySettingCell: UITableViewCell {
    
    static let identifier = "CategorySettingCell"
    
    @IBOutlet weak var Category: UILabel!
    
    func configure(category: String){
        
        //Scale the text to fit the label
        self.Category.adjustsFontSizeToFitWidth = true
        self.Category.text = category
    }
}
