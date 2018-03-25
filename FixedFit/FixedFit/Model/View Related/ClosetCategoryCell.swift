//
//  CategoryCategoryCell.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/3/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class ClosetCategoryCell: UITableViewCell {
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var selectedItemImageView: UIImageView!

    static let identifier = "closetCategoryCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedItemImageView.contentMode = .scaleAspectFill
        selectedItemImageView.clipsToBounds = true
        selectedItemImageView.layer.cornerRadius = 5
    }
}
