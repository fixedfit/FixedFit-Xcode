//
//  TagCell.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {
    @IBOutlet weak var tagCellLabel: UILabel!

    static let identifier = "tagCell"
    
    override func awakeFromNib() {
        cornerRadius = 5
    }

}
