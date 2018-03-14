//
//  CategorySectionCell.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/3/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class CategorySectionCell: UITableViewCell {
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var selectedItemImageView: UIImageView!

    static let identifier = "categorySectionCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedItemImageView.clipsToBounds = true
        selectedItemImageView.layer.cornerRadius = 5
    }
}
