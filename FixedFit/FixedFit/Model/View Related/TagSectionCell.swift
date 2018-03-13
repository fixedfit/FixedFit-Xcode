//
//  TagSectionCell.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/3/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class TagSectionCell: UITableViewCell {
    @IBOutlet weak var tagNameLabel: UILabel!
    @IBOutlet weak var selectedItemImageView: UIImageView!

    static let identifier = "tagSectionCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedItemImageView.clipsToBounds = true
        selectedItemImageView.layer.cornerRadius = 5
    }
}
