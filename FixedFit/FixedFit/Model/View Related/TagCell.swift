//
//  categoryCell.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class categoryCell: UICollectionViewCell {
    @IBOutlet weak var categoryCellLabel: UILabel!

    static let identifier = "categoryCell"
    
    override func awakeFromNib() {
        cornerRadius = 5
    }

}
