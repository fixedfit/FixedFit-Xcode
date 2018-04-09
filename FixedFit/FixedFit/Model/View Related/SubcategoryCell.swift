//
//  SubcategoryCell.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/19/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class SubcategoryCell: UITableViewCell {
    static let identifier = "subcategoryCell"

    @IBOutlet weak var subcategoryNameLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
